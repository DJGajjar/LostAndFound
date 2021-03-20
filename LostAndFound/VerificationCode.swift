//  VerificationCode.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class VerificationCode: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblVerificationCode: UILabel!
    @IBOutlet weak var viewOTP: PinView!
    @IBOutlet weak var btnResendOTP: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    var strMobile = ""
    @IBOutlet weak var inputOtp: DTTextField!
    
    var txtFirstName = ""
    var txtLastName = ""
    var txtEmail = ""
    var txtMobile = ""
    var txtPassword = ""

    var mTimer = Timer()
    var seconds = 180

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()

        var config:PinConfig!     = PinConfig()
        config.otpLength          = .six
        config.dotColor           = .black
        config.lineColor          = #colorLiteral(red: 0.8265652657, green: 0.8502194881, blue: 0.9000532627, alpha: 1)
        config.spacing            = 20
        config.isSecureTextEntry  = true
        config.showPlaceHolder    = false
//        viewOTP.config = config
//        viewOTP.setUpView()
//        viewOTP.textFields[0].becomeFirstResponder()
        inputOtp.becomeFirstResponder()

        NotificationCenter.default.addObserver(self, selector: #selector(self.doFinishOTP(notification:)), name: Notification.Name("finishOTP"), object: nil)

        inputOtp.delegate = self
        
        self.doRunTimer()
    }

    func doRunTimer() {
        self.mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(doUpdateTimer), userInfo: nil, repeats: true)
    }

    @objc func doUpdateTimer() {
        seconds -= 1
        self.lblTimer.text = self.doTimeString(time: TimeInterval(seconds))
        if seconds <= 0 {
            self.doStopTimer()
//            self.viewOTP.textFields[0].becomeFirstResponder()
            self.inputOtp.becomeFirstResponder()
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("verificationcodeexpired", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func doStopTimer() {
        self.mTimer.invalidate()
        seconds = 180
        self.lblTimer.text = self.doTimeString(time: TimeInterval(seconds))
        self.ResetOTP_Blank()
    }

    func doTimeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"🕑 %02i:%02i", minutes, seconds)
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
        self.lblVerificationCode.text = NSLocalizedString("verificationcode", comment: "")
        self.btnResendOTP.setTitle(NSLocalizedString("resendotp", comment: ""), for: .normal)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 6
        let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (textField.text?.count == 6) {
            doFinishOTP()
        }
    }
    
    @objc func doFinishOTP(notification: Notification) {
        doFinishOTP()
    }
    func doFinishOTP() {
        var otpCode = ""
        var aMessage = ""
        do {
//            otpCode = try self.viewOTP.getOTP()
            otpCode = inputOtp.text!
        } catch OTPError.inCompleteOTPEntry {
            aMessage = NSLocalizedString("incompleteotp", comment: "")
        } catch let error {
            print(error.localizedDescription)
            aMessage = error.localizedDescription
        }

        if (!aMessage.isEmpty) {
//            self.viewOTP.textFields[0].becomeFirstResponder()
            self.inputOtp.becomeFirstResponder()
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: aMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }

            let param: [String: Any] = ["email": self.txtEmail, "otp": otpCode]
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().OTPVerificationAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(data, forKey:"userdata")
                        constants().doSaveLoginStatus(sStatus: "true")
                        
                        /* Uncomment if you want to make payment
                        if constants().doGetUserType() == constants().USERTYPE_ORGANIZATION && constants().doGetActiveOrganisation() == "false" {
                            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "organisationactivation") as! OrganisationActivation
                            constants().APPDEL.window?.rootViewController = ivc
                        } else {
                            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                            ivc.selectedIndex = 2
                            constants().APPDEL.window?.rootViewController = ivc
                        }*/
                        // --- Skip Payment
                        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                        ivc.selectedIndex = 2
                        constants().APPDEL.window?.rootViewController = ivc
                    } else {
//                        self.viewOTP.textFields[0].becomeFirstResponder()
                        self.inputOtp.becomeFirstResponder()
                        self.doStopTimer()
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

    @objc func doHideKeyboard() {
        self.view.endEditing(true)
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "createaccount") as! CreateAccount

        ivc.strTxtFirstName = self.txtFirstName
        ivc.strTxtLastName = self.txtLastName
        ivc.strTxtEmail = self.txtEmail
        ivc.strTxtMobile = self.txtMobile
        ivc.strTxtPassword = self.txtPassword

        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doResendOTP() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }

        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["email": self.txtEmail], APIName: apiClass().ResendOtpAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("newverificationcodesend", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        self.doRunTimer()
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
    
    func ResetOTP_Blank() {
//        self.viewOTP.textFields[0].text = ""
//        self.viewOTP.textFields[1].text = ""
//        self.viewOTP.textFields[2].text = ""
//        self.viewOTP.textFields[3].text = ""
//        self.viewOTP.textFields[4].text = ""
//        self.viewOTP.textFields[5].text = ""
        self.inputOtp.text = ""
    }
}
