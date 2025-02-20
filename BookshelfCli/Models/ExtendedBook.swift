//
//  ExtendedBook.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/20/25.
//

import Foundation

struct ExtendedBook: BookRepresentable, Codable {
    let id: UUID
    let title: String
    let author: String
    let year: UInt
    let genre: Genre
    let additionalFields: [AdditionalField]
    
    init(decoratingBook: BookRepresentable, additionalFields: [AdditionalField]) {
        self.id = decoratingBook.id
        self.title = decoratingBook.title
        self.author = decoratingBook.author
        self.year = decoratingBook.year
        self.genre = decoratingBook.genre
        self.additionalFields = additionalFields
    }
}

struct AdditionalField: Codable {
    enum FieldType: String, Codable {
        case string
        case int
        case double
        case bool
        case date
    }
    
    let name: String
    let type: FieldType
    let value: Value
    
    enum Value {
        case string(String)
        case int(Int)
        case double(Double)
        case bool(Bool)
        case date(Date)
    }
}

extension AdditionalField.Value: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let dateValue = try? container.decode(Date.self){
            self = .date(dateValue)
        } else {
            throw BSError.CodableError(
                "Can not decode data"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        do {
            switch self {
            case .string(let value):
                try container.encode(value)
            case .int(let value):
                try container.encode(value)
            case .double(let value):
                try container.encode(value)
            case .bool(let value):
                try container.encode(value)
            case .date(let value):
                try container.encode(value)
            }
        } catch {
            throw BSError.CodableError("Can not encode data")
        }
    }
}

extension BSDebugable where Self == ExtendedBook {
    func format() -> String {
        let base = """
        ExtendedBook {
            id: \(self.id),
            title: \(self.title),
            author: \(self.author),
            year: \(self.year),
            genre: \(self.genre),\n
        """
        
        var mid = ""
        for field in self.additionalFields {
            mid += "\t\(field.name): \(field.value),\n"
        }
        let end = "},\n"
        
        return base + mid + end
    }
}
