//
//  BookshelfService.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/14/25.
//

import Foundation
    
struct BookshelfService<TRepo: BSRepository> : BSService where TRepo.Item == BookRepresentable {
        
    typealias Item = TRepo.Item
    
    let repo: TRepo

    init(repo: TRepo) {
        self.repo = repo
    }

    func addItem(_ item: Item) -> Result<Void, Error> {
        return repo.saveItem(item)
    }
    
    func getItem(by id: UUID) -> Result<Item, Error> {
        repo.getItem(by: id)
    }
    
    func getAllItems() -> Result<[Item], Error> {
        repo.getAllItems()
    }
    
    func removeItem(by id: UUID) -> Result<Void, Error> {
        repo.removeItem(by: id)
    }
    
    func clearAllItems() -> Result<Void, Error> {
        repo.clearAllItems()
    }
    
    func searchItems(by predicate: (Item) -> Bool) -> Result<[Item], Error> {
        switch repo.getAllItems() {
        case .failure(let error):
            return .failure(error)
        case .success(let items):
            let filteredItems = items.filter(predicate)
            return .success(filteredItems)
        }
    }

    func rawTextSearch(by rawText: String) -> Result<[Item], Error> {
        return repo.getItemsContains(text: rawText)
    }
    
    func dbURL() -> URL {
        return repo.dbURL()
    }
}
