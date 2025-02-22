//
//  Controller.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/15/25.
//

protocol BSFlowController {
    
    associatedtype TBook
        
    func addBook()
    func listAllBooks()
    func removeBook()
    func searchBooks()
    func clearAllBooks()
    
    func dbURL()
}
