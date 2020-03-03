/**************************************************
*
* UIViewController+Extension
*
* Extend properties and methods.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

//MARK: - Camera & Album
public typealias IDOMediaImageDelegate = (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
public extension UIViewController {

    /// A convenience method to open camera.
    ///
    /// target: The object whose imp IDOMediaImageDelegate
    func openCamera(in target: IDOMediaImageDelegate?) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = target
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("The camera isn't availabel, please check settings.")
        }
    }
    
    /// A convenience method to open album.
    ///
    /// target: The object whose imp IDOMediaImageDelegate
    func openAlbum(in target: IDOMediaImageDelegate?) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = target
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
    /// title: The title
    /// message: The message
    /// options: The titles for other actions but except 'Cancel'
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
    /// title: The title
    /// message: The message
    /// options: The titles for other actions but except 'Cancel'
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
