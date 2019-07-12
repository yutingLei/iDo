//
//  IDOPopover.swift
//  An object that used to tip/display/select
//
//  Created by admin on 2019/6/13.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

/// Protocol
@objc public protocol IDOPopoverProtocol: NSObjectProtocol {}

public extension IDOPopover {
    /// Reference location
    enum ReferenceLocation {
        case left
        case right
        case top
        case bottom
        case auto
    }

    /// How is the popover shown with animations
    enum AnimationStyle {
        case fade
        case expand
        case zoomScale
    }

    /// Alignment
    enum Alignment {
        case left
        case right
        case center
    }
}

/// An abstract class for Popover, don't used it directly,
/// using TextPopover/ImagePopover/TablePopover or subclassed instead.
public class IDOPopover: UIView {

    /// Reference view
    public var referenceView: UIView!

    /// The delegate
    public var delegate: IDOPopoverProtocol?

    /// Is sharp contrast(default true)
    public var isSharpContrast = true { didSet { setSharpContrast() } }

    /// Where is Popover located at referece view
    public var referenceLocation: ReferenceLocation = .auto

    /// How is the popover shown with animations
    public var animationStyle: AnimationStyle = .fade

    /// Drawing an arrow and arrowed to reference view
    public var isArrowed = true

    /// Fixed content size
    public var fixedContentSize: CGSize?

    /// The arrow's height
    var arrowHeight: CGFloat { get { return isArrowed ? 8 : 0 } }

    /// The containerView
    var containerView = UIView()

    /// The contentView
    var contentView = UIView()

    /// The main screen's w/h
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    /// The status bar's height
    lazy var statusHeight = UIApplication.shared.statusBarFrame.height
    lazy var minX: CGFloat = 8
    lazy var minY: CGFloat = statusHeight + 8
    lazy var maxX: CGFloat = screenWidth - 8
    lazy var maxY: CGFloat = screenHeight - 8
    lazy var maxW: CGFloat = screenWidth - 16
    lazy var maxH: CGFloat = screenHeight - statusHeight - 16

    /// Init
    init() {
        super.init(frame: UIScreen.main.bounds)
        alpha = 0
        backgroundColor = UIColor.black.withAlphaComponent(0.15)
        addSubview(containerView)

        containerView.backgroundColor = .clear
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 1.5, height: 0)
        containerView.addSubview(contentView)

        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Touch events
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            if !containerView.frame.contains(point) {
                dismiss()
            }
        }
    }
}

//MARK: - Show & Hide
public extension IDOPopover {
    /// Show
    @objc func show() {
        /// Added to window
        if superview == nil {
            UIApplication.shared.keyWindow?.addSubview(self)

            /// With animations
            showWithAnimations()
        }
    }

    /// Dismission
    @objc func dismiss() {
        dismissWithAnimations()
    }
}

//MARK: - Set property
extension IDOPopover {
    /// Set contrast
    func setSharpContrast() {
        backgroundColor = isSharpContrast ? UIColor.black.withAlphaComponent(0.15) : .clear
    }

    /// The arrow's anchor
    func arrowsAnchor() -> CGPoint {
        let refRect = referenceView.convert(referenceView.bounds, to: UIApplication.shared.keyWindow)
        let midY: CGFloat = refRect.midY - containerView.frame.minY
        let midX: CGFloat = refRect.midX - containerView.frame.minX
        switch referenceLocation {
        case .left: return CGPoint(x: contentView.frame.width, y: midY)
        case .right: return CGPoint(x: 0, y: midY)
        default:
            if isContainerViewLocatedAtTop {
                return CGPoint(x: midX, y: contentView.frame.height)
            } else {
                return CGPoint(x: midX, y: 0)
            }
        }
    }

    /// Draw arrow
    func drawArrow() {

        /// Remove shapeLayer first
        contentView.layer.mask = nil

        /// Then, create
        if isArrowed {
            let bezierPath: UIBezierPath

            switch referenceLocation {
            case .left:
                bezierPath = UIBezierPath(roundedRect: contentView.bounds.sub(dw: arrowHeight), cornerRadius: 5)

                let rc = arrowsAnchor()
                bezierPath.move(to: rc)
                bezierPath.addLine(to: rc.offset(dx: -arrowHeight, dy: arrowHeight))
                bezierPath.addLine(to: rc.offset(dx: -arrowHeight, dy: -arrowHeight))
                bezierPath.addLine(to: rc)
            case .right:
                bezierPath = UIBezierPath(roundedRect: contentView.bounds.offset(dx: 8), cornerRadius: 5)

                let lc = arrowsAnchor()
                bezierPath.move(to: lc)
                bezierPath.addLine(to: lc.offset(dx: arrowHeight, dy: arrowHeight))
                bezierPath.addLine(to: lc.offset(dx: arrowHeight, dy: -arrowHeight))
                bezierPath.addLine(to: lc)
            default:
                if isContainerViewLocatedAtTop {
                    bezierPath = UIBezierPath(roundedRect: contentView.bounds.sub(dh: arrowHeight), cornerRadius: 5)
                    let bc = arrowsAnchor()
                    bezierPath.move(to: bc)
                    bezierPath.addLine(to: bc.offset(dx: -arrowHeight, dy: -arrowHeight))
                    bezierPath.addLine(to: bc.offset(dx: arrowHeight, dy: -arrowHeight))
                    bezierPath.addLine(to: bc)
                } else {
                    bezierPath = UIBezierPath(roundedRect: contentView.bounds.offset(dy: arrowHeight), cornerRadius: 5)
                    let tc = arrowsAnchor()
                    bezierPath.move(to: tc)
                    bezierPath.addLine(to: tc.offset(dx: -arrowHeight, dy: arrowHeight))
                    bezierPath.addLine(to: tc.offset(dx: arrowHeight, dy: arrowHeight))
                    bezierPath.addLine(to: tc)
                }
            }
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = bezierPath.cgPath
            contentView.layer.mask = shapeLayer
        }
    }
}

//MARK: - Calculates
extension IDOPopover {

    /// Whether the containerView located top at referenceView
    var isContainerViewLocatedAtTop: Bool {
        get {
            let refRect = referenceView.convert(referenceView.bounds, to: UIApplication.shared.keyWindow)
            return (referenceLocation == .top || (referenceLocation == .auto && refRect.midY > screenHeight / 2))
        }
    }

    /// Calculate containerView's size
    private func containerViewSize(with contentSize: CGSize) {
        if let fixedContentSize = fixedContentSize {
            containerView.frame.size = fixedContentSize
        }

        let refRect = referenceView.convert(referenceView.bounds, to: UIApplication.shared.keyWindow)
        if containerView.frame.width == 0 || (fixedContentSize == nil && contentSize.width != containerView.frame.width) {
            switch referenceLocation {
            case .left:
                containerView.frame.size.width = min(contentSize.width + 16 + arrowHeight, refRect.minX - minX)
            case .right:
                containerView.frame.size.width = min(contentSize.width + 16 + arrowHeight, maxX - refRect.maxX)
            default: containerView.frame.size.width = min(contentSize.width + 16, maxW)
            }
        }
        if containerView.frame.height == 0 || (fixedContentSize == nil && contentSize.width != containerView.frame.width) {
            switch referenceLocation {
            case .left, .right: containerView.frame.size.height = min(contentSize.height + 16, maxH)
            default:
                if isContainerViewLocatedAtTop {
                    containerView.frame.size.height = min(contentSize.height + 16 + arrowHeight, refRect.minY - minY)
                } else {
                    containerView.frame.size.height = min(contentSize.height + 16 + arrowHeight, maxY - refRect.maxY)
                }
            }
        }
        containerView.frame.size.width = min(maxW, containerView.frame.width)
        containerView.frame.size.height = min(maxH, containerView.frame.height)
    }

    /// Calculate containerView's frame
    private func containerViewOrigin() {
        var x, y: CGFloat
        let refRect = referenceView.convert(referenceView.bounds, to: UIApplication.shared.keyWindow)
        switch referenceLocation {
        case .left:
            x = refRect.minX - containerView.frame.width
            y = max(minY, min(refRect.midY - containerView.frame.height / 2, maxY - containerView.frame.height))
            if x < 8 { x = 8 }
        case .right:
            x = refRect.maxX
            y = max(minY, min(refRect.midY - containerView.frame.height / 2, maxY - containerView.frame.height))
        default:
            if isContainerViewLocatedAtTop {
                x = max(minX, min(refRect.midX - containerView.frame.width / 2, maxX - containerView.frame.width))
                y = refRect.minY - containerView.frame.height
            } else {
                x = max(minX, min(refRect.midX - containerView.frame.width / 2, maxX - containerView.frame.width))
                y = refRect.maxY
            }
        }

        containerView.frame.origin = CGPoint(x: x, y: y)
    }
    
    /// Calculate containerView's rect
    func containerViewRect(with contentSize: CGSize) {
        containerViewSize(with: contentSize)
        containerViewOrigin()

        /// Set contentView's rect
        contentView.frame = containerView.bounds
    }

    /// Calculate contentView's rect
    func layoutSubviewOfContentView(with subview: UIView) {
        switch referenceLocation {
        case .left:
            subview.frame = CGRect(origin: CGPoint(x: 8, y: 8),
                                   size: containerView.frame.size.add(dw: -16 - arrowHeight, dh: -16))
        case .right:
            subview.frame = CGRect(origin: CGPoint(x: 8 + arrowHeight, y: 8),
                                   size: containerView.frame.size.add(dw: -16 - arrowHeight, dh: -16))
        default:
            if isContainerViewLocatedAtTop {
                subview.frame = CGRect(origin: CGPoint(x: 8, y: 8),
                                       size: containerView.frame.size.add(dw: -16, dh: -16 - arrowHeight))
            } else {
                subview.frame = CGRect(origin: CGPoint(x: 8, y: 8 + arrowHeight),
                                       size: containerView.frame.size.add(dw: -16, dh: -16 - arrowHeight))
            }
        }
        drawArrow()
    }
}

//MARK: - Animations
extension IDOPopover {
    /// Show with animations
    func showWithAnimations() {
        let desRect = contentView.frame
        var oriRect = contentView.frame
        
        switch animationStyle {
        case .fade: break
        case .expand:
            switch referenceLocation {
            case .left:
                oriRect.origin.x += oriRect.width
                oriRect.size.width = 0
            case .right:
                oriRect.size.width = 0
            default:
                if isContainerViewLocatedAtTop {
                    oriRect.origin.y += oriRect.height
                    oriRect.size.height = 0
                } else {
                    oriRect.size.height = 0
                }
            }
        case .zoomScale:
            oriRect.origin = arrowsAnchor()
            oriRect.size = CGSize.zero
        }
        contentView.frame = oriRect
        UIView.animate(withDuration: 0.35) {[weak self] in
            self?.alpha = 1
            self?.contentView.frame = desRect
        }
    }

    /// Dismiss with animations
    func dismissWithAnimations() {
        UIView.animate(withDuration: 0.35, animations: {[weak self] in
            self?.alpha = 0
        }) {[weak self] _ in
            self?.removeFromSuperview()
        }
    }
}

//MARK: - Error
extension IDOPopover {
    func error(with code: Int, message: String) -> NSError {
        return NSError(domain: "com.ido.poper",
                       code: code,
                       userInfo: [NSLocalizedDescriptionKey: message])
    }
}
