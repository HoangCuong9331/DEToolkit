//
//  UIView.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//
import UIKit

public extension UIView {
    
    /// Custom radius for each corners
    ///
    /// Example Usage:
    /// ``` swift
    /// view.roundCornerView(corner: [.topLeft, .bottomRight], radius: 10)
    ///
    /// ```
    func roundCornerView(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: .init(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func spill(on viewB: UIView, margin: CGFloat = .zero) {
        viewB.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: viewB.topAnchor, constant: margin),
            self.bottomAnchor.constraint(equalTo: viewB.bottomAnchor, constant: -margin),
            self.leadingAnchor.constraint(equalTo: viewB.leadingAnchor, constant: margin),
            self.trailingAnchor.constraint(equalTo: viewB.trailingAnchor, constant: -margin),
            ])
    }
    
    static func loadFrom<T: UIView>(nibNamed: String, bundle: Bundle? = nil) -> T? {
            let nib = UINib(nibName: nibNamed, bundle: bundle)
            let instantiatedNibs = nib.instantiate(withOwner: nil, options: nil)
            return instantiatedNibs.first as? T
        }
}
