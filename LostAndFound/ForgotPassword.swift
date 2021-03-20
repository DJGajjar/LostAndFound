//  ForgotPassword.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class ForgotPassword: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblForgotPassword : UILabel!
    @IBOutlet weak var txtEmailMobile: DTTextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnBackToLogin: UIButton!

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Gesture Methods
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        var frame = self.view.frame
        frame.origin.y = translation.y
        self.view.frame = frame
        if translation.y >= constants().swipeCloseArea() {
            frame.origin.y = constants().SCREENSIZE.height
            self.view.frame = frame
            self.doBack()
        } else {
            if(gesture.state == UIGestureRecognizer.State.ended) {
                var frame = self.view.frame
                frame.origin.y = 0
                self.view.frame = frame
            }
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.txtEmailMobile.layer.cornerRadius = 10.0
        self.txtEmailMobile.layer.masksToBounds = true

        self.btnSubmit.layer.cornerRadius = 27.5
        self.btnSubmit.layer.masksToBounds = true

        self.btnBackToLogin.sizeToFit()
        var frame = self.btnBackToLogin.frame
        frame.origin.x = (constants().SCREENSIZE.width - frame.size.width) / 2
        self.btnBackToLogin.frame = frame
    }

    func doApplyLocalisation() {
        self.lblForgotPassword.text = NSLocalizedString("forgotpassword", comment: "")
        self.txtEmailMobile.placeholder = NSLocalizedString("email", comment: "")
        self.btnSubmit.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        self.btnBackToLogin.setTitle(NSLocalizedString("backtologin", comment: ""), for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doSubmit() {
        if self.txtEmailMobile.text!.isEmpty {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("entervalidemail", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }

            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["email_mobile":self.txtEmailMobile.text!], APIName: apiClass().ForgetPasswordAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("forgetpassowordlinksent", comment: ""), preferredStyle: .alert)
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                            self.doBack()
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "signin") as! SignIn
        constants().APPDEL.window?.rootViewController = ivc
    }

    //MARK:- UITextField delegate methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        constants().doMoveViewToDown(mView: self.view)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtEmailMobile {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                if Int(updatedText) != nil {
                    if (updatedText.count) == 1 {
                        if !updatedText.contains(constants().doPhoneCode()) {
                            textField.text = constants().doPhoneCode() + textField.text!
                        }
                    }
                }
            }
        }
        return true
    }
}
