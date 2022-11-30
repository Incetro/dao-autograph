//
//  Accessibility.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation
import Synopsis

// MARK: - Accessibility

public enum Accessibility: String {

    case `public`
    case `private`
    case `internal`
    case `open`

    public var verse: String {
        switch self {
        case .internal:
            return ""
        default:
            return rawValue + " "
        }
    }

    public var synopsisAccessibility: AccessibilitySpecification {
        switch self {
        case .public:
            return .public
        case .private:
            return .private
        case .internal:
            return .internal
        case .open:
            return .open
        }
    }
}
