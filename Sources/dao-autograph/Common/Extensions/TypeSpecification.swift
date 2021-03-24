//
//  TypeSpecification.swift
//  
//
//  Created by incetro on 3/20/21.
//

import Synopsis

// MARK: - TypeSpecification

public extension TypeSpecification {

    /// Return realm analog for current type
    /// - Parameter specifications: Synopsis specifications of our parsed code
    /// - Returns: realm analog for current type
    func realmAnalog(using specifications: Specifications) -> TypeSpecification {
        if case let .object(name) = self {
            switch name {
            case "URL":
                return .string
            default:
                if name.isPlainObjectName {
                    return .object(name: name.extractedPlainObjectName.modelObjectName)
                } else if
                    let `enum` = specifications.enums.first(where: { $0.name == name }),
                    let enumRawType = `enum`.realmAnalog {
                    return enumRawType
                }
                return self
            }
        } else if case let .optional(type) = self {
            switch type {
            case .integer, .doublePrecision, .floatingPoint, .boolean:
                return .generic(
                    name: "RealmOptional",
                    constraints: [
                        type.unwrapped
                    ]
                )
            case .object(let name):
                if
                    let `enum` = specifications.enums.first(where: { $0.name == name }),
                    let enumRawType = `enum`.realmAnalog {
                    return TypeSpecification.optional(wrapped: enumRawType).realmAnalog(using: specifications)
                } else {
                    fallthrough
                }
            default:
                return .optional(wrapped: type.realmAnalog(using: specifications))
            }
        } else {
            return self
        }
    }
}
