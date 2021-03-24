//
//  UserModelObject.swift
//  Sandbox
//
//  Generated automatically by dao-autograph
//  https://github.com/Incetro/dao-autograph
//
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import SDAO
import RealmSwift

// MARK: - UserModelObject

final class UserModelObject: RealmModel {

    // MARK: - Properties

    /// User's identifier
    @objc dynamic var id = 0

    /// User's name
    @objc dynamic var name = ""

    /// User's age
    @objc dynamic var age = 0

    /// User's favorite books list
    let favoriteBooks = List<BookModelObject>()

    /// User's favorite authors list
    let favoriteAuthors = List<AuthorModelObject>()
}
