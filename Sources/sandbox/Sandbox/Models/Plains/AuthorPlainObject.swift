//
//  AuthorPlainObject.swift
//  Sandbox
//
//  Created by incetro on 3/21/21.
//

import SDAO

// MARK: - AuthorPlainObject

/// @realm
public struct AuthorPlainObject: Plain {

    public var uniqueId: UniqueID {
        .init(value: id)
    }

    /// User's identifier
    let id: Int

    /// User's name
    let name: String

    /// User's age
    let age: Int

    /// Author's preferrable genres
    let genres: [Genre]
}
