//
//  Optional.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/5/25.
//

extension Optional {
    /// A string value for interpolating.
    /// Either the interpolation of the contained value or `nil`.
    public var interpolationString: String {
        return "\(map { "\($0)" } ?? "`nil`")"
    }
}
