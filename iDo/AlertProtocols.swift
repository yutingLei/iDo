//
//  AlertProtocols.swift
//  Declare some of protocols that used for alerting & actionSheeting
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public typealias IDOAlertActionHandler = ((UIAlertAction) -> Void)
public protocol IDOAlertProtocol {
    /// Whose presenting UIAlertController
    associatedtype Presentor

    /// Alert
    func alert(with title: String?, message: String?, options: [String]?, handleAction: IDOAlertActionHandler?)

    /// ActionSheet
    func actionSheet(with title: String?, message: String?, options: [String]?, handleAction: IDOAlertActionHandler?)

    /// Presentor
    var presentor: Do<Presentor> { get }
}

extension IDOAlertProtocol {
    /// Alert
    ///
    /// @title: The title
    /// @message: The message
    /// @options: The titles for other actions but exclude 'Cancel'
    public func alert(with title: String?, message: String?, options: [String]?, handleAction: IDOAlertActionHandler?) {
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

        if presentor.el is UIView {
            (presentor.el as? UIView)?.controller?.present(alertController, animated: true, completion: nil)
        }

        if presentor.el is UIViewController {
            (presentor.el as? UIViewController)?.present(alertController, animated: true, completion: nil)
        }
    }

    /// Action Sheet
    ///
    /// @title: The title
    /// @message: The message
    /// @options: The titles for other actions but exclude 'Cancel'
    public func actionSheet(with title: String?, message: String?, options: [String]?, handleAction: IDOAlertActionHandler?) {
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

        if presentor.el is UIView {
            (presentor.el as? UIView)?.controller?.present(alertController, animated: true, completion: nil)
        }

        if presentor.el is UIViewController {
            (presentor.el as? UIViewController)?.present(alertController, animated: true, completion: nil)
        }
    }

    /// Presentor
    public var presentor: Do<Self> {
        get { return Do(self) }
    }
}

extension UIView: IDOAlertProtocol {}
extension UIViewController: IDOAlertProtocol {}
