//
//  BookshelfController.swift
//  BookshelfCli
//
//  Created by Makar A. Pestrikov on 2/15/25.
//


import Foundation

struct BookshelfFlowController<TService: BSService> : BSFlowController where TService.Item == BookRepresentable {
    
    typealias TBook = TService.Item
    
    let service: TService
    
    init(service: TService) {
        self.service = service
    }
    
    func addBook() {
        print("Enter book title: ", terminator: "")
        let title = readLine() ?? ""
        
        print("Enter author: ", terminator: "")
        let author = readLine() ?? ""
        
        print("Enter publication year: ", terminator: "")
        guard let yearString = readLine(), let year = UInt(yearString), year > 0 else {
            print("Year must be a positive integer")
            return
        }
        
        print("Enter genre: ", terminator: "")
        let genreString = readLine() ?? ""
        guard let genre = Genre(rawValue: genreString) else {
            print("Genre must be one of: \(Genre.allCases.map(\.rawValue).joined(separator: ",\n"))")
            return
        }
        
        let baseBook = Book(title: title, author: author, year: year, genre: genre)
        var book: BookRepresentable = baseBook
        
        print("Do you want to customize book? [Y/n]: ", terminator: "")
        guard let additionalFieldsAnswer = readLine(),
              ["y", "Y"].contains(additionalFieldsAnswer) ||
                ["n", "N"].contains(additionalFieldsAnswer) else {
            
            print("Invalid input")
            return
        }
        
        if additionalFieldsAnswer == "Y" || additionalFieldsAnswer == "y" {
            print("The type of book is ...")
            print("1) Comic Book")
            print("2) Book with additional fields")
            print("Enter the number of type: ", terminator: "")
            switch readLine() {
            case "1":
                let bookResult = createComicBook(from: book)
                switch bookResult {
                case .success(let bookOk):
                    book = bookOk
                case .failure(let error):
                    print("Error creating comic book: \(error)")
                    return
                }
            case "2":
                var additionalFields: [AdditionalField] = []
                
                print("Write name:type:value or done to finish\n")
                while let input = readLine(), input.lowercased() != "done" {
                    let components = input.split(separator: ":")
                    if components.count != 3 {
                        print("Invalid input format. Expected name:type:value.")
                        continue
                    }
                    let name = String(components[0])
                    let typeString = String(components[1])
                    let valueString = String(components[2])
                    
                    guard let fieldType = AdditionalField.FieldType(rawValue: typeString.lowercased()) else {
                        print("Invalid field type. Valid types are: string, int, double, bool, date.")
                        continue
                    }
                    
                    switch fieldType {
                    case .string:
                        additionalFields.append(AdditionalField(name: name, type: fieldType, value: .string(valueString)))
                    case .int:
                        if let intValue = Int(valueString) {
                            additionalFields.append(AdditionalField(name: name, type: fieldType, value: .int(intValue)))
                        } else {
                            print("Invalid value for int")
                        }
                    case .double:
                        if let doubleValue = Double(valueString) {
                            additionalFields.append(AdditionalField(name: name, type: fieldType, value: .double(doubleValue)))
                        } else {
                            print("Invalid value for double")
                        }
                    case .bool:
                        if let boolValue = Bool(valueString) {
                            additionalFields.append(AdditionalField(name: name, type: fieldType, value: .bool(boolValue)))
                        } else {
                            print("Invalid value for bool")
                        }
                    case .date:
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy"
                        if let dateValue = dateFormatter.date(from: valueString) {
                            additionalFields.append(AdditionalField(name: name, type: fieldType, value: .date(dateValue)))
                        } else {
                            print("Invalid value for date, expected format: dd.MM.yyyy")
                        }
                    }
                }
                
                let extendedBook = ExtendedBook(decoratingBook: baseBook, additionalFields: additionalFields)
                book = extendedBook
            default:
                print("No such type")
                return
            }
        }
        
        switch service.addItem(
            book
        ) {
        case .success(()):
            print("Book added successfully")
            return
        case .failure(let error):
            print("Error adding book: \(error)")
            return
        }
    }
    
    func listAllBooks() {
        switch service.getAllItems() {
        case .failure(let error):
            print("Error getting books: \(error)")
            return
        case .success(let books):
            let formattedBooks = books.map { $0.format() }
            print(formattedBooks.joined(separator: ""))
        }
        
    }
    
    func removeBook() {
        print("Enter the ID of the book to remove: ", terminator: "")
        guard let idString = readLine(), let id = UUID(uuidString: idString) else {
            print("Invalid ID format. Please enter a valid UUID string.")
            return
        }
        
        switch service.removeItem(by: id) {
        case .failure(let error):
            print("Error removing book: \(error)")
        case .success:
            print("Book removed successfully.")
        }
    }
    
    func searchBooks() {
        print("Select option of search:")
        print("1) By title")
        print("2) By author")
        print("3) By publication year")
        print("4) By raw text")
        var items: [BookRepresentable] = []
        
        switch readLine() {
        case "1":
            print("Enter book title: ")
            let title = readLine() ?? ""
            let searchResult = service.searchItems(by: { $0.title.lowercased().contains(title.lowercased()) })
            switch searchResult {
            case .failure(let error):
                print("Error searching books: \(error)")
            case .success(let res):
                items.append(contentsOf: res)
            }
        case "2":
            print("Enter book author: ")
            let author = readLine() ?? ""
            let searchResult = service.searchItems(by: { $0.author.lowercased().contains(author.lowercased()) })
            switch searchResult {
            case .failure(let error):
                print("Error searching books: \(error)")
            case .success(let res):
                items.append(contentsOf: res)
            }
        case "3":
            print("Enter book publication year: ")
            let yearString = readLine() ?? ""
            guard let year = UInt(yearString) else {
                print("Invalid year format. Please enter a valid integer.")
                return
            }
            let searchResult = service.searchItems(by: { $0.year == year })
            switch searchResult {
            case .failure(let error):
                print("Error searching books: \(error)")
            case .success(let res):
                items.append(contentsOf: res)
            }
        case "4":
            print("Enter text to search in book description: ")
            let textToSearch = readLine() ?? ""
            let searchResult = service.rawTextSearch(by: textToSearch)
            switch searchResult {
            case .failure(let error):
                print("Error searching books: \(error)")
            case .success(let res):
                items.append(contentsOf: res)
            }
        default:
            print("Incorrect option")
            return
        }
        
        for item in items {
            print(item.format())
        }
    }
    
    func clearAllBooks() {
        switch service.clearAllItems() {
        case .failure(let error):
            print("Error clearing books: \(error)")
        case .success:
            print("All books cleared.")
        }
    }
    
    func dbURL() {
        print("Database URL: \(service.dbURL())")
    }
    
    private func createComicBook(from baseBook: BookRepresentable) -> Result<ComicBook, Error> {
        print("Enter issue number: ", terminator: "")
        guard let issueString = readLine(), let issueNumber = UInt(issueString) else {
            return .failure(BSError.ParseError("Invalid issue number"))
        }
        
        print("Enter artist name: ", terminator: "")
        let artist = readLine() ?? "Unknown"
        
        return .success(ComicBook(decoratingBook: baseBook, issueNumber: issueNumber, artist: artist))
    }
}
