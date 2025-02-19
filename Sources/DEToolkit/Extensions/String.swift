//
//  string.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//

import Foundation
import UIKit

public extension String {
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
    
    func sizeOfString(using font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}
