import Foundation

class PasswordFileChecker {
    private var content: String = ""
    private let delimiter = "\n"
    private var counter = 0

    func call(filePath: String) -> Int {
        let parser = FileReader(filePath)
        content = parser.call()
        let lines = content.components(separatedBy: delimiter).map({ row in
            RowParser(row).call()
        })

        for line in lines {
            do {
                let regex = try NSRegularExpression(pattern: String(line[0]))
                let countFrom = Int(line[1])
                let countTo = Int(line[2])
                let password = String(line[3])

                let results = regex.matches(in: password, range: NSRange(location: 0, length: password.utf16.count))
                if let countFrom = countFrom, let countTo = countTo, results.count >= countFrom && results.count <= countTo {
                    counter += 1
                }
            } catch { print(error) }
        }
        return counter
    }

    class FileReader {
        private let filePath: String
        private let homeDir = FileManager.default.homeDirectoryForCurrentUser
        private let fileURL: URL
        private let emptyStr = ""

        init(_ filePath: String) {
            self.filePath = filePath
            self.fileURL = homeDir.appendingPathComponent(filePath)
        }

        func call() -> String {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                preconditionFailure("file expected at \(fileURL.absoluteString) is missing")
            }

            do {
                return try String(contentsOf: fileURL, encoding: .utf8)
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            } catch { return emptyStr }
        }
    }

    class RowParser {
        private let regexStr = "\\A([a-zA-Z]{1})\\s(\\d)-(\\d):\\s(\\S+)"
        private let criterium = 1
        private let countFrom = 2
        private let countTo = 3
        private let password = 4
        private let row: String

        init(_ row: String) {
            self.row = row
        }

        func call() -> [Substring] {
            do {
                let regex = try NSRegularExpression(pattern: regexStr)
                let results = regex.matches(in: row, range: NSRange(location: 0, length: row.utf16.count))

                if let result = results.first {
                    return [
                        strFromRange(result.range(at: criterium)),
                        strFromRange(result.range(at: countFrom)),
                        strFromRange(result.range(at: countTo)),
                        strFromRange(result.range(at: password))
                    ]
                }
            } catch { print(error) }
            return []
        }

        private func strFromRange(_ nsrange: NSRange) -> Substring {
            guard let range = Range(nsrange, in: row) else { return "" }

            return row[range]
        }
    }
}

print(
    PasswordFileChecker().call(filePath: "Project/input.txt")
)
