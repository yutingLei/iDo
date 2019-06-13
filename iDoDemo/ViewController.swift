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

    @IBAction func onTouched(_ sender: Any) {
        DateRangePicker.shared.located = .bottom
        DateRangePicker.shared.shortcuts = DateRangePicker.Shortcut.all
        DateRangePicker.shared.show(with: nil)
    }
}

