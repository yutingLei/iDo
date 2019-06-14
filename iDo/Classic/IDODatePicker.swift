//
//  DatePicker.swift
//  Select a date in picker view
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public class IDODatePicker: IDODatePickerControl {

    /// Singleton instance
    public static let shared = IDODatePicker()

    /// The title
    public var title: String = "请选择日期"

    /// The min date
    public var minDate: Date? { willSet { picker.minimumDate = newValue } }

    /// The max date
    public var maxDate: Date? { willSet { picker.minimumDate = newValue } }

    /// The picker's view
    private var picker = UIDatePicker()

    /// The title label
    private var titleLabel = UILabel()

    /// The selected handler
    private var selectedHandler: SingleSelectedHandler?

    /// Init with mode
    public init(mode: UIDatePicker.Mode = .date) {
        super.init()
        self.datePickerMode = mode

        picker.datePickerMode = mode
        picker.locale = Locale(identifier: "zh")
        picker.backgroundColor = .white
        contentView.addSubview(picker)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.backgroundColor = .white
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.rgb(54, 55, 56)
        contentView.addSubview(titleLabel)
        layoutSubviewOfContent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension IDODatePicker {

    /// Show with selected handler
    func show(with selectedHandler: SingleSelectedHandler?) {

        /// Set titles
        titleLabel.text = title
        cancelButton.setTitle(cancelTitle, for: .normal)
        submitButton.setTitle(submitTitle, for: .normal)

        /// Saved handler
        self.selectedHandler = selectedHandler
        super.show()
    }

    /// Show with selected handler
    class func show(with selectedHandler: SingleSelectedHandler?) {
        let datePicker = IDODatePicker()
        datePicker.show(with: selectedHandler)
    }
}

extension IDODatePicker {

    /// Set date mode
    override func setDateMode() {
        picker.datePickerMode = datePickerMode
    }

    /// Layout subviews
    override func layoutSubviewOfContent() {
        super.layoutSubviewOfContent()
        if located == .center {
            let minWidth = max(UIScreen.main.bounds.width * 0.7, 280)
            containerView.frame = CGRect(x: 0, y: 0, width: minWidth, height: 290)
            containerView.center = center

            contentView.frame = containerView.bounds

            titleLabel.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 40)
            picker.frame = CGRect(x: 0, y: 40, width: contentView.frame.width, height: 200)
            cancelButton.frame = CGRect(x: 0, y: 241, width: contentView.frame.width / 2, height: 50)
            submitButton.frame = CGRect(x: contentView.frame.width / 2 + 1, y: 241, width: contentView.frame.width / 2, height: 50)
        } else {
            containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.9, height: 340)
            containerView.center.x = center.x
            containerView.frame.origin.y = frame.height

            contentView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 285)

            titleLabel.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 40)
            picker.frame = CGRect(x: 0, y: 40, width: contentView.frame.width, height: 200)

            submitButton.frame = CGRect(x: 0, y: 241, width: contentView.frame.width, height: 45)
            cancelButton.frame = CGRect(x: 0, y: 296, width: contentView.frame.width, height: 45)
        }
    }

    /// Dismiss datePicker
    @objc override func dismiss(_ sender: UIButton) {
        if sender == submitButton {
            selectedHandler?(datesInformation(of: picker))
        }

        /// Hide datePicker
        super.dismiss(sender)
    }
}
