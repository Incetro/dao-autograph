//
//  TranslatorsAssembleyImplementationComposer.swift
//  dao-autograph
//
//
//  Created by Alexander Lezya on 22.11.2022.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - TranslatorsAssembleyImplementationComposer

public final class TranslatorsAssembleyImplementationComposer {

    // MARK: - Initializers

    required public init() {
    }

    // MARK: - Private

    /// Composes necessary translators from the given specifications
    /// - Parameters:
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    /// - Throws: generating errors
    /// - Returns: necessary translators implementations
    private func composeTranslatorsAssembley(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        guard let translatorsAssembleyFolder = parameters[.translators] else {
            throw DAOAutographError.noTranslatorsAssembleyFolder
        }
        let targetClasses = specifications
            .classes
            .filter { $0.name.isTranslatorName }
        let classesImplementations = try targetClasses
            .map {
                try composeTranslatorsAssembley(
                    forExtensible: $0,
                    specifications: specifications,
                    parameters: parameters,
                    translatorsAssembleyFolder: translatorsAssembleyFolder
                )
            }
        return classesImplementations
    }
    
    /// Composes a single translators assembley for the given extensible
    /// - Parameters:
    ///   - extensible: some plain object specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    ///   - translatorsAssembleyFolder: target translators assembley folder for generated class
    /// - Throws: generating errors
    /// - Returns: necessary translator implementation
    private func composeTranslatorRegistration<T: ExtensibleSpecification>(
        forExtensible extensible: T,
        specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> AutographImplementation {
    }

    /// Composes a single translators assembley for the given extensible
    /// - Parameters:
    ///   - extensible: some plain object specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    ///   - translatorsAssembleyFolder: target translators assembley folder for generated class
    /// - Throws: generating errors
    /// - Returns: necessary translator implementation
    private func composeTranslatorsAssembley<T: ExtensibleSpecification>(
        forExtensible extensible: T,
        specifications: Specifications,
        parameters: AutographExecutionParameters,
        translatorsAssembleyFolder: String
    ) throws -> AutographImplementation {
        let code = """
        // MARK: - TranslatorsAssembly

        final class TranslatorsAssembly: CollectableAssembly {

            required init() {
            }

            func assemble(inContainer container: Container) {

            
            }
        }
        """
        guard let projectName = parameters[.projectName] else {
            throw DAOAutographError.noProjectName
        }
        let header = headerComment(
            filename: "TranslatorsAssembly",
            projectName: projectName,
            imports: ["Swinject", "Monreau", RealmSwift]
        )
        let sourceCode = header + "\n" + code
        return AutographImplementation(
            filePath: "/\(translatorsFolder)/TranslatorsAssembly.swift",
            sourceCode: sourceCode
        )
    }
}

// MARK: - ImplementationComposer

extension TranslatorsAssembleyImplementationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        let translatorsAssembleyImplementation = try composeTranslatorsAssembley(
            forSpecifications: specifications,
            parameters: parameters
        )
        return translatorsImplementations
    }
}
