//
//  Toast.swift
//  It's delicious for alerting
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension Toast {
    enum Duration: RawRepresentable {
        /// 1500 milliseconds
        case short

        /// 2500 milliseconds
        case medium

        /// 5000 milliseconds
        case long

        /// Customize milliseconds
        case other(RawValue)

        public typealias RawValue = Int
        public init?(rawValue: RawValue) {
            switch rawValue {
            case 1500: self = .short
            case 2500: self = .medium
            case 5000: self = .long
            default: self = .other(rawValue)
            }
        }

        /// How many milliseconds
        public var rawValue: Int {
            switch self {
            case .short: return 1000
            case .medium: return 1500
            case .long: return 2500
            case .other(let s): return s
            }
        }
    }

    /// Where the Toast shown
    enum Location {
        case center
        case bottom
    }
}

public class Toast: NSObject {

    /// Singleton instance
    public static let shared = Toast()

    /// The content's view will be rounded
    public var isRounded = false

    /// The containerView
    private var containerView = UIView(frame: UIScreen.main.bounds)
    
    /// The contentView
    private var contentView = UIView()

    /// The text's label
    private var textLabel = UILabel()

    /// Init
    public override init() {
        super.init()
        containerView.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor(red: 54 / 255.0, green: 55 / 255.0, blue: 56 / 255.0, alpha: 1)
        contentView.layer.masksToBounds = true
        contentView.alpha = 0
        
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.textColor = .white
    }
}

public extension Toast {

    /// Show
    ///
    /// @text: The shown text
    /// @location: The text located. default is .center
    /// @duration: How times the text will be shown. default is .short
    func show(_ text: String, from location: Location = .center, duration: Duration = .short) {

        /// Get estimation width of text
        var textWidth = UIScreen.main.bounds.width * 0.35
        if (textWidth - 30) < text.boundingWidth(fontSize: 16) {
            textWidth = UIScreen.main.bounds.width * 0.5
        }

        /// Get estimation height of text
        let textHeight = text.boundingHeight(with: textWidth - 30, fontSize: 16)

        /// Set contentView
        contentView.frame = CGRect(x: 0, y: 0, width: textWidth, height: textHeight + 30)
        contentView.layer.cornerRadius = isRounded ? (textHeight + 30) / 2 : 5
        if location == .center {
            contentView.center = containerView.center
        } else {
            contentView.center.x = containerView.center.x
            contentView.center.y = containerView.frame.height
        }

        /// Set textLabel
        textLabel.frame = CGRect(x: 15, y: 15, width: textWidth - 30, height: textHeight)
        textLabel.text = text

        /// Add subviews
        if contentView.superview == nil {
            containerView.addSubview(contentView)
        }
        if textLabel.superview == nil {
            contentView.addSubview(textLabel)
        }

        /// Animation
        if containerView.superview == nil {
            UIApplication.shared.keyWindow?.addSubview(containerView)
        }
        UIView.animate(withDuration: 0.35) {[unowned self] in
            self.contentView.alpha = 1
            if location == .center {
                self.contentView.center = self.containerView.center
            } else {
                self.contentView.frame.origin.y = self.containerView.frame.height - self.contentView.frame.height - 65
            }
        }
        
        /// After duration later. hide toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(duration.rawValue) / 1000) {[unowned contentView, containerView] in
            UIView.animate(withDuration: 0.35, animations: { [unowned contentView] in
                contentView.alpha = 0
            }) { [unowned containerView] _ in
                containerView.removeFromSuperview()
            }
        }
    }

    /// Show
    ///
    /// @text: The shown text
    /// @location: The text located
    /// @duration: How times the text will be shown
    class func show(_ text: String, from location: Location = .center, duration: Duration = .short) {
        let toast = Toast()
        toast.show(text, from: location, duration: duration)
    }
}
