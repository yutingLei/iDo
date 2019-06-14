//
//  IDOTextPoperover.swift
//  Pure text popover
//
//  Created by admin on 2019/6/14.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public class IDOTextPopover: IDOPopover {

    /// The text
    public var text: String? { willSet { textView.text = newValue ?? "" } }

    /// The text's font
    public var fontSize: CGFloat = 15 { willSet { textView.font = UIFont.systemFont(ofSize: newValue) } }

    /// The text's color
    public var textColor: UIColor = UIColor.rgb(45, 54, 56) { willSet { textView.textColor = newValue } }

    /// The text view
    private var textView = UITextView()

    /// Init
    public init(referenceView: UIView) {
        super.init()
        self.referenceView = referenceView

        textView.isEditable = false
        textView.textColor = textColor
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = UIFont.systemFont(ofSize: fontSize)
        contentView.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension IDOTextPopover {

    /// Show
    override func show() {
        containerViewRect(with: estimationTextSize())
        layoutSubviewOfContentView(with: textView)
        super.show()
    }
}

//MARK: - Calculates
extension IDOTextPopover {

    /// Calculate text's width/height
    func estimationTextSize() -> CGSize {
        var contentSize = fixedContentSize ?? CGSize.zero
        let refRect = referenceView.convert(referenceView.bounds, to: UIApplication.shared.keyWindow)

        /// Width
        if contentSize.width == 0, let text = text {
            let textWidth = text.boundingWidth(with: fixedContentSize?.width ?? CGFloat.infinity, fontSize: fontSize)
            switch referenceLocation {
            case .left: contentSize.width = min(refRect.minX - 32, textWidth)
            case .right: contentSize.width = min(screenWidth - refRect.maxX - 32, textWidth)
            default: contentSize.width = min(screenWidth - 32, textWidth)
            }
        }

        /// Height
        if contentSize.height == 0, let text = text {
            var estimationWidth: CGFloat = contentSize.width
            if fixedContentSize != nil, fixedContentSize!.width > 0 {
                switch referenceLocation {
                case .left, .right: estimationWidth = contentSize.width - 16 - arrowHeight
                default: estimationWidth = contentSize.width - 16
                }
            }
            contentSize.height = text.boundingHeight(with: estimationWidth, fontSize: fontSize)
        }
        return contentSize
    }
}
