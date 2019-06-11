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

//MARK: - Alert
extension Do where Element: UIViewController {
    /// Alert
    ///
    /// @title: The title
    /// @message: The message
    /// @options: The titles for other actions but exclude 'Cancel'
    public func alert(with title: String? = nil,
                      message: String?,
                      options: [String]? = nil,
                      handleAction: IDOAlertActionHandler? = nil)
    {
        self.el.alert(with: title, message: message, options: options, handleAction: handleAction)
    }

    /// Action Sheet
    ///
    /// @title: The title
    /// @message: The message
    /// @options: The titles for other actions but exclude 'Cancel'
    public func actionSheet(with title: String? = nil,
                            message: String? = nil,
                            options: [String]? = nil,
                            handleAction: IDOAlertActionHandler? = nil)
    {
        self.el.actionSheet(with: title, message: message, options: options, handleAction: handleAction)
    }
}
