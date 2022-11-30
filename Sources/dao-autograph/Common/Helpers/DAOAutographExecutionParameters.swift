//
//  DAOAutographExecutionParameters.swift
//  
//
//  Created by incetro on 3/20/21.
//

import Autograph
import Foundation

// MARK: - DAOAutographExecutionParameters

public enum DAOAutographExecutionParameters: String {

    // MARK: - Case

    /// Enums folder
    case enums = "-enums"

    /// Plain objects folder
    case plains = "-plains"

    /// Model object folder
    case models = "-models"

    /// Translators folder
    case translators = "-translators"
    
    /// Translators assembly folder
    case translatorsAssembly = "-translators_assembly"
    
    /// DAO assembly folder
    case daoAssembly = "-dao_assembly"
    
    /// DAO autograph aliases folder
    case daoAutographAliases = "-dao_aliases"
    
    /// DAO autograph asemblies folder (generate all assemblies)
    case daoAssembliesPath = "-dao_assemblies_path"

    /// Current project name
    case projectName = "-project_name"

    /// Generated objects and properties accessibility
    case accessibility = "-accessibility"
}

// MARK: - ExecutionParameters

public extension AutographExecutionParameters {

    subscript(_ parameter: DAOAutographExecutionParameters) -> String? {
        self[parameter.rawValue]
    }
}
