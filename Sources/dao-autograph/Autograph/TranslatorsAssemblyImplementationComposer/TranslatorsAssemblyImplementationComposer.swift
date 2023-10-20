//
//  TranslatorsAssemblyImplementationComposer.swift
//  dao-autograph
//
//
//  Created by Alexander Lezya on 22.11.2022.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - TranslatorsAssemblyImplementationComposer

public final class TranslatorsAssemblyImplementationComposer {

    // MARK: - Initializers

    required public init() {
    }

    // MARK: - Private
    
    /// Composes a translators regestration for the given extensible
    /// - Parameters:
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: necessary translators regestration implementation string value
    private func composeTranslatorsRegistration(specifications: Specifications) -> String {
        let targetStructures = specifications
            .structures
            .filter { $0.name.isPlainObjectName }
            .filter { $0.annotations.contains(annotationName: "realm") }
        let targetClasses = specifications
            .classes
            .filter { $0.name.isPlainObjectName }
            .filter { $0.annotations.contains(annotationName: "realm") }
        let structuresTranslatorsRegestration = targetStructures.map {
            composeTranslatorRegistration(
                forExtensible: $0,
                specifications: specifications
            )
        }
        let classesTranslatorsRegestration = targetClasses.map {
            composeTranslatorRegistration(
                forExtensible: $0,
                specifications: specifications
            )
        }
        return (structuresTranslatorsRegestration + classesTranslatorsRegestration)
            .joined(separator: "\n\n").indent.indent
    }
    
    /// Composes a single translator registration for the given extensible
    /// - Parameters:
    ///   - extensible: some plain object specification
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: necessary translator registration implementation string value
    private func composeTranslatorRegistration<T: ExtensibleSpecification>(
        forExtensible extensible: T,
        specifications: Specifications
    ) -> String {
        """
        container.register(\(extensible.name.extractedPlainObjectName)Translator.self) { resolver in
            let configuration = resolver.resolve(RealmConfiguration.self).unsafelyUnwrapped
            return \(extensible.name.extractedPlainObjectName)Translator(configuration: configuration)
        }
        """
    }

    /// Composes translators assembly for the given extensible
    /// - Parameters:
    ///   - extensible: some plain object specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    ///   - translatorsAssemblyFolder: target translators assembly folder for generated class
    /// - Throws: generating errors
    /// - Returns: necessary translator implementation
    private func composeTranslatorsAssembly(
        specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> AutographImplementation? {
        guard let translatorsAssemblyFolder = parameters[.translatorsAssembly] ?? parameters[.daoAssembliesPath] else {
            return nil
        }
        let registrationsStr = composeTranslatorsRegistration(specifications: specifications)
        let code = """
        // MARK: - TranslatorsAssembly

        final class TranslatorsAssembly: CollectableAssembly {

            required init() {
            }

            func assemble(inContainer container: Container) {

        \(registrationsStr)
            }
        }
        """
        guard let projectName = parameters[.projectName] else {
            throw DAOAutographError.noProjectName
        }
        let header = headerComment(
            filename: "TranslatorsAssembly",
            projectName: projectName,
            imports: ["Monreau", "Swinject", "RealmSwift"]
        )
        let sourceCode = header + "\n" + code
        return AutographImplementation(
            filePath: "\(translatorsAssemblyFolder)/TranslatorsAssembly.swift",
            sourceCode: sourceCode
        )
    }
}

// MARK: - ImplementationComposer

extension TranslatorsAssemblyImplementationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        let translatorsAssemblyImplementation = try composeTranslatorsAssembly(
            specifications: specifications,
            parameters: parameters
        )
        guard let translatorsAssemblyImplementation = translatorsAssemblyImplementation else {
            return []
        }
        return [translatorsAssemblyImplementation]
    }
}
