//
//  UIView+iDo.swift
//  Extend some functions or others for class UIView
//
//  Created by admin on 2019/6/6.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit


//MARK: - Convenience Properties
public extension UIView {

    /// Get controller
    var controller: UIViewController? {
        get {
            if next is UIViewController {
                return next as? UIViewController
            }
            if next is UIView {
                return (next as? UIView)?.controller
            }
            return nil
        }
    }

    /// Set corner radius
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    /// Set border color
    var borderColor: UIColor? {
        get { return layer.borderColor == nil ? nil : UIColor(cgColor: layer.borderColor!) }
        set {
            layer.borderColor = newValue?.cgColor
            layer.borderWidth = newValue == nil ? 0 : 1
        }
    }
}

//MARK: - Constraints
public extension UIView {

    /// Filled self to it's superview
    func filled() {
        assert(superview != nil, "It doesn't added to a view.")
        top(to: superview!)
        leading(to: superview!)
        trailing(to: superview!)
        bottom(to: superview!)
    }

    /// Filled self to it's superview with some conditions
    /// top: distance to top
    /// leading: distance to left.
    /// trailing: distance to right
    /// bottom: distance to bottom
    func filled(but topD: CGFloat = 0, leadingD: CGFloat = 0, trailingD: CGFloat = 0, bottomD: CGFloat = 0) {
        assert(superview != nil, "It doesn't added to a view.")
        top(to: superview!, constant: topD)
        leading(to: superview!, constant: leadingD)
        trailing(to: superview!, constant: -trailingD)
        bottom(to: superview!, constant: -bottomD)
    }

    /// Top constraint
    ///
    /// @aView: A reference view used to constraint
    /// @constant: The value of constraint, default is 0
    func top(to aView: UIView, constant: CGFloat = 0) {
        assert(superview != nil, "It doesn't added to a view.")
        translatesAutoresizingMaskIntoConstraints = false
        if aView == superview {
            topAnchor.constraint(equalTo: aView.topAnchor, constant: constant).isActive = true
        } else {
            topAnchor.constraint(equalTo: aView.bottomAnchor, constant: constant).isActive = true
        }
    }

    /// Leading/Left constraint
    ///
    /// @aView: A reference view that use to constraint
    /// @constant: The value of constraint, default is 0
    func leading(to aView: UIView, constant: CGFloat = 0) {
        assert(superview != nil, "It doesn't added to a view.")
        translatesAutoresizingMaskIntoConstraints = false
        if aView == superview {
            leadingAnchor.constraint(equalTo: aView.leadingAnchor, constant: constant).isActive = true
        } else {
            leadingAnchor.constraint(equalTo: aView.trailingAnchor, constant: constant).isActive = true
        }
    }

    /// Bottom constraint
    ///
    /// @aView: A reference view that use to constraint
    /// @constant: The value of constraint, default is 0
    func bottom(to aView: UIView, constant: CGFloat = 0) {
        assert(superview != nil, "It doesn't added to a view.")
        translatesAutoresizingMaskIntoConstraints = false
        if aView == superview {
            bottomAnchor.constraint(equalTo: aView.bottomAnchor, constant: constant).isActive = true
        } else {
            bottomAnchor.constraint(equalTo: aView.topAnchor, constant: constant).isActive = true
        }
    }

    /// Trailing/Right constraint
    ///
    /// @aView: A reference view that use to constraint
    /// @constant: The value of constraint, default is 0
    func trailing(to aView: UIView, constant: CGFloat = 0) {
        assert(superview != nil, "It doesn't added to a view.")
        translatesAutoresizingMaskIntoConstraints = false
        if aView == superview {
            trailingAnchor.constraint(equalTo: aView.trailingAnchor, constant: constant).isActive = true
        } else {
            trailingAnchor.constraint(equalTo: aView.leadingAnchor, constant: constant).isActive = true
        }
    }

    /// Width constraint
    ///
    /// @aView: A reference view that use to constraint, default is nil.
    /// @constant: The value of constraint, default is 0.
    func width(equalTo aView: UIView? = nil, multiplier: CGFloat = 1, constant: CGFloat) {
        assert(superview != nil, "It doesn't added to a view.")
        translatesAutoresizingMaskIntoConstraints = false
        if let aView = aView {
            widthAnchor.constraint(equalTo: aView.widthAnchor, multiplier: multiplier, constant: constant).isActive = true
        } else {
            widthAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }

    /// Height constraint
    ///
    /// @aView: A reference view that use to constraint, default is nil.
    /// @constant: The value of constraint, default is 0.
    func height(equalTo aView: UIView? = nil, multiplier: CGFloat = 1, constant: CGFloat) {
        assert(superview != nil, "It doesn't added to a view.")
        translatesAutoresizingMaskIntoConstraints = false
        if let aView = aView {
            heightAnchor.constraint(equalTo: aView.heightAnchor, multiplier: multiplier, constant: constant).isActive = true
        } else {
            heightAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }

    /// Centered axis of X.
    ///
    /// @aView: A reference view that use to constraint, default is nil.
    /// @constant: The value of constraint, default is 0.
    func centerX(to aView: UIView, constant: CGFloat = 0) {
        assert(superview != nil, "It doesn't added to a view.")
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: aView.centerXAnchor, constant: constant).isActive = true
    }

    /// Centered axis of Y
    ///
    /// @aView: A reference view that use to constraint, default is nil.
    /// @constant: The value of constraint, default is 0.
    func centerY(to aView: UIView, constant: CGFloat = 0) {
        assert(superview != nil, "It doesn't added to a view.")
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: aView.centerYAnchor, constant: constant).isActive = true
    }
}

//MARK: - Camera & Album
public extension UIView {
    /// Open camera
    func openCamera(with delegate: IDOMediaImageDelegate?) {
        controller?.openCamera(with: delegate)
    }
    
    /// Open album
    func openAlbum(with delegate: IDOMediaImageDelegate?) {
        controller?.openAlbum(with: delegate)
    }
}

//MARK: - Alert
public extension UIView {
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
        controller?.alert(with: title, message: message, options: options, handleAction: handleAction)
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
        controller?.actionSheet(with: title, message: message, options: options, handleAction: handleAction)
    }
}
