//
//  String.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Synopsis
import Foundation

// MARK: - String

public extension String {

    var isPlainObjectName: Bool {
        contains(Constants.plainObjectSuffix)
    }

    var isModelObjectName: Bool {
        contains(Constants.modelObjectSuffix)
    }

    var extractedPlainObjectName: String {
        replacingOccurrences(of: Constants.plainObjectSuffix, with: "")
    }

    var extractedModelObjectName: String {
        replacingOccurrences(of: Constants.modelObjectSuffix, with: "")
    }

    var plainObjectName: String {
        if !contains(Constants.plainObjectSuffix) {
            return appending(Constants.plainObjectSuffix)
        }
        return self
    }

    func lowercasingFirstLetter() -> String {
        prefix(1).lowercased() + dropFirst()
    }

    var modelObjectName: String {
        if !contains(Constants.modelObjectSuffix) {
            return appending(Constants.modelObjectSuffix)
        }
        return self
    }

    func indent(_ count: Int) -> String {
        var result = self
        for _ in 0..<count {
            result = result.indent
        }
        return result
    }
}
