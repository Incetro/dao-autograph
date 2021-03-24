//
//  File.swift
//  
//
//  Created by incetro on 3/20/21.
//

import Autograph
import Foundation

// MARK: - DAOAutographExecutionParameters

public enum DAOAutographExecutionParameters: String {

    /// Enums folder
    case enums = "-enums"

    /// Plain objects folder
    case plains = "-plains"

    /// Model object folder
    case models = "-models"

    /// Translators folder
    case translators = "-translators"

    /// Current project name
    case projectName = "-project_name"
}

// MARK: - ExecutionParameters

public extension AutographExecutionParameters {

    subscript(_ parameter: DAOAutographExecutionParameters) -> String? {
        self[parameter.rawValue]
    }
}
