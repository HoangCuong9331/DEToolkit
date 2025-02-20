//
//  UIColor.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//

import UIKit

public extension UIColor {
    /// Initializes a `UIColor` instance from a hexadecimal color string.
    ///
    /// - Parameter hex: A hex string representation of the color (e.g., `"#FF5733"` or `"FF5733"`).
    /// - Returns: A `UIColor` instance if the hex string is valid; otherwise, `nil`.
    convenience init?(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return nil
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
        return
    }
}

