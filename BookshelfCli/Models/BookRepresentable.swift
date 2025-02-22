//
//  BookRepresentable.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/14/25.
//

import Foundation

protocol BookRepresentable: Codable, BSDebugable {
    var id: UUID { get }
    var title: String { get }
    var author: String { get }
    var year: UInt { get }
    var genre: Genre { get }
}
