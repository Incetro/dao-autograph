//
//  File.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - ModelObjectsImplementationsComposer

public final class ModelObjectsImplementationsComposer {

    required public init() {
    }
}

// MARK: - ImplementationComposer

extension ModelObjectsImplementationsComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        let plainStructures = specifications.structures.filter { $0.name.isPlainObjectName }
        let plainClasses = specifications.classes.filter { $0.name.isPlainObjectName }
        let structModels = try RealmModelObjectImplementationComposer<StructureSpecification>()
            .models(
                fromExtensibles: plainStructures,
                usingSpecifications: specifications,
                parameters: parameters
            )
        let classModels = try RealmModelObjectImplementationComposer<ClassSpecification>()
            .models(
                fromExtensibles: plainClasses,
                usingSpecifications: specifications,
                parameters: parameters
            )
        return structModels + classModels
    }
}
