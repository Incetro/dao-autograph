//
//  AuthorModelObject.swift
//  Sandbox
//
//  Generated automatically by dao-autograph
//  https://github.com/Incetro/dao-autograph
//
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import SDAO
import RealmSwift

// MARK: - AuthorModelObject

final class AuthorModelObject: RealmModel {

    // MARK: - Properties

    /// User's identifier
    @objc dynamic var id = 0

    /// User's name
    @objc dynamic var name = ""

    /// User's age
    @objc dynamic var age = 0

    /// Author's preferrable genres
    let genres = List<String>()
}
