//
//  DAOAssemblyImplemetationComposer.swift
//  dao-autograph
//
//
//  Created by Alexander Lezya on 22.11.2022.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - DAOAssemblyImplemetationComposer

public final class DAOAssemblyImplemetationComposer {

    // MARK: - Initializers

    required public init() {
    }

    // MARK: - Private
    
    /// Composes DAO regestrations for the given extensible
    /// - Parameters:
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: translators regestration implementation string value
    private func composeDAORegistration(specifications: Specifications) -> String {
        let targetStructures = specifications
            .structures
            .filter { $0.name.isPlainObjectName }
            .filter { $0.annotations.contains(annotationName: "realm") }
        let targetClasses = specifications
            .classes
            .filter { $0.name.isPlainObjectName }
            .filter { $0.annotations.contains(annotationName: "realm") }
        let structuresDAORegestration = targetStructures.map {
            composeDAORegistration(
                forExtensible: $0,
                specifications: specifications
            )
        }
        let classesDAORegestration = targetClasses.map {
            composeDAORegistration(
                forExtensible: $0,
                specifications: specifications
            )
        }
        return (structuresDAORegestration + classesDAORegestration).joined(separator: "\n\n").indent.indent
    }
    
    /// Composes a single dao registration for the given extensible
    /// - Parameters:
    ///   - extensible: some plain object specification
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: necessary dao registration implementation string value
    private func composeDAORegistration<T: ExtensibleSpecification>(
        forExtensible extensible: T,
        specifications: Specifications
    ) -> String {
        """
        container.register(\(extensible.name.extractedPlainObjectName)DAO.self) { resolver in
            let translator = resolver.resolve(\(extensible.name.extractedPlainObjectName)Translator.self).unsafelyUnwrapped
            let configuration = resolver.resolve(RealmConfiguration.self).unsafelyUnwrapped
            return \(extensible.name.extractedPlainObjectName)DAO(
                storage: RealmStorage<\(extensible.name.extractedPlainObjectName)ModelObject>(configuration: configuration),
                translator: translator
            )
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
        guard let translatorsAssemblyFolder = parameters[.daoAssembly] ?? parameters[.daoAssembliesPath] else {
            return nil
        }
        let registrationsStr = composeDAORegistration(specifications: specifications)
        let code = """
        // MARK: - DAOAssembly

        final class DAOAssembly: CollectableAssembly {

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
            filename: "DAOAssembly",
            projectName: projectName,
            imports: ["SDAO", "Monreau", "Swinject", "RealmSwift"]
        )
        let sourceCode = header + "\n" + code
        return AutographImplementation(
            filePath: "\(translatorsAssemblyFolder)/DAOAssembly.swift",
            sourceCode: sourceCode
        )
    }
}

// MARK: - ImplementationComposer

extension DAOAssemblyImplemetationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        let daoAssemblyImplementation = try composeTranslatorsAssembly(
            specifications: specifications,
            parameters: parameters
        )
        guard let daoAssemblyImplementation = daoAssemblyImplementation else {
            return []
        }
        return [daoAssemblyImplementation]
    }
}

