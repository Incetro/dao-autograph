//
//  BookTranslator.swift
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

// MARK: - BookTranslator

final class BookTranslator {

    // MARK: - Aliases

    typealias PlainModel = BookPlainObject
    typealias DatabaseModel = BookModelObject

    /// Book storage
    private lazy var bookStorage = RealmStorage<BookModelObject>(configuration: self.configuration)

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

extension BookTranslator: Translator {

    func translate(model: DatabaseModel) throws -> PlainModel {
        guard let author = model.author else {
            throw NSError(
                domain: "com.incetro.author-translator",
                code: 1000,
                userInfo: [
                    NSLocalizedDescriptionKey: "Cannot find AuthorModelObject instance for BookPlainObject with id: '\(model.uniqueId)'"
                ]
            )
        }
        guard let genre = model.genre else {
            throw NSError(
                domain: "com.incetro.genre-translator",
                code: 1000,
                userInfo: [
                    NSLocalizedDescriptionKey: "Cannot find GenreModelObject instance for BookPlainObject with id: '\(model.uniqueId)'"
                ]
            )
        }
        return BookPlainObject(
            id: model.id,
            name: model.name,
            author: try AuthorTranslator(configuration: configuration).translate(model: author),
            genre: try GenreTranslator(configuration: configuration).translate(model: genre)
        )
    }

    func translate(plain: PlainModel) throws -> DatabaseModel {
        let model = try bookStorage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
        try translate(from: plain, to: model)
        return model
    }

    func translate(from plain: PlainModel, to databaseModel: DatabaseModel) throws {
        if databaseModel.uniqueId.isEmpty {
            databaseModel.uniqueId = plain.uniqueId.rawValue
        }
        databaseModel.id = plain.id
        databaseModel.name = plain.name
        databaseModel.author = try AuthorTranslator(configuration: configuration).translate(plain: plain.author)
        databaseModel.genre = try GenreTranslator(configuration: configuration).translate(plain: plain.genre)
    }
}