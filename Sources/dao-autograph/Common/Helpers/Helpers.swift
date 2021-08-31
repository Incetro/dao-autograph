//
//  File.swift
//  dao-autograph
//
//  Created by incetro on 12/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - Header

/// Constructs signed by dao-autograph header
/// - Parameters:
///   - filename: target file name
///   - projectName: current project name
///   - imports: necessary imports
/// - Returns: signed by dao-autograph header
public func headerComment(
    filename: String,
    projectName: String,
    imports: [String]
) -> String {
    let imports = imports.map { "import \($0)" }.joined(separator: "\n")
    return """
        //
        //  \(filename).swift
        //  \(projectName)
        //
        //  Generated automatically by dao-autograph
        //  https://github.com/Incetro/dao-autograph
        //
        //  Copyright © 2020 Incetro Inc. All rights reserved.
        //
        // swiftlint:disable trailing_newline

        \(imports)

        """
}
