//
//  File.swift
//  
//
//  Created by incetro on 3/21/21.
//

import Autograph

// MARK: - DAOAutographApplication

public final class DAOAutographApplication: AutographApplication<TranslatorImplementationsComposer, DAOInputFoldersProvider> {

    // MARK: - AutographApplication

    override public func printHelp() {
        super.printHelp()
        print("""
        Accepted arguments:

        -translators <directory>
        Path to the folder, where generated translator files should be placed.
        If not set, current working directory is used by default.

        -plains <directory>
        Path to the folder, where model files to be processed are stored.
        If not set, current working directory is used by default.

        -models <directory>
        Path to the folder, where generated model files should be placed.
        If not set, current working directory is used by default.

        -enums <directory>
        Path to the folder, where enum files to be processed are stored.
        Some of the "PlainObjects" may contain enums which should be stored
        in their models classes as raw values. So we need to know these enums structure.
        If not set, current working directory is used by default.
        
        -translatorsAssembly <directory>
        Path to the folder, where generated translator files should be registered to DI container.
        If not set, current working directory is used by default.
        
        -daoAutographAliases <directory>
        The path to the folder where the aliases file should be placed.
        If not set, current working directory is used by default.
        
        -daoAssembly <directory>
        The path to the folder where the aliases should be registered to DI container.
        If not set, current working directory is used by default.
        """
        )
    }
}
