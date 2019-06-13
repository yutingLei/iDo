//
//  DatePickerControl.swift
//  An abstract class for DatePicker
//
//  Created by admin on 2019/6/13.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension DatePickerControl {
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
public class DatePickerControl: NSObject {

    /// Typealise functions
    public typealias SignleSelectedHandler = (([Key: Any]) -> Void)
    public typealias RangeSelectedHandler = (([Key: Any], [Key: Any]) -> Void)

    /// DatePicker's mode(default is .date)
    public var datePickerMode: UIDatePicker.Mode = .date

    /// Where DatePicker's view located
    public var located: Location = .center

    /// The date's format string when selected('yyyy-MM-dd')
    public var dateFormat: String = "yyyy-MM-dd" { willSet { dateFormatter.dateFormat = newValue } }

    /// The cancel button's title
    public var cancelTitle: String = "取消"

    /// The submit button's title
    public var submitTitle: String = "确定"

    /// The instance of date format
    var dateFormatter = DateFormatter()

    /// The backgroundView
    var backgroundView = UIView()

    /// The containerView
    var containerView = UIView()

    /// The contentView
    var contentView = UIView()

    /// The cancel/submit button
    var cancelButton = UIButton()
    var submitButton = UIButton()

    /// Init
    override init() {
        super.init()
        dateFormatter.dateFormat = dateFormat
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        backgroundView.alpha = 0
        
        containerView.backgroundColor = .clear
        backgroundView.addSubview(containerView)
        
        contentView.backgroundColor = UIColor.rgb(230, 230, 230)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        containerView.addSubview(contentView)
        
        cancelButton.setTitleColor(UIColor(hex: "#F56C6C"), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        cancelButton.backgroundColor = .white
        contentView.addSubview(cancelButton)
        
        submitButton.setTitleColor(UIColor(hex: "#67C23A"), for: .normal)
        submitButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        submitButton.backgroundColor = .white
        contentView.addSubview(submitButton)
    }
}

extension DatePickerControl {
    /// Show DatePicker
    func show() {
        /// Add to window
        if backgroundView.superview == nil {
            UIApplication.shared.keyWindow?.addSubview(backgroundView)
        }
        
        /// Animations
        UIView.animate(withDuration: 0.35) {[unowned self] in
            self.backgroundView.alpha = 1
            if self.located == .center {
                self.containerView.center = self.backgroundView.center
            } else {
                self.containerView.frame.origin.y = self.backgroundView.frame.height - self.containerView.frame.height - 25
            }
        }
    }

    /// Hide datePicker
    @objc func dismiss(_ sender: UIButton) {
        UIView.animate(withDuration: 0.35, animations: {[unowned self] in
            self.backgroundView.alpha = 0
            if self.located == .bottom {
                self.containerView.frame.origin.y = self.backgroundView.frame.height
            }
        }) {[unowned self] _ in
            self.backgroundView.removeFromSuperview()
        }
    }
}

extension DatePickerControl {
    /// Generate date's info
    func datesInformation(of datePicker: UIDatePicker) -> [Key: Any] {
        var dateInfo = [Key: Any]()
        dateInfo[.date] = datePicker.date
        dateInfo[.timeInterval] = datePicker.date.timeIntervalSince1970
        dateInfo[.dateString] = dateFormatter.string(from: datePicker.date)
        return dateInfo
    }
}
