//
//  CALayer.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//

import UIKit

extension CALayer {
    /// Applies a Sketch-like shadow effect to the layer.
    ///
    /// - Parameters:
    ///   - color: The shadow color. Default is black.
    ///   - alpha: The opacity of the shadow, ranging from 0 (transparent) to 1 (opaque). Default is 0.5.
    ///   - x: The horizontal offset of the shadow. Positive values move the shadow to the right. Default is 0.
    ///   - y: The vertical offset of the shadow. Positive values move the shadow downward. Default is 2.
    ///   - blur: The blur radius of the shadow. Higher values create a softer shadow. Default is 4.
    ///   - spread: The expansion of the shadow. A positive value increases the shadow size, while a negative value shrinks it. Default is 0.
    @MainActor
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
