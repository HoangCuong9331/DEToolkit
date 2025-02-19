//
//  Collection.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//

import Foundation

public extension Collection where Indices.Iterator.Element == Index {

    subscript (safe index: Index?) -> Iterator.Element? {
        guard let index = index else { return nil }
        return indices.contains(index) ? self[index] : nil
    }
}
