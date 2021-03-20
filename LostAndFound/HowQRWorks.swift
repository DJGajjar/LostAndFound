//  HowQRWorks.swift
//  LostAndFound
//  Created by Revamp on 30/11/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class HowQRWorks: UIViewController {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("howqrworks", comment: "")
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
