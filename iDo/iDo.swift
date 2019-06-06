//
//  iDo.swift
//  iDo
//
//  Created by admin on 2019/6/6.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit

public struct Do<Element> {
    /// Presentor to extend.
    public let el: Element
    
    /// Creates extensions with base object.
    public init(_ el: Element) {
        self.el = el
    }
}
