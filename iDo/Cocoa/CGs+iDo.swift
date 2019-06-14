//
//  CGs+iDo.swift
//  Extend some function or others for class which has prefix with 'CG'
//
//  Created by admin on 2019/6/13.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public extension CGPoint {
    /// Offset x/y
    func offset(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
        var newPoint = self
        newPoint.x += dx
        newPoint.y += dy
        return newPoint
    }
}

public extension CGSize {
    /// Add w/h
    func add(dw: CGFloat = 0, dh: CGFloat = 0) -> CGSize {
        var newSize = self
        newSize.width += dw
        newSize.height += dh
        return newSize
    }
}

public extension CGRect {
    /// Add w/h
    func add(dw: CGFloat = 0, dh: CGFloat = 0) -> CGRect {
        var newRect = self
        newRect.size.width += dw
        newRect.size.height += dh
        return newRect
    }

    /// Subtract w/h
    func sub(dw: CGFloat = 0, dh: CGFloat = 0) -> CGRect {
        var newRect = self
        newRect.size.width -= dw
        newRect.size.height -= dh
        return newRect
    }

    /// Offset x/y sync w/h at present
    func offset(dx: CGFloat = 0, dy: CGFloat = 0, sync: Bool = true) -> CGRect {
        var newRect = self
        newRect.origin = newRect.origin.offset(dx: dx, dy: dy)
        if sync {
            newRect.size.width -= dx
            newRect.size.height -= dy
        }
        return newRect
    }
}
