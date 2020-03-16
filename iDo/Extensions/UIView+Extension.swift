/**************************************************
*
* UIView+Extension
*
* Extend properties and methods.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

public extension UIView {

    /// Get owning controller.
    var owningController: UIViewController? {
        get {
            if next is UIViewController {
                return next as? UIViewController
            } else if next is UIView {
                return (next as? UIView)?.owningController
            } else {
                return nil
            }
        }
    }
}

//MARK: - Convenience Constraints

/// There are convenience methods to make constraints. but please note
/// that, there are must be invoked only once.
public extension UIView {

    /// Make top constraint to other view.
    ///
    /// view: Top to this view.
    /// constant: The distance between views.
    /// opposite: If true, top to view's bottom. else top to view's top.
    @discardableResult
    func top(to view: UIView, distance: CGFloat = 0, opposite: Bool = false) -> NSLayoutConstraint {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }

        let layout: NSLayoutConstraint
        if opposite {
            layout = topAnchor.constraint(equalTo: view.bottomAnchor, constant: distance)
        } else {
            layout = topAnchor.constraint(equalTo: view.topAnchor, constant: distance)
        }
        layout.isActive = true
        return layout
    }

    /// A convenience method to make top constraint with it's superview.
    @discardableResult
    func topToSuperview(distance: CGFloat = 0) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        return top(to: superview!, distance: distance)
    }


    /// Make leading constraint to other view.
    ///
    /// view: Leading to this view.
    /// constant: The distance between views.
    /// opposite: If true, leading to view's trailing. else leading to view's leading.
    @discardableResult
    func leading(to view: UIView, distance: CGFloat = 0, opposite: Bool = false) -> NSLayoutConstraint {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }

        let layout: NSLayoutConstraint
        if opposite {
            layout = leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: distance)
        } else {
            layout = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: distance)
        }
        layout.isActive = true
        return layout
    }

    /// A convenience method to make leading constraint with its superview.
    @discardableResult
    func leadingToSuperview(distance: CGFloat = 0) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        return leading(to: superview!, distance: distance)
    }


    /// Make trailing constraint with other view.
    ///
    /// view: Leading to this view.
    /// constant: The distance between views.
    /// opposite: If true, trailing to view's leading. else trailing to view's trailing.
    @discardableResult
    func trailing(to view: UIView, distance: CGFloat = 0, opposite: Bool = false) -> NSLayoutConstraint {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }

        let layout: NSLayoutConstraint
        if opposite {
            layout = trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: distance)
        } else {
            layout = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -distance)
        }
        layout.isActive = true
        return layout
    }

    /// A convenience method that make trailing constraint with it's superview.
    @discardableResult
    func trailingToSuperview(distance: CGFloat = 0) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        return trailing(to: superview!, distance: distance)
    }


    /// Make bottom constraint with other view.
    ///
    /// view: Bottom to this view.
    /// constant: The distance between views.
    /// opposite: If true, bottom to view's top. else bottom to view's bottom.
    @discardableResult
    func bottom(to view: UIView, distance: CGFloat = 0, opposite: Bool = false) -> NSLayoutConstraint {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }

        let layout: NSLayoutConstraint
        if opposite {
            layout = bottomAnchor.constraint(equalTo: view.topAnchor, constant: distance)
        } else {
            layout = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -distance)
        }
        layout.isActive = true
        return layout
    }

    /// A convenience method that make bottom constraint with it's superview.
    @discardableResult
    func bottomToSuperview(distance: CGFloat = 0) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        return bottom(to: superview!, distance: distance)
    }


    /// Make top/leading/trailing/bottom constraints with it's superview.
    ///
    /// edge: The distance to top/leading/trailing/bottom.
    /// @note: if edges.right > 0 indicate that it's superview contains view's right.
    /// about bottom, as above.
    ///
    /// @return: sory with top->leading->trailing->bottom.
    @discardableResult
    func fillToSuperview(edges: UIEdgeInsets) -> [NSLayoutConstraint] {
        assert(superview != nil, "You must add it into a view before make constraints.")
        let top = topToSuperview(distance: edges.top)
        let leading = leadingToSuperview(distance: edges.left)
        let trailing = trailingToSuperview(distance: edges.right)
        let bottom = bottomToSuperview(distance: edges.bottom)
        return [top, leading, trailing, bottom]
    }

    /// Make width constraint.
    ///
    /// aView: The refer view.
    /// scale: the width scale, default = 1.
    @discardableResult
    func equalWidth(to aView: UIView, scale: CGFloat = 1) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        let wc = widthAnchor.constraint(equalTo: aView.widthAnchor, multiplier: scale, constant: 0)
        wc.isActive = true
        return wc
    }

    /// Make width equal to it's superview.
    ///
    /// scale: The width scale, default = 1
    @discardableResult
    func equalToSuperviewWidth(scale: CGFloat = 1) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        return equalWidth(to: superview!, scale: scale)
    }

    /// Make width constraint with plain value.
    @discardableResult
    func width(_ value: CGFloat) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        let wc = widthAnchor.constraint(equalToConstant: value)
        wc.isActive = true
        return wc
    }

    /// Make height constraint.
    ///
    /// aView: The refer view.
    /// scaleHeight: the height scale, default = 1.
    @discardableResult
    func equalHeight(to aView: UIView, scale: CGFloat = 1) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        let hc = heightAnchor.constraint(equalTo: aView.heightAnchor, multiplier: scale, constant: 0)
        hc.isActive = true
        return hc
    }

    /// Make height equal to it's superview.
    ///
    /// scale: The height scale, default = 1
    @discardableResult
    func equalToSuperviewHeight(scale: CGFloat = 1) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        return equalHeight(to: superview!, scale: scale)
    }

    /// Make width constraint with plain value.
    @discardableResult
    func height(_ value: CGFloat) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        let hc = heightAnchor.constraint(equalToConstant: value)
        hc.isActive = true
        return hc
    }

    /// Make center constrains.
    ///
    /// aView: The refer view.
    /// offset: The delta offset refer to aView.
    ///
    /// @return: the first is X, then Y.
    @discardableResult
    func center(to aView: UIView, offset: CGPoint = .zero) -> [NSLayoutConstraint] {
        assert(superview != nil, "You must add it into a view before make constraints.")
        let cx = centerX(to: aView, offset: offset.x)
        let cy = centerY(to: aView, offset: offset.y)
        return [cx, cy]
    }

    /// Align center to superview.
    @discardableResult
    func centerToSuperview(offset: CGPoint = .zero) -> [NSLayoutConstraint] {
        assert(superview != nil, "You must add it into a view before make constraints.")
        return center(to: superview!, offset: offset)
    }

    /// Align x axis refer to a view.
    ///
    /// aView: The refer view.
    /// offset: Offset x value, default 0.
    @discardableResult
    func centerX(to aView: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        let cx = centerXAnchor.constraint(equalTo: aView.centerXAnchor, constant: offset)
        cx.isActive = true
        return cx
    }

    /// Align y axis refer to a view.
    ///
    /// aView: The refer view.
    /// offset: Offset y value, default 0.
    @discardableResult
    func centerY(to aView: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        assert(superview != nil, "You must add it into a view before make constraints.")
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        let cy = centerYAnchor.constraint(equalTo: aView.centerYAnchor, constant: offset)
        cy.isActive = true
        return cy
    }
}
