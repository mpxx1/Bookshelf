//
//  BSDBRecord.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/15/25.
//

struct BSDBRecord<TData: Codable> : Codable {
    // associatedtype TData: Codable
    
    var type: String
    var data: TData
    
    init(type: Any.Type, data: TData) {
        self.type = String(describing: type)
        self.data = data
    }
}
