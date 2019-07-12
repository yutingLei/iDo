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
    @objc optional func tablePopover(_ popover: IDOTablePopover, disabledRowAt index: Int) -> Bool

    /// The height of each rows in table
    /// Default is 50
    @objc optional func tablePopover(_ popover: IDOTablePopover, heightOfRowAt index: Int) -> CGFloat

    /// When selected contents
    @objc optional func tablePopover(_ popover: IDOTablePopover, didSelectRowAt index: Int)
}

public class IDOTablePopover: IDOPopover {

    /// Row's style
    public enum RowStyle {
        case `default`      /// Pure text
        case value1         /// Left icon and right text
        case value2         /// Left text and right icon
        case subtitle1      /// Top text and bottom subtitle
        case subtitle2      /// Left title and right subtitle
    }

    /// Show the actity indicator when null contents
    /// Default is true
    public var showLoadingWhenNullContent = true

    /// Show the null data's label when empty contents.
    /// Default is true
    /// Note: empty is not equal null
    public var showTextsWhenEmptyContent = true

    /// How the text will be shown when null data occurred.
    /// Default is  "未找到数据"
    public var textForNullData = "未找到数据"

    /// The contents of selections
    public var contents: [Any]?

    /// The keys that to get value needed.
    /// If nil. typeof(contents) must be type [String]
    /// If not nil, dependency ContentType
    /// case .pureText, need one key at least.
    /// case .value1, need two keys at least, and the first for icon, second for text
    /// case .value2, need two keys at least, and the first for text, second for icon
    /// case .subtitle[1|2], need two keys at least, and the first for title, second for subtitle
    public var extendKeys: [String]?

    /// Is multiple select
    public var isMultipleSelect: Bool = false

    /// The table view
    var tableView = UITableView()

    /// The loading activity
    lazy var loadingActivity = UIActivityIndicatorView()

    /// The label for null data
    lazy var nullDataLabel = UILabel()

    /// The row's style
    private var rowStyle: RowStyle!

    /// The current index of selected row
    private var selectedIndexes: [Int] = []

    /// The selections handler
    private var _selectedHandler: ((IDOTablePopover, [Int]) -> Void)?

    /// Init
    public init(referenceView: UIView, rowStyle: RowStyle = .default) {
        super.init()
        self.rowStyle = rowStyle
        self.referenceView = referenceView

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        contentView.addSubview(tableView)
    }

    /// Init with completion handler
    /// You should known that this initializer only suitable for .default style of rows
    ///
    /// Handle params:
    ///     - IDOTablePoper: The object of table popover
    ///     - [Int]:         Which the rows selected already.
    public convenience init(referenceView: UIView, onSelected handler: @escaping ((IDOTablePopover, [Int]) -> Void)) {
        self.init(referenceView: referenceView, rowStyle: .default)
        _selectedHandler = handler
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Show & hide
public extension IDOTablePopover {

    /// Show popover
    /// Note: You should invoke again if the popover
    /// already shown while set some properties
    override func show() {
        do {
            defer {
                super.show()
            }

            /// First. null contents
            if contents == nil {
                setLoading()
                containerViewRect(with: CGSize(width: 120, height: 120))
                layoutSubviewOfContentView(with: loadingActivity)
                return
            } else {
                loadingActivity.isHidden = true
            }

            /// Second. empty contents
            if contents != nil, contents!.isEmpty {
                setNullDataLabel()
                containerViewRect(with: CGSize(width: 120, height: 120))
                layoutSubviewOfContentView(with: nullDataLabel)
                return
            } else {
                nullDataLabel.isHidden = true
            }

            containerViewRect(with: try estimationSize())
            layoutSubviewOfContentView(with: tableView)
            tableView.reloadData()
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
            loadingActivity.backgroundColor = .white
            contentView.addSubview(loadingActivity)
        }
        loadingActivity.startAnimating()
        loadingActivity.isHidden = false
        contentView.bringSubviewToFront(loadingActivity)
    }

    /// Set null data
    func setNullDataLabel() {
        if nullDataLabel.superview == nil {
            nullDataLabel.backgroundColor = .white
            nullDataLabel.textColor = UIColor.rgb(200, 200, 200)
            nullDataLabel.font = UIFont.systemFont(ofSize: 14)
            nullDataLabel.textAlignment = .center
            contentView.addSubview(nullDataLabel)
        }
        nullDataLabel.isHidden = false
        nullDataLabel.text = textForNullData
        contentView.bringSubviewToFront(nullDataLabel)
    }
}

//MARK: Calculated
extension IDOTablePopover {

    /// Estimation content's size
    func estimationSize() throws -> CGSize {
        var contentSize = fixedContentSize ?? CGSize.zero

        /// Get texts from contents
        let texts = getTexts()
        
        /// Width
        if contentSize.width == 0 {

            var totalWidth: CGFloat = 0
            /// Get the max length of texts.0
            if let titles = texts.0 {
                totalWidth = maxLength(of: titles, with: 15)
            }

            /// Get the max length of texts.1
            if let subtitles = texts.1 {
                let ml = maxLength(of: subtitles, with: 13)
                if ((rowStyle != .default) && (rowStyle != .subtitle2)) {
                    totalWidth += ml
                } else {
                    totalWidth = max(totalWidth, ml)
                }
            }

            /// Get the icon's width
            if (rowStyle == .value1) || (rowStyle == .value2) {
                totalWidth += 30
            }
            
            /// Get spacing with texts or text-icon
            if (rowStyle != .`default`) && (rowStyle != .subtitle2) {
                totalWidth += 15
            }
            contentSize.width = totalWidth
        }
        
        /// Height
        if contentSize.height == 0 {
            let count = texts.0?.count ?? 0
            for i in 0..<count {
                let height = invoke("tablePopover(_:heightOfRowAt:)", param: i, dValue: CGFloat(50))
                contentSize.height += height
            }
        }
        return contentSize
    }

    /// Get texts from contents
    /// The first is title | text
    /// The second is subtitle | text
    func getTexts() -> ([String]?, [String]?) {

        if let contents = contents as? [String] {
            return (contents, nil)
        }

        guard let contents = contents as? [[String: Any]] else { return (nil, nil) }
        switch rowStyle! {
        case .value1:
            if let keys = extendKeys, keys.count >= 2 {
                return (contents.compactMap({ $0[keys[1]] as? String }), nil)
            }
        case .`default`, .value2:
            if let keys = extendKeys, keys.count >= 1 {
                return (contents.compactMap({ $0[keys[0]] as? String }), nil)
            }
        default:
            if let keys = extendKeys, keys.count >= 2 {
                return (contents.compactMap({ $0[keys[0]] as? String }),
                        contents.compactMap({ $0[keys[1]] as? String }))
            }
        }
        return (nil, nil)
    }

    /// Get the max lenght of texts
    func maxLength(of texts: [String], with fontSize: CGFloat) -> CGFloat {
        var maxLength: CGFloat = 0
        for i in 0..<texts.count {
            let height = invoke("tablePopover(_:heightOfRowAt:)", param: i, dValue: CGFloat(50))
            let textWidth = texts[i].boundingWidth(with: height, fontSize: fontSize)
            if textWidth > maxLength {
                maxLength = textWidth
            }
        }
        return maxLength
    }

    /// Invoke methods by delegate
    @discardableResult
    func invoke<T>(_ method: String, param: Int, dValue: T) -> T {
        unowned let weakSelf = self
        let dl = delegate as? IDOTablePopoverDelegate
        if method.contains("heightOfRowAt") {
            return dl?.tablePopover?(weakSelf, heightOfRowAt: param) as? T ?? dValue
        }
        if method.contains("disabledRowAt") {
            return dl?.tablePopover?(weakSelf, disabledRowAt: param) as? T ?? dValue
        }
        if method.contains("didSelectedRowAt") {
            dl?.tablePopover?(weakSelf, didSelectRowAt: param)
            return dValue
        }
        return dValue
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
            cell = IDOTablePopoverCell(rowStyle: rowStyle)
        }

        /// Set constraints
        cell?.setConstraints()

        /// Apply values
        cell?.setValues(contents![indexPath.row], with: extendKeys)

        /// Whether it disabled
        let isDisabled = invoke("tablePopover(_:disabledRowAt:)",
                                param: indexPath.row,
                                dValue: false)
        cell?.setDisabled(isDisabled, value: contents![indexPath.row] as? [String: Any])

        /// Whether it selected
        cell?.setSelected(selectedIndexes.contains(indexPath.row))
        return cell!
    }

    /// The row's height
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return invoke("tablePopover(_:heightOfRowAt:)", param: indexPath.row, dValue: CGFloat(50))
    }

    /// Selected rows
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Invoke closure when rows updated
        defer {
            if let handle = _selectedHandler {
                unowned let weakSelf = self
                handle(weakSelf, selectedIndexes)
            } else {
                invoke("tablePopover(_:didSelectRowAt:)", param: indexPath.row, dValue: NSNull())
            }
        }

        /// Process selected rows
        if !isMultipleSelect {
            selectedIndexes.removeAll()
        }
        if selectedIndexes.contains(indexPath.row) {
            selectedIndexes.removeAll(where: { $0 == indexPath.row })
        } else {
            selectedIndexes.append(indexPath.row)
        }
        selectedIndexes = selectedIndexes.sorted()

        /// Update UI
        if !isMultipleSelect {
            dismiss()
        } else {
            tableView.reloadData()
        }
    }
}

//MARK: - The TableCell
class IDOTablePopoverCell: UITableViewCell {

    /// The original image
    var originalImage: UIImage?

    /// The row's style
    private var rowStyle: IDOTablePopover.RowStyle

    /// Init
    init(rowStyle: IDOTablePopover.RowStyle) {
        self.rowStyle = rowStyle
        switch rowStyle {
        case .default:
            super.init(style: .default, reuseIdentifier: "kIDOTablePopoverCell")
            textLabel?.filled()
        case .value1:
            super.init(style: .default, reuseIdentifier: "kIDOTablePopoverCell")
            imageView?.contentMode = .scaleAspectFit
        case .value2:
            super.init(style: .default, reuseIdentifier: "kIDOTablePopoverCell")
        case .subtitle1:
            super.init(style: .value1, reuseIdentifier: "kIDOTablePopoverCell")
        case .subtitle2:
            super.init(style: .subtitle, reuseIdentifier: "kIDOTablePopoverCell")
        }
        selectionStyle = .none
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Set constraints
    func setConstraints() {
        switch rowStyle {
        case .default:
            textLabel?.filled()
        case .value1:
            imageView?.leading(to: contentView)
            imageView?.centerY(to: contentView)
            imageView?.width(constant: 20)
            imageView?.height(constant: 20)
            textLabel?.leading(to: imageView!, constant: 15)
            textLabel?.centerY(to: contentView)
        case .value2:
            textLabel?.leading(to: contentView)
            textLabel?.centerY(to: contentView)
            accessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            accessoryView?.contentMode = .scaleAspectFit
            if accessoryView?.superview == nil {
                contentView.addSubview(accessoryView!)
            }
        case .subtitle1:
            textLabel?.leading(to: contentView)
            textLabel?.centerY(to: contentView)
            detailTextLabel?.trailing(to: contentView)
            detailTextLabel?.centerY(to: contentView)
        case .subtitle2:
            textLabel?.leading(to: contentView)
            textLabel?.trailing(to: contentView)
            textLabel?.centerY(to: contentView, constant: -10)
            detailTextLabel?.leading(to: contentView)
            detailTextLabel?.trailing(to: contentView)
            detailTextLabel?.centerY(to: contentView, constant: 10)
        }
    }

    /// Set selected state
    func setSelected(_ selected: Bool) {
        guard isUserInteractionEnabled else { return }
        textLabel?.textColor = selected ? UIColor(hex: "#409EFF") : .black
        detailTextLabel?.textColor = selected ? UIColor(hex: "#409EFF") : UIColor(hex: "#666666")
    }

    /// Apply values
    func setValues(_ value: Any, with keys: [String]?) {
        if let text = value as? String {
            textLabel?.text = text
        }
        if let value = value as? [String: Any], let keys = keys {
            switch rowStyle {
            case .default: keys.count >= 1 ? (textLabel?.text = value[keys[0]] as? String) : nil
            case .value1, .value2:
                if keys.count >= 2 {
                    let iconKeyIndex = rowStyle == .value1 ? 0 : 1
                    let titleKeyIndex = rowStyle == .value1 ? 1 : 0
                    let imgView = (rowStyle == .value1) ? imageView : (accessoryView as? UIImageView)
                    if let image = value[keys[iconKeyIndex]] as? UIImage {
                        originalImage = image
                        imgView?.image = image
                    }
                    if let imageName = value[keys[iconKeyIndex]] as? String {
                        imgView?.image = UIImage(named: imageName)
                        originalImage = imgView?.image
                    }
                    textLabel?.text = value[keys[titleKeyIndex]] as? String
                }
            default:
                if keys.count >= 2 {
                    textLabel?.text = value[keys[0]] as? String
                    detailTextLabel?.text = value[keys[1]] as? String
                }
            }
        }
    }

    /// Set disabled state
    func setDisabled(_ disabled: Bool, value: [String: Any]?) {
        var isDisabled = disabled
        if !isDisabled, let value = value {
            isDisabled = (value["isDisabled"] as? Bool ?? false) || (value["disabled"] as? Bool ?? false)
        }
        isUserInteractionEnabled = !isDisabled
        if !isUserInteractionEnabled {
            textLabel?.textColor = UIColor(hex: "#DDDDDD")
            detailTextLabel?.textColor = UIColor(hex: "#EEEEEE")
        }
    }
}
