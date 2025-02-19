//
//  UIDevice.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//

import UIKit

public extension UIDevice {
    var hasNotch: Bool {
        let bottom = bottomSafeAreaInset
        print("hasNotch")
        print(bottom)
        return bottom > 0
    }
    
    var bottomSafeAreaInset: CGFloat {
        let window = UIApplication.shared.keyWindow
        var bottomPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        }
        return bottomPadding
    }

}
