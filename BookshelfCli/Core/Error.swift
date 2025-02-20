//
//  BookshelfError.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/14/25.
//

enum BSError: Error {
    case DbError(String)
    case DataProccessingError(String)
    case IncorrectInput(String)
    case ParseError(String)
    case CodableError(String)
}
