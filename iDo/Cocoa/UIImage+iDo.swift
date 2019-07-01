//
//  UIImage+iDo.swift
//  Extend some functions or others for class UIImage
//
//  Created by admin on 2019/6/17.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension UIImage {

    /// Render image with color
    /// If failure, return self
    func render(with color: UIColor) -> UIImage {
        /// Begin context
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        /// set fill color
        color.setFill()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        /// fill color
        UIRectFill(rect)
        
        /// Draw image
        draw(in: rect, blendMode: .destinationIn, alpha: 1)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }

    /// Resize image with size
    /// If failure, return self
    func resize(to newSize: CGSize) -> UIImage {
        /// Begin context
        UIGraphicsBeginImageContext(newSize)
        
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        
        /// Draw image
        draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }

    /// Scale image
    /// If failure, return self
    func scale(to scales: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scales, height: size.height * scales)
        return resize(to: newSize)
    }
}
