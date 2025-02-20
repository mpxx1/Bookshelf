//
//  Book.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/13/25.
//

import Foundation

struct Book: BookRepresentable {
    let id: UUID
    let title: String
    let author: String
    let year: UInt
    let genre: Genre
    
    init(title: String, author: String, year: UInt, genre: Genre) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.year = year
        self.genre = genre
    }
}

extension BSDebugable where Self == Book {
    func format() -> String {
        """
        Book {
            id: \(self.id),
            title: \(self.title),
            author: \(self.author),
            year: \(self.year),
            genre: \(self.genre),
        },\n
        """
    }
}

