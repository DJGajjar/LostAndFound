//  ChangePassword.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class ChangePassword: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var ContentView : UIView!
    @IBOutlet weak var txtCurrentPassword : UITextField!
    @IBOutlet weak var txtNewPassword : UITextField!
    @IBOutlet weak var txtConfirmPassword : UITextField!
    @IBOutlet weak var btnSubmit : UIButton!

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
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.ContentView.semanticContentAttribute = .forceLeftToRight
        self.txtCurrentPassword.semanticContentAttribute = .forceLeftToRight
        self.txtNewPassword.semanticContentAttribute = .forceLeftToRight
        self.txtConfirmPassword.semanticContentAttribute = .forceLeftToRight

        let paddingCpassword = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtCurrentPassword.frame.height))
        paddingCpassword.backgroundColor = UIColor.clear
        self.txtCurrentPassword.leftView = paddingCpassword
        self.txtCurrentPassword.leftViewMode = .always
        let buttonCurrent = UIButton(type: .custom)
        buttonCurrent.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        buttonCurrent.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        buttonCurrent.frame = CGRect(x: CGFloat(self.txtCurrentPassword.frame.size.width - 75), y: CGFloat(17.5), width: CGFloat(20), height: CGFloat(20))
        buttonCurrent.addTarget(self, action: #selector(self.doCurrentPasswordVisible), for: .touchUpInside)
        self.txtCurrentPassword.rightView = buttonCurrent
        self.txtCurrentPassword.rightViewMode = .always
        self.txtCurrentPassword.layer.cornerRadius = 10.0
        self.txtCurrentPassword.layer.masksToBounds = true

        let paddingNpassword = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtNewPassword.frame.height))
        paddingNpassword.backgroundColor = UIColor.clear
        self.txtNewPassword.leftView = paddingNpassword
        self.txtNewPassword.leftViewMode = .always
        let buttonNew = UIButton(type: .custom)
        buttonNew.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        buttonNew.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        buttonNew.frame = CGRect(x: CGFloat(self.txtNewPassword.frame.size.width - 75), y: CGFloat(17.5), width: CGFloat(20), height: CGFloat(20))
        buttonNew.addTarget(self, action: #selector(self.doNewPasswordVisible), for: .touchUpInside)
        self.txtNewPassword.rightView = buttonNew
        self.txtNewPassword.rightViewMode = .always
        self.txtNewPassword.layer.cornerRadius = 10.0
        self.txtNewPassword.layer.masksToBounds = true

        let paddingConfirmpassword = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtConfirmPassword.frame.height))
        paddingConfirmpassword.backgroundColor = UIColor.clear
        self.txtConfirmPassword.leftView = paddingConfirmpassword
        self.txtConfirmPassword.leftViewMode = .always
        let buttonConfirm = UIButton(type: .custom)
        buttonConfirm.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        buttonConfirm.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        buttonConfirm.frame = CGRect(x: CGFloat(self.txtConfirmPassword.frame.size.width - 75), y: CGFloat(17.5), width: CGFloat(20), height: CGFloat(20))
        buttonConfirm.addTarget(self, action: #selector(self.doConfirmPasswordVisible), for: .touchUpInside)
        self.txtConfirmPassword.rightView = buttonConfirm
        self.txtConfirmPassword.rightViewMode = .always
        self.txtConfirmPassword.layer.cornerRadius = 10.0
        self.txtConfirmPassword.layer.masksToBounds = true

        self.btnSubmit.layer.cornerRadius = self.btnSubmit.frame.size.height / 2
        self.btnSubmit.layer.masksToBounds = true

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

                frame = self.ContentView.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 60
                self.ContentView.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("changepassword", comment: "")
        self.txtCurrentPassword.placeholder = NSLocalizedString("currentpassword", comment: "")
        self.txtNewPassword.placeholder = NSLocalizedString("newpassword", comment: "")
        self.txtConfirmPassword.placeholder = NSLocalizedString("confirmnewpassword", comment: "")
        self.btnSubmit.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
    }

    @objc func doCurrentPasswordVisible(button: UIButton) {
        if self.txtCurrentPassword.isSecureTextEntry {
            self.txtCurrentPassword.isSecureTextEntry = false
            button.setImage(UIImage(named: "eyeIcon_Show"), for: .normal)
        } else {
            self.txtCurrentPassword.isSecureTextEntry = true
            button.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        }
    }

    @objc func doNewPasswordVisible(button: UIButton) {
        if self.txtNewPassword.isSecureTextEntry {
            self.txtNewPassword.isSecureTextEntry = false
            button.setImage(UIImage(named: "eyeIcon_Show"), for: .normal)
        } else {
            self.txtNewPassword.isSecureTextEntry = true
            button.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        }
    }

    @objc func doConfirmPasswordVisible(button: UIButton) {
        if self.txtConfirmPassword.isSecureTextEntry {
            self.txtConfirmPassword.isSecureTextEntry = false
            button.setImage(UIImage(named: "eyeIcon_Show"), for: .normal)
        } else {
            self.txtConfirmPassword.isSecureTextEntry = true
            button.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doSubmit() {
        var passflag = 0
        var aMessage = ""
        if self.txtCurrentPassword.text!.isEmpty {
            aMessage = NSLocalizedString("entercurrentpassword", comment: "")
        } else if self.txtNewPassword.text!.isEmpty {
            aMessage = NSLocalizedString("enternewpassword", comment: "")
        } else if self.txtConfirmPassword.text!.isEmpty {
            aMessage = NSLocalizedString("enterconfirmpassword", comment: "")
        } else if (self.txtNewPassword.text != self.txtConfirmPassword.text) {
            aMessage = NSLocalizedString("passwordmismatch", comment: "")
        } else if (constants().isStrongPassword(sPassword: self.txtNewPassword.text!) == false) {
            passflag = 1
            aMessage = NSLocalizedString("passwordlength", comment: "")
        }

        if !aMessage.isEmpty {
            if passflag == 1 {
                let alertController = UIAlertController(title: NSLocalizedString("weakpassword", comment: ""), message: aMessage, preferredStyle: .alert)
                alertController.view.tintColor = constants().COLOR_LightBlue
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: aMessage, preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "old_password": self.txtCurrentPassword.text!, "password": self.txtNewPassword.text!], APIName: apiClass().ChangePasswordAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("passwordchanged", comment: ""), preferredStyle: .alert)
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

    //MARK:- UITextField delegate methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        constants().doMoveViewToDown(mView: self.view)
        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if constants().SCREENSIZE.height == 568 {
            if textField == self.txtCurrentPassword {
                constants().doMoveViewToUp(mView: self.view, mValue: 40)
            } else {
                constants().doMoveViewToDown(mView: self.view)
            }
        } else if constants().SCREENSIZE.height == 667 {
        } else if constants().SCREENSIZE.height == 736 {
        }
    }
}
