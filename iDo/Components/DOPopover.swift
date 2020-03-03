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

    /// Alias
    public typealias OperateHandler = ((Any?) -> Void)

    /// Define pop direction.
    public enum Direction {
        case auto
        case up
        case down
    }
    private(set) var direction: Direction

    /// Define pop animation.
    public enum AnimateStyle {
        case fade
        case slide
        case none
    }
    /// It determinate pop aninations. default fade.
    var animateStyle: AnimateStyle = .fade

    /// The refer view to position popover.
    private(set) var referView: UIView

    /// The container view that could be saw.
    /// It's control shadow/shape.
    private(set) var containerView: DOPopoverContainer!

    /// The contentView that contains all components
    /// It's display content(such text, list view e.g.)
    private(set) var contentView: UIView!

    /// Is containerView fixed by referView, default false.
    /// if false, adjustment containerView refer to screen.
    public var fixedContainerView = false

    /// Fixed containerView's size.
    public var fixedContainerViewSize: CGSize?

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
    @objc func show(_ operateHandler: OperateHandler? = nil) {}

    /// Show the popover with duartion
    ///
    /// duration: Continues display popover with given time.
    /// hideHandler: Handle event when popover hidden.
    @objc func show(duration: TimeInterval, hideHandler: OperateHandler? = nil) {}

    /// Hide the popover.
    @objc func hide() {}
}

//MARK: - Animations
extension DOPopover {

    /// Start animating accroding to animate style.
    func startAnimating() {}
}

//MARK: - Container View
/// Please note that this view just suitable for Popover.
public class DOPopoverContainer: UIView {

    /// Define arrow alignment.
    public enum Align {
        case left
        case right
        case middle // default
    }

    /// Shadow effect.
    /// The shadow color, default lightGray.
    public var shadowColor: UIColor = .lightGray
    /// The shadow radius, default 0.
    public var shadowRadius: CGFloat = 0
    /// The shadow offset, expand Y to 3/-3(determin by Direction).
    public var shadowOffset: CGFloat = 3
    /// The shadow opacity, default 0.8.
    public var shadowOpcity: CGFloat = 0.8

    /// Use arrow to point to refer view, default true.
    public var useArrow = true
    /// Align arrow, default middle.
    /// But, if self beyond screen's boundary, it will be changed.
    public var arrowAlignment: Align = .middle

    /// Init container view.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
