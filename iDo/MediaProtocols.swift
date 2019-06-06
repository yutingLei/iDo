//
//  MediaProtocols.swift
//  Declare some of the protocols that we used later
//
//  Created by admin on 2019/6/6.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit



//MARK: - Media
public typealias IDOMediaImageDelegate = (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
public protocol IDOMediaImageProtocol {
    
    /// Whose presenting UIImagePickerController
    associatedtype Presentor
    
    /// Open system's camera
    func openCamera(with delegate: IDOMediaImageDelegate?)
    
    /// Open system's album
    func openAlbum(with delegate: IDOMediaImageDelegate?)
    
    /// The presentor that will present UIImagePickerController
    var media: Do<Presentor> { get set }
}

extension IDOMediaImageProtocol {
    
    /// Convenience function that can open system's camera
    ///
    /// - delegate: Which object or instance that agreement this protocol
    /// - return: An instance of UIImagePickerController
    public func openCamera(with delegate: IDOMediaImageDelegate?) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = delegate
            imagePicker.sourceType = .camera
            if media.el is UIView {
                (media.el as? UIView)?.controller?.present(imagePicker, animated: true, completion: nil)
            }
            if media.el is UIViewController {
                (media.el as? UIViewController)?.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("The camera isn't availabel, please check settings.")
        }
    }
    
    /// Convenience function that can open system's album
    ///
    /// - delegate: Which object or instance that agreement this protocol
    /// - return: An instance of UIImagePickerController
    public func openAlbum(with delegate: IDOMediaImageDelegate?) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = delegate
            imagePicker.sourceType = .photoLibrary
            if media.el is UIView {
                (media.el as? UIView)?.controller?.present(imagePicker, animated: true, completion: nil)
            }
            if media.el is UIViewController {
                (media.el as? UIViewController)?.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("The photo library isn't availabel, please check settings.")
        }
    }
    
    /// IDOMediaImage extensions
    public var media: Do<Self> {
        get {
            return Do(self)
        }
        set {
            // swiftlint:disable:next unused_setter_value
        }
    }
}

extension UIView: IDOMediaImageProtocol {}
extension UIViewController: IDOMediaImageProtocol {}
