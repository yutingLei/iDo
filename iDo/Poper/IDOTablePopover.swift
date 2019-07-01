//
//  IDOTablePopover.swift
//  A table popover for selections
//
//  Created by admin on 2019/6/17.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

/// The delegate of table popover
@objc public protocol IDOTablePopoverDelegate: IDOPopoverProtocol {

    /// Whether the rows can be selected
    /// Also, we can detect the keys 'isDisabled' | 'disabled' in contents to determine whether it can
    /// be select. But this function has the higher priority
    @objc optional func canSelect(_ popover: IDOTablePopover, at index: Int) -> Bool

    /// Whether the row is selected
    @objc optional func isSelected(_ popover: IDOTablePopover, at index: Int) -> Bool

    /// Selected
    @objc optional func tablePopover(_ popover: IDOTablePopover, selectedAt index: Int)
}

public class IDOTablePopover: IDOPopover {

    /// Show the network activity while loading remote contents.
    /// Default is true
    public var isLoading = true { didSet { setLoading() } }

    /// Show the label when null data.
    /// Default is true
    public var isNullData = true { didSet { setNullDataLabel() } }

    /// How the text will be shown when null data occurred.
    /// Default is  "未找到数据"
    public var textForNullData = "未找到数据"

    /// The contents of selections
    public var contents: [Any]?

    /// The keys that to get value needed.
    /// If nil. typeof(contents) must be type [String]
    /// If not nil, dependency ContentType
    /// case .pureText, need one key at least.
    /// case .iconText, need two keys at least, and the first for icon, second for text
    /// case .textIcon, need two keys at least, and the first for text, second for icon
    /// case .subtitle[1|2], need two keys at least, and the first for title, second for subtitle
    public var extendKeys: [String]?

    /// The config of cells
    private(set) public var cellsConfig: IDOTablePopoverCellsConfiguration!

    /// The table view
    var tableView = UITableView()

    /// The loading activity
    lazy var loadingActivity = UIActivityIndicatorView()

    /// The label for null data
    lazy var nullDataLabel = UILabel()

    /// Init
    public init(referenceView: UIView, with configuration: IDOTablePopoverCellsConfiguration = IDOTablePopoverCellsConfiguration()) {
        super.init()
        self.referenceView = referenceView
        self.cellsConfig = configuration

        contentView.addSubview(tableView)

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = configuration.separatorColor
        tableView.separatorInset = configuration.separatorInsets
        tableView.separatorStyle = configuration.separatorColor == nil ? .none : .singleLine
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Show & hide
public extension IDOTablePopover {

    /// Show
    override func show() {
        do {
            containerViewRect(with: try estimationSize())
            layoutSubviewOfContentView(with: tableView)
            tableView.reloadData()
            super.show()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK: Settings
extension IDOTablePopover {

    /// Set loading
    func setLoading() {
        if loadingActivity.superview == nil {
            loadingActivity.style = .gray
            contentView.addSubview(loadingActivity)
        }
        loadingActivity.frame = contentView.bounds
        loadingActivity.isHidden = !isLoading
        contentView.bringSubviewToFront(loadingActivity)
    }

    /// Set null data
    func setNullDataLabel() {
        if nullDataLabel.superview == nil {
            nullDataLabel.textColor = UIColor.rgb(200, 200, 200)
            nullDataLabel.font = UIFont.systemFont(ofSize: 14)
            nullDataLabel.textAlignment = .center
            contentView.addSubview(nullDataLabel)
        }
        nullDataLabel.frame = contentView.bounds
        nullDataLabel.isHidden = !isNullData
        nullDataLabel.text = textForNullData
        contentView.bringSubviewToFront(nullDataLabel)
    }
}

//MARK: Calculated
extension IDOTablePopover {

    /// Estimation content's size
    func estimationSize() throws -> CGSize {
        var contentSize = fixedContentSize ?? CGSize.zero
        let refRect = referenceView.convert(referenceView.bounds, to: UIApplication.shared.keyWindow)
        
        /// Width
        if contentSize.width == 0 {
            if let contents = contents as? [String] {
                contentSize.width = maxLength(of: contents, with: cellsConfig.titlesFontSize)
                if cellsConfig.shouldAddedIndicator {
                    contentSize.width += 33
                }
            }
            if let contents = contents as? [[String: Any]] {
                guard let keys = extendKeys, keys.count >= 1 else {
                    throw error(with: -1004, message: "The 'extendKeys' mustn't be nil while type of 'contents' is [[String: Any]].")
                }
                switch cellsConfig.contentType {
                case .pureText:
                    contentSize.width = maxLength(of: contents.compactMap({ $0[keys[0]] as? String }),
                                                              with: cellsConfig.titlesFontSize)
                    if cellsConfig.shouldAddedIndicator {
                        contentSize.width += 33
                    }
                default:
                    guard keys.count >= 2 else {
                        throw error(with: -1005, message: "The count of 'extendKeys' must be greater than 2 when 'cellsConfig.ContentType' is .iconText or .textIcon")
                    }
                    let indexOfKeys = cellsConfig.contentType == .iconText ? 1 : 0
                    let fTexts = contents.compactMap({ $0[keys[indexOfKeys]] as? String })
                    let sTexts = contents.compactMap({ $0[keys[1]] as? String })
                    contentSize.width = max(maxLength(of: fTexts, with: cellsConfig.titlesFontSize),
                                            maxLength(of: sTexts, with: cellsConfig.subtitlesFontSize))
                    if cellsConfig.contentType == .iconText || cellsConfig.contentType == .textIcon {
                        contentSize.width += 33
                    }
                }
                switch referenceLocation {
                case .left: contentSize.width = min(refRect.minX - 32, contentSize.width)
                case .right: contentSize.width = min(screenWidth - refRect.maxX - 32, contentSize.width)
                default: contentSize.width = min(screenWidth - 32, contentSize.width)
                }
            }
        }
        
        /// Height
        if contentSize.height == 0 {
            contentSize.height = cellsConfig.height * CGFloat(contents?.count ?? 0)
        }
        return contentSize
    }

    /// Get the max lenght of texts
    func maxLength(of texts: [String], with fontSize: CGFloat) -> CGFloat {
        var maxLength: CGFloat = 0
        for text in texts {
            let textWidth = text.boundingWidth(with: cellsConfig.height, fontSize: fontSize)
            if textWidth > maxLength {
                maxLength = textWidth
            }
        }
        return maxLength
    }
}

//MARK: Table's delegates
extension IDOTablePopover: UITableViewDataSource, UITableViewDelegate {

    /// How many rows will be create
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents?.count ?? 0
    }

    /// Create content cell
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "kIDOTablePopoverCell") as? IDOTablePopoverCell
        if cell == nil {
            cell = IDOTablePopoverCell(configuration: cellsConfig)
        }
        if let content = contents?[indexPath.row] {
            cell?.applyValues(content, with: extendKeys)
        }
        unowned let weakSelf = self
        if let isDisabled = (delegate as? IDOTablePopoverDelegate)?.canSelect?(weakSelf, at: indexPath.row) {
            cell?.setDisabled(with: isDisabled)
        }
        return cell!
    }

    /// The row's height
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellsConfig.height
    }

    /// Selected rows
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? IDOTablePopoverCell {
            cell.setSelected(!cell.isSelected)
            cell.isSelected = !cell.isSelected
        }
    }
}

//MARK: - The TableCell
class IDOTablePopoverCell: UITableViewCell {

    /// The title label
    var titleLabel = UILabel()

    /// The subtitle label
    lazy var subtitleLabel = UILabel()

    /// The icon image
    lazy var iconImage = UIImageView()

    /// The original image
    var originalImage: UIImage?

    /// The config
    private var config: IDOTablePopoverCellsConfiguration!

    /// The disalbed layer
    private var disabledView = UIView()

    /// Init
    init(configuration: IDOTablePopoverCellsConfiguration) {
        super.init(style: .default, reuseIdentifier: "kIDOTablePopoverCell")
        self.config = configuration

        /// Title
        titleLabel.font = UIFont.systemFont(ofSize: configuration.titlesFontSize)
        titleLabel.textColor = configuration.textColor
        addSubview(titleLabel)

        /// Layout
        switch configuration.contentType {
        case .pureText:
            titleLabel.top(to: self)
            titleLabel.leading(to: self)
            titleLabel.bottom(to: self)
            titleLabel.trailing(to: self, constant: configuration.shouldAddedIndicator ? -33 : 0)
            if configuration.shouldAddedIndicator {
                iconImage.image = IDOSource.getIcon(.check)?.render(with: configuration.selectedTextColor)
                iconImage.contentMode = .scaleAspectFit
                iconImage.isHidden = !isSelected
                addSubview(iconImage)
                iconImage.centerY(to: self)
                iconImage.width(constant: 25)
                iconImage.height(constant: 25)
                iconImage.trailing(to: self)
            }
        case .iconText, .textIcon:
            iconImage.contentMode = .scaleAspectFit
            addSubview(iconImage)
            titleLabel.top(to: self)
            titleLabel.bottom(to: self)
            iconImage.centerY(to: self)
            iconImage.width(constant: 25)
            iconImage.height(constant: 25)
            if configuration.contentType == .iconText {
                iconImage.leading(to: self)
                titleLabel.textAlignment = .right
                titleLabel.trailing(to: self)
                titleLabel.leading(to: iconImage, constant: 8)
            } else {
                iconImage.trailing(to: self)
                titleLabel.leading(to: self)
                titleLabel.trailing(to: iconImage, constant: 8)
            }
        case .subtitle1:
            subtitleLabel.font = UIFont.systemFont(ofSize: configuration.subtitlesFontSize)
            subtitleLabel.textColor = configuration.subTextColor
            addSubview(subtitleLabel)
            titleLabel.top(to: self)
            titleLabel.leading(to: self)
            titleLabel.bottom(to: self)
            titleLabel.width(equalTo: self, multiplier: 0.66, constant: 0)
            subtitleLabel.leading(to: titleLabel, constant: 8)
            subtitleLabel.top(to: self)
            subtitleLabel.bottom(to: self)
            subtitleLabel.trailing(to: self)
        case .subtitle2:
            subtitleLabel.font = UIFont.systemFont(ofSize: configuration.subtitlesFontSize)
            subtitleLabel.textColor = configuration.subTextColor
            addSubview(subtitleLabel)
            titleLabel.leading(to: self)
            titleLabel.trailing(to: self)
            titleLabel.centerY(to: self, constant: -18)
            subtitleLabel.leading(to: self)
            subtitleLabel.trailing(to: self)
            subtitleLabel.top(to: titleLabel, constant: 5)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Apply value
    func applyValues(_ content: Any, with keys: [String]?) {
        if content is String {
            titleLabel.text = content as? String
        } else if let content = content as? [String: Any], let keys = keys, keys.count >= 1 {
            switch config.contentType {
            case .pureText:
                titleLabel.text = content[keys[0]] as? String
            case .iconText:
                titleLabel.text = (keys.count >= 2) ? (content[keys[1]] as? String) : nil
                iconImage.image = content[keys[0]] as? UIImage
                originalImage = iconImage.image
            case .textIcon:
                titleLabel.text = content[keys[0]] as? String
                iconImage.image = (keys.count >= 2) ? (content[keys[1]] as? UIImage) : nil
                originalImage = iconImage.image
            case .subtitle1, .subtitle2:
                titleLabel.text = content[keys[0]] as? String
                subtitleLabel.text = (keys.count >= 2) ? (content[keys[1]] as? String) : nil
            }
            setDisabled(with: isDisabled(with: content))
        }
    }

    /// Is disabled
    func isDisabled(with content: [String: Any]) -> Bool {
        if let isDisabled = content["isDisabled"] as? String {
            return isDisabled == "true"
        }
        if let isDisabled = content["isDisabled"] as? Bool {
            return isDisabled
        }
        if let isDisabled = content["disabled"] as? String {
            return isDisabled == "true"
        }
        if let isDisabled = content["disabled"] as? Bool {
            return isDisabled
        }
        return false
    }

    /// Set disabled
    func setDisabled(with isDisabled: Bool) {
        selectionStyle = isDisabled ? .none : selectionStyle
        isUserInteractionEnabled = !isDisabled
        if isDisabled {
            disabledView.tag = 10001
            disabledView.filled()
            disabledView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            addSubview(disabledView)
        } else {
            viewWithTag(10001)?.removeFromSuperview()
        }
    }

    /// Set selected
    func setSelected(_ selected: Bool) {
        titleLabel.textColor = selected ? config.selectedTextColor : config.textColor
        switch config.contentType {
        case .pureText:
            if config.shouldAddedIndicator {
                iconImage.isHidden = !selected
            }
        case .iconText, .textIcon:
            iconImage.isHidden = !selected
            if selected {
                iconImage.image = originalImage?.render(with: config.selectedTextColor)
            } else {
                iconImage.image = originalImage
            }
        case .subtitle1, .subtitle2:
            subtitleLabel.textColor = selected ? config.selectedTextColor : config.textColor
        }
    }
}

//MARK: - The contents layout
public struct IDOTablePopoverCellsConfiguration {
    public enum ContentType {
        /// Only text
        case pureText
        /// Icon - text
        case iconText
        /// Text - icon
        case textIcon
        /// Left - title, right - subtitle
        case subtitle1
        /// Top - title, bottom - subtitle
        case subtitle2
    }

    /// Layout type
    public var contentType: ContentType

    /// The row's height
    public var height: CGFloat

    /// Separator insets
    public var separatorInsets: UIEdgeInsets

    /// Separator color
    /// If nil, none separator
    public var separatorColor: UIColor?

    /// The fontSize, default is 15
    public var titlesFontSize: CGFloat
    public var subtitlesFontSize: CGFloat

    /// The text's color for normal
    public var textColor: UIColor
    public var subTextColor: UIColor?

    /// The text's color for selected
    public var selectedTextColor: UIColor

    /// Should add an indicator when selected rows,
    /// Note that it only suitable for ContentType = .pureText
    public var shouldAddedIndicator: Bool

    /// Init
    public init(height: CGFloat = 45, contentType: ContentType = .pureText, separatorInsets: UIEdgeInsets = UIEdgeInsets.zero, separatorColor: UIColor? = nil, titlesFontSize: CGFloat = 15, subtitlesFontSize: CGFloat = 13, textColor: UIColor = UIColor.rgb(54, 55, 56), subTextColor: UIColor? = nil, selectedTextColor: UIColor = UIColor.rgb(56, 128, 255), shouldAddedIndicator: Bool = true) {
        self.height = height
        self.contentType = contentType
        self.separatorInsets = separatorInsets
        self.separatorColor = separatorColor
        self.titlesFontSize = titlesFontSize
        self.subtitlesFontSize = subtitlesFontSize
        self.textColor = textColor
        self.subTextColor = subTextColor
        self.selectedTextColor = selectedTextColor
        self.shouldAddedIndicator = shouldAddedIndicator
    }
}
