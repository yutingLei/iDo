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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onTouched(_ sender: UIButton) {
        let tablePopover = IDOTablePopover(referenceView: sender)
        tablePopover.contents = ["测试一", "测试二", "再来一个长的字符串"]
        tablePopover.show()
    }
}

