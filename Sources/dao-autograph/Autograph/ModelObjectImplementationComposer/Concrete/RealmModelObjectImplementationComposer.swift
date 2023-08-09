//
//  RealmModelObjectImplementationComposer.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - RealmModelObjectImplementationComposer

public final class RealmModelObjectImplementationComposer<Extensible: ExtensibleSpecification> {

    /// Returns general property specification for model object
    /// - Parameters:
    ///   - property: plain object property specification
    ///   - type: plain object property type
    ///   - isOptional: true if the given property is already optional
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: general property specification for model object
    private func propertySpecification(
        fromProperty property: PropertySpecification,
        withType type: TypeSpecification? = nil,
        isOptional: Bool = false,
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) -> PropertySpecification? {
        switch type ?? property.type {
        case .boolean, .integer, .floatingPoint, .doublePrecision, .string, .date, .data:
            return baseSpecification(
                fromProperty: property,
                withType: type ?? property.type,
                isOptional: isOptional,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .object:
            let isOptionalObject: Bool
            switch property.type {
            case .optional(let wrapped):
                if let `enum` = specifications.enums.first(where: { $0.name == wrapped.verse }) {
                    if let type = `enum`.realmAnalog {
                        return baseSpecification(
                            fromProperty: property,
                            withType: type,
                            isOptional: isOptional,
                            isSwiftType: true,
                            usingSpecifications: specifications,
                            parameters: parameters
                        )
                    }
                }
                /// We need to remove double-optional
                isOptionalObject = false
            case .object(name: let name):
                let `enum` = specifications.enums.first { $0.name == name }
                let enumRawType = `enum`.flatMap { isOptional ? $0.realmAnalog.map { .optional(wrapped: $0) } : $0.realmAnalog }
                if let type = enumRawType {
                    return baseSpecification(
                        fromProperty: property,
                        withType: type,
                        isOptional: isOptional,
                        isSwiftType: true,
                        usingSpecifications: specifications,
                        parameters: parameters
                    )
                } else if name == "URL" {
                    return baseSpecification(
                        fromProperty: property,
                        withType: .string,
                        isOptional: false,
                        usingSpecifications: specifications,
                        parameters: parameters
                    )
                } else {
                    fallthrough
                }
            default:
                isOptionalObject = true
            }
            return baseSpecification(
                fromProperty: property,
                withType: type ?? property.type,
                withDefaultValue: nil,
                isOptional: isOptionalObject,
                isSwiftType: false,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .array(element: let type):
            return arraySpecification(
                fromProperty: property,
                elementType: type,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .optional(wrapped: let type):
            return propertySpecification(
                fromProperty: property,
                withType: type,
                isOptional: true,
                usingSpecifications: specifications,
                parameters: parameters
            )
        default:
            return nil
        }
    }

    /// Returns general property specification for model object
    /// - Parameters:
    ///   - property: plain object property specification
    ///   - type: plain object property type
    ///   - isOptional: true if the given property is already optional
    ///   - isSwiftType: true if the given property is a Swift type
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: general property specification for model object
    private func baseSpecification(
        fromProperty property: PropertySpecification,
        withType type: TypeSpecification,
        isOptional: Bool,
        isSwiftType: Bool? = nil,
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) -> PropertySpecification {
        switch type {
        case .boolean:
            return baseSpecification(
                fromProperty: property,
                withType: type,
                withDefaultValue: "false",
                isOptional: isOptional,
                isSwiftType: isSwiftType ?? true,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .integer:
            return baseSpecification(
                fromProperty: property,
                withType: type,
                withDefaultValue: "0",
                isOptional: isOptional,
                isSwiftType: isSwiftType ?? true,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .floatingPoint:
            return baseSpecification(
                fromProperty: property,
                withType: type,
                withDefaultValue: "0.0",
                isOptional: isOptional,
                isSwiftType: isSwiftType ?? true,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .doublePrecision:
            return baseSpecification(
                fromProperty: property,
                withType: type,
                withDefaultValue: "0.0",
                isOptional: isOptional,
                isSwiftType: isSwiftType ?? true,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .string:
            return baseSpecification(
                fromProperty: property,
                withType: type,
                withDefaultValue: "\"\"",
                isOptional: isOptional,
                isSwiftType: isSwiftType ?? false,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .date:
            return baseSpecification(
                fromProperty: property,
                withType: type,
                withDefaultValue: "Date()",
                isOptional: isOptional,
                isSwiftType: isSwiftType ?? false,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .data:
            return baseSpecification(
                fromProperty: property,
                withType: type,
                withDefaultValue: "Data()",
                isOptional: isOptional,
                isSwiftType: isSwiftType ?? false,
                usingSpecifications: specifications,
                parameters: parameters
            )
        case .object:
            return baseSpecification(
                fromProperty: property,
                withType: type,
                withDefaultValue: nil,
                isOptional: isOptional,
                isSwiftType: isSwiftType ?? false,
                usingSpecifications: specifications,
                parameters: parameters
            )
        default:
            fatalError()
        }
    }

    /// Returns general property specification for model object
    /// - Parameters:
    ///   - property: plain object property specification
    ///   - type: plain object property type
    ///   - defaultValue: target property default value
    ///   - isOptional: true if the given property is already optional
    ///   - isSwiftType: true if the given property is a Swift type
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: general property specification for model object
    private func baseSpecification(
        fromProperty property: PropertySpecification,
        withType type: TypeSpecification,
        withDefaultValue defaultValue: String?,
        isOptional: Bool,
        isSwiftType: Bool,
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) -> PropertySpecification {
        let accessibility = parameters[.accessibility].flatMap(Accessibility.init) ?? .internal
        if !isOptional {
            let nonSkippingTypeDeclarationTypes: [TypeSpecification] = [.floatingPoint, .doublePrecision]
            return .template(
                comment: property.comment,
                accessibility: accessibility.synopsisAccessibility,
                declarationKind: .objcDynamicVar,
                name: property.name,
                type: property.type.realmAnalog(using: specifications),
                defaultValue: property.defaultValue ?? defaultValue,
                skippingTypeDeclaration: !nonSkippingTypeDeclarationTypes.contains(property.type),
                kind: .instance,
                body: nil
            )
        } else if isSwiftType {
            let type = TypeSpecification.generic(
                name: "RealmOptional",
                constraints: [
                    type.unwrapped
                ]
            )
            return .template(
                comment: property.comment,
                accessibility: accessibility.synopsisAccessibility,
                declarationKind: .let,
                name: property.name,
                type: type,
                defaultValue: type.verse + "()",
                skippingTypeDeclaration: true,
                kind: .instance,
                body: nil
            )
        } else {
            return .template(
                comment: property.comment,
                accessibility: accessibility.synopsisAccessibility,
                declarationKind: .objcDynamicVar,
                name: property.name,
                type: .optional(wrapped: type.realmAnalog(using: specifications)),
                defaultValue: nil,
                kind: .instance,
                body: nil
            )
        }
    }

    /// Returns general array property specification for model object
    /// - Parameters:
    ///   - property: plain object property specification
    ///   - elementType: plain object property element type specification
    ///   - specifications: Synopsis specifications of our parsed code
    /// - Returns: general array property specification for model object
    private func arraySpecification(
        fromProperty property: PropertySpecification,
        elementType: TypeSpecification,
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) -> PropertySpecification {
        let type = TypeSpecification.generic(
            name: "List",
            constraints: [
                elementType.realmAnalog(using: specifications)
            ]
        )
        let accessibility = parameters[.accessibility].flatMap(Accessibility.init) ?? .internal
        return .template(
            comment: property.comment,
            accessibility: accessibility.synopsisAccessibility,
            declarationKind: .let,
            name: property.name,
            type: type,
            defaultValue: type.verse + "()",
            skippingTypeDeclaration: true,
            kind: .instance,
            body: nil
        )
    }
}

// MARK: - ModelObjectImplementationComposer

extension RealmModelObjectImplementationComposer: ModelObjectImplementationComposer {

    public var annotation: String { "realm" }

    public func model(
        fromExtensible extensible: Extensible,
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> AutographImplementation {
        guard let modelsFolder = parameters[.models] else {
            throw DAOAutographError.noModelsFolder
        }
        guard let projectName = parameters[.projectName] else {
            throw DAOAutographError.noProjectName
        }
        var modelProperties: [PropertySpecification] = []
        for property in extensible.properties where property.body == nil {
            if let prop = propertySpecification(
                fromProperty: property,
                usingSpecifications: specifications,
                parameters: parameters
            ) {
                modelProperties.append(prop)
            }
        }
        let objectName = extensible.name.extractedPlainObjectName.modelObjectName
        let header = headerComment(
            filename: objectName,
            projectName: projectName,
            imports: ["SDAO", "Foundation", "RealmSwift"]
        )
        let accessibility = parameters[.accessibility].flatMap(Accessibility.init) ?? .internal
        let modelObjectClassSpecification = ClassSpecification.template(
            comment: nil,
            accessibility: accessibility.synopsisAccessibility,
            attributes: [.final],
            name: extensible.name.extractedPlainObjectName.modelObjectName,
            inheritedTypes: ["RealmModel"],
            properties: modelProperties,
            methods: []
        )
        let sourceCode = header + "\n" + modelObjectClassSpecification.verse
        return AutographImplementation(
            filePath: "/\(modelsFolder)/\(objectName).swift",
            sourceCode: sourceCode
        )
    }
}
