//
//  UserTranslator.swift
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

// MARK: - UserTranslator

final class UserTranslator {

    // MARK: - Aliases

    typealias PlainModel = UserPlainObject
    typealias DatabaseModel = UserModelObject

    /// User storage
    private lazy var userStorage = RealmStorage<UserModelObject>(configuration: self.configuration)

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

extension UserTranslator: Translator {

    func translate(model: DatabaseModel) throws -> PlainModel {
        UserPlainObject(
            id: model.id,
            name: model.name,
            age: model.age,
            favoriteBooks: try BookTranslator(configuration: configuration).translate(models: Array(model.favoriteBooks)),
            favoriteAuthors: try AuthorTranslator(configuration: configuration).translate(models: Array(model.favoriteAuthors))
        )
    }

    func translate(plain: PlainModel) throws -> DatabaseModel {
        let model = try userStorage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
        try translate(from: plain, to: model)
        return model
    }

    func translate(from plain: PlainModel, to databaseModel: DatabaseModel) throws {
        if databaseModel.uniqueId.isEmpty {
            databaseModel.uniqueId = plain.uniqueId.rawValue
        }
        databaseModel.id = plain.id
        databaseModel.name = plain.name
        databaseModel.age = plain.age
        databaseModel.favoriteBooks.removeAll()
        databaseModel.favoriteBooks.append(objectsIn:
            try BookTranslator(configuration: configuration).translate(plains: plain.favoriteBooks)
        )
        databaseModel.favoriteAuthors.removeAll()
        databaseModel.favoriteAuthors.append(objectsIn:
            try AuthorTranslator(configuration: configuration).translate(plains: plain.favoriteAuthors)
        )
    }
}