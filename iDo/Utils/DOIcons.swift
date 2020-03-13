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

    /// Get icon typed "check".
    public static let check = DOIcons.icon(name: "do-icon-check")

    /// Get icon by name.
    private class func icon(name: String) -> UIImage? {
        let bundle = Bundle(for: DOIcons.self)
        let path = "\(bundle.bundlePath)/DOResource.bundle/\(name)"
        return UIImage(contentsOfFile: path)!
    }
}
