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
    func size(of text: String, estimateWidth width: CGFloat) -> CGSize {
        let esSize = CGSize(width: width, height: CGFloat.infinity)
        let truthSize = (text as NSString).boundingRect(with: esSize,
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: [.font: font],
                                                        context: nil).size
        if truthSize.height > width {
            return size(of: text, estimateWidth: width + font.pointSize * 2)
        }
        return truthSize
    }

    /// Generate container/content view.
    func genViews(forAttributing isAttributed: Bool) {
        let str: String?
        if isAttributed && attriubtedText != nil {
            str = attriubtedText?.string
        } else {
            str = text
        }
        guard let text = str else { return }

        let contentSize = size(of: text, estimateWidth: 80)
        let containerSize = contentSize.extend(width: contentMargin.left + contentMargin.right,
                                               height: contentMargin.top + contentMargin.bottom)

        /// Create containerView/contentView
        if containerView == nil {
            containerView = DOPopoverContainer(frame: CGRect(origin: .zero, size: containerSize))
        }
        if contentView == nil {
            contentView = DOPopoverContent(frame: CGRect(origin: .zero, size: containerSize))
        }
        containerView.frame.size = containerSize
        contentView.frame.size = contentSize
        if containerView.superview == nil {
            addSubview(containerView)
        }
        if contentView.superview == nil {
            containerView.addSubview(contentView)
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
            textView?.textContainerInset = .zero
            textView?.textContainer.lineFragmentPadding = 0
            contentView.addSubview(textView!)
            textView?.fillToSuperview(edges: .zero)
        }
        textView?.font = font
        textView?.textColor = textColor
    }
}
