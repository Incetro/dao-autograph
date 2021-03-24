//
//  DAOInputFoldersProvider.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Autograph

// MARK: - DAOInputFoldersProvider

public final class DAOInputFoldersProvider {

    required public init() {
    }
}

// MARK: - InputFoldersProvider

extension DAOInputFoldersProvider: InputFoldersProvider {

    public func inputFoldersList(fromParameters parameters: AutographExecutionParameters) throws -> [String] {
        var inputFolders: [String] = []
        guard let plainsFolder = parameters[.plains] else {
            throw DAOAutographError.noPlainsFolder
        }
        inputFolders.append(plainsFolder)
        if let enumsFolder = parameters[.enums] {
            inputFolders.append(enumsFolder)
        }
        return inputFolders
    }
}
