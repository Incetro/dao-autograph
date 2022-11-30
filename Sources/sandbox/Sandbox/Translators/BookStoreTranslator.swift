//
//  BookStoreTranslator.swift
//  Sandbox
//
//  Generated automatically by dao-autograph
//  https://github.com/Incetro/dao-autograph
//
//  Copyright © 2020 Incetro Inc. All rights reserved.
//
// swiftlint:disable trailing_newline

import SDAO
import Monreau

// MARK: - BookStoreTranslator

final class BookStoreTranslator {

    // MARK: - Aliases

    typealias PlainModel = BookStorePlainObject
    typealias DatabaseModel = BookStoreModelObject

    /// BookStore storage
    private lazy var bookStoreStorage = RealmStorage<BookStoreModelObject>(configuration: self.configuration)

    /// RealmConfiguration instance
    private let configuration: RealmConfiguration

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - configuration: current realm db config
    init(configuration: RealmConfiguration) {
        self.configuration = configuration
    }
}

// MARK: - Translator

extension BookStoreTranslator: Translator {

    func translate(model: DatabaseModel) throws -> PlainModel {
        BookStorePlainObject(
            id: model.id,
            authors: try AuthorTranslator(configuration: configuration).translate(models: Array(model.authors)),
            books: try BookTranslator(configuration: configuration).translate(models: Array(model.books))
        )
    }

    func translate(plain: PlainModel) throws -> DatabaseModel {
        let model = try bookStoreStorage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
        try translate(from: plain, to: model)
        return model
    }

    func translate(from plain: PlainModel, to databaseModel: DatabaseModel) throws {
        if databaseModel.uniqueId.isEmpty {
            databaseModel.uniqueId = plain.uniqueId.rawValue
        }
        databaseModel.id = plain.id
        databaseModel.authors.removeAll()
        databaseModel.authors.append(objectsIn:
            try AuthorTranslator(configuration: configuration).translate(plains: plain.authors)
        )
        databaseModel.books.removeAll()
        databaseModel.books.append(objectsIn:
            try BookTranslator(configuration: configuration).translate(plains: plain.books)
        )
    }
}