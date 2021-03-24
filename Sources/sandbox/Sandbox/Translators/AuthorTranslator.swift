//
//  AuthorTranslator.swift
//  Sandbox
//
//  Generated automatically by dao-autograph
//  https://github.com/Incetro/dao-autograph
//
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import SDAO
import Monreau

// MARK: - AuthorTranslator

final class AuthorTranslator {

    // MARK: - Aliases

    typealias PlainModel = AuthorPlainObject
    typealias DatabaseModel = AuthorModelObject

    /// Author storage
    private lazy var authorStorage = RealmStorage<AuthorModelObject>(configuration: self.configuration)

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

extension AuthorTranslator: Translator {

    func translate(model: DatabaseModel) throws -> PlainModel {
        AuthorPlainObject(
            id: model.id,
            name: model.name,
            age: model.age,
            genres: model.genres.compactMap(Genre.init)
        )
    }

    func translate(plain: PlainModel) throws -> DatabaseModel {
        let model = try authorStorage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
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
        databaseModel.genres.removeAll()
        databaseModel.genres.append(objectsIn: plain.genres.map(\.rawValue))
    }
}