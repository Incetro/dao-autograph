//
//  EnumSpecification.swift
//  
//
//  Created by incetro on 3/20/21.
//

import Synopsis

// MARK: - EnumSpecification

public extension EnumSpecification {

    /// Returns realm type analog for current enum type
    var realmAnalog: TypeSpecification? {
        if inheritedTypes.contains("Int") {
            return .integer
        }
        if inheritedTypes.contains("String") {
            return .string
        }
        return nil
    }
}
