//  CreateAccount.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import AuthenticationServices
import TPKeyboardAvoiding

class CreateAccount: UIViewController, UITextFieldDelegate, GIDSignInDelegate, UITextViewDelegate {
    @IBOutlet weak var MyScroll : TPKeyboardAvoidingScrollView!
    @IBOutlet weak var lblCreateAccount : UILabel!

    @IBOutlet var mySegmentView: UIView!
    @IBOutlet weak var btnIndividual : UIButton!
    @IBOutlet weak var btnOrganisation : UIButton!
    var selectedSegment = 0

    @IBOutlet weak var NameView : UIView!
    @IBOutlet weak var txtFirstName : DTTextField!
    @IBOutlet weak var txtLastName : DTTextField!
    @IBOutlet weak var txtEmail : DTTextField!
    @IBOutlet weak var txtMobile : DTTextField!
    @IBOutlet weak var txtPassword : DTTextField!
    @IBOutlet weak var btnCreateAccount : UIButton!
    @IBOutlet weak var lblContinue : UILabel!

    @IBOutlet weak var SocialView : UIView!
    @IBOutlet weak var btnFacebook : UIButton!
    @IBOutlet weak var btnGoogle : UIButton!
    @IBOutlet weak var BtnAppleSignIn: UIStackView!

    @IBOutlet weak var btnAlreadyAccountSignin : UIButton!
    @IBOutlet weak var btnTerms : UIButton!
    @IBOutlet weak var lblTerms : UITextView!

    @IBOutlet weak var CustomToolbar : UIView!
    @IBOutlet weak var CustomDone : UIButton!
    var keyboardHEIGHT : CGFloat = 240.0

    var strTxtFirstName = ""
    var strTxtLastName = ""
    var strTxtEmail = ""
    var strTxtMobile = ""
    var strTxtPassword = ""

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
            self.setUpSignInAppleButton()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.doCustomToolHide()

        self.doApplyLocalisation()
        self.doSetFrames()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        self.txtFirstName.text = self.strTxtFirstName
        self.txtLastName.text = self.strTxtLastName
        self.txtEmail.text = self.strTxtEmail
        self.txtMobile.text = self.strTxtMobile
        self.txtPassword.text = self.strTxtPassword
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
    func setUpSignInAppleButton() {
        if #available(iOS 13.0, *) {
            let authorizationButton = ASAuthorizationAppleIDButton()
            authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            authorizationButton.cornerRadius = 10
            self.BtnAppleSignIn.addArrangedSubview(authorizationButton)
        }
    }

    func doSetFrames() {
        self.mySegmentView.layer.cornerRadius = 25.0
        self.mySegmentView.layer.masksToBounds = true

        self.btnIndividual.semanticContentAttribute = .forceLeftToRight
        self.btnIndividual.layer.cornerRadius = 23.0
        self.btnIndividual.layer.masksToBounds = true

        self.btnOrganisation.semanticContentAttribute = .forceLeftToRight
        self.btnOrganisation.layer.cornerRadius = 23.0
        self.btnOrganisation.layer.masksToBounds = true

        self.txtFirstName.layer.cornerRadius = 10.0
        self.txtFirstName.layer.masksToBounds = true

        self.txtLastName.layer.cornerRadius = 10.0
        self.txtLastName.layer.masksToBounds = true

        self.txtEmail.layer.cornerRadius = 10.0
        self.txtEmail.layer.masksToBounds = true

        self.txtMobile.layer.cornerRadius = 10.0
        self.txtMobile.layer.masksToBounds = true

        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        button.frame = CGRect(x: CGFloat(self.txtPassword.frame.origin.x + self.txtPassword.frame.size.width - 30), y: CGFloat(self.txtPassword.frame.origin.y + self.txtPassword.frame.size.height - 35), width: CGFloat(20), height: CGFloat(20))
        button.addTarget(self, action: #selector(self.doPasswordVisible), for: .touchUpInside)
        button.backgroundColor = UIColor.clear
        self.MyScroll.addSubview(button)
        self.txtPassword.layer.cornerRadius = 10.0
        self.txtPassword.layer.masksToBounds = true

        self.btnCreateAccount.layer.cornerRadius = 25.0
        self.btnCreateAccount.layer.masksToBounds = true

        self.BtnAppleSignIn.layer.cornerRadius = 20.0
        self.BtnAppleSignIn.layer.masksToBounds = true

        let signUpAttributedString = NSMutableAttributedString(string:NSLocalizedString("alreadyhaveaccount", comment: ""), attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_REGULAR, size: 16)!, NSAttributedString.Key.foregroundColor: UIColor.white])
        signUpAttributedString.append(NSMutableAttributedString(string:NSLocalizedString("signin", comment: ""), attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_Medium, size: 16)!, NSAttributedString.Key.foregroundColor: UIColor.white]))
        self.btnAlreadyAccountSignin.setAttributedTitle(signUpAttributedString, for: .normal)

        let text = NSMutableAttributedString(string: "By tapping on \"create account\" button, you are agree to ")
        text.addAttribute(NSAttributedString.Key.font, value: UIFont(name: constants().FONT_REGULAR, size: 12)!, range: NSRange(location: 0, length: text.length))
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: text.length))

        let interactableText = NSMutableAttributedString(string: "Terms & Condition")
        interactableText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: constants().FONT_Medium, size: 12)!, range: NSRange(location: 0, length: interactableText.length))
        interactableText.addAttribute(NSAttributedString.Key.link, value: "Terms", range: NSRange(location: 0, length: interactableText.length))
        interactableText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: interactableText.length))
        text.append(interactableText)
        self.lblTerms.attributedText = text
        self.lblTerms.textAlignment = .center
    }

    func doApplyLocalisation() {
        self.lblCreateAccount.text = NSLocalizedString("createanaccount", comment: "")
        self.txtFirstName.placeholder = NSLocalizedString("firstname", comment: "")
        self.txtLastName.placeholder = NSLocalizedString("lastname", comment: "")
        self.txtEmail.placeholder = NSLocalizedString("email", comment: "")
        self.txtMobile.placeholder = NSLocalizedString("mobilenumber", comment: "")
        self.txtPassword.placeholder = NSLocalizedString("password", comment: "")
        self.btnCreateAccount.setTitle(NSLocalizedString("createaccount", comment: ""), for: .normal)
        self.lblContinue.text = NSLocalizedString("orcontinuewith", comment: "")
        if !(self.txtEmail.placeholder?.contains("*"))! {
            self.txtEmail.placeholder?.append("*")
        }
    }

    //MARK:- IBAction Methods
    @IBAction func handleAuthorizationAppleIDButtonPress() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("signinonlysupported", comment: ""), preferredStyle: .alert)
            alertController.view.tintColor = constants().COLOR_LightBlue
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func doIndividual() {
        self.selectedSegment = 0

        self.btnIndividual.backgroundColor = constants().COLOR_LightBlue
        self.btnIndividual.setTitleColor(UIColor.white, for: .normal)
        self.btnIndividual.setImage(UIImage(named: "user_white"), for: .normal)
    
        self.btnOrganisation.backgroundColor = UIColor.white
        self.btnOrganisation.setTitleColor(UIColor.black, for: .normal)
        self.btnOrganisation.setImage(UIImage(named: "org_gray"), for: .normal)

        if !(self.txtEmail.placeholder?.contains("*"))! {
            self.txtEmail.placeholder?.append("*")
        }

//        self.txtEmail.placeholder = self.txtEmail.placeholder?.replacingOccurrences(of: "*", with: "")
        if !(self.txtMobile.placeholder?.contains("*"))! {
            self.txtMobile.placeholder?.append("*")
        }
    }

    @IBAction func doOrganisation() {
        self.selectedSegment = 1

        self.btnIndividual.backgroundColor = UIColor.white
        self.btnIndividual.setTitleColor(UIColor.black, for: .normal)
        self.btnIndividual.setImage(UIImage(named: "user_gray"), for: .normal)

        self.btnOrganisation.backgroundColor = constants().COLOR_LightBlue
        self.btnOrganisation.setTitleColor(UIColor.white, for: .normal)
        self.btnOrganisation.setImage(UIImage(named: "org_white"), for: .normal)

        if !(self.txtEmail.placeholder?.contains("*"))! {
            self.txtEmail.placeholder?.append("*")
        }
        self.txtMobile.placeholder = self.txtMobile.placeholder?.replacingOccurrences(of: "*", with: "")
    }

    @IBAction func doTerms() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "terms") as! TermsConditions
        ivc.isFromSignUp = true
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    @objc func doPasswordVisible(button: UIButton) {
        if self.txtPassword.isSecureTextEntry {
            self.txtPassword.isSecureTextEntry = false
            button.setImage(UIImage(named: "eyeIcon_Show"), for: .normal)
        } else {
            self.txtPassword.isSecureTextEntry = true
            button.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        }
    }

    @IBAction func doCreateAccount() {
        self.doCustomToolHide()
        var passflag = 0
        var aMessage = ""
        if (self.txtFirstName.text?.isEmpty)! {
            aMessage = NSLocalizedString("enterfirstname", comment: "")
        } else if (self.txtLastName.text?.isEmpty)! {
            aMessage = NSLocalizedString("enterlastname", comment: "")
        } else if (self.selectedSegment == 1 && self.txtEmail.text!.isEmpty) {
            aMessage = NSLocalizedString("enteremail", comment: "")
        } else if (self.selectedSegment == 1 && constants().isValidEmail(testStr: self.txtEmail.text!) == false) {
            aMessage = NSLocalizedString("entervalidemail", comment: "")
//        } else if (self.selectedSegment == 0 && self.txtMobile.text!.isEmpty) {
//            aMessage = NSLocalizedString("entermobile", comment: "")
//        } else if (self.selectedSegment == 0 && constants().isValidPhone(phone: self.txtMobile.text!) == false) {
//            aMessage = NSLocalizedString("entervalidmobile", comment: "")
        } else if (self.txtPassword.text?.isEmpty)! {
            aMessage = NSLocalizedString("enterpassword", comment: "")
        } else if (constants().isStrongPassword(sPassword: self.txtPassword.text!) == false) {
            passflag = 1
            aMessage = NSLocalizedString("passwordlength", comment: "")
        }

        if !aMessage.isEmpty {
            if passflag == 1 {
                let alertController = UIAlertController(title: "Weak Password", message: aMessage, preferredStyle: .alert)
                alertController.view.tintColor = constants().COLOR_LightBlue
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: aMessage, preferredStyle: .alert)
                alertController.view.tintColor = constants().COLOR_LightBlue
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            constants().APPDEL.dictSignupDetails = [
                "fname"    : self.txtFirstName.text!,
                "lname"    : self.txtLastName.text!,
                "email"    : self.txtEmail.text!,
                "mobile"   : self.txtMobile.text!,
                "password" : self.txtPassword.text!,
                "orgname"  : "",
                "weburl"   : "",
                "regnumber": ""
                ] as NSMutableDictionary

            if self.selectedSegment == 0 {
                if constants().APPDEL.isInternetOn(currentController: self) == false {
                    return
                }

                let param: [String: Any] = ["first_name": self.txtFirstName.text!, "last_name": self.txtLastName.text!, "email": self.txtEmail.text!, "mobile": self.txtMobile.text!, "password": self.txtPassword.text!, "type": constants().USERTYPE_INDIVIDUAL, "organization_name": "", "website": "", "registration_number":""]
                constants().APPDEL.doStartSpinner()
                apiClass().doNormalAPI(param: param, APIName: apiClass().SignUpAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                            let userDefaults = UserDefaults.standard
                            userDefaults.set(data, forKey:"userdata")
                            constants().doSendDEviceToken()
                            constants().doSaveUserType(uType: constants().USERTYPE_INDIVIDUAL)
                            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "verificationcode") as! VerificationCode
                            ivc.strMobile = self.txtMobile.text!
                            ivc.txtFirstName = self.txtFirstName.text!
                            ivc.txtLastName = self.txtLastName.text!
                            ivc.txtEmail = self.txtEmail.text!
                            ivc.txtMobile = self.txtMobile.text!
                            ivc.txtPassword = self.txtPassword.text!
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
            } else {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "registercompany") as! RegisterCompany
                ivc.strMobile = self.txtEmail.text!
                constants().APPDEL.window?.rootViewController = ivc
            }
        }
    }

    @IBAction func doFacebook() {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil) {
                let fbloginresult : LoginManagerLoginResult = result!
                if(fbloginresult.isCancelled) {
                    print("Login Failed")
                } else {
                    self.returnUserData()
                }
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func returnUserData() {
        if((AccessToken.current) != nil) {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil) {
                    let mDict = (result as Any) as! NSDictionary
                    var fEmail = ""
                    var fMobile = ""
                    var fName = ""
                    if let mEmail = mDict.value(forKey: "email") {
                        fEmail = mEmail as! String
                    }
                    if let mMobile = mDict.value(forKey: "mobile") {
                        fMobile = mMobile as! String
                    }
                    if let mName = mDict.value(forKey: "name") {
                        fName = mName as! String
                    }

                    if constants().APPDEL.isInternetOn(currentController: self) == false {
                        return
                    }

                    if (self.selectedSegment == 0) {
                        if (fEmail.isEmpty == true) {
                            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Unable to get your Email ID. Please change your privacy settings & try again.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            constants().APPDEL.doStartSpinner()
                            apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile":fMobile, "type":constants().USERTYPE_INDIVIDUAL], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                                DispatchQueue.main.async {
                                    if success == true {
                                        let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                                        let userDefaults = UserDefaults.standard
                                        userDefaults.set(data, forKey:"userdata")
                                        constants().doSendDEviceToken()
                                        constants().doSaveSocial(sStr: "true")
                                        constants().doSaveUserType(uType: constants().USERTYPE_INDIVIDUAL)
                                        constants().doSaveLoginStatus(sStatus: "true")
                                        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                                        ivc.selectedIndex = 2
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
                    } else {
                        if (fEmail.isEmpty == true) {
                            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Unable to get your Email ID. Please change your privacy settings & try again.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            constants().APPDEL.doStartSpinner()
                            apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile":"", "type":constants().USERTYPE_ORGANIZATION], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                                DispatchQueue.main.async {
                                    if success == true {
                                        let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                                        let userDefaults = UserDefaults.standard
                                        userDefaults.set(data, forKey:"userdata")
                                        constants().doSendDEviceToken()
                                        constants().doSaveSocial(sStr: "true")
                                        constants().doSaveUserType(uType: constants().USERTYPE_ORGANIZATION)
                                        constants().doSaveLoginStatus(sStatus: "true")
                                        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                                        ivc.selectedIndex = 2
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
                    }
                }
            })
        }
    }

    @IBAction func doGoogle() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func doAlreadyAccountSignIn() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "signin") as! SignIn
        constants().APPDEL.window?.rootViewController = ivc
    }

    //MARK:- Google SignIn Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        } else {
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                var fEmail = ""
                var fName = ""
                if let mEmail = user.profile.email {
                    fEmail = mEmail
                }
                if let mName = user.profile.name {
                    fName = mName
                }

                if constants().APPDEL.isInternetOn(currentController: self) == false {
                    return
                }

                if (self.selectedSegment == 0) {
                    if (fEmail.isEmpty) {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Unable to get your Email ID. Please change your privacy settings & try again.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        constants().APPDEL.doStartSpinner()
                        apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile": "", "type":constants().USERTYPE_INDIVIDUAL], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                            DispatchQueue.main.async {
                                if success == true {
                                    let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                                    let userDefaults = UserDefaults.standard
                                    userDefaults.set(data, forKey:"userdata")
                                    constants().doSendDEviceToken()
                                    constants().doSaveSocial(sStr: "true")
                                    constants().doSaveUserType(uType: constants().USERTYPE_INDIVIDUAL)
                                    constants().doSaveLoginStatus(sStatus: "true")
                                    let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                                    ivc.selectedIndex = 2
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
                } else {
                    if (fEmail.isEmpty) {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Unable to get your Email ID. Please change your privacy settings & try again.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        constants().APPDEL.doStartSpinner()
                        apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile":"", "type":constants().USERTYPE_ORGANIZATION], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                            DispatchQueue.main.async {
                                if success == true {
                                    let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                                    let userDefaults = UserDefaults.standard
                                    userDefaults.set(data, forKey:"userdata")
                                    constants().doSendDEviceToken()
                                    constants().doSaveSocial(sStr: "true")
                                    constants().doSaveUserType(uType: constants().USERTYPE_ORGANIZATION)
                                    constants().doSaveLoginStatus(sStatus: "true")
                                    let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                                    ivc.selectedIndex = 2
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
                }
            }
        }
    }

    //MARK:- UITextView delegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.description == "Terms" {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "terms") as! TermsConditions
            ivc.isFromSignUp = true
            ivc.modalPresentationStyle = .fullScreen
            self.present(ivc, animated: true, completion: nil)
        }
        return true
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

extension CreateAccount: ASAuthorizationControllerDelegate {
    //MARK:- Apple did_complete_authorization
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            var fEmail = ""
            var fName = ""
            if let mEmail = appleIDCredential.email {
                fEmail = mEmail
            }
            if let mName = appleIDCredential.fullName?.givenName {
                fName = mName
            }

            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }

            if (self.selectedSegment == 0) {
                 if (fEmail.isEmpty) {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Unable to get your email. Please change your privacy settings & try again.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    constants().APPDEL.doStartSpinner()
                    apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile": "", "type":constants().USERTYPE_INDIVIDUAL], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                        DispatchQueue.main.async {
                            if success == true {
                                let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                                let userDefaults = UserDefaults.standard
                                userDefaults.set(data, forKey:"userdata")
                                constants().doSendDEviceToken()
                                constants().doSaveSocial(sStr: "true")
                                constants().doSaveUserType(uType: constants().USERTYPE_INDIVIDUAL)
                                constants().doSaveLoginStatus(sStatus: "true")
                                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                                ivc.selectedIndex = 2
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
            } else {
                if (fEmail.isEmpty) {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("allowtoaccessemail", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    constants().APPDEL.doStartSpinner()
                    apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile":"", "type":constants().USERTYPE_ORGANIZATION], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                        DispatchQueue.main.async {
                            if success == true {
                                let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                                let userDefaults = UserDefaults.standard
                                userDefaults.set(data, forKey:"userdata")
                                constants().doSendDEviceToken()
                                constants().doSaveSocial(sStr: "true")
                                constants().doSaveUserType(uType: constants().USERTYPE_ORGANIZATION)
                                constants().doSaveLoginStatus(sStatus: "true")
                                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                                ivc.selectedIndex = 2
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
            }
            break
        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            print(username)
            break
        default:
            break
        }
    }

    //MARK:- Apple did_complete_error
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }
}

extension CreateAccount: ASAuthorizationControllerPresentationContextProviding {
    //MARK:- provide_presentation_anchor
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
