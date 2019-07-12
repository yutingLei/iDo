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

    var tablePopover: IDOTablePopover?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
    }

    @IBAction func onTouched(_ sender: UIButton) {
        if tablePopover == nil {
            tablePopover = IDOTablePopover(referenceView: sender, rowStyle: .value1)
            tablePopover?.extendKeys = ["subtitle", "title"]
            tablePopover?.isMultipleSelect = true
        }
        tablePopover?.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[unowned self] in
            self.tablePopover?.contents = []
            self.tablePopover?.show()
        }
    }
}
