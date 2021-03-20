//  NoConnections.swift
//  LostAndFound
//  Created by Revamp on 10/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class NoConnections: UIViewController {
    @IBOutlet weak var lblOops : UILabel!
    @IBOutlet weak var lblPleaseCheck : UILabel!
    @IBOutlet weak var btnRetry : UIButton!

    //MARK:- UIViewController Methods
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
        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
            }
        }
    }

    func doApplyLocalisation() {
        self.btnRetry.setTitle(NSLocalizedString("retry", comment: ""), for: .normal)
        self.lblOops.text = NSLocalizedString("connectionlost", comment: "")
        self.lblPleaseCheck.text = NSLocalizedString("pleasecheckinternet", comment: "")
    }

    //MARK:- IBAction Methods
    @IBAction func doRetry() {
        self.dismiss(animated: true, completion: nil)
    }
}
