/**************************************************
*
* DOToast
*
* A short-lived alert which can be from center or bottom.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

public class DOToast: UIView {

    /// Define mode.
    public enum AnimateStyle {
        case center
        case bottom
    }
    public var animateStyle: AnimateStyle = .center

    /// reverse animation while hide.
    public var reverseAnimateWhenHide = true

    /// U can use shared toast to alert something.
    public static let shared = DOToast()

    /// The content view which display the contents.
    private(set) public var contentView: UIView!
    private var textView: UITextView!

    //MARK: Settings for text.
    ///
    /// The font settings for text, default(system 14).
    public var font = UIFont.systemFont(ofSize: 14)
    /// The color for text, default white.
    public var textColor: UIColor = .white

    /// Get screen's width and height.
    let sWidth       = UIScreen.main.bounds.width
    let sHeight      = UIScreen.main.bounds.height
    private var cancelable = true

    /// Init method.
    init(animateStyle: AnimateStyle = .center) {
        super.init(frame: UIApplication.shared.keyWindow!.bounds)
        self.animateStyle = animateStyle
        backgroundColor = .clear
        createContentView()
        createTextView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard cancelable else { return }
        if let touch = touches.first {
            let loc = touch.location(in: self)
            if !contentView.frame.contains(loc) {
                hide()
            }
        }
    }
}

//MARK: - Show & Hide
public extension DOToast {

    /// Show toast with duration.
    ///
    /// text: Which string should be display.
    /// duration: How many time should continue, default 3s.
    /// cancelable: The toast view hide right now while user tapped outside
    /// of content view.
    func show(_ text: String, duration: TimeInterval = 3, cancelable: Bool = true) {
        let textSize = size(of: text, estimateWidth: 80)
        textView.text = text
        textView.font = font
        textView.textColor = textColor

        let fromBottom = animateStyle == .bottom
        if fromBottom {
            contentView.frame.size = textSize.extend(width: 40, height: 20)
        } else {
            contentView.frame.size = textSize.extend(width: 20, height: 20)
        }
        if fromBottom {
            contentView.layer.cornerRadius = contentView.frame.height / 2
            contentView.center = CGPoint(x: center.x,
                                         y: sHeight + contentView.frame.height * 1.2)
        } else {
            contentView.layer.cornerRadius = 5
            contentView.center = center
        }

        /// Add to window.
        if superview == nil {
            UIApplication.shared.keyWindow?.addSubview(self)
            if fromBottom {
                slide(in: true)
            } else {
                fade(from: 0, to: 1)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {[weak self] in
                self?.hide()
            }
        }
    }

    /// Hide toast right now.
    func hide() {
        if reverseAnimateWhenHide {
            if animateStyle == .bottom {
                slide(in: false)
                return
            }
        }
        fade(from: 1, to: 0)
    }
}

//MARK: - Creations & Calculate
fileprivate extension DOToast {

    /// Create content view.
    func createContentView() {
        contentView = UIView()
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        addSubview(contentView)
    }

    /// Create text view.
    func createTextView() {
        textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        contentView.addSubview(textView)
        textView.fillToSuperview(edges: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }

    /// Calculate height of texts.
    func size(of text: String, estimateWidth width: CGFloat) -> CGSize {
        let esSize = CGSize(width: width, height: CGFloat.infinity)
        let rect = (text as NSString).boundingRect(with: esSize,
                                                   options: .usesLineFragmentOrigin,
                                                   attributes: [.font: font],
                                                   context: nil)
        if animateStyle == .center {
            if rect.height > width && width < sWidth / 2 {
                return size(of: text, estimateWidth: width + font.pointSize * 2)
            }
        } else {
            if rect.height > width && width < sWidth * 0.75 {
                return size(of: text, estimateWidth: width + font.pointSize * 2)
            }
        }
        return rect.size
    }
}

//MARK: - Animations
fileprivate extension DOToast {

    /// Fade animate.
    func fade(from: CGFloat, to: CGFloat) {
        self.alpha = from
        UIView.animate(withDuration: 0.35, animations: {[weak self] in
            self?.alpha = to
        }) {[weak self] _ in
            if to <= 0 {
                self?.removeFromSuperview()
            }
        }
    }

    /// Slide from bottom.
    func slide(in isIn: Bool) {
        let to: CGFloat
        if isIn {
            to = sHeight - contentView.frame.height - 55
        } else {
            to = sHeight * 2
        }
        UIView.animate(withDuration: 0.35, animations: {[weak self] in
            self?.contentView.frame.origin.y = to
        }) {[weak self] _ in
            if !isIn {
                self?.removeFromSuperview()
            }
        }
    }
}
