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

    /// Annotation that defines if the current
    /// composer should process the given specification
    var annotation: String { get }

    /// Returns some model object's implementation for
    /// the given plain structure specification
    /// - Parameters:
    ///   - structure: some plain structure
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: current execution parameters
    func model(
        fromStructure structure: StructureSpecification,
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> AutographImplementation
}

extension ModelObjectImplementationComposer {

    /// Returns some model object's implementations for
    /// the given plain structures specifications
    /// - Parameters:
    ///   - structures: some plain structures
    ///   - specifications: Synopsis specifications of our parsed code
    ///   - parameters: current execution parameters
    func models(
        fromStructures structures: [StructureSpecification],
        usingSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        try structures
            .filter {
                $0.annotations.contains(annotationName: annotation)
            }
            .map {
                try model(
                    fromStructure: $0,
                    usingSpecifications: specifications,
                    parameters: parameters
                )
            }
    }
}
