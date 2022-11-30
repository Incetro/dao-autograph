//
//  BookStoreModelObject.swift
//  Sandbox
//
//  Generated automatically by dao-autograph
//  https://github.com/Incetro/dao-autograph
//
//  Copyright © 2020 Incetro Inc. All rights reserved.
//
// swiftlint:disable trailing_newline

import SDAO
import RealmSwift

// MARK: - BookStoreModelObject

final class BookStoreModelObject: RealmModel {

    // MARK: - Properties

    /// Store's unique identifier
    @objc dynamic var id = 0

    /// All available authors in the store
    let authors = List<AuthorModelObject>()

    /// All available books in the store
    let books = List<BookModelObject>()
}
