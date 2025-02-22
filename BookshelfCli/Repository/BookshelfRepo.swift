//
//  BookshelfRepo.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/14/25.
//

import Foundation

#if os(macOS)
final class BookshelfMacRepo : BSRepository {
    
    typealias Item = BookRepresentable
    
    private let dbFileName: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    private var dbFileURL: URL {
        let dir = FileManager.default.currentDirectoryPath
        return URL(fileURLWithPath: dir).appendingPathComponent(dbFileName)
    }
    
    init(dbFileName: String) {
        self.dbFileName = dbFileName
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }
    
    func saveItem(_ item: Item) -> Result<Void, Error> {
        let itemType = Mirror(reflecting: item).subjectType
        let jsonStringResult = encodeItem(itemType: itemType, data: item)
        switch jsonStringResult {
        case .success(let content):
            return appendToDbFile(content: content)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getItem(by id: UUID) -> Result<Item, Error> {
        switch readFileLines() {
        case .failure(let error):
            return .failure(error)
        case .success(let lines):
            for line in lines {
                if line.hasPrefix("DROP") { continue }
                
                let decodedResult = decodeItem(from: line)
                switch decodedResult {
                case .failure:
                    continue
                case .success(let item):
                    if item.id == id {
                        return .success(item)
                    }
                }
            }
            return .failure(BSError.DbError("Book with ID \(id) not found"))
        }
    }

    func removeItem(by id: UUID) -> Result<Void, Error> {
        return appendToDbFile(content: "DROP \(id.uuidString)")
    }
    
    func clearAllItems() -> Result<Void, Error> {
        return deleteFile(at: dbFileURL)
    }
    
    func getAllItems() -> Result<[Item], Error> {
        switch readFileLines() {
        case .failure(let error):
            return .failure(error)
        case .success(let lines):
            var items: [Item] = []
            var deletedIDs: Set<UUID> = []
            
            for line in lines {
                if line.hasPrefix("DROP") {
                    let idString = line.replacingOccurrences(of: "DROP ", with: "")
                    if let id = UUID(uuidString: idString) {
                        deletedIDs.insert(id)
                    }
                } else {
                    let decodedResult = decodeItem(from: line)
                    switch decodedResult {
                    case .failure:
                        continue
                    case .success(let item):
                        items.append(item)
                    }
                }
            }

            for identifier in deletedIDs {
                items.removeAll { $0.id == identifier }
            }

            return .success(items)
        }
    }
    
    func getItemsContains(text: String) -> Result<[Item], Error> {
        switch readFileLines() {
        case .failure(let error):
            return .failure(error)
        case .success(let lines):
            var items: [Item] = []
            var deletedIDs: Set<UUID> = []
            
            for line in lines {
                if line.hasPrefix("DROP") {
                    let idString = line.replacingOccurrences(of: "DROP ", with: "")
                    if let id = UUID(uuidString: idString) {
                        deletedIDs.insert(id)
                    }
                } else {
                    if text.isEmpty || !line.lowercased().contains(text.lowercased()) {
                        continue
                    }
                    
                    let decodedResult = decodeItem(from: line)
                    switch decodedResult {
                    case .failure:
                        continue
                    case .success(let item):
                        if !item.id.uuidString.contains(text) {
                            items.append(item)
                        }
                    }
                }
            }
            
            for identifier in deletedIDs {
                items.removeAll { $0.id == identifier }
            }
            
            return .success(items)
        }
    }
    
    func dbURL() -> URL {
        return dbFileURL
    }

    // in perfect world it generates with macros
    private func encodeItem(itemType: Any.Type, data: Item) -> Result<String, Error> {
        if let book = data as? Book {
            do {
                let dbRecord = BSDBRecord<Book>(type: itemType, data: book)
                let jsonData = try encoder.encode(dbRecord)
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    return .failure(BSError.DataProccessingError("Failed to convert data to string"))
                }
                return .success(jsonString)
            } catch {
                return .failure(BSError.DataProccessingError("Failed to encode book: \(error.localizedDescription)"))
            }
        } else if let comicBook = data as? ComicBook {
            do {
                let dbRecord = BSDBRecord<ComicBook>(type: itemType, data: comicBook)
                let jsonData = try encoder.encode(dbRecord)
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    return .failure(BSError.DataProccessingError("Failed to convert data to string"))
                }
                return .success(jsonString)
            } catch {
                return .failure(BSError.DataProccessingError("Failed to encode comic book: \(error.localizedDescription)"))
            }
        } else if let book = data as? ExtendedBook {
            do {
                let dbRecord = BSDBRecord<ExtendedBook>(type: itemType, data: book)
                let jsonData = try encoder.encode(dbRecord)
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    return .failure(BSError.DataProccessingError("Failed to convert data to string"))
                }
                return .success(jsonString)
            } catch {
                return .failure(BSError.DataProccessingError("Failed to encode extended book: \(error.localizedDescription)"))
            }
        } else {
            return .failure(BSError.DataProccessingError("Unsupported item type"))
        }
    }

    
    // in perfect world it generates with macros
    private func decodeItem(from jsonString: String) -> Result<Item, Error> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(BSError.DataProccessingError("Can not convert string to json"))
        }

        struct TypeWrapper: Codable {
            let type: String
        }

        do {
            let wrapper = try decoder.decode(TypeWrapper.self, from: data)
            switch wrapper.type {
            case "Book":
                let record = try decoder.decode(BSDBRecord<Book>.self, from: data)
                return .success(record.data)
            case "ComicBook":
                let record = try decoder.decode(BSDBRecord<ComicBook>.self, from: data)
                return .success(record.data)
            case "ExtendedBook":
                let record = try decoder.decode(BSDBRecord<ExtendedBook>.self, from: data)
                return .success(record.data)
            default:
                return .failure(BSError.DataProccessingError("Unsupported type: \(wrapper.type)"))
            }
        } catch {
            return .failure(BSError.DataProccessingError("Failed to decode item: \(error.localizedDescription)"))
        }
    }
    
    private func deleteFile(at url: URL) -> Result<Void, Error> {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
                return .success(())
            } else {
                return .failure(BSError.DbError("File not found"))
            }
        } catch {
            return .failure(BSError.DbError("Error deleting file: \(error.localizedDescription)"))
        }
    }
    
    private func readFileLines() -> Result<[String], Error> {
        do {
            let lines = try String(contentsOf: dbFileURL, encoding: .utf8)
                .components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
            return .success(lines)
        } catch {
            return .failure(BSError.DbError("Error reading file: \(error.localizedDescription)"))
        }
    }
    
    private func appendToDbFile(content: String) -> Result<Void, Error> {
        let contentWithNewline = content + "\n"
        guard let data = contentWithNewline.data(using: .utf8) else {
            return .failure(BSError.DataProccessingError("Failed to convert string to data"))
        }
        
        do {
            if FileManager.default.fileExists(atPath: dbFileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: dbFileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try contentWithNewline.write(to: dbFileURL, atomically: true, encoding: .utf8)
            }
            return .success(())
        } catch {
            return .failure(BSError.DbError("Writing to file error: \(error.localizedDescription)"))
        }
    }
}
#elseif os(iOS)
// unimplemented (better to use SwiftStorage)
#endif
