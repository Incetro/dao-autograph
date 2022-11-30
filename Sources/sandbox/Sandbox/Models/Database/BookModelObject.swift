//
//  BookModelObject.swift
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

// MARK: - BookModelObject

final class BookModelObject: RealmModel {

    // MARK: - Properties

    /// Books unique identifier
    @objc dynamic var id = 0

    /// Book's name
    @objc dynamic var name = ""

    /// Book's author
    @objc dynamic var author: AuthorModelObject?

    /// Book's genre
    @objc dynamic var genre: Genre?
}
