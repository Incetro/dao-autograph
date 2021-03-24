//
//  BookPlainObject.swift
//  Sandbox
//
//  Created by incetro on 3/21/21.
//

import SDAO

// MARK: - BookPlainObject

/// @realm
struct BookPlainObject: Plain {

    var uniqueId: UniqueID {
        .init(value: id)
    }

    /// Books unique identifier
    let id: Int

    /// Book's name
    let name: String

    /// Book's author
    let author: AuthorPlainObject

    /// Book's genre
    let genre: Genre
}
