//
//  ViewController.swift
//  iDoDemo
//
//  Created by admin on 2019/6/11.
//  Copyright © 2019 Conjur. All rights reserved.
//

import UIKit
import iDo

class ViewController: UIViewController {
    
    @IBOutlet weak var testView: UIButton!

    var directs: [DOPopover.Direction] = [.auto, .up, .left, .right, .down]
    var idx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onTouched(_ sender: UIButton) {
        idx = (idx + directs.count + 1) % directs.count
        let popover = DOListPopover(referView: testView,
                                    popDirection: directs[idx])
        popover.rowsConfiguration.isAllowedSeparator = false
        popover.animateStyle = .slideInOut
        popover.style = .iconText
        popover.contents = [
            ["image": "icon-20-ipad", "name": "Test 1"],
            ["image": "icon-20-ipad", "name": "Test 2"],
            ["image": "icon-20-ipad", "name": "Test 3"],
            ["image": "icon-20-ipad", "name": "Test 4"],
        ]
        popover.show { (result) in
            if let res = result as? (Any, Any) {
                print("RES: \(res)")
            }
        }
    }
}
