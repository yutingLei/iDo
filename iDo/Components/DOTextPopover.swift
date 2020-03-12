/**************************************************
*
* DOTextPopover
*
* Subclassed from DOPopover.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

public class DOTextPopover: DOPopover {

    /// Set text.
    public var text: String? {
        didSet {
            genViews(forAttributing: false)
            shouldUpdate = true
        }
    }

    /// Set attributes text.
    public var attriubtedText: NSAttributedString? {
        didSet {
            genViews(forAttributing: true)
            shouldUpdate = true
        }
    }

    /// Set font for text. default system font 15.
    public var font: UIFont = UIFont.systemFont(ofSize: 15)

    /// Set text color for text. default black.
    public var textColor: UIColor = .black

    /// The text container view.
    private var textView: UITextView?
}

//MARK: - Calculate
extension DOTextPopover {

    /// Calculate the size of text.
    ///
    /// text: The given text.
    /// size: The estimate size for text.
    func size(of text: Any, estimateWidth width: CGFloat? = nil) -> CGSize
    {
        /// Get limit size.
        let limitSize: CGSize
        var shouldResize = true
        if let fixedSize = fixedPopoverViewSize {
            if fixedSize.width <= 0 && fixedSize.height > 0 {
                shouldResize = false
                limitSize = CGSize(width: CGFloat.infinity, height: fixedSize.height)
            } else if fixedSize.width > 0 && fixedSize.height <= 0 {
                shouldResize = false
                limitSize = CGSize(width: fixedSize.width, height: CGFloat.infinity)
            } else if fixedSize.width > 0 && fixedSize.height > 0 {
                return fixedSize
            } else {
                limitSize = CGSize(width: width ?? 80, height: CGFloat.infinity)
            }
        } else {
            limitSize = CGSize(width: width ?? 80, height: CGFloat.infinity)
        }

        /// Calculate size.
        let truthSize: CGSize
        if let text = text as? String {
            truthSize = (text as NSString).boundingRect(with: limitSize,
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: [.font: font],
                                                        context: nil).size
        } else {
            let text = text as! NSAttributedString
            var range = NSRange(location: 0, length: text.string.count)
            let ptr = withUnsafeMutablePointer(to: &range, { $0 })
            let attr = text.attributes(at: 0, effectiveRange: ptr)
            truthSize = (text.string as NSString).boundingRect(with: limitSize,
                                                               options: .usesLineFragmentOrigin,
                                                               attributes: attr,
                                                               context: nil).size
        }

        /// Should resize text.
        if shouldResize && (truthSize.height > limitSize.width) {
            return size(of: text,
                        estimateWidth: limitSize.width + font.pointSize * 2)
        }
        return truthSize
    }

    /// Generate container/content view.
    func genViews(forAttributing isAttributed: Bool) {
        let str: Any?
        if isAttributed && attriubtedText != nil {
            str = attriubtedText
        } else {
            str = text
        }
        guard let chars = str else { return }

        let containerSize: CGSize
        if let _ = fixedPopoverViewSize {
            containerSize = size(of: chars)
        } else {
            let esSize = size(of: chars, estimateWidth: 80)
            containerSize = esSize.extend(width: contentMargin.left + contentMargin.right,
                                          height: contentMargin.top + contentMargin.bottom)
        }

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

        createTextView()
        if isAttributed {
            textView?.attributedText = attriubtedText
        } else {
            textView?.text = text
        }
    }

    /// Create the text container view.
    private func createTextView() {
        if textView == nil {
            textView = UITextView()
            textView?.isEditable = false
            textView?.isSelectable = false
            textView?.textContainerInset = .zero
            textView?.textContainer.lineFragmentPadding = 0
            contentView.addSubview(textView!)
            textView?.fillToSuperview(edges: .zero)
        }
        textView?.font = font
        textView?.textColor = textColor
    }
}
