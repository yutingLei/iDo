/**************************************************
*
* String+Extension
*
* Extend properties and methods.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

//MARK: - Subscript
public extension String {

    /// Get substring use ClosedRange
    ///
    /// For example: "1234567890"[1...3] = "234"
    subscript(_ rng: ClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: rng.lowerBound)
        let end = index(startIndex, offsetBy: rng.upperBound)
        return self[start...end]
    }

    /// Get substring use Range
    ///
    /// For example: "1234567890"[1..<3] = "23"
    subscript(_ rng: Range<Int>) -> Substring {
        let start = index(startIndex, offsetBy: rng.lowerBound)
        let end = index(startIndex, offsetBy: rng.upperBound)
        return self[start..<end]
    }

    /// Get substring use range from.
    ///
    /// For example: "1234567890"[2...] = "34567890"
    subscript(_ rng: PartialRangeFrom<Int>) -> Substring {
        let rng = rng.relative(to: 0..<count)
        return self[rng]
    }

    /// Get substring use range through
    ///
    /// For example: "1234567890"[..<3] = "123"
    subscript(_ rng: PartialRangeUpTo<Int>) -> Substring {
        let rng = rng.relative(to: 0..<count)
        return self[rng]
    }

    /// Get substring use range through
    ///
    /// For example: "1234567890"[...2] = "123"
    subscript(_ rng: PartialRangeThrough<Int>) -> Substring {
        let rng = rng.relative(to: 0..<count)
        return self[rng]
    }
}

//MARK: - Process
/// Convenience method to process string.
public extension String {

    /// URL encode.
    func urlEncoded() -> String? {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }

    /// Reject head/trail white-space and newline
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

//MARK: - Attributed
/// Please use this method with [NSMutableAttributedString]'s extend methods.
public extension String {

    /// Make current string into attribute string.
    ///
    /// For example: "test".attributed().bold().italic().underline()
    func attributed() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }

    /// Parse HTML string.
    func parseHTML(str htmlStr: String) -> NSAttributedString? {
        if let data = htmlStr.data(using: .utf8) {
            let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            return try? NSAttributedString(data: data, options: opts, documentAttributes: nil)
        }
        return nil
    }
}

public extension NSMutableAttributedString {

    /// Get effect range by given range.
    private func range(from otherRange: ClosedRange<Int>? = nil) -> NSRange? {
        if otherRange != nil && otherRange!.isEmpty {
            return nil
        }
        let loc = otherRange?.lowerBound ?? 0
        let len = (otherRange?.upperBound ?? string.count) - (otherRange?.lowerBound ?? 0)
        return NSRange(location: loc, length: len)
    }

    /// Make string bold in given range.
    ///
    /// range: Effective range, if nil, all string are effect.
    /// degree: The thickness of stroke line.
    func bold(in rng: ClosedRange<Int>? = nil, thickness: CGFloat = -3) -> Self {
        if let range = range(from: rng) {
            addAttributes([.strokeWidth: thickness], range: range)
        }
        return self
    }

    /// Make string italic in given range.
    ///
    /// range: Effective range, if nil, all string are effect.
    /// degree: The italic level, values in [0...1].
    func italic(in rng: ClosedRange<Int>? = nil, degree: CGFloat = 0.1) -> Self {
        if let range = range(from: rng) {
            addAttribute(.obliqueness, value: degree, range: range)
        }
        return self
    }

    /// Render color for string in given range.
    ///
    /// color: The color will be rendered onto text.
    /// range: Effective range, if nil, all string are rendering by this color.
    func color(_ color: UIColor, in rng: ClosedRange<Int>? = nil) -> Self {
        if let range = range(from: rng) {
            addAttributes([.foregroundColor: color], range: range)
        }
        return self
    }

    /// Render background color for string in given range.
    ///
    /// color: The color will be rendered onto text's background.
    /// range: Effective range.
    func bgColor(_ color: UIColor, in rng: ClosedRange<Int>? = nil) -> Self {
        if let range = range(from: rng) {
            addAttributes([.backgroundColor: color], range: range)
        }
        return self
    }

    /// Add delete line onto string in given range.
    ///
    /// color: As same as foregroundColor, if fore...Color is nil, use black instead.
    /// range: Delete line make effecial range.
    /// degree: The thickness of line.
    func deleleLine(with color: UIColor? = nil,
                    in rng: ClosedRange<Int>? = nil,
                    thickness: CGFloat = 1) -> Self
    {
        if var range = range(from: rng) {
            let rngPtr = withUnsafeMutablePointer(to: &range) { $0 }
            let attrs = attributes(at: range.location, effectiveRange: rngPtr)
            let color = attrs[.foregroundColor] ?? UIColor.black
            addAttributes([.strikethroughStyle: thickness,
                           .strikethroughColor: color], range: range)
        }
        return self
    }

    /// Add underline onto string in given range.
    ///
    /// color: As same as foregroundColor, if fore...Color is nil, use black instead.
    /// range: Make underline effecial range.
    /// thickness: The thickness of line.
    func underline(with color: UIColor? = nil,
                   in rng: ClosedRange<Int>? = nil,
                   thickness: CGFloat = 1) -> Self
    {
        if var range = range(from: rng) {
            let rngPtr = withUnsafeMutablePointer(to: &range) { $0 }
            let attrs = attributes(at: range.location, effectiveRange: rngPtr)
            let color = attrs[.foregroundColor] ?? UIColor.black
            addAttributes([.underlineColor: color,
                           .underlineStyle: thickness], range: range)
        }
        return self
    }

    /// Adjust string's size in given range.
    ///
    /// size: Use system font.
    /// range: The effective range.
    func fontSize(_ size: CGFloat, in rng: ClosedRange<Int>? = nil) -> Self {
        if let range = range(from: rng) {
            addAttributes([.font: UIFont.systemFont(ofSize: size)], range: range)
        }
        return self
    }

    /// Render some strings with sepcial font in given range.
    func font(_ font: UIFont, in rng: ClosedRange<Int>? = nil) -> Self {
        if let range = range(from: rng) {
            addAttributes([.font: font], range: range)
        }
        return self
    }
}
