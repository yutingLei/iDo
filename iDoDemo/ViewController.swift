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

    private var browser: DOImageLoop!
    private var classicLoading = DOLoading()
//    private var systemLoading = DOLoading(mode: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        classicLoading.show(in: testView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            self.classicLoading.hide()
//            self.systemLoading.show(in: self.view)
//        }
    }

    @IBAction func onTouched(_ sender: UIButton) {
    }
}
