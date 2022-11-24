//
//  DAOAutographError.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - DAOAutographError

public enum DAOAutographError {

    // MARK: - Cases

    /// You haven't specified a path to plain objects
    case noModelsFolder

    /// You haven't specified a path to model objects
    case noPlainsFolder

    /// You haven't specified a path to your app enums
    case noEnumsFolder

    /// You haven't specified a path to your app translators
    case noTranslatorsFolder

    /// You haven't specified your project name
    case noProjectName

    /// We cannot translate the given type to other db type
    case unknownType(String, propertyName: String)
}

// MARK: - LocalizedError

extension DAOAutographError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .noModelsFolder:
            return "You haven't specified a path to plain objects"
        case .noPlainsFolder:
            return "You haven't specified a path to model objects"
        case .noEnumsFolder:
            return "You haven't specified a path to your app enums"
        case .noTranslatorsFolder:
            return "You haven't specified a path to your app translators"
        case .noProjectName:
            return "You haven't specified your project name"
        case let .unknownType(type, propertyName: propertyName):
            return "We cannot translate the given type \(type) to other db type for property \(propertyName)"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension DAOAutographError: CustomDebugStringConvertible {

    public var debugDescription: String {
        errorDescription ?? ""
    }
}
