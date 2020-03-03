/**************************************************
*
* UIImage+Extension
*
* Extend properties and methods.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

public extension UIImage {

    /// Render image with given color.
    ///
    /// color: The result image's color.
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

    /// Resize image to given size.
    ///
    /// newSize: After resized, the image's size.
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
    ///
    /// scale: The zoom in/out values.
    func scale(to scales: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scales, height: size.height * scales)
        return resize(to: newSize)
    }

    /// Crop image with given rect.
    ///
    /// rect: The crop rect.
    func crop(to rect: CGRect) -> UIImage {
        if let cg = cgImage?.cropping(to: rect) {
            return UIImage(cgImage: cg)
        }
        return self
    }
}
