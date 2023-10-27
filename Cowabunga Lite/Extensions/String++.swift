//
//  String++.swift
//  CowabungaJailed
//
//  Created by lemin on 3/20/23.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension String {
    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }
}
