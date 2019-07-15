//
//  UIViewController+iDo.swift
//  Extend some functions or others for class UIViewController
//
//  Created by admin on 2019/6/6.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

//MARK: - Camera & Album
public typealias IDOMediaImageDelegate = (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
public extension UIViewController {
    /// Open camera
    func openCamera(with delegate: IDOMediaImageDelegate?) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = delegate
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("The camera isn't availabel, please check settings.")
        }
    }
    
    /// Open album
    func openAlbum(with delegate: IDOMediaImageDelegate?) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = delegate
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("The photo library isn't availabel, please check settings.")
        }
    }
}

//MARK: - Alert
public typealias IDOAlertActionHandler = ((UIAlertAction) -> Void)
public extension UIViewController {
    /// Alert
    ///
    /// @title: The title
    /// @message: The message
    /// @options: The titles for other actions but exclude 'Cancel'
    func alert(with title: String? = nil,
               message: String?,
               options: [String]? = nil,
               handleAction: IDOAlertActionHandler? = nil)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        /// Cancel
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: handleAction)
        alertController.addAction(cancel)

        /// Other options
        if let options = options {
            for option in options {
                let action = UIAlertAction(title: option, style: .default, handler: handleAction)
                alertController.addAction(action)
            }
        }

        present(alertController, animated: true, completion: nil)
    }

    /// Action Sheet
    ///
    /// @title: The title
    /// @message: The message
    /// @options: The titles for other actions but exclude 'Cancel'
    func actionSheet(with title: String? = nil,
                     message: String? = nil,
                     options: [String]? = nil,
                     handleAction: IDOAlertActionHandler? = nil)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        /// Cancel
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: handleAction)
        alertController.addAction(cancel)
        
        /// Other options
        if let options = options {
            for option in options {
                let action = UIAlertAction(title: option, style: .default, handler: handleAction)
                alertController.addAction(action)
            }
        }

        present(alertController, animated: true, completion: nil)
    }
}
