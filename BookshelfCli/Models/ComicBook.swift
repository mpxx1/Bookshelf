//
//  ComicBook.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/15/25.
//

import Foundation

struct ComicBook: BookRepresentable {
    let id: UUID
    var title: String
    var author: String
    var year: UInt
    var genre: Genre
    var issueNumber: UInt
    var artist: String
    
    init(decoratingBook: BookRepresentable, issueNumber: UInt, artist: String) {
        self.id = decoratingBook.id
        self.title = decoratingBook.title
        self.author = decoratingBook.author
        self.year = decoratingBook.year
        self.genre = decoratingBook.genre
        self.issueNumber = issueNumber
        self.artist = artist
    }
}

extension BSDebugable where Self == ComicBook {
    func format() -> String {
        """
        ComicBook {
            id: \(self.id),
            title: \(self.title),
            author: \(self.author),
            year: \(self.year),
            genre: \(self.genre),
            issueNumber: \(self.issueNumber),
            artist: \(self.artist),
        },\n
        """
    }
}
