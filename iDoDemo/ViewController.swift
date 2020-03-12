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
        let popover = DOTextPopover(referView: testView,
                                    popDirection: directs[idx])
        popover.animateStyle = .slideInOut
        popover.text = "Just test popover."
        popover.show()
    }
}
