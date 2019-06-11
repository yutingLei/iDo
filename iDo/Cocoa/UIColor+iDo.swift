//
//  UIColor+iDo.swift
//  Extend some functions and others for class UIColor
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension UIColor {

    /// Using RGB literal values to init color
    class func rgb(_ values: CGFloat...) -> UIColor {
        return rgb(values)
    }

    /// Using RGB array values to init color
    class func rgb(_ values: [CGFloat]) -> UIColor {
        let values = values.map({ $0 > 1 ? $0 / 255.0 : $0 })
        let r = values.count >= 1 ? values[0] : 0
        let g = values.count >= 2 ? values[1] : 0
        let b = values.count >= 3 ? values[2] : 0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    /// Using RGBA literal values to init color
    class func rgba(_ values: CGFloat...) -> UIColor {
        return rgba(values)
    }

    /// Using RGBA array values to init color
    class func rgba(_ values: [CGFloat]) -> UIColor {
        let values = values.map({ $0 > 1 ? $0 / 255.0 : $0 })
        let r = values.count >= 1 ? values[0] : 0
        let g = values.count >= 2 ? values[1] : 0
        let b = values.count >= 3 ? values[2] : 0
        let a = values.count >= 4 ? values[3] : 0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// Using hex string to init color
    convenience init?(hex: String) {
        /// Guard and filter
        var value = hex.uppercased()
        value = value.replacingOccurrences(of: "0X", with: "")
        value = value.replacingOccurrences(of: "#", with: "")

        /// Get A,R,G,B
        var a: CGFloat = 255
        var r, g, b: CGFloat
        if let intValue = UInt64(value, radix: 16) {
            if value.count > 6 {
                a = CGFloat((intValue & 0xff000000) >> 24)
            }
            r = CGFloat((intValue & 0xff0000) >> 16)
            g = CGFloat((intValue & 0xff00) >> 8)
            b = CGFloat(intValue & 0xff)
            self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 255.0)
        } else {
            return nil
        }
    }
}
