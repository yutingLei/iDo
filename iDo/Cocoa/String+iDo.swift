//
//  String+iDo.swift
//  Extend some funcitons or others for class String
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

//MARK: - Convert to values
public extension String {

    /// To Int
    var int: Int? { get { return Int(self) } }

    /// To Float
    var float: Float? { get { return Float(self) } }

    /// To Double
    var double: Double? { get { return Double(self) } }

    /// To CGFloat
    var cgFloat: CGFloat? { get { return float != nil ? CGFloat(float!) : nil } }

    /// To decimal
    var decimal: Decimal? { get { return Decimal(string: self) } }
}

//MARK: - Substring
#if swift(>=4.0)
public extension String {

    /// Get range of strings
    subscript(_ slice: CountableClosedRange<Int>) -> Substring {
        assert(slice.lowerBound >= 0, "The begin of slice that must be greater than 0")
        assert(slice.upperBound < count, "The end of slice that must be smaller that 'count'")
        let start = index(startIndex, offsetBy: slice.lowerBound)
        let end = index(startIndex, offsetBy: slice.upperBound)
        return self[start...end]
    }

    /// Get range of strings
    subscript(_ slice: CountableRange<Int>) -> Substring {
        assert(slice.lowerBound >= 0, "The begin of slice that must be greater than 0")
        assert(slice.upperBound <= count, "The end of slice that must be smaller than or equel to 'count'")
        let start = index(startIndex, offsetBy: slice.lowerBound)
        let end = index(startIndex, offsetBy: slice.upperBound)
        return self[start..<end]
    }
}
#endif

//MARK: - Calculate width&height
public extension String {

    /// Get estimation width while drawing
    ///
    /// @height: Limit height, default is .infinity
    /// @fontSize: The font's size
    func boundingWidth(with height: CGFloat = CGFloat.infinity, fontSize: CGFloat) -> CGFloat {
        let width = (self as NSString).boundingRect(with: CGSize(width: CGFloat.infinity, height: height),
                                                    options: .usesLineFragmentOrigin,
                                                    attributes: [.font: UIFont.systemFont(ofSize: fontSize)],
                                                    context: nil).width
        return ceil(width)
    }

    /// Get estimation height while drawing
    ///
    /// @height: Limit width, default is .infinity
    /// @fontSize: The font's size
    func boundingHeight(with width: CGFloat = CGFloat.infinity, fontSize: CGFloat) -> CGFloat {
        let height = (self as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.infinity),
                                                     options: .usesLineFragmentOrigin,
                                                     attributes: [.font: UIFont.systemFont(ofSize: fontSize)],
                                                     context: nil).height
        return ceil(height)
    }
}
