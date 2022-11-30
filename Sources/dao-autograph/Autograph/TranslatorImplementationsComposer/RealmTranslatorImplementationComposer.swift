//
//  File.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - RealmTranslatorImplementationComposer

public final class RealmTranslatorImplementationComposer {

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
    private func composeTranslators(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        guard let translatorsFolder = parameters[.translators] else {
            throw DAOAutographError.noTranslatorsFolder
        }
        let targetStructures = specifications
            .structures
            .filter { $0.name.isPlainObjectName }
            .filter { $0.annotations.contains(annotationName: "realm") }
        let targetClasses = specifications
            .classes
            .filter { $0.name.isPlainObjectName }
            .filter { $0.annotations.contains(annotationName: "realm") }
        let structuresImplementations = try targetStructures
            .map {
                try composeTranslator(
                    forExtensible: $0,
                    specifications: specifications,
                    parameters: parameters,
                    translatorsFolder: translatorsFolder
                )
            }
        let classesImplementations = try targetClasses
            .map {
                try composeTranslator(
                    forExtensible: $0,
                    specifications: specifications,
                    parameters: parameters,
                    translatorsFolder: translatorsFolder
                )
            }
        return structuresImplementations + classesImplementations
    }

    /// Composes a single translator for the given extensible
    /// - Parameters:
    ///   - extensible: some plain object specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    ///   - translatorsFolder: target translators folder for generated classes
    /// - Throws: generating errors
    /// - Returns: necessary translator implementation
    private func composeTranslator<T: ExtensibleSpecification>(
        forExtensible extensible: T,
        specifications: Specifications,
        parameters: AutographExecutionParameters,
        translatorsFolder: String
    ) throws -> AutographImplementation {
        let accessibility = parameters[.accessibility].flatMap(Accessibility.init) ?? .internal
        let objectName = extensible.name.extractedPlainObjectName
        let code = """
        // MARK: - \(objectName)Translator

        \(accessibility.verse)final class \(objectName)Translator {

            // MARK: - Aliases

            \(accessibility.verse)typealias PlainModel = \(objectName)PlainObject
            \(accessibility.verse)typealias DatabaseModel = \(objectName)ModelObject

            /// \(objectName) storage
            private lazy var \(objectName.lowercasingFirstLetter())Storage = RealmStorage<\(objectName)ModelObject>(configuration: self.configuration)

            /// RealmConfiguration instance
            private let configuration: RealmConfiguration

            // MARK: - Initializers

            /// Default initializer
            /// - Parameters:
            ///   - configuration: current realm db config
            \(accessibility.verse)init(configuration: RealmConfiguration) {
                self.configuration = configuration
            }
        }

        // MARK: - Translator

        extension \(objectName)Translator: Translator {

            \(accessibility.verse)func translate(model: DatabaseModel) throws -> PlainModel {
        \(try modelTranslationDefinition(
            forExtensible: extensible,
            specifications: specifications,
            parameters: parameters
        ))
            }

            \(accessibility.verse)func translate(plain: PlainModel) throws -> DatabaseModel {
                let model = try \(objectName.lowercasingFirstLetter())Storage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
                try translate(from: plain, to: model)
                return model
            }

            \(accessibility.verse)func translate(from plain: PlainModel, to databaseModel: DatabaseModel) throws {
                if databaseModel.uniqueId.isEmpty {
                    databaseModel.uniqueId = plain.uniqueId.rawValue
                }
        \(try modelAssignmentDefinition(
            forExtensible: extensible,
            specifications: specifications,
            parameters: parameters
        ))
            }
        }
        """
        guard let projectName = parameters[.projectName] else {
            throw DAOAutographError.noProjectName
        }
        let translatorName = objectName.appending("Translator")
        let header = headerComment(
            filename: translatorName,
            projectName: projectName,
            imports: ["SDAO", "Monreau"]
        )
        let sourceCode = header + "\n" + code
        return AutographImplementation(
            filePath: "/\(translatorsFolder)/\(translatorName).swift",
            sourceCode: sourceCode
        )
    }

    /// Returns a sequence of target models's properties assignments
    /// - Parameters:
    ///   - extensible: target extensible specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    /// - Throws: generating errors
    /// - Returns: a sequence of target models's properties assignments
    private func modelAssignmentDefinition<T: ExtensibleSpecification>(
        forExtensible extensible: T,
        specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> String {
        let assignmentSequence = try extensible.properties
            .filter { "UniqueID" != $0.type.verse }
            .filter { $0.body == nil }
            .map {
                try modelAssignmentPropertyDefinition(
                    forProperty: $0,
                    specifications: specifications,
                    parameters: parameters
                )
            }
            .joined(separator: "\n")
        return assignmentSequence
    }

    /// Returns a single property assignment statement
    /// - Parameters:
    ///   - property: target property specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    /// - Throws: generating errors
    /// - Returns: a single property assignment statement
    private func modelAssignmentPropertyDefinition(
        forProperty property: PropertySpecification,
        specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> String {
        let result: String
        switch property.type {
        case .boolean,
             .integer,
             .doublePrecision,
             .floatingPoint,
             .date,
             .data,
             .string,
             .optional(wrapped: .string):
            result = "databaseModel.\(property.name) = plain.\(property.name)"
        case .optional(wrapped: let type):
            switch type {
            case .boolean,
                 .floatingPoint,
                 .doublePrecision,
                 .integer:
                result = "databaseModel.\(property.name).value = plain.\(property.name)"
            case .date, .data:
                result = "databaseModel.\(property.name) = plain.\(property.name)"
            case .object(name: let name):
                if specifications.enums.contains(where: { $0.name == name }) {
                    result = "databaseModel.\(property.name).value = plain.\(property.name)?.rawValue"
                } else {
                    switch name {
                    case "URL":
                        result = "databaseModel.\(property.name) = plain.\(property.name)?.absoluteString"
                    default:
                        result = """
                        databaseModel.\(property.name) = try plain.\(property.name).map {
                            try \(name.extractedPlainObjectName)Translator(configuration: configuration).translate(plain: $0)
                        }
                        """
                    }
                }
            default:
                result = "/// unknown optional \(property.name)"
            }
        case .object(name: let name):
            if specifications.enums.contains(where: { $0.name == name }) {
                result = "databaseModel.\(property.name) = plain.\(property.name).rawValue"
            } else {
                switch name {
                case "URL":
                    result = "databaseModel.\(property.name) = plain.\(property.name).absoluteString"
                default:
                    result = """
                        databaseModel.\(property.name) = try \(name.extractedPlainObjectName)Translator(configuration: configuration).translate(plain: plain.\(property.name))
                        """
                }
            }
        case .array(element: let type):
            switch type {
            case .boolean,
                 .floatingPoint,
                 .doublePrecision,
                 .integer,
                 .data,
                 .string,
                 .date:
                result = """
                databaseModel.\(property.name).removeAll()
                databaseModel.\(property.name).append(objectsIn: plain.\(property.name))
                """
            case .object(name: let name):
                if specifications.enums.contains(where: { $0.name == name }) {
                    result = """
                    databaseModel.\(property.name).removeAll()
                    databaseModel.\(property.name).append(objectsIn: plain.\(property.name).map(\\.rawValue))
                    """
                } else {
                    switch name {
                    case "URL":
                        result = """
                        databaseModel.\(property.name).removeAll()
                        databaseModel.\(property.name).append(objectsIn: plain.\(property.name).map(\\.absoluteString))
                        """
                    default:
                        result = """
                        databaseModel.\(property.name).removeAll()
                        databaseModel.\(property.name).append(objectsIn:
                            try \(name.extractedPlainObjectName)Translator(configuration: configuration).translate(plains: plain.\(property.name))
                        )
                        """
                    }
                }
            default:
                throw DAOAutographError.unknownType(property.type.verse, propertyName: property.name)
            }
        default:
            throw DAOAutographError.unknownType(property.type.verse, propertyName: property.name)
        }
        return result.indent(2)
    }

    /// Returns a plain object initialization code
    /// - Parameters:
    ///   - extensible: target extensible specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    /// - Throws: generating errors
    /// - Returns: a plain object initialization code
    private func modelTranslationDefinition<T: ExtensibleSpecification>(
        forExtensible extensible: T,
        specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> String {
        let propertiesInitializerSequence = try extensible.properties
            .filter { "UniqueID" != $0.type.verse }
            .filter { $0.body == nil }
            .map {
                try modelTranslationPropertyDefinition(
                    forProperty: $0,
                    specifications: specifications,
                    parameters: parameters
                )
            }
            .joined(separator: ",\n")
        let necessaryGuardSequence = try self.necessaryGuardSequence(
            forExtensible: extensible,
            specifications: specifications,
            parameters: parameters
        )
        let returnKeyword = necessaryGuardSequence.isEmpty ? "" : "return ".indent(2)
        let extensibleName = returnKeyword.isEmpty ? extensible.name.indent(2) : extensible.name
        return """
        \(necessaryGuardSequence)\(returnKeyword)\(extensibleName)(
        \(propertiesInitializerSequence)
        \(")".indent(2))
        """
    }

    /// Composes guard sequence for some required properties
    /// - Parameters:
    ///   - extensible: target extensible specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    /// - Throws: generating errors
    /// - Returns: guard sequence for some required properties
    private func necessaryGuardSequence<T: ExtensibleSpecification>(
        forExtensible extensible: T,
        specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> String {
        let ignoredTypes = ["UniqueID", "URL"]
        let sequence = extensible.properties
            .filter { !ignoredTypes.contains($0.type.verse) }
            .filter { $0.body == nil }
            .reduce("") { res, property in
            switch property.type {
            case .object(name: let name):
                guard !specifications.enums.contains(where: { $0.name == name }) else {
                    return res
                }
                return res.appending(
                """
                guard let \(property.name) = model.\(property.name) else {
                    throw NSError(
                        domain: "com.incetro.\(name.extractedPlainObjectName.lowercased())-translator",
                        code: 1000,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Cannot find \(name.extractedPlainObjectName.modelObjectName) instance for \(extensible.name) with id: '\\(model.uniqueId)'"
                        ]
                    )
                }\n
                """.indent(2)
                )
            default:
                return res
            }
        }
        return sequence
    }

    /// Returns a single property translation statement
    /// - Parameters:
    ///   - property: target property specification
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: curent execution parameters
    /// - Throws: generating errors
    /// - Returns: a single property translation statement
    private func modelTranslationPropertyDefinition(
        forProperty property: PropertySpecification,
        specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> String {
        let result: String
        switch property.type {
        case .boolean,
             .integer,
             .doublePrecision,
             .floatingPoint,
             .date,
             .data,
             .string,
             .optional(wrapped: .string),
             .optional(wrapped: .data),
             .optional(wrapped: .date):
            result = "\(property.name): model.\(property.name)"
        case .optional(wrapped: let type):
            switch type {
            case .boolean,
                 .floatingPoint,
                 .doublePrecision,
                 .integer:
                result = "\(property.name): model.\(property.name).value"
            case .object(name: let name):
                if specifications.enums.contains(where: { $0.name == name }) {
                    result = "\(property.name): model.\(property.name).value.map(\(name).init).unsafelyUnwrapped"
                } else {
                    switch name {
                    case "URL":
                        result = "\(property.name): model.\(property.name).flatMap(URL.init)"
                    default:
                        result = """
                        \(property.name): try model.\(property.name).map {
                            try \(name.extractedPlainObjectName)Translator(configuration: configuration).translate(model: $0)
                        }
                        """
                    }
                }
            default:
                result = "unknown optional \(property.name)"
            }
        case .object(name: let name):
            if specifications.enums.contains(where: { $0.name == name }) {
                result = "\(property.name): \(name)(rawValue: model.\(property.name)).unsafelyUnwrapped"
            } else {
                switch name {
                case "URL":
                    result = "\(property.name): URL(string: model.\(property.name)).unsafelyUnwrapped"
                default:
                    result = "\(property.name): try \(name.extractedPlainObjectName)Translator(configuration: configuration).translate(model: \(property.name))"
                }
            }
        case .array(element: let type):
            switch type {
            case .boolean,
                 .floatingPoint,
                 .doublePrecision,
                 .integer,
                 .data,
                 .string,
                 .date:
                result = "\(property.name): Array(model.\(property.name))"
            case .object(name: let name):
                if specifications.enums.contains(where: { $0.name == name }) {
                    result = "\(property.name): model.\(property.name).compactMap(\(name).init)"
                } else {
                    switch name {
                    case "URL":
                        result = "\(property.name): Array(model.\(property.name).compactMap(URL.init))"
                    default:
                        result = """
                        \(property.name): try \(name.extractedPlainObjectName)Translator(configuration: configuration).translate(models: Array(model.\(property.name)))
                        """
                    }
                }
            default:
                throw DAOAutographError.unknownType(property.type.verse, propertyName: property.name)
            }
        default:
            throw DAOAutographError.unknownType(property.type.verse, propertyName: property.name)
        }
        return result.indent(3)
    }
}

// MARK: - ImplementationComposer

extension RealmTranslatorImplementationComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        let translatorsImplementations = try composeTranslators(
            forSpecifications: specifications,
            parameters: parameters
        )
        return translatorsImplementations
    }
}
