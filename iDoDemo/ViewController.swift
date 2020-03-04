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
    
    @IBOutlet weak var testView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let popover = DOTextPopover(referView: testView, popDirection: .auto)
        popover.text = "Just test popover."
        popover.show()
    }

    @IBAction func onTouched(_ sender: UIButton) {
    }
}
