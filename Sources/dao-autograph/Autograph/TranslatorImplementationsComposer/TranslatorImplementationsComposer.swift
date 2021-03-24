//
//  File.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Synopsis
import Autograph

// MARK: - TranslatorImplementationsComposer

public final class TranslatorImplementationsComposer {

    required public init() {
    }
}

// MARK: - ImplementationComposer

extension TranslatorImplementationsComposer: ImplementationComposer {

    public func compose(
        forSpecifications specifications: Specifications,
        parameters: AutographExecutionParameters
    ) throws -> [AutographImplementation] {
        let modelsComposer = ModelObjectsImplementationsComposer()
        let modelsImplementations = try modelsComposer.compose(
            forSpecifications: specifications,
            parameters: parameters
        )
        let realmTranslatorsImplementations = try RealmTranslatorImplementationComposer()
            .compose(forSpecifications: specifications, parameters: parameters)
        return modelsImplementations + realmTranslatorsImplementations
    }
}
