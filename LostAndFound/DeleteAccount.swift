//  DeleteAccount.swift
//  LostAndFound
//  Created by Revamp on 07/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class DeleteAccount: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var ContentView : UIView!
    @IBOutlet weak var instructionView : UIView!
    @IBOutlet weak var lblInstruction1 : UILabel!
    @IBOutlet weak var lblInstruction2 : UILabel!
    @IBOutlet weak var txtMobileNumber : UITextField!
    @IBOutlet weak var btnDelete : UIButton!

    @IBOutlet weak var CustomToolbar : UIView!
    @IBOutlet weak var CustomDone : UIButton!
    var keyboardHEIGHT : CGFloat = 240.0

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        self.doCustomToolHide()
        self.doApplyLocalisation()
        self.doSetFrames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHEIGHT = keyboardRectangle.height
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.txtMobileNumber.semanticContentAttribute = .forceLeftToRight

        self.instructionView.layer.cornerRadius = 10.0
        self.instructionView.layer.masksToBounds = true

        let paddingMobile = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtMobileNumber.frame.height))
        paddingMobile.backgroundColor = UIColor.clear
        self.txtMobileNumber.leftView = paddingMobile
        self.txtMobileNumber.leftViewMode = .always

        self.txtMobileNumber.layer.cornerRadius = 10.0
        self.txtMobileNumber.layer.masksToBounds = true

        self.btnDelete.layer.cornerRadius = 27.5
        self.btnDelete.layer.masksToBounds = true

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.topView.frame
                frame.size.height = 80
                self.topView.frame = frame

                frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.btnClose.frame
                frame.origin.y = 40
                self.btnClose.frame = frame

                frame = self.ContentView.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.ContentView.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("deleteaccount", comment: "")
        self.txtMobileNumber.placeholder = NSLocalizedString("mobilenumber", comment: "")
        self.btnDelete.setTitle(NSLocalizedString("deleteaccount", comment: ""), for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doClose() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "settings") as! SettingsPage
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doDeleteAccount() {
        self.doCustomToolHide()
        if self.txtMobileNumber.text!.isEmpty {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("entervalidmobile", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("areyousuredelete", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { (action) in
                constants().APPDEL.doStartSpinner()
                apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "mobile":self.txtMobileNumber.text!], APIName: apiClass().DeleteAccountAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            constants().doCleanUpUserData()
                            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("accountdeleted", comment: ""), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "signin") as! SignIn
                                constants().APPDEL.window?.rootViewController = ivc
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "signin") as! SignIn
                                constants().APPDEL.window?.rootViewController = ivc
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            alertController.addAction(okAction)
            let noAction = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    //MARK:- Custom toolbar Methods
    func doCustomToolShow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.CustomToolbar.isHidden = false
            var frame = self.CustomToolbar.frame
            frame.origin.y = constants().SCREENSIZE.height - self.keyboardHEIGHT - 50
            self.CustomToolbar.frame = frame
        })
    }

    func doCustomToolHide() {
        self.CustomToolbar.isHidden = true
        self.view.endEditing(true)
    }

    @IBAction func doToolbarDone() {
        self.doCustomToolHide()
    }

    //MARK:- UITextField Delegate Methods
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.doCustomToolShow()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.doCustomToolHide()
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtMobileNumber {
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
