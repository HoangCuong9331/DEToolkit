//
//  Dictionary.swift
//  DEToolkit
//
//  Created by Le Cuong on 25/4/25.
//
import Foundation

public extension Dictionary {
    
    /// Converts the dictionary into a JSON string.
    ///
    /// - Returns: A `String` containing the JSON representation of the dictionary, or `nil` if conversion fails.
    func toJson() -> String? {
        guard let data = self.toData() else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Converts the dictionary into `Data` using JSON serialization.
    ///
    /// - Returns: A `Data` object containing the JSON-encoded dictionary, or `nil` if serialization fails.
    func toData() -> Data? {
        try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}
