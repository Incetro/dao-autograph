//
//  DAOAutographAliasesImplemetationComposer.swift
//  dao-autograph
//
//
//  Created by Alexander Lezya on 22.11.2022.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - DAOAutographAliasesImplemetationComposer

public final class DAOAutographAliasesImplemetationComposer {

    // MARK: - Initializers

    required public init() {
    }

    // MARK: - Private
    
    /// Composes DAO autograph aliases for the given specifications
    /// - Parameters:
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: DAO autograph aliases string value
    private func composeDAOAutographAliases(specifications: Specifications) -> String {
        let targetStructures = specifications
            .structures
            .filter { $0.name.isPlainObjectName }
            .filter { $0.annotations.contains(annotationName: "realm") }
        let targetClasses = specifications
            .classes
            .filter { $0.name.isPlainObjectName }
            .filter { $0.annotations.contains(annotationName: "realm") }
        let structuresDAOAutographAliases = targetStructures.map {
                """
                /// DAO alias for \($0.name) entity
                typealias \($0.name.extractedPlainObjectName)DAO = DAO<RealmStorage<\($0.name.extractedPlainObjectName)ModelObject>, \($0.name.extractedPlainObjectName)Translator>
                """
        }
        let classesDAOAutographAliases = targetClasses.map {
                """
                /// DAO alias for \($0.name) entity
                typealias \($0.name.extractedPlainObjectName)DAO = DAO<RealmStorage<\($0.name.extractedPlainObjectName)ModelObject>, \($0.name.extractedPlainObjectName)Translator>
                """
        }
        return (structuresDAOAutographAliases + classesDAOAutographAliases).joined(separator: "\n\n")
    }

    /// Composes DAO autograph aliases implementation for the given specifications
    /// - Parameters:
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    /// - Throws: generating errors
    /// - Returns: necessary DAO autograph aliases implementation
    private func composeDAOAutographAliases(
        specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> AutographImplementation? {
        guard let daoAutographAliasesFolder = parameters[.daoAutographAliases] ?? parameters[.daoAssembliesPath] else {
            return nil
        }
        let daoAutographAliasesStr = composeDAOAutographAliases(specifications: specifications)
        let code = """
        // MARK: - Aliases

        \(daoAutographAliasesStr)
        """
        guard let projectName = parameters[.projectName] else {
            throw DAOAutographError.noProjectName
        }
        let header = headerComment(
            filename: "DAOAutographAliases",
            projectName: projectName,
            imports: ["SDAO", "Monreau", "Foundation"]
        )
        let sourceCode = header + "\n" + code
        return AutographImplementation(
            filePath: "\(daoAutographAliasesFolder)/DAOAutographAliases.swift",
            sourceCode: sourceCode
        )
    }
}

// MARK: - ImplementationComposer

extension DAOAutographAliasesImplemetationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        let daoAutographAliasesImplementation = try composeDAOAutographAliases(
            specifications: specifications,
            parameters: parameters
        )
        guard let daoAutographAliasesImplementation = daoAutographAliasesImplementation else {
            return []
        }
        return [daoAutographAliasesImplementation]
    }
}
