//  RegisterCompany.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class RegisterCompany: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblRegisterOrg : UILabel!
    @IBOutlet weak var txtOrgName : DTTextField!
    @IBOutlet weak var txtRegNumber : DTTextField!
    @IBOutlet weak var txtWebURL : DTTextField!
    @IBOutlet weak var btnSubmit : UIButton!
    var strMobile = ""

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
        self.txtOrgName.layer.cornerRadius = 10.0
        self.txtOrgName.layer.masksToBounds = true

        self.txtRegNumber.layer.cornerRadius = 10.0
        self.txtRegNumber.layer.masksToBounds = true

        self.txtWebURL.layer.cornerRadius = 10.0
        self.txtWebURL.layer.masksToBounds = true

        self.btnSubmit.layer.cornerRadius = 27.5
        self.btnSubmit.layer.masksToBounds = true
    }

    func doApplyLocalisation() {
        self.lblRegisterOrg.text = NSLocalizedString("registerasorganisation", comment: "")
        self.txtOrgName.placeholder = NSLocalizedString("organisationname", comment: "")
        self.txtRegNumber.placeholder = NSLocalizedString("registrationnumber", comment: "")
        self.txtWebURL.placeholder = NSLocalizedString("websiteurl", comment: "")
        self.btnSubmit.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "createaccount") as! CreateAccount
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doSubmit() {
        if self.txtOrgName.text!.isEmpty {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("enterorganisationname", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }

            let param: [String: Any] = ["first_name": constants().APPDEL.dictSignupDetails.value(forKey: "fname") as! String, "last_name": constants().APPDEL.dictSignupDetails.value(forKey: "lname") as! String, "email": constants().APPDEL.dictSignupDetails.value(forKey: "email") as! String, "mobile": constants().APPDEL.dictSignupDetails.value(forKey: "mobile") as! String, "password": constants().APPDEL.dictSignupDetails.value(forKey: "password") as! String, "type": constants().USERTYPE_ORGANIZATION, "organization_name": self.txtOrgName.text!, "website": self.txtWebURL.text!, "registration_number": self.txtRegNumber.text!]
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().SignUpAPI, method: "POST") { (success, errMessage, mDict) in
                if success == true {
                    let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(data, forKey:"userdata")
                    constants().doSendDEviceToken()
                    if (mDict.value(forKey: "payment_required") as! String) == "true" {
                        constants().doSaveActiveOrganisation(uActive: "false")
                    } else {
                        constants().doSaveActiveOrganisation(uActive: "true")
                    }

                    constants().APPDEL.dictSignupDetails.setValue(self.txtOrgName.text, forKey: "orgname")
                    constants().APPDEL.dictSignupDetails.setValue(self.txtRegNumber.text, forKey: "regnumber")
                    constants().APPDEL.dictSignupDetails.setValue(self.txtWebURL.text, forKey: "weburl")
                    constants().doSaveUserType(uType: constants().USERTYPE_ORGANIZATION)
                    let ivc = constants().storyboard.instantiateViewController(withIdentifier: "verificationcode") as! VerificationCode
                    ivc.strMobile = self.strMobile
                    constants().APPDEL.window?.rootViewController = ivc
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

    //MARK:- UITextField delegate methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        constants().doMoveViewToDown(mView: self.view)
        return true
    }
}
