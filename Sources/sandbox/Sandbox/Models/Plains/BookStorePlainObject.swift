//
//  BookStorePlainObject.swift
//  Sandbox
//
//  Created by incetro on 3/21/21.
//

import SDAO

// MARK: - BookStorePlainObject

/// @realm
public struct BookStorePlainObject: Plain {

    public var uniqueId: UniqueID {
        UniqueID(value: id)
    }

    /// Store's unique identifier
    let id: Int

    /// All available authors in the store
    let authors: [AuthorPlainObject]

    /// All available books in the store
    let books: [BookPlainObject]
}
