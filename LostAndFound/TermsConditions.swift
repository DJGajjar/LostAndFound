//  TermsConditions.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import WebKit
class TermsConditions: UIViewController {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var txtContent : UITextView!
    var isFromSignUp = false

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        self.doSetFrames()
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: [:], APIName: apiClass().TermsAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.txtContent.attributedText = constants().setHTMLFromString(text: mDict.value(forKey: "terms_condition") as! String)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.lblTitle.text = NSLocalizedString("termscondition", comment: "")
        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.topView.frame
                frame.size.height = 80
                self.topView.frame = frame

                frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.btnBack.frame
                frame.origin.y = 40
                self.btnBack.frame = frame

                frame = self.txtContent.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 60
                self.txtContent.frame = frame
            }
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
