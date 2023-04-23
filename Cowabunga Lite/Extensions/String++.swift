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
