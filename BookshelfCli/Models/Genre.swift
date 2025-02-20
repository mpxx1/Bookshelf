//
//  Genre.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/14/25.
//

enum Genre: String, Codable, CaseIterable, BSDebugable {
    case fiction
    case nonFiction = "non-fiction"
    case mystery
    case sciFi = "science fiction"
    case biography
}

extension BSDebugable where Self == Genre {
    func format() -> String {
        return self.rawValue
    }
}
