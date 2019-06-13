//
//  DateRangePicker.swift
//  Select date range
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension DateRangePicker {
    enum Shortcut: String {
        /// Today, from 00:00:00 to now
        case today          = "今天"
        /// Yestoday, from 00:00:00 to 23:59:59
        case yestoday       = "昨天"
        /// Three days, from 3-days ago to now
        case threeDays      = "三天"
        /// This week, from monday to now
        case thisWeek       = "本周"
        /// A week, from 7-days ago to now
        case week           = "一周"
        /// This month, from the first day of month to now
        case thisMonth      = "本月"
        /// A month, from 30/31/29/28 days ago to now
        case month          = "一个月"
        /// This quarter, from the first day of quarter to now
        case thisQuarter    = "本季度"
        /// A quarter, from 3-months ago to now
        case quarter        = "一季度"
        /// This year, from the first day of year to now
        case thisYear       = "今年"
        /// Last year, from the first day of year to end of year
        case lastYear       = "去年"
        /// A year, from 1-year ago to now
        case year           = "一年"

        /// All shortcuts
        public static let all: [Shortcut] = [.today, .yestoday, .threeDays, .thisWeek,
                                             .week, .thisMonth, .month, .thisQuarter,
                                             .quarter, .thisYear, .lastYear, .year]
    }
}

public class DateRangePicker: NSObject {
    /// Typealise handler when selected
    public typealias SelectedHandler = (([DatePicker.Key: Any], [DatePicker.Key: Any]) -> Void)

    /// Singleton instance
    public static let shared = DateRangePicker()

    /// The datePicker's mode
    public var dateMode: UIDatePicker.Mode! { didSet { setDateMode() } }

    /// The shortcuts
    public var shortcuts: [Shortcut]? { didSet { setShortcuts() } }

    /// Located at
    public var located: DatePicker.Location = .center { didSet { layoutSubviews() } }

    /// The date's format
    public var dateFormat: String = "yyyy-MM-dd"

    /// The cancel button's title
    public var cancelTitle: String = "取消"

    /// The submit button's title
    public var submitTitle: String = "确定"

    /// The title
    public var beginTitle: String = "请选择起始日期"
    public var endTitle: String = "请选择截止日期"

    /// The min date
    public var minBeginDate: Date? { willSet { beginPicker.minimumDate = newValue } }

    /// The max date
    public var maxEndDate: Date? { willSet { endPicker.minimumDate = newValue } }

    /// The picker's view
    private var beginPicker = UIDatePicker()
    private var endPicker = UIDatePicker()

    /// The backgroundView
    private var backgroundView = UIView(frame: UIScreen.main.bounds)

    /// The containerView
    private var containerView = UIView()

    /// The contentView
    private var contentView = UIView()

    /// The title label
    private var beginTitleLabel = UILabel()
    private var endTitleLabel = UILabel()

    /// The cancel/submit button
    private var cancelButton = UIButton()
    private var submitButton = UIButton()

    /// The backgroundView of shortcuts
    private lazy var shortcutsContainer = UIScrollView()

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

        beginPicker.datePickerMode = mode
        beginPicker.locale = Locale(identifier: "zh")
        beginPicker.backgroundColor = .white
        contentView.addSubview(beginPicker)
        
        endPicker.datePickerMode = mode
        endPicker.locale = Locale(identifier: "zh")
        endPicker.backgroundColor = .white
        contentView.addSubview(endPicker)

        beginTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        beginTitleLabel.backgroundColor = .white
        beginTitleLabel.textAlignment = .center
        beginTitleLabel.textColor = UIColor.rgb(54, 55, 56)
        contentView.addSubview(beginTitleLabel)
        
        endTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        endTitleLabel.backgroundColor = .white
        endTitleLabel.textAlignment = .center
        endTitleLabel.textColor = UIColor.rgb(54, 55, 56)
        contentView.addSubview(endTitleLabel)

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

public extension DateRangePicker {

    /// Show with selected handler
    func show(with selectedHandler: SelectedHandler?) {

        /// Set titles
        beginTitleLabel.text = beginTitle
        endTitleLabel.text = endTitle
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
        let datePicker = DateRangePicker()
        datePicker.show(with: selectedHandler)
    }

    /// Set title for shortcut
    func setTitle(_ title: String, for shortcut: Shortcut) {
        if let shortcutBtn = shortcutsContainer.viewWithTag(shortcut.rawValue.hash) as? UIButton {
            shortcutBtn.setTitle(title, for: .normal)
        }
    }
}

//MARK: - Settings
private extension DateRangePicker {

    /// Set date's mode
    func setDateMode() {
        beginPicker.datePickerMode = dateMode
        endPicker.datePickerMode = dateMode
    }

    /// Set shortcuts
    func setShortcuts() {
        _ = shortcutsContainer.subviews.map({ $0.removeFromSuperview() })

        var offsetY: CGFloat = 0
        for shortcut in shortcuts! {
            let shortcutBtn = UIButton(frame: CGRect(x: 0, y: offsetY, width: 65, height: 40))
            shortcutBtn.addTarget(self, action: #selector(onShortcut), for: .touchUpInside)
            shortcutBtn.setTitleColor(UIColor.rgb(64, 128, 255), for: .selected)
            shortcutBtn.setTitleColor(.darkText, for: .normal)
            shortcutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            shortcutBtn.setTitle(shortcut.rawValue, for: .normal)
            shortcutBtn.tag = shortcut.rawValue.hash
            shortcutsContainer.addSubview(shortcutBtn)
            offsetY += 46
        }
        shortcutsContainer.backgroundColor = .white
        shortcutsContainer.contentSize = CGSize(width: 0, height: offsetY)
        contentView.addSubview(shortcutsContainer)

        if shortcuts != nil {
            layoutSubviews()
        } else {
            shortcutsContainer.removeFromSuperview()
        }
    }
}

private extension DateRangePicker {

    /// Estimation width
    func estimationWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        var widthScale: CGFloat = shortcuts != nil ? 0.9 : 0.7
        if screenWidth == 320 {
            widthScale += 0.05
        }
        return screenWidth * widthScale
    }

    /// Layout subviews
    func layoutSubviews() {
        let contentWidth = estimationWidth()
        if located == .center {
            containerView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: 530)
            containerView.center = backgroundView.center

            contentView.frame = containerView.bounds
            let x: CGFloat = shortcuts != nil ? 66 : 0
            if shortcuts != nil {
                shortcutsContainer.frame = CGRect(x: 0, y: 0, width: 65, height: 480)
            }

            beginTitleLabel.frame = CGRect(x: x, y: 0, width: contentView.frame.width - x, height: 40)
            beginPicker.frame = CGRect(x: x, y: 40, width: contentView.frame.width - x, height: 200)
            endTitleLabel.frame = CGRect(x: x, y: 241, width: contentView.frame.width - x, height: 40)
            endPicker.frame = CGRect(x: x, y: 280, width: contentView.frame.width - x, height: 200)
            cancelButton.frame = CGRect(x: 0, y: 481, width: contentView.frame.width / 2, height: 50)
            submitButton.frame = CGRect(x: contentView.frame.width / 2 + 1, y: 481, width: contentView.frame.width / 2, height: 50)
            if cancelButton.superview != contentView {
                cancelButton.layer.cornerRadius = 0
                cancelButton.layer.masksToBounds = false
                contentView.addSubview(cancelButton)
            }
        } else {
            containerView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: 500)
            containerView.center.x = backgroundView.center.x
            containerView.frame.origin.y = backgroundView.frame.height

            contentView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 445)
            let x: CGFloat = shortcuts != nil ? 66 : 0
            if shortcuts != nil {
                shortcutsContainer.frame = CGRect(x: 0, y: 0, width: 65, height: 401)
            }

            beginTitleLabel.frame = CGRect(x: x, y: 0, width: contentView.frame.width - x, height: 40)
            beginPicker.frame = CGRect(x: x, y: 40, width: contentView.frame.width - x, height: 160)
            endTitleLabel.frame = CGRect(x: x, y: 201, width: contentView.frame.width - x, height: 40)
            endPicker.frame = CGRect(x: x, y: 241, width: contentView.frame.width - x, height: 160)
            submitButton.frame = CGRect(x: 0, y: 402, width: contentView.frame.width, height: 45)
            
            cancelButton.frame = CGRect(x: 0, y: 455, width: contentView.frame.width, height: 45)
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
            var beginDateInfo = [DatePicker.Key: Any]()
            beginDateInfo[.date] = beginPicker.date
            beginDateInfo[.dateString] = {
                let formatter = DateFormatter()
                formatter.dateFormat = dateFormat
                return formatter.string(from: beginPicker.date)
            }()
            beginDateInfo[.timeInterval] = beginPicker.date.timeIntervalSince1970

            var endDateInfo = [DatePicker.Key: Any]()
            endDateInfo[.date] = endPicker.date
            endDateInfo[.dateString] = {
                let formatter = DateFormatter()
                formatter.dateFormat = dateFormat
                return formatter.string(from: endPicker.date)
            }()
            endDateInfo[.timeInterval] = endPicker.date.timeIntervalSince1970
            selectedHandler?(beginDateInfo, endDateInfo)
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

//MARK: - Calculate date
private extension DateRangePicker {
    /// Selected shortcut
    @objc func onShortcut(_ sender: UIButton) {
        for view in shortcutsContainer.subviews {
            if view is UIButton {
                (view as? UIButton)?.isSelected = sender == view
            }
        }
        setDatePicker(with: sender.tag)
    }

    /// Set date picker when selected shortcut
    func setDatePicker(with viewsTag: Int) {

        /// current calendar
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        calendar.firstWeekday = 2

        /// current date component
        var dateComponent = calendar.dateComponents(in: calendar.timeZone, from: Date())

        /// Begin of day, 00:00:00
        func beginOfDay() -> Date {
            dateComponent.hour = 0
            dateComponent.minute = 0
            dateComponent.second = 0
            return calendar.date(from: dateComponent) ?? Date()
        }

        /// End of day, 23:59:59
        func endOfDay() -> Date {
            dateComponent.hour = 23
            dateComponent.minute = 59
            dateComponent.second = 59
            return calendar.date(from: dateComponent) ?? Date()
        }

        switch viewsTag {
        case Shortcut.today.rawValue.hash:
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.yestoday.rawValue.hash:
            dateComponent.day = dateComponent.day! - 1
            endPicker.date = endOfDay()
            beginPicker.date = beginOfDay()
        case Shortcut.threeDays.rawValue.hash:
            dateComponent.day = dateComponent.day! - 3
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.thisWeek.rawValue.hash:
            var date = Date()
            var interval: TimeInterval = 0
            _ = calendar.dateInterval(of: .weekOfYear, start: &date, interval: &interval, for: date)
            dateComponent = calendar.dateComponents(in: calendar.timeZone, from: date)
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.week.rawValue.hash:
            dateComponent.day = dateComponent.day! - 7
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.thisMonth.rawValue.hash:
            dateComponent.day = 1
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.month.rawValue.hash:
            dateComponent.month = dateComponent.month! - 1
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.thisQuarter.rawValue.hash:
            dateComponent.day = 1
            if dateComponent.month! <= 3 {
                dateComponent.month = 1
            } else if dateComponent.month! <= 6 {
                dateComponent.month = 4
            } else if dateComponent.month! <= 8 {
                dateComponent.month = 7
            } else {
                dateComponent.month = 10
            }
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.quarter.rawValue.hash:
            dateComponent.month = dateComponent.month! - 3
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.thisYear.rawValue.hash:
            dateComponent.month = 1
            dateComponent.day = 1
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.year.rawValue.hash:
            dateComponent.year = dateComponent.year! - 1
            dateComponent.yearForWeekOfYear = dateComponent.yearForWeekOfYear! - 1
            beginPicker.date = beginOfDay()
            endPicker.date = Date()
        case Shortcut.lastYear.rawValue.hash:
            dateComponent.year = dateComponent.year! - 1
            dateComponent.yearForWeekOfYear = dateComponent.yearForWeekOfYear! - 1
            dateComponent.month = 1
            dateComponent.day = 1
            beginPicker.date = beginOfDay()
            dateComponent.month = 12
            dateComponent.day = 31
            endPicker.date = endOfDay()
        default: break
        }
    }
}
