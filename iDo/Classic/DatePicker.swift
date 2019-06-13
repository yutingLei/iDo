//
//  DatePicker.swift
//  Select a date in picker view
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension DatePicker {
    /// Where the pickerView located at
    enum Location {
        case center
        case bottom
    }

    /// Keys
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

public class DatePicker: NSObject {

    /// Typealise handler when selected
    public typealias SelectedHandler = (([Key: Any]) -> Void)

    /// Singleton instance
    public static let shared = DatePicker()

    /// The datePicker's mode
    public var dateMode: UIDatePicker.Mode! { didSet { picker.datePickerMode = dateMode } }

    /// Located at
    public var located: Location = .center { didSet { layoutSubviews() } }

    /// The date's format
    public var dateFormat: String = "yyyy-MM-dd"

    /// The cancel button's title
    public var cancelTitle: String = "取消"

    /// The submit button's title
    public var submitTitle: String = "确定"

    /// The title
    public var title: String = "请选择日期"

    /// The min date
    public var minDate: Date? { willSet { picker.minimumDate = newValue } }

    /// The max date
    public var maxDate: Date? { willSet { picker.minimumDate = newValue } }

    /// The picker's view
    private var picker = UIDatePicker()

    /// The backgroundView
    private var backgroundView = UIView(frame: UIScreen.main.bounds)

    /// The containerView
    private var containerView = UIView()

    /// The contentView
    private var contentView = UIView()

    /// The title label
    private var titleLabel = UILabel()

    /// The cancel/submit button
    private var cancelButton = UIButton()
    private var submitButton = UIButton()

    /// The selected handler
    private var selectedHandler: SelectedHandler?

    /// Init with mode
    public init(mode: UIDatePicker.Mode = .date) {
        super.init()
        self.dateMode = mode
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        backgroundView.alpha = 0

        containerView.backgroundColor = .clear
        backgroundView.addSubview(containerView)

        contentView.backgroundColor = UIColor.rgb(230, 230, 230)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        containerView.addSubview(contentView)

        picker.datePickerMode = mode
        picker.locale = Locale(identifier: "zh")
        picker.backgroundColor = .white
        contentView.addSubview(picker)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.backgroundColor = .white
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.rgb(54, 55, 56)
        contentView.addSubview(titleLabel)

        cancelButton.setTitleColor(UIColor(hex: "#F56C6C"), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        cancelButton.backgroundColor = .white
        contentView.addSubview(cancelButton)

        submitButton.setTitleColor(UIColor(hex: "#67C23A"), for: .normal)
        submitButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        submitButton.backgroundColor = .white
        contentView.addSubview(submitButton)
        layoutSubviews()
    }
}

public extension DatePicker {

    /// Show with selected handler
    func show(with selectedHandler: SelectedHandler?) {

        /// Set titles
        titleLabel.text = title
        cancelButton.setTitle(cancelTitle, for: .normal)
        submitButton.setTitle(submitTitle, for: .normal)

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

        /// Saved handler
        self.selectedHandler = selectedHandler
    }

    /// Show with selected handler
    class func show(with selectedHandler: SelectedHandler?) {
        let datePicker = DatePicker()
        datePicker.show(with: selectedHandler)
    }
}

private extension DatePicker {

    /// Layout subviews
    func layoutSubviews() {
        if located == .center {
            let minWidth = max(UIScreen.main.bounds.width, 250)
            containerView.frame = CGRect(x: 0, y: 0, width: minWidth, height: 290)
            containerView.center = backgroundView.center

            contentView.frame = containerView.bounds

            titleLabel.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 40)
            picker.frame = CGRect(x: 0, y: 40, width: contentView.frame.width, height: 200)
            cancelButton.frame = CGRect(x: 0, y: 241, width: contentView.frame.width / 2, height: 50)
            submitButton.frame = CGRect(x: contentView.frame.width / 2 + 1, y: 241, width: contentView.frame.width / 2, height: 50)

            if cancelButton.superview != contentView {
                cancelButton.layer.cornerRadius = 0
                cancelButton.layer.masksToBounds = false
                contentView.addSubview(cancelButton)
            }
        } else {
            containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.9, height: 340)
            containerView.center.x = backgroundView.center.x
            containerView.frame.origin.y = backgroundView.frame.height

            contentView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 285)

            titleLabel.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 40)
            picker.frame = CGRect(x: 0, y: 40, width: contentView.frame.width, height: 200)

            submitButton.frame = CGRect(x: 0, y: 241, width: contentView.frame.width, height: 45)
            cancelButton.frame = CGRect(x: 0, y: 296, width: contentView.frame.width, height: 45)
            if cancelButton.superview != containerView {
                cancelButton.layer.cornerRadius = 5
                cancelButton.layer.masksToBounds = true
                containerView.addSubview(cancelButton)
            }
        }
    }

    /// Dismiss datePicker
    @objc func dismiss(_ sender: UIButton) {
        if sender == submitButton {
            let timeInterval = picker.date.timeIntervalSince1970
            let date = picker.date
            let dateString: String = {
                let formatter = DateFormatter()
                formatter.dateFormat = dateFormat
                return formatter.string(from: picker.date)
            }()
            selectedHandler?([.timeInterval: timeInterval, .date: date, .dateString: dateString])
        }

        /// Hide datePicker
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
