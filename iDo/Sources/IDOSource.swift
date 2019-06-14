//
//  IDOSource.swift
//  Manage resource of IDOFramework
//
//  Created by admin on 2019/6/14.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension IDOSource {
    /// Icon images
    enum Icon: String {
        case download       = "ido-icon-download.png"

        /// Get all available icons
        public static let all: [Icon] = [.download]
    }
}

public class IDOSource: NSObject {

    /// The source bundle
    public static let bundle = Bundle(for: IDOSource.self)

    /// Get icon image
    /// The size of icon is 120x120
    public class func getIcon(_ icon: Icon) -> UIImage? {

        /// Get icon's path
        let iconPath = bundle.bundlePath + "/IDOSource.bundle/\(icon.rawValue)"

        /// Is image exist?
        if FileManager.default.fileExists(atPath: iconPath) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: iconPath))
                return UIImage(data: data)
            } catch {
                print("IDOSource Error: \(error.localizedDescription)")
            }
        }

        return nil
    }
}
