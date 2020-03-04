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
        case fade
        case slide
        case none
    }
    /// It determinate pop aninations. default fade.
    public var animateStyle: AnimateStyle = .fade

    /// Define arrow alignment.
    public enum ArrowAlignment {
        case left
        case right
        case middle // default
    }

    /// Whether current popover is popped.
    private(set) public var isPopped = false

    /// The refer view to position popover.
    private(set) public var referView: UIView

    /// The container view that could be saw.
    /// It's control shadow/shape.
    internal(set) public var containerView: DOPopoverContainer!

    /// Use arrow to point to refer view, default true.
    public var useArrow = true { didSet { shouldUpdate = true } }
    /// Align arrow, default middle.
    /// But, if self beyond screen's boundary, it will be changed.
    public var arrowAlignment: ArrowAlignment = .middle { didSet { shouldUpdate = true } }

    /// The contentView that contains all components
    /// It's display content(such text, list view e.g.)
    internal(set) public var contentView: DOPopoverContent!

    /// The gaps between containerView with contentView.
    /// default is (8, 8, 8, 8)
    public var contentMargin: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    /// Fixed containerView's size.
    public var fixedContainerViewSize: CGSize?

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
            adjustmentContainerViewSize(by: direction)
        }
    }

    /// Show the popover with duartion
    ///
    /// duration: Continues display popover with given time.
    /// hideHandler: Handle event when popover hidden.
    @objc func show(duration: TimeInterval, hideHandler: OperateHandler? = nil) {
        self.hideHandler = hideHandler

        /// If is popped, ignore.
        guard !isPopped else { return }
    }

    /// Hide the popover.
    @objc func hide() {}
}

//MARK: - Position & Animation
extension DOPopover {

    /// Adjustment containerView's size.
    func adjustmentContainerViewSize(by direction: Direction) {
        let refRect = referView.convert(referView.bounds, to: UIApplication.shared.keyWindow)
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
        containerView.frame.size.width = min(maxWidth, containerView.frame.width + horizontalGap)
        containerView.frame.size.height = min(maxHeight, containerView.frame.height + verticalGap)
        setContentViewConstraints(by: direction)
    }

    /// Make constraints to contentView.
    func setContentViewConstraints(by direction: Direction) {
        let refRect = referView.convert(referView.bounds, to: UIApplication.shared.keyWindow)
        contentTop = contentTop ?? topToSuperview(distance: contentMargin.top)
        contentLeading = contentLeading ?? leadingToSuperview(distance: contentMargin.left)
        contentTrailing = contentTrailing ?? trailingToSuperview(distance: contentMargin.right)
        contentBottom = contentBottom ?? bottomToSuperview(distance: contentMargin.bottom)
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
    func adjustmentContainerViewPosition() {
        let refRect = referView.convert(referView.bounds, to: UIApplication.shared.keyWindow)
        var x: CGFloat = refRect.minX
        var y: CGFloat = refRect.minY
        var w: CGFloat = containerView.frame.width
        var h: CGFloat = containerView.frame.height
    }

    /// Start animating accroding to animate style.
    func startAnimating() {}
}

//MARK: - Container View
/// Please note that this view just suitable for Popover.
public class DOPopoverContainer: UIView {

    /// This view to control container view's shadow.
    public var shadowView: UIView!

    /// Init container view.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        createShadowView()
    }

    /// Create contentView.
    private func createShadowView() {
        shadowView = UIView()
        shadowView.backgroundColor = .white
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowRadius = 0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        shadowView.layer.opacity = 0.8
        addSubview(shadowView)
        shadowView.fillToSuperview(edges: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Content View
public class DOPopoverContent: UIView {}
