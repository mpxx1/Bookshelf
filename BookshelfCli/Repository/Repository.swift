//
//  Repository.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/14/25.
//

import Foundation

protocol BSRepository {
    
    associatedtype Item
    
    func saveItem(_ item: Item) -> Result<Void, Error>
    func getItem(by id: UUID) -> Result<Item, Error>
    func getAllItems() -> Result<[Item], Error>
    func removeItem(by id: UUID) -> Result<Void, Error>
    func clearAllItems() -> Result<Void, Error>
    func getItemsContains(text: String) -> Result<[Item], Error>
    
    func dbURL() -> URL
}
