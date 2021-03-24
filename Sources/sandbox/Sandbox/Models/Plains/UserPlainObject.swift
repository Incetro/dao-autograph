//
//  UserPlainObject.swift
//  Sandbox
//
//  Created by incetro on 3/13/21.
//

import SDAO

// MARK: - UserPlainObject

/// @realm
struct UserPlainObject: Plain {

    var uniqueId: UniqueID {
        .init(value: id)
    }

    /// User's identifier
    let id: Int

    /// User's name
    let name: String

    /// User's age
    let age: Int

    /// User's favorite books list
    let favoriteBooks: [BookPlainObject]

    /// User's favorite authors list
    let favoriteAuthors: [AuthorPlainObject]
}
