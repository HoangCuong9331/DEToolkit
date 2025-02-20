//
//  UIView.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//
import UIKit

public extension UIView {
    
    /// Rounds specific corners of a UIView with a given radius.
    ///
    /// - Parameters:
    ///   - corners: The corners to round (e.g., .topLeft, [.topLeft, .topRight])
    ///   - radius: The radius of the rounded corners
    ///
    /// - Example:
    /// ```swift
    /// myView.roundCornerView(corners: [.topLeft, .topRight], radius: 10)
    ///
    /// ```
    func roundCornerView(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: .init(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /// Adds the view to another view with equal margins on all sides.
    ///
    /// This method adds the current view as a subview of the specified view and
    /// constrains it to the edges with the given margin.
    ///
    /// - Parameters:
    ///   - viewB: The container view to add this view to
    ///   - margin: The margin to apply to all edges (default is 0)
    ///
    /// - Example:
    /// ```swift
    /// childView.spill(on: parentView, margin: 16)
    ///
    /// ```
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
    
    /// Loads a view from a nib file with the same name as the view class.
    ///
    /// This method automatically finds and loads a nib file matching the class name
    /// of the specified view type. The nib file must exist in the same bundle as the class.
    ///
    /// - Parameter viewType: The type of view to load from the nib
    /// - Returns: An instance of the specified view type
    /// - Throws: Fatal error if the nib doesn't exist or can't be loaded
    ///
    /// - Note: The nib file name must exactly match the class name
    ///
    /// - Example:
    /// ```swift
    /// // For a class named CustomView:
    /// // Load from CustomView.xib
    /// let customView = UIView.loadNib(CustomView.self)
    ///
    /// // The nib file structure should be:
    /// // - CustomView.swift (the class file)
    /// // - CustomView.xib (the nib file with same name)
    /// ```
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
       let className = String(describing: viewType)
       let bundle = Bundle(for: viewType)
       guard let view = bundle.loadNibNamed(className, owner: nil, options: nil)?.first as? T else {
           fatalError("Failed to load nib for \(className). Ensure the nib file exists and matches the class name.")
       }
       return view
    }

    /// Convenience method to load the current view type from its matching nib file.
    ///
    /// This is a type-safe wrapper around loadNib(_:) that uses the current class type.
    ///
    /// - Returns: An instance of the current view type
    /// - Throws: Fatal error if the nib doesn't exist or can't be loaded
    ///
    /// - Example:
    /// ```swift
    /// // Inside CustomView.swift
    /// class CustomView: UIView {
    ///     static let shared = CustomView.loadNib()
    /// }
    ///
    /// ```
    class func loadNib() -> Self {
       return loadNib(self)
    }
}
