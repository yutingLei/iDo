/**************************************************
*
* UITextField+Extension
*
* Extend properties and methods.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

public extension UITextField {

    /// Append something into left side.
    ///
    /// something: Maybe view, image, string e.g.
    /// size: The fixed size something.
    /// edge: padding to it's content view.
    /// clickable: If true, create button, else create a view.
    ///
    /// @note: if string too long, please use size to limit it.
    ///
    /// If you want to setting something:
    ///  (leftView as? <#YOU_WANT#>).<#property#> = <#value#>
    func append(_ something: Any,
                size: CGSize? = nil,
                edge: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
                clickable canClick: Bool = false)
    {
        if let image = something as? UIImage {
            let esEdge: CGFloat = edge.top + edge.bottom
            let esSize: CGFloat = frame.height - (esEdge * 2)
            let size = size ?? CGSize(width: esSize, height: esSize)
            let imageView = createImageView(with: image, size: size)
            setView(imageView, toLeft: false, edge: edge, clickable: canClick)
        } else if let text = something as? String {
            let label = createLabel(with: text, size: size)
            setView(label, toLeft: false, edge: edge, clickable: canClick)
        } else if let aView = something as? UIView {
            setView(aView, toLeft: false, edge: edge, clickable: canClick)
        }
    }

    /// Prepend something into right side
    ///
    /// something: Maybe view, image, string e.g.
    /// size: The fixed size something.
    /// edge: padding to it's content view.
    /// clickable: If true, create button, else create a view.
    ///
    /// @note: if string too long, please use size to limit it.
    ///
    /// If you want to setting something:
    ///  (rightView as? <#YOU_WANT#>).<#property#> = <#value#>
    func prepend(_ something: Any,
                 size: CGSize? = nil,
                 edge: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
                 clickable canClick: Bool = false)
    {
        if let image = something as? UIImage {
            let esEdge: CGFloat = edge.top + edge.bottom
            let esSize: CGFloat = frame.height - (esEdge * 2)
            let size = size ?? CGSize(width: esSize, height: esSize)
            let imageView = createImageView(with: image, size: size)
            setView(imageView, toLeft: true, edge: edge, clickable: canClick)
        } else if let text = something as? String {
            let label = createLabel(with: text, size: size)
            setView(label, toLeft: true, edge: edge, clickable: canClick)
        } else if let aView = something as? UIView {
            setView(aView, toLeft: true, edge: edge, clickable: canClick)
        }
    }

    /// Set left/right view.
    ///
    /// aView: Will be append/prepend to left/right view.
    /// size: The view's size.
    /// clickable: If true, create button intead.
    private func setView(_ aView: UIView,
                         toLeft isLeft: Bool,
                         edge: UIEdgeInsets,
                         clickable canClick: Bool)
    {
        /// Create content view to contain image view.
        let contentView: UIView
        let edgeHorizotal = edge.left + edge.right
        let edgeVertical = edge.top + edge.bottom
        let contentRect = CGRect(x: 0,
                                 y: 0,
                                 width: min(aView.frame.width + edgeHorizotal, frame.width),
                                 height: min(aView.frame.height + edgeVertical, frame.height))
        contentView = UIView(frame: contentRect)
        if canClick {
            let btn = UIButton(frame: contentRect)
            contentView.addSubview(btn)
            btn.fillToSuperview(edges: .zero)
        }
        contentView.clipsToBounds = true
        contentView.addSubview(aView)

        /// Align image center.
        aView.center = contentView.center

        /// Apply to left view.
        if isLeft {
            leftViewMode = .always
            leftView = contentView
        } else {
            rightViewMode = .always
            rightView = contentView
        }
        print("\(contentView.frame): \(aView.frame)")
    }

    /// Create image with image.
    private func createImageView(with image: UIImage, size: CGSize) -> UIImageView {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let imageView = UIImageView(frame: rect)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        return imageView
    }

    /// Create text label with text.
    private func createLabel(with text: String, size: CGSize? = nil) -> UILabel {
        let label: UILabel
        let font = UIFont.systemFont(ofSize: 14)
        if size != nil {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: size!.width, height: size!.height))
        } else {
            let esSize = CGSize(width: CGFloat.infinity, height: font.pointSize)
            let textSize = (text as NSString).boundingRect(with: esSize,
                                                           options: .usesLineFragmentOrigin,
                                                           attributes: [.font: UIFont.systemFont(ofSize: 14)],
                                                           context: nil).size

            /// Create label.
            label = UILabel(frame: CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height))
        }
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = text
        return label
    }
}
