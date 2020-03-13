/**************************************************
*
* CG+Extension
*
* Extend properties and methods.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

//MARK: - CGPoint
public extension CGPoint {

    /// Make point offset.
    ///
    /// x: Offset x value.
    /// y: Offset y value
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        var p = self
        p.x += x
        p.y += y
        return p
    }

    /// Get distance between self with other point.
    ///
    /// p: The other point.
    /// @note: the result value must be positive.
    func distance(to p: CGPoint) -> CGFloat {
        let dx = abs(x - p.x)
        let dy = abs(y - p.y)
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
}

//MARK: - CGSize
public extension CGSize {

    /// Extend width and height.
    ///
    /// width: Extend or unfold width.
    /// height: Extend or unfold height.
    func extend(width: CGFloat = 0, height: CGFloat = 0) -> CGSize {
        var s = self
        s.width += width
        s.height += height
        return s
    }
}

//MARK: - CGRect
public extension CGRect {

    /// Fixed the size and offset origin point.
    ///
    /// x: Offset x value.
    /// y: Offset y value.
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGRect {
        return CGRect(origin: origin.offset(x: x, y: y), size: size)
    }

    /// Fixed the origin and extend size.
    ///
    /// width: Extend width value.
    /// height: Extend height value.
    func extend(width: CGFloat = 0, height: CGFloat = 0) -> CGRect {
        return CGRect(origin: origin, size: size.extend(width: width, height: height))
    }

    /// Enum location.
    enum Point {
        case top
        case left
        case right
        case bottom
        case center
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    /// Resize with given width and height.
    ///
    /// width: Add or subtract width value.
    /// height: Add or subtract height value.
    /// point: Fixed the point, so it's maybe affect origin.
    /// case top: fixed y, and x += (o.width - n.width) / 2
    /// case left: fixed x, and y += (o.height - n.height) / 2
    /// case right: x += (o.width - n.width), y += (o.height - n.height) / 2
    /// case bottom: x += (o.width - n.width) / 2, y += (o.height - n.height)
    /// case center: x += (o.width - n.width) / 2, y += (o.height - n.height) / 2
    /// case topLeft: fixed x and y
    /// case topRight: fixed y, x += (o.width - n.width)
    /// case bottomLeft: fixed x, y += (o.height - n.height)
    /// case bottomRight: x += (o.width - n.width), y += (o.heigth - n.height)
    func resize(width: CGFloat = 0, height: CGFloat = 0, fixed point: Point = .center) -> CGRect {
        var s = size
        s.width += width
        s.height += height

        var p = origin
        switch point {
        case .top:
            p.x += (size.width - s.width) / 2
        case .left:
            p.y += (size.height - s.height) / 2
        case .right:
            p.x += (size.width - s.width)
            p.y += (size.height - s.height) / 2
        case .bottom:
            p.x += (size.width - s.width) / 2
            p.y += (size.height - s.height)
        case .center:
            p.x += (size.width - s.width) / 2
            p.y += (size.height - s.height) / 2
        case .topRight:
            p.x += (size.width - s.width)
        case .bottomLeft:
            p.y += (size.height - s.height)
        case .bottomRight:
            p.x += (size.width - s.width)
            p.y += (size.height - s.height)
        default:
            break
        }
        return CGRect(origin: p, size: s)
    }
}

//MARK: - UIEdgeInsets
public extension UIEdgeInsets {

    /// Get vertical insets.
    var vertical: CGFloat { get { return top + bottom } }

    /// Get horizontal insets.
    var horizontal: CGFloat { get { return left + right } }
}
