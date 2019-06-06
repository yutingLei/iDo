//
//  UIView+iDo.swift
//  Extend some functions or others for class UIView
//
//  Created by admin on 2019/6/6.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit


//MARK: - Properties
public extension UIView {
    
    /// Get controller
    var controller: UIViewController? {
        get {
            if next is UIViewController {
                return next as? UIViewController
            }
            return superview?.controller
        }
    }
}

//MARK: - Camera & Album
extension Do where Element: UIView {
    /// Open camera
    public func openCamera(with delegate: IDOMediaImageDelegate?) {
        self.el.openCamera(with: delegate)
    }
    
    /// Open album
    public func openAlbum(with delegate: IDOMediaImageDelegate?) {
        self.el.openAlbum(with: delegate)
    }
}
