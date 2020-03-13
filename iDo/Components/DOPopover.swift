/**************************************************
*
* DOPopover
*
* An abstract class for popovers.
*
* Frame:
* +-------------------------------+
* |         Popover View          |
* |    +---------------------+    |
* |    |      Container      |    |
* |    |  +---------------+  |    |
* |    |  |     Content   |  |    |
* |    |  +---------------+  |    |
* |    +---------------------+    |
* +-------------------------------+
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

public class DOPopover: UIView {

    /// Get screen's width and height.
    let sWidth       = UIScreen.main.bounds.width
    let sHeight      = UIScreen.main.bounds.height

    /// Get status bar's height.
    let statusHeight = UIApplication.shared.statusBarFrame.height
    /// Get gaps between containerView with screen.
    let gap: CGFloat = 10

    /// Alias
    public typealias OperateHandler = ((Any?) -> Void)

    /// Define pop direction.
    public enum Direction {
        case auto
        case up
        case down
        case left
        case right
    }
    private(set) public var direction: Direction

    /// Define pop animation.
    public enum AnimateStyle {
        case fadeInOut
        case slideInOut
        case slideInFadeOut
        case none
    }
    /// It determinate pop aninations. default fade.
    public var animateStyle: AnimateStyle = .fadeInOut

    /// Whether current popover is popped.
    private(set) public var isPopped = false

    /// The refer view to position popover.
    private(set) public var referView: UIView
    internal var refRect: CGRect {
        get {
            return referView.convert(referView.bounds, to: UIApplication.shared.keyWindow)
        }
    }

    /// The shadow view that control the shadow effects.
    internal(set) public var shadowView: DOPopoverShadow!

    /// About corners & borders.
    ///
    /// Clip corner with radius. default 5.
    /// Affect corners by your given. default all.
    public var cornerRadius: CGFloat = 5
    public var affectCorners: UIRectCorner = .allCorners
    /// Set border width and color. default 1 "DFDFDF"
    public var borderWidth: CGFloat = 1
    public var borderColor: UIColor = UIColor(hex: "DFDFDF")!

    /// Use arrow to point to refer view, default true.
    public var useArrow = true { didSet { shouldUpdate = true } }

    /// The contentView that contains all components
    /// It's display content(such text, list view e.g.)
    internal(set) public var contentView: DOPopoverContent!

    /// The gaps between containerView with contentView.
    /// default is (8, 8, 8, 8)
    public var contentMargin: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    /// Fixed the view size that display the contents.
    public var fixedPopoverSize: CGSize?

    //MARK: Private
    /// These constraints are constraint with contentView.
    private var contentTop: NSLayoutConstraint?
    private var contentLeading: NSLayoutConstraint?
    private var contentTrailing: NSLayoutConstraint?
    private var contentBottom: NSLayoutConstraint?

    /// Whether update contents.
    var shouldUpdate = true

    /// The operate handler.
    var operateHandler: OperateHandler?
    var hideHandler: OperateHandler?

    /// Define init method(Use subclass to pop something).
    ///
    /// referView: A refer view.
    /// direction: Pop direction.
    public init(referView: UIView, popDirection direction: Direction = .auto) {
        self.referView = referView
        self.direction = direction
        super.init(frame: UIApplication.shared.keyWindow?.bounds ?? .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Touch outside of contents. auto hide.
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            if !shadowView.frame.contains(loc) {
                guard let _ = hideHandler else {
                    hide()
                    return
                }
            }
        }
    }
}

//MARK: - Show & Hide
public extension DOPopover {

    /// Show the popover, subclass must override this method.
    ///
    /// operationHandler: User interat with content view.
    /// For example: in list view, select one of items.
    @objc func show(_ operateHandler: OperateHandler? = nil) {
        self.operateHandler = operateHandler

        /// If is popped, ignore.
        guard !isPopped else { return }
        if shouldUpdate {
            if let fixedSize = fixedPopoverSize {
                shadowView.frame.size = fixedSize
            } else {
                adjustmentContainerViewSize(by: direction)
            }
            adjustmentContainerViewPosition(by: direction)
        }

        /// Add to key window.
        if superview == nil {
            UIApplication.shared.keyWindow?.addSubview(self)
        }

        /// Start animating.
        startAnimating()
    }

    /// Show the popover with duartion, and can't be hide in
    /// durations
    ///
    /// duration: Continues display popover with given time.
    /// hideHandler: Handle event when popover hidden.
    @objc func show(duration: TimeInterval, hideHandler: OperateHandler? = nil) {
        self.hideHandler = hideHandler

        /// If is popped, ignore.
        guard !isPopped else { return }
        if shouldUpdate {
            if let fixedSize = fixedPopoverSize {
                shadowView.frame.size = fixedSize
            } else {
                adjustmentContainerViewSize(by: direction)
            }
            adjustmentContainerViewPosition(by: direction)
        }

        /// Add to key window.
        if superview == nil {
            UIApplication.shared.keyWindow?.addSubview(self)
        }

        /// Start animating.
        startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hide()
        }
    }

    /// Hide the popover.
    @objc func hide() {
        reverseAnimation()
    }
}

//MARK: - Position & Animation
extension DOPopover {

    /// Adjustment containerView's size.
    func adjustmentContainerViewSize(by direction: Direction) {
        /// According to direction, adjustment origin.
        let maxWidth: CGFloat
        let maxHeight: CGFloat
        var verticalGap: CGFloat = 0
        var horizontalGap: CGFloat = 0
        var contentOffsetX: CGFloat = contentMargin.left
        var contentOffsetY: CGFloat = contentMargin.top
        switch direction {
        case .left:
            maxWidth = refRect.minX - (useArrow ? 10 : 0) - gap
            maxHeight = sHeight - statusHeight - gap * 2
            horizontalGap = 10
        case .right:
            maxWidth = sWidth - gap - (useArrow ? 10 : 0) - refRect.maxX
            maxHeight = sHeight - statusHeight - gap * 2
            horizontalGap = 10
            contentOffsetX += 10
        case .up:
            verticalGap = 10
            maxWidth = sWidth - gap * 2
            maxHeight = refRect.minY - statusHeight - gap
        case .down:
            verticalGap = 10
            maxWidth = sWidth - gap * 2
            maxHeight = sHeight - refRect.maxY - gap
            contentOffsetY += 10
        default:
            if refRect.midY >= (sHeight - statusHeight) / 2 {
                adjustmentContainerViewSize(by: .up)
            } else {
                adjustmentContainerViewSize(by: .down)
            }
            return
        }
        if !useArrow {
            verticalGap = 0
            horizontalGap = 0
            contentOffsetX = contentMargin.left
            contentOffsetY = contentMargin.top
        }
        shadowView.frame.size.width = min(maxWidth, shadowView.frame.width + horizontalGap)
        shadowView.frame.size.height = min(maxHeight, shadowView.frame.height + verticalGap)
        setContentViewConstraints(by: direction)
    }

    /// Make constraints to contentView.
    func setContentViewConstraints(by direction: Direction) {
        contentTop = contentTop ?? contentView.topToSuperview(distance: contentMargin.top)
        contentLeading = contentLeading ?? contentView.leadingToSuperview(distance: contentMargin.left)
        contentTrailing = contentTrailing ?? contentView.trailingToSuperview(distance: contentMargin.right)
        contentBottom = contentBottom ?? contentView.bottomToSuperview(distance: contentMargin.bottom)
        switch direction {
        case .left:
            contentTrailing?.constant += (useArrow ? -10 : 0)
        case .right:
            contentLeading?.constant += (useArrow ? 10 : 0)
        case .up:
            contentBottom?.constant += (useArrow ? -10 : 0)
        case .down:
            contentTop?.constant += (useArrow ? 10 : 0)
        default:
            if refRect.midY >= (sHeight - statusHeight) / 2 {
                setContentViewConstraints(by: .up)
            } else {
                setContentViewConstraints(by: .down)
            }
            return
        }
    }

    /// Adjustment containerView's position.
    ///
    /// before invoke this method, please generate
    /// containerView and contentView.
    func adjustmentContainerViewPosition(by direction: Direction) {
        let x: CGFloat
        let y: CGFloat
        let w = shadowView.frame.width
        let h = shadowView.frame.height
        let minY: CGFloat = statusHeight + gap
        switch direction {
        case .left:
            x = refRect.minX - w
            y = max(minY, refRect.midY - h / 2)
        case .right:
            x = refRect.maxX
            y = max(minY, refRect.midY - h / 2)
        case .up:
            x = refRect.midX - w / 2
            y = refRect.minY - h
        case .down:
            x = refRect.midX - w / 2
            y = refRect.maxY
        default:
            if refRect.midY >= (sHeight - statusHeight) / 2 {
                adjustmentContainerViewPosition(by: .up)
            } else {
                adjustmentContainerViewPosition(by: .down)
            }
            return
        }

        /// Adjustment x
        if (x + w) > (sWidth - gap) {
            shadowView.frame.origin.x = max(gap, (x + w) - (sWidth - gap))
        } else {
            shadowView.frame.origin.x = x
        }
        shadowView.frame.origin.y = y
    }

    /// Start animating accroding to animate style.
    func startAnimating() {
        /// Fade animation
        switch animateStyle {
        case .fadeInOut: fade(from: 0, to: 1)
        case .slideInOut, .slideInFadeOut:
            alpha = 1
            slide(in: true)
        default:
            break
        }
    }

    /// Reverse animations while hide popover.
    func reverseAnimation() {
        switch animateStyle {
        case .fadeInOut, .slideInFadeOut: fade(from: 1, to: 0)
        case .slideInOut: slide(in: false)
        default:
            hideHandler?(nil)
            removeFromSuperview()
        }
    }

    /// Fade animation.
    func fade(from: CGFloat, to: CGFloat) {
        alpha = from
        UIView.animate(withDuration: 0.35, animations: {
            self.alpha = to
        }) { (_) in
            if to < 1 {
                self.hideHandler?(nil)
                self.removeFromSuperview()
            }
        }
    }

    /// Slide animation.
    func slide(in isIn: Bool) {
        var direction = self.direction
        if direction == .auto {
            if refRect.midY >= (sHeight - statusHeight) / 2 {
                direction = .up
            } else {
                direction = .down
            }
        }

        /// Height & Width
        let height = shadowView.frame.height
        let width = shadowView.frame.width
        var from: CGRect = shadowView.bounds
        var to: CGRect = shadowView.bounds
        switch direction {
        case .up:
            if isIn {
                from = from.resize(height: -height, fixed: .bottom)
            } else {
                to = to.resize(height: -height / 2, fixed: .bottom)
            }
        case .down:
            if isIn {
                from = from.resize(height: -height, fixed: .top)
            } else {
                to = to.resize(height: -height / 2, fixed: .top)
            }
        case .left:
            if isIn {
                from = from.resize(width: -width, fixed: .right)
            } else {
                to = to.resize(width: -width / 2, fixed: .right)
            }
        default:
            if isIn {
                from = from.resize(width: -width, fixed: .left)
            } else {
                to = to.resize(width: -width / 2, fixed: .left)
            }
        }
        if isIn {
            shadowView.animationContainerView.frame = from
        }

        /// Start animating.
        UIView.animate(withDuration: 0.35, animations: {
            self.shadowView.animationContainerView.frame = to
            if !isIn {
                self.alpha = 0
                self.shadowView.animationContainerView.layoutIfNeeded()
            }
        }) { _ in
            if !isIn {
                self.hideHandler?(nil)
                self.removeFromSuperview()
            }
        }
    }
}

//MARK: - Shadow View
/// This view only control shadow effects.
/// Don't set maskToBounds or clipToBounds properties,
/// set for containerView instead.
public class DOPopoverShadow: UIView {

    /// The animated view. this view control
    /// display animations.
    internal var animationContainerView: UIView!

    /// The container view that contains everything.
    /// It's control the shape of contents.
    internal var containerView: DOPopoverContainer!

    /// Init container view.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.8
        layer.shadowColor = UIColor.lightGray.cgColor
        createAnimateContainerView()
    }
    
    /// Create animate container view.
    private func createAnimateContainerView() {
        animationContainerView = UIView()
        animationContainerView.clipsToBounds = true
        animationContainerView.backgroundColor = .clear
        addSubview(animationContainerView)
        createContainerView()
    }
    
    /// Create container view.
    private func createContainerView() {
        containerView = DOPopoverContainer()
        containerView.backgroundColor = .white
        animationContainerView.addSubview(containerView)
        containerView.fillToSuperview(edges: .zero)
    }

    /// While draw shadow view, reset shadow effects.
    public override func draw(_ rect: CGRect) {
        guard let popover = superview as? DOPopover else { return }
        switch popover.direction {
        case .up: layer.shadowOffset = CGSize(width: 0, height: -3)
        case .down: layer.shadowOffset = CGSize(width: 0, height: 3)
        case .left: layer.shadowOffset = CGSize(width: -3, height: 0)
        case .right: layer.shadowOffset = CGSize(width: 3, height: 0)
        default:
            /// First, defined direction.
            let refRect = popover.refRect
            if refRect.midY >= (popover.sHeight - popover.statusHeight) / 2 {
                layer.shadowOffset = CGSize(width: 0, height: -3)
            } else {
                layer.shadowOffset = CGSize(width: 0, height: 3)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Container View
/// This view control the shape of display contents,
/// like a arrow or border e.g.
public class DOPopoverContainer: UIView {

    /// The corner layer.
    private var shapeLayer: CAShapeLayer?

    /// Draw arrow if needed.
    public override func draw(_ rect: CGRect) {
        guard let shadowView = superview?.superview else { return }
        guard let popover = shadowView.superview as? DOPopover else { return }
        guard popover.useArrow else { return }

        /// First, defined direction.
        let refRect = popover.refRect
        var direction = popover.direction
        if direction == .auto {
            if refRect.midY >= (popover.sHeight - popover.statusHeight) / 2 {
                direction = .up
            } else {
                direction = .down
            }
        }

        /// second, locate arrow.
        let ax: CGFloat
        let ay: CGFloat
        let path = CGMutablePath()

        /// Get maxX and maxY
        let mx = bounds.maxX
        let my = bounds.maxY
        let r  = popover.cornerRadius
        let cs = popover.affectCorners

        /// Start drawing.
        switch direction {
        case .up:
            ax = refRect.midX - shadowView.frame.minX
            ay = bounds.maxY
            path.move(to: CGPoint(x: ax, y: ay))
            path.addLine(to: CGPoint(x: ax - 10, y: ay - 10))
            path.addLine(to: CGPoint(x: r, y: ay - 10))
            path.add(.bottomLeft, with: (0, ay - 10 - r, r, cs.contains(.bottomLeft)))
            path.addLine(to: CGPoint(x: 0, y: r))
            path.add(.topLeft, with: (r, 0, r, cs.contains(.topLeft)))
            path.addLine(to: CGPoint(x: mx - r, y: 0))
            path.add(.topRight, with: (mx, r, r, cs.contains(.topRight)))
            path.addLine(to: CGPoint(x: mx, y: my - 10 - r))
            path.add(.bottomRight, with: (mx - r, my - 10, r, cs.contains(.bottomRight)))
            path.addLine(to: CGPoint(x: ax + 10, y: ay - 10))
        case .down:
            ax = refRect.midX - shadowView.frame.minX
            ay = 0
            path.move(to: CGPoint(x: ax, y: ay))
            path.addLine(to: CGPoint(x: ax + 10, y: ay + 10))
            path.addLine(to: CGPoint(x: mx - r, y: 10))
            path.add(.topRight, with: (mx, 10 + r, r, cs.contains(.topRight)))
            path.addLine(to: CGPoint(x: mx, y: my - r))
            path.add(.bottomRight, with: (mx - r, my, r, cs.contains(.bottomRight)))
            path.addLine(to: CGPoint(x: r, y: my))
            path.add(.bottomLeft, with: (0, my - r, r, cs.contains(.bottomLeft)))
            path.addLine(to: CGPoint(x: 0, y: 10 + r))
            path.add(.topLeft, with: (r, 10, r, cs.contains(.topLeft)))
            path.addLine(to: CGPoint(x: ax - 10, y: 10))
        case .left:
            ax = bounds.maxX
            ay = refRect.midY - shadowView.frame.minY
            path.move(to: CGPoint(x: ax, y: ay))
            path.addLine(to: CGPoint(x: ax - 10, y: ay + 10))
            path.addLine(to: CGPoint.init(x: ax - 10, y: my - r))
            path.add(.bottomRight, with: (ax - 10 - r, my, r, cs.contains(.bottomRight)))
            path.addLine(to: CGPoint(x: r, y: my))
            path.add(.bottomLeft, with: (0, my - r, r, cs.contains(.bottomLeft)))
            path.addLine(to: CGPoint(x: 0, y: r))
            path.add(.topLeft, with: (r, 0, r, cs.contains(.topLeft)))
            path.addLine(to: CGPoint(x: mx - 10 - r, y: 0))
            path.add(.topRight, with: (mx - 10, r, r, cs.contains(.topRight)))
            path.addLine(to: CGPoint(x: ax - 10, y: ay - 10))
        default:
            ax = 0
            ay = refRect.midY - shadowView.frame.minY
            path.move(to: CGPoint(x: ax, y: ay))
            path.addLine(to: CGPoint(x: ax + 10, y: ay - 10))
            path.addLine(to: CGPoint(x: ax + 10, y: r))
            path.add(.topLeft, with: (ax + 10 + r, 0, r, cs.contains(.topLeft)))
            path.addLine(to: CGPoint(x: mx - r, y: 0))
            path.add(.topRight, with: (mx, r, r, cs.contains(.topRight)))
            path.addLine(to: CGPoint(x: mx, y: my - r))
            path.add(.bottomRight, with: (mx - r, my, r, cs.contains(.bottomRight)))
            path.addLine(to: CGPoint(x: ax + 10 + r, y: my))
            path.add(.bottomLeft, with: (ax + 10, my - r, r, cs.contains(.bottomLeft)))
            path.addLine(to: CGPoint(x: ax + 10, y: ay + 10))
        }
        path.closeSubpath()

        /// clip layer with path.
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.path = path
        layer.mask = shapeLayer

        /// If border width > 0
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.beginPath()
        if popover.borderWidth > 0 {
            ctx?.setLineWidth(popover.borderWidth)
            ctx?.setStrokeColor(popover.borderColor.cgColor)
            ctx?.addPath(path)
            ctx?.strokePath()
        }
    }
}

//MARK: - Content View
/// This view display the details.
public class DOPopoverContent: UIView {}

internal extension CGMutablePath {

    /// Add cornerPath
    ///
    /// corner: which corner should be added.
    /// option: x point -> y point -> radiu -> isAffected
    func add(_ corner: UIRectCorner, with option: (CGFloat, CGFloat, CGFloat, Bool)) {
        let (x, y, r, isAffected) = option
        if corner.rawValue == UIRectCorner.topLeft.rawValue {
            if isAffected {
                addQuadCurve(to: CGPoint(x: x, y: y),
                             control: CGPoint(x: x - r, y: y))
            } else {
                addLine(to: CGPoint(x: x - r, y: y))
                addLine(to: CGPoint(x: x, y: y))
            }
        } else if corner.rawValue == UIRectCorner.topRight.rawValue {
            if isAffected {
                addQuadCurve(to: CGPoint(x: x, y: y),
                             control: CGPoint(x: x, y: y - 5))
            } else {
                addLine(to: CGPoint(x: x, y: y - r))
                addLine(to: CGPoint(x: x, y: y))
            }
        } else if corner.rawValue == UIRectCorner.bottomRight.rawValue {
            if isAffected {
                addQuadCurve(to: CGPoint(x: x, y: y),
                             control: CGPoint(x: x + 5, y: y))
            } else {
                addLine(to: CGPoint(x: x + r, y: y))
                addLine(to: CGPoint(x: x, y: y))
            }
        } else {
            if isAffected {
                addQuadCurve(to: CGPoint(x: x, y: y),
                             control: CGPoint(x: x, y: y + 5))
            } else {
                addLine(to: CGPoint(x: x, y: y + r))
                addLine(to: CGPoint(x: x, y: y))
            }
        }
    }
}
