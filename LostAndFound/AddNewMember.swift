//  AddNewMember.swift
//  LostAndFound
//  Created by Revamp on 09/05/20.
//  Copyright © 2020 Revamp. All rights reserved.

import UIKit
import TPKeyboardAvoiding
class AddNewMember: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var MyScroll : TPKeyboardAvoidingScrollView!
    @IBOutlet weak var txtFirstName : UITextField!
    @IBOutlet weak var txtLastName : UITextField!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtMobile : UITextField!
    @IBOutlet weak var btnSendInvitation : UIButton!

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
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.MyScroll.semanticContentAttribute = .forceLeftToRight
        self.txtFirstName.semanticContentAttribute = .forceLeftToRight
        self.txtLastName.semanticContentAttribute = .forceLeftToRight
        self.txtEmail.semanticContentAttribute = .forceLeftToRight
        self.txtMobile.semanticContentAttribute = .forceLeftToRight

        let paddingFName = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtFirstName.frame.height))
        paddingFName.backgroundColor = UIColor.clear
        self.txtFirstName.leftView = paddingFName
        self.txtFirstName.leftViewMode = .always
        self.txtFirstName.layer.cornerRadius = 8.0
        self.txtFirstName.layer.masksToBounds = true

        let paddingLName = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtLastName.frame.height))
        paddingLName.backgroundColor = UIColor.clear
        self.txtLastName.leftView = paddingLName
        self.txtLastName.leftViewMode = .always
        self.txtLastName.layer.cornerRadius = 8.0
        self.txtLastName.layer.masksToBounds = true

        let paddingEmail = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtEmail.frame.height))
        paddingEmail.backgroundColor = UIColor.clear
        self.txtEmail.leftView = paddingEmail
        self.txtEmail.leftViewMode = .always
        self.txtEmail.layer.cornerRadius = 8.0
        self.txtEmail.layer.masksToBounds = true

        let paddingMobile = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtMobile.frame.height))
        paddingMobile.backgroundColor = UIColor.clear
        self.txtMobile.leftView = paddingMobile
        self.txtMobile.leftViewMode = .always
        self.txtMobile.layer.cornerRadius = 8.0
        self.txtMobile.layer.masksToBounds = true

        self.btnSendInvitation.layer.cornerRadius = 25.0
        self.btnSendInvitation.layer.masksToBounds = true

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

                frame = self.MyScroll.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.MyScroll.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("invitemember", comment: "")
        self.btnSendInvitation.setTitle(NSLocalizedString("sendinvitation", comment: ""), for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doSendInvitation() {
        var aMessage = ""
        if (self.txtFirstName.text?.isEmpty)! {
            aMessage = NSLocalizedString("enterfirstname", comment: "")
        } else if (self.txtLastName.text?.isEmpty)! {
            aMessage = NSLocalizedString("enterlastname", comment: "")
        } else if (self.txtEmail.text!.isEmpty) {
            aMessage = NSLocalizedString("enteremail", comment: "")
        } else if (constants().isValidEmail(testStr: self.txtEmail.text!) == false) {
            aMessage = NSLocalizedString("entervalidemail", comment: "")
        } else if (self.txtMobile.text!.isEmpty) {
            aMessage = NSLocalizedString("entermobile", comment: "")
        } else if (constants().isValidPhone(phone: self.txtMobile.text!) == false) {
            aMessage = NSLocalizedString("entervalidmobile", comment: "")
        }

        if aMessage.isEmpty {
            let param: [String: Any] = ["organization_id":constants().doGetUserId(), "first_name": self.txtFirstName.text!, "last_name":self.txtLastName.text!, "email":self.txtEmail.text!, "mobile":self.txtMobile.text!]
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().SendOrganisationInvitationAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Invitation Send Successfully", preferredStyle: .alert)
                        alertController.view.tintColor = constants().COLOR_LightBlue
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                            self.doBack()
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                        alertController.view.tintColor = constants().COLOR_LightBlue
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: aMessage, preferredStyle: .alert)
            alertController.view.tintColor = constants().COLOR_LightBlue
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
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

    //MARK:- UITextField delegate methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doCustomToolHide()
        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtMobile {
            self.doCustomToolShow()
        } else {
            self.CustomToolbar.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtMobile {
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
