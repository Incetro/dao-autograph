//
//  File.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - ModelObjectImplementationComposer

public protocol ModelObjectImplementationComposer {

    associatedtype Extensible: ExtensibleSpecification

    /// Annotation that defines if the current
    /// composer should process the given specification
    var annotation: String { get }

    /// Returns some model object's implementation for
    /// the given plain object specification
    /// - Parameters:
    ///   - extensible: some plain object
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: current execution parameters
    func model(
        fromExtensible extensible: Extensible,
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> AutographImplementation
}

extension ModelObjectImplementationComposer {

    /// Returns some model object's implementations for
    /// the given plain extensible specifications
    /// - Parameters:
    ///   - extensibles: some plain objects
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: current execution parameters
    func models(
        fromExtensibles extensibles: [Extensible],
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        try extensibles
            .filter {
                $0.annotations.contains(annotationName: annotation)
            }
            .map {
                try model(
                    fromExtensible: $0,
                    usingSpecifications: specifications,
                    parameters: parameters
                )
            }
    }
}
