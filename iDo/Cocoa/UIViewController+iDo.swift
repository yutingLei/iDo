//
//  UIViewController+iDo.swift
//  Extend some functions or others for class UIViewController
//
//  Created by admin on 2019/6/6.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

//MARK: - Camera & Album
extension Do where Element: UIViewController {
    /// Open camera
    public func openCamera(with delegate: IDOMediaImageDelegate?) {
        self.el.openCamera(with: delegate)
    }
    
    /// Open album
    public func openAlbum(with delegate: IDOMediaImageDelegate?) {
        self.el.openAlbum(with: delegate)
    }
}
