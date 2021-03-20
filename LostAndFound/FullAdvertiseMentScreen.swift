//  FullAdvertiseMentScreen.swift
//  LostAndFound
//  Created by Revamp on 07/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class FullAdvertiseMentScreen: UIViewController {
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var adImageview : UIImageView!

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

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
        self.btnClose.layer.cornerRadius = self.btnClose.frame.size.width / 2
        self.btnClose.layer.masksToBounds = true
    }

    //MARK:- IBAction Methods
    @IBAction func doClose() {
        self.dismiss(animated: true, completion: nil)
    }
}
