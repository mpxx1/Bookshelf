//
//  main.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/14/25.
//

import Foundation

let dbFileName = "books.db"
let flowController: any BSFlowController = BookshelfFlowController(
    service: BookshelfService(
        repo: BookshelfMacRepo(
            dbFileName: dbFileName
        )
    )
)

while true {
    print("\n📚 Menu:")
    print("1 - Add book")
    print("2 - Remove book")
    print("3 - Show book list")
    print("4 - Search book")
    print("5 - Remove all books")
    print("0 - Exit")
    print("Enter the action: ", terminator: "")

    switch readLine() {
    case "1":
        flowController.addBook()

    case "2":
        flowController.removeBook()

    case "3":
        flowController.listAllBooks()

    case "4":
        flowController.searchBooks()

    case "5":
        flowController.clearAllBooks()

    case "u":
        flowController.dbURL()

    case "0":
        print("Bye!")
        exit(0)

    default:
        continue
    }
}

//print("It compiles!")
//
//let dbFileName = "books.db"
//let service = BookshelfService(repo: BookshelfMacRepo(dbFileName: dbFileName))
//
//let _ = service.clearAllItems()
//
//let _ = service.addItem(Book(title: "Book 1", author: "Author 1", year: 1, genre: Genre.fiction))
//let baseComicBook = Book(title: "Book 2", author: "Author 2", year: 2, genre: Genre.fiction)
//let _ = service.addItem(ComicBook(decoratingBook: baseComicBook, issueNumber: 10, artist: "Artist 2"))
//let allResult = service.getAllItems()
//switch allResult {
//case .failure(let error):
//    print("Error: \(error)")
//
//case .success(let items):
//    for elem in items {
//        print(elem.format())
//    }
//
//}
//
//print("It works!")
