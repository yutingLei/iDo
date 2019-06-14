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
        let imagePopover = IDOImagePopover(referenceView: sender)
        imagePopover.remotePath = "https://images.pexels.com/photos/67636/rose-blue-flower-rose-blooms-67636.jpeg?auto=format%2Ccompress&cs=tinysrgb&dpr=1&w=500"
        imagePopover.show()
    }
}

