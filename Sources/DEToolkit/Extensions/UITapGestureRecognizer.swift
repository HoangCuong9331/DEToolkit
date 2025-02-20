//
//  UITapGestureRecognizer.swift
//  DEToolkit
//
//  Created by Le Cuong on 19/2/25.
//

import UIKit

public extension UITapGestureRecognizer {
    /// Determines if a tap gesture occurred within a specific range of attributed text in a UILabel.
    ///
    /// This method calculates whether the touch location intersects with the specified range
    /// of characters in the label's attributed text. It accounts for label padding, line breaks,
    /// and text alignment.
    ///
    /// - Parameters:
    ///   - label: The UILabel containing the attributed text
    ///   - targetRange: The NSRange of text to check for intersection with the tap
    ///
    /// - Returns: Boolean indicating whether the tap occurred within the target text range
    ///
    /// - Example:
    /// ```swift
    /// let label = UILabel()
    /// label.attributedText = NSAttributedString(string: "Tap here to continue")
    /// let tapGesture = UITapGestureRecognizer()
    ///
    /// // Check if "here" was tapped
    /// let range = (label.attributedText?.string as NSString).range(of: "here")
    /// if tapGesture.didTapAttributedTextInLabel(label: label, inRange: range) {
    ///     // Handle tap on "here"
    /// }
    /// ```
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedText)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
    
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
