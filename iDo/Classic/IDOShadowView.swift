//
//  IDOShadowView.swift
//  The view that contains shadow although set clips/masks.
//
//  Created by admin on 2019/7/2.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public class IDOShadowView: UIView {

    /// The shadow color
    public var color: UIColor? {
        get { return UIColor(cgColor: layer.shadowColor ?? UIColor.black.cgColor) }
        set { layer.shadowColor = newValue?.cgColor }
    }

    /// The shadow offset
    public var offset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }

    /// The shadow radius
    public var radius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }

    /// The shadow opacity
    public var opacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }

    /// The shadow path
    public var path: CGPath? {
        get { return layer.shadowPath }
        set { layer.shadowPath = newValue }
    }

    /// The shadow bezier path
    public var bezierPath: UIBezierPath? {
        willSet { layer.shadowPath = newValue?.cgPath }
    }

    /// The shadow effective view.
    private(set) public var contentView: UIView!

    /// Init
    public init(frame: CGRect, contentView: UIView) {
        super.init(frame: frame)

        /// Make background color clear.
        backgroundColor = .clear

        /// Set shadow options
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 1.5)

        /// Init shadow effective view
        self.contentView = contentView
        addSubview(contentView)

        /// Make constrains of effectiveView
        contentView.filled()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
