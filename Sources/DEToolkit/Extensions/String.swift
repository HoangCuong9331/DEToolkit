//
//  string.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//

import Foundation
import UIKit

public extension String {
    /// Converts an HTML string into an `NSAttributedString`.
    ///
    /// - Returns: An `NSAttributedString` representation of the HTML string, or `nil` if conversion fails.
    func htmlToNSAttributedString() -> NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// Attempts to open the string as a URL in the default web browser.
    ///
    /// - Returns: `true` if the URL was successfully opened, `false` otherwise.
    @discardableResult
    @MainActor
    func openAsURL() -> Bool {
        if let url = URL(string: self), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            return true
        } else {
            print("Cannot open this url: \(self)")
            return false
        }
    }
    
    /// Calculates the size of the string when rendered with a specific font.
    ///
    /// - Parameter font: The font to be used for size calculation.
    /// - Returns: The `CGSize` representing the width and height of the rendered string.
    func sizeOfString(using font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    /// Converts a JSON-formatted string into an `NSDictionary`.
    ///
    /// - Returns: An `NSDictionary` representation of the JSON string, or an empty dictionary if parsing fails.
    func toDictionary() -> NSDictionary {
        guard let data = self.data(using: .utf8), let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary  else {
            return [:]
        }
        return dict
    }
}
