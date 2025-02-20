//
//  Service.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/14/25.
//

import Foundation

protocol BSService {
    
    associatedtype Item
    
    func addItem(_ item: Item) -> Result<Void, Error>
    func getItem(by id: UUID) -> Result<Item, Error>
    func getAllItems() -> Result<[Item], Error>
    func removeItem(by id: UUID) -> Result<Void, Error>
    func clearAllItems() -> Result<Void, Error>
    func searchItems(by predicate: (Item) -> Bool) -> Result<[Item], Error>
    func rawTextSearch(by rawText: String) -> Result<[Item], Error>
    
    func dbURL() -> URL
}
