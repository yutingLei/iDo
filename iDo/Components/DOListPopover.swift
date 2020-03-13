/**************************************************
*
* DOListPopover
*
* Subclassed from DOPopover. Display a list of
* contents, also u can selec by config.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

//MARK: - Row's Configuration
public class DOListRowConfiguration {

    /// Define indent.
    public struct Indent {
        public var left: CGFloat
        public var right: CGFloat
        init(left: CGFloat = 0, right: CGFloat = 0) {
            self.left = left
            self.right = right
        }
    }

    /// Get default configuration.
    static let `default`: DOListRowConfiguration = DOListRowConfiguration()

    /// The row's height. default is 45
    public var height: CGFloat

    /// The row's background color. default is white.
    public var backgroundColor: UIColor

    /// The row's background color for selected.
    public var selectedColor: UIColor?

    /// The separator between rows. default is true
    public var isAllowedSeparator: Bool
    /// The indent aboutn separator, default left 8, righ 8
    public var separatorIndent: Indent
    /// The background color for separator view.
    public var separatorColor: UIColor

    /// Display the checked indicator if selected. default is true.
    public var showCheckedIndicator = true

    /// U can custom the check indicator. support String|UIImage.
    /// String represente image name.
    public var checkedIndicator: Any?

    /// About texts.
    public var font: UIFont
    public var textColor: UIColor
    public var textAlign: NSTextAlignment

    /// Init method.
    init() {
        height = 45
        backgroundColor = .white
        isAllowedSeparator = true
        separatorIndent = Indent(left: 8, right: 8)
        separatorColor = UIColor(hex: "AFAFAF")!
        font = UIFont.systemFont(ofSize: 15)
        textColor = UIColor(hex: "696969")!
        textAlign = .center
    }
}

public class DOListPopover: DOPopover {

    /// Display style.
    public enum Style {
        case text       /// Display plain text in each cell.
        case iconText   /// Left icon with right text. space is 10.
    }
    /// Default is text
    public var style: Style = .text

    /// Whether allow user select. default true.
    public var allowSelection = true

    /// Whether allow user multiple select. default false.
    /// If true, u must set canSelect = true before. else
    /// ignore this property.
    public var allowMulipleSelection = false

    /// Config each rows.
    private(set) public var rowsConfiguration: DOListRowConfiguration = DOListRowConfiguration.default

    /// Which strings should be displayed, maybe set
    /// one of [strings] or [contents].
    public var strings: [String]?

    /// Which contents should be displayed, maybe set
    /// one of [strings] or [contents].
    ///
    /// The keys that needed beacuse get the values
    /// from contents.
    /// if keys equal nil:
    ///     .text:      ["name"] be used.
    ///     .iconText   ["image", "name"] be used.
    public var contents: [[String: Any]]?
    public var keys: [String]?

    //MARK: Private

    /// The listView.
    private var listView: UITableView!

    /// The strings will be displayed.
    private var _strings: [String]?
    private var _selections: [IndexPath] = []

    // MARK: Override
    public override func show(_ operateHandler: DOPopover.OperateHandler? = nil) {
        calculateContainerSize()
        super.show(operateHandler)
    }

    public override func show(duration: TimeInterval, hideHandler: DOPopover.OperateHandler? = nil) {
        calculateContainerSize()
        super.show(duration: duration, hideHandler: hideHandler)
    }

    public override func hide() {
        if let handle = operateHandler, !_selections.isEmpty {
            if allowMulipleSelection {
                let indexes = _selections.compactMap({ $0.row })
                var texts = [String]()
                for index in indexes {
                    texts.append(_strings![index])
                }
                handle((indexes, texts))
            } else {
                let index = _selections[0].row
                handle((index, _strings![index]))
            }
        }
        super.hide()
    }
}

//MARK: - Creations
extension DOListPopover {

    /// Calculate width of strings.
    func calculateEstimateWidth() -> CGFloat? {
        if strings == nil && contents == nil {
            print("Note: [strings] or [contents] aren't be nil at same time.")
            return nil
        }

        /// Get all texts that will be displayed.
        let texts: [String]
        if let strings = strings {
            texts = strings
        } else {
            if keys != nil && keys!.isEmpty {
                print("If keys passed, so can't be empty.")
                return nil
            }
            if style == .text {
                let ks = keys ?? ["name"]
                keys = ks
                texts = contents!.compactMap({ $0[ks[0]] as? String })
            } else {
                let ks = keys ?? ["image", "name"]
                keys = ks
                texts = contents!.compactMap({ $0[ks[1]] as? String })
            }
        }

        guard !texts.isEmpty else {
            print("Unfound any strings could be display.")
            return nil
        }
        _strings = texts

        /// Calculate the max lenght of texts.
        var maxWidth: CGFloat = 0
        let esSize = CGSize(width: CGFloat.infinity,
                            height: rowsConfiguration.height)
        for text in texts {
            let w = (text as NSString).boundingRect(with: esSize,
                                                    options: .truncatesLastVisibleLine,
                                                    attributes: [.font: rowsConfiguration.font],
                                                    context: nil).width
            if w > maxWidth {
                maxWidth = w
            }
        }

        /// If display icon with text.
        if style == .iconText {
            maxWidth += 25 /// Icon size: 15, space: 10
        }

        /// If check indicator will be shown in future.
        if rowsConfiguration.showCheckedIndicator {
            maxWidth += 20  /// Indicator size: 15, space: 5
        }

        return maxWidth
    }

    /// Calculate size of contents.
    func calculateContainerSize() {

        if let fixedSize = fixedPopoverSize, fixedSize.width > 0 {
            if fixedSize.height <= 0 {
                let height = rowsConfiguration.height * CGFloat(_strings?.count ?? 0)
                genView(ofSize: CGSize(width: fixedSize.width, height: height))
            } else {
                genView(ofSize: fixedSize)
            }
        } else if let width = calculateEstimateWidth() {

            let height = rowsConfiguration.height * CGFloat(_strings?.count ?? 0)
            genView(ofSize: CGSize(width: width, height: height))
        }
    }

    /// After calculates, generate listView.
    func genView(ofSize size: CGSize) {
        let containerSize = size.extend(width: contentMargin.horizontal,
                                        height: contentMargin.vertical)
        /// Create containerView/contentView
        if shadowView == nil {
            shadowView = DOPopoverShadow(frame: CGRect(origin: .zero, size: containerSize))
        }
        if contentView == nil {
            contentView = DOPopoverContent()
        }
        shadowView.frame.size = containerSize
        if shadowView.superview == nil {
            addSubview(shadowView)
        }
        if contentView.superview == nil {
            shadowView.containerView.addSubview(contentView)
        }

        if listView == nil {
            listView = UITableView()
            listView.dataSource = self
            listView.delegate = self
            contentView.addSubview(listView)
            listView.fillToSuperview(edges: .zero)
        }
        listView.allowsSelection = allowSelection
        listView.separatorStyle = rowsConfiguration.isAllowedSeparator ? .singleLine : .none
        listView.separatorColor = rowsConfiguration.separatorColor
        listView.separatorInset = UIEdgeInsets(top: 0,
                                               left: rowsConfiguration.separatorIndent.left,
                                               bottom: 0,
                                               right: rowsConfiguration.separatorIndent.right)
    }
}

//MARK: - TableView Delegate
extension DOListPopover: UITableViewDataSource, UITableViewDelegate {

    /// The number of rows.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _strings?.count ?? 0
    }

    /// The rows view.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// Get reused cell.
        let cellID = style == .text ? "kDOPureTextReuseID" : "kDOIconTextReuseID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)

        /// Create new cell if needed.
        if cell == nil {
            if style == .text {
                cell = DOTextRow(style: .default, reuseIdentifier: cellID)
            } else {
                cell = DOIconTextRow(style: .default, reuseIdentifier: cellID)
            }
        }

        /// Apply values.
        if style == .text {
            (cell as? DOTextRow)?.setText(_strings![indexPath.row], with: rowsConfiguration)
            (cell as? DOTextRow)?.setTextSelection(_selections.contains(indexPath),
                                                   with: rowsConfiguration)
        } else {
            if let icon = contents?[indexPath.row][keys![0]] {
                (cell as? DOIconTextRow)?.setIcon(icon)
            }
            (cell as? DOIconTextRow)?.setText(_strings![indexPath.row], with: rowsConfiguration)
            (cell as? DOIconTextRow)?.setTextSelection(_selections.contains(indexPath),
                                                       with: rowsConfiguration)
        }

        return cell!
    }

    /// The height for each rows.
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowsConfiguration.height
    }

    /// Did select row at indexPath.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard allowSelection else { return }
        if let index = _selections.firstIndex(of: indexPath) {
            _selections.remove(at: index)
            tableView.reloadData()
            return
        }
        if allowMulipleSelection {
            _selections.append(indexPath)
            tableView.reloadData()
            return
        }
        _selections = [indexPath]
        hide()
    }
}

//MARK: - Text Row
class DOTextRow: UITableViewCell {

    /// The pure text label.
    private var ptextLabel: UILabel!
    private var ptextLabelTrailing: NSLayoutConstraint!

    /// The checked icon.
    private lazy var checkIndicator = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        ptextLabel = UILabel()
        contentView.addSubview(ptextLabel)
        let cons = ptextLabel.fillToSuperview(edges: .zero)
        ptextLabelTrailing = cons[3]
    }

    /// Settings for text label.
    func setText(_ text: String, with config: DOListRowConfiguration) {
        backgroundColor = config.backgroundColor
        ptextLabel.text = text
        ptextLabel.font = config.font
        ptextLabel.textColor = config.textColor
        ptextLabel.textAlignment = config.textAlign
    }

    /// If rows allow selection, please invoke this.
    func setTextSelection(_ selected: Bool, with config: DOListRowConfiguration) {
        if selected {
            backgroundColor = config.selectedColor
            if config.showCheckedIndicator {
                if checkIndicator.superview == nil {
                    contentView.addSubview(checkIndicator)
                    checkIndicator.centerY(to: contentView, offset: 0)
                    checkIndicator.trailingToSuperview()
                    checkIndicator.width(15)
                    checkIndicator.height(15)
                }
                ptextLabelTrailing.constant = -20
                checkIndicator.isHidden = false
            } else {
                ptextLabelTrailing.constant = 0
                checkIndicator.isHidden = true
            }

            /// Apply check indicator.
            if let imageName = config.checkedIndicator as? String,
                let image = UIImage(named: imageName)
            {
                checkIndicator.image = image
            } else if let image = config.checkedIndicator as? UIImage {
                checkIndicator.image = image
            } else {
                checkIndicator.image = DOIcons.check?.render(with: .blue)
            }
        } else {
            backgroundColor = config.backgroundColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - IconText Row
class DOIconTextRow: UITableViewCell {

    /// The icon.
    private var icon: UIImageView!

    /// The text.
    private var textLbl: UILabel!
    private var textLblTrailing: NSLayoutConstraint!

    /// The checked icon.
    private lazy var checkIndicator = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        icon = UIImageView()
        contentView.addSubview(icon)
        icon.leadingToSuperview(distance: 5)
        icon.centerY(to: contentView)
        icon.width(15)
        icon.height(15)

        textLbl = UILabel()
        contentView.addSubview(textLbl)
        textLbl.topToSuperview()
        textLbl.bottomToSuperview()
        textLblTrailing = textLbl.trailingToSuperview()
        textLbl.leading(to: icon, distance: 5, opposite: true)
    }

    /// Settings for icon.
    func setIcon(_ value: Any) {
        if let name = value as? String {
            icon.image = UIImage(named: name)
        } else if let image = value as? UIImage {
            icon.image = image
        }
    }

    /// Settings for text label.
    func setText(_ text: String, with config: DOListRowConfiguration) {
        backgroundColor = config.backgroundColor
        textLbl.text = text
        textLbl.font = config.font
        textLbl.textColor = config.textColor
        textLbl.textAlignment = config.textAlign
    }

    /// If rows allow selection, please invoke this.
    func setTextSelection(_ selected: Bool, with config: DOListRowConfiguration) {
        if selected {
            backgroundColor = config.selectedColor
            if config.showCheckedIndicator {
                if checkIndicator.superview == nil {
                    contentView.addSubview(checkIndicator)
                    checkIndicator.centerY(to: contentView, offset: 0)
                    checkIndicator.trailingToSuperview()
                    checkIndicator.width(15)
                    checkIndicator.height(15)
                }
                textLblTrailing.constant = -20
                checkIndicator.isHidden = false
            } else {
                textLblTrailing.constant = 0
                checkIndicator.isHidden = true
            }

            /// Apply check indicator.
            if let imageName = config.checkedIndicator as? String,
                let image = UIImage(named: imageName)
            {
                checkIndicator.image = image
            } else if let image = config.checkedIndicator as? UIImage {
                checkIndicator.image = image
            } else {
                checkIndicator.image = DOIcons.check?.render(with: .blue)
            }
        } else {
            if checkIndicator.superview != nil {
                checkIndicator.isHidden = true
                textLblTrailing.constant = 0
            }
            backgroundColor = config.backgroundColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
