//
//  DatePickerControl.swift
//  An abstract class for DatePicker
//
//  Created by admin on 2019/6/13.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension IDODatePickerControl {
    /// Where the DatePicker's view located
    enum Location {
        case center
        case bottom
    }
    
    /// It's necessary to generate values about date's info
    struct Key: Hashable {
        /// Init with key
        public var key: String
        init(key: String) {
            self.key = key
        }
        
        public static let timeInterval = Key(key: "iDoTimeIntervalKey")
        public static let date = Key(key: "iDoDateKey")
        public static let dateString = Key(key: "iDoDateStringKey")
    }
}

/// An abstract class for DatePicker, please note that don't used it directly,
/// using DatePicker/DateRangePicker instead.
public class IDODatePickerControl: UIView {

    /// Typealise functions
    public typealias SingleSelectedHandler = (([Key: Any]) -> Void)
    public typealias RangeSelectedHandler = (([Key: Any], [Key: Any]) -> Void)

    /// DatePicker's mode(default is .date)
    public var datePickerMode: UIDatePicker.Mode = .date { didSet { setDateMode() } }

    /// Where DatePicker's view located
    public var located: Location = .center { didSet { layoutSubviewOfContent() } }

    /// The date's format string when selected('yyyy-MM-dd')
    public var dateFormat: String = "yyyy-MM-dd" { willSet { dateFormatter.dateFormat = newValue } }

    /// The cancel button's title
    public var cancelTitle: String = "取消"

    /// The submit button's title
    public var submitTitle: String = "确定"

    /// The instance of date format
    var dateFormatter = DateFormatter()

    /// The containerView
    var containerView = UIView()

    /// The contentView
    var contentView = UIView()

    /// The cancel/submit button
    var cancelButton = UIButton()
    var submitButton = UIButton()

    /// Init
    init() {
        super.init(frame: UIScreen.main.bounds)
        dateFormatter.dateFormat = dateFormat
        alpha = 0
        backgroundColor = UIColor.black.withAlphaComponent(0.15)
        addSubview(containerView)

        containerView.backgroundColor = .clear
        containerView.addSubview(contentView)

        contentView.backgroundColor = UIColor.rgb(230, 230, 230)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        cancelButton.setTitleColor(UIColor(hex: "#F56C6C"), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        cancelButton.backgroundColor = .white
        contentView.addSubview(cancelButton)

        submitButton.setTitleColor(UIColor(hex: "#67C23A"), for: .normal)
        submitButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        submitButton.backgroundColor = .white
        contentView.addSubview(submitButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IDODatePickerControl {

    /// Set mode
    @objc func setDateMode() {}

    /// Layout subviews
    @objc func layoutSubviewOfContent() {
        if located == .center {
            if cancelButton.superview != contentView {
                cancelButton.layer.cornerRadius = 0
                cancelButton.layer.masksToBounds = false
                contentView.addSubview(cancelButton)
            }
        } else {
            if cancelButton.superview != containerView {
                cancelButton.layer.cornerRadius = 5
                cancelButton.layer.masksToBounds = true
                containerView.addSubview(cancelButton)
            }
        }
    }

    /// Show DatePicker
    func show() {
        /// Add to window
        if superview == nil {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        
        /// Animations
        UIView.animate(withDuration: 0.35) {[weak self] in
            if let strongSelf = self {
                strongSelf.alpha = 1
                if strongSelf.located == .center {
                    strongSelf.containerView.center = strongSelf.center
                } else {
                    strongSelf.containerView.frame.origin.y = strongSelf.frame.height - strongSelf.containerView.frame.height - 25
                }
            }
        }
    }

    /// Hide datePicker
    @objc func dismiss(_ sender: UIButton) {
        UIView.animate(withDuration: 0.35, animations: {[weak self] in
            if let strongSelf = self {
                strongSelf.alpha = 0
                if strongSelf.located == .bottom {
                    strongSelf.containerView.frame.origin.y = strongSelf.frame.height
                }
            }
        }) {[weak self] _ in
            if let strongSelf = self {
                strongSelf.removeFromSuperview()
            }
        }
    }
}

extension IDODatePickerControl {
    /// Generate date's info
    func datesInformation(of datePicker: UIDatePicker) -> [Key: Any] {
        var dateInfo = [Key: Any]()
        dateInfo[.date] = datePicker.date
        dateInfo[.timeInterval] = datePicker.date.timeIntervalSince1970
        dateInfo[.dateString] = dateFormatter.string(from: datePicker.date)
        return dateInfo
    }
}
