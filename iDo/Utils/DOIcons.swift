/**************************************************
*
* DOIcons
*
* Some static icons, the size is 15x15.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

public class DOIcons: NSObject {

    /// Defines icon.
    public enum Name: String {
        case check = "do-icon-check"
        case circle = "do-icon-circle"
        case checkCircleFill = "do-icon-check-circle-fill"
        case checkCircleOutline = "do-icon-check-circle-outline"
        case checkBox = "do-icon-check-box"
        case checkBoxOutline = "do-icon-check-box-outline"
        case checkBoxFill = "do-icon-check-box-fill"
    }

    /// Get Icons
    ///
    /// name: The name of icon.
    /// size: The size of image returned. Range in [1 ~ 128], default 15.
    public class func get(_ name: Name, size: CGFloat = 15) -> UIImage {
        let bundle = Bundle(for: DOIcons.self)
        let path = "\(bundle.bundlePath)/DOResource.bundle/\(name.rawValue)"
        return UIImage(contentsOfFile: path)!.resize(to: CGSize(width: size, height: size))
    }
}
