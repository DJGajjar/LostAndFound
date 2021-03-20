//  SignIn.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import LocalAuthentication
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import AuthenticationServices
import CoreTelephony

//https://developers.facebook.com/docs/accountkit/ios
class SignIn: UIViewController, UITextFieldDelegate, GIDSignInDelegate {
    @IBOutlet weak var lblSignIn : UILabel!
    @IBOutlet weak var btnFaceID : UIButton!
    @IBOutlet weak var lblFaceID : UILabel!
    @IBOutlet weak var lblOr : UILabel!
    @IBOutlet weak var txtEmailMobile : DTTextField!
    @IBOutlet weak var txtPassword : DTTextField!
    @IBOutlet weak var btnSignIn : UIButton!
    @IBOutlet weak var btnForgetPassword : UIButton!
    @IBOutlet weak var lblContinue : UILabel!

    @IBOutlet weak var SocialView : UIView!
    @IBOutlet weak var btnFacebook : UIButton!
    @IBOutlet weak var btnGoogle : UIButton!
    @IBOutlet weak var btnCreateAccount : UIButton!
    @IBOutlet weak var BtnAppleSignIn: UIStackView!

    @IBOutlet weak var viewRememberMe: UIView!
    @IBOutlet weak var imgRememberMe: UIImageView!
    var rememberMe = true
    
    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
            self.setUpSignInAppleButton()
        }
        self.doApplyLocalisation()
        self.doSetFrames()

        viewRememberMe.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rememberMeTapped(sender:))))
        
        self.txtEmailMobile.text = constants().doGetUsername()
        self.txtPassword.text = constants().doGetPassword()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signOut()
        self.doBiometricSettings()
    }
    
    @objc func rememberMeTapped(sender: Any?) {
        rememberMe = !rememberMe
        imgRememberMe.image = rememberMe ? #imageLiteral(resourceName: "selectedBlueIcon") : #imageLiteral(resourceName: "CheckboxEmpty")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Biometric Configure
    func doBiometricSettings() {
        if constants().doGetBiometricStatus() == "face"  {
            self.btnFaceID.setImage(UIImage(named: "FaceID_small"), for: .normal)
            self.lblFaceID.text = "Face ID"
            self.doFaceID()
        } else if constants().doGetBiometricStatus() == "touch"  {
            self.btnFaceID.setImage(UIImage(named: "TouchID_small"), for: .normal)
            self.lblFaceID.text = "Touch ID"
            self.doFaceID()
        } else {
            self.btnFaceID.isHidden = true
            self.lblFaceID.isHidden = true
            self.lblOr.isHidden = true
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
        self.lblSignIn.text = NSLocalizedString("signin", comment: "")
        self.txtEmailMobile.layer.cornerRadius = 10.0
        self.txtEmailMobile.layer.masksToBounds = true
        self.txtEmailMobile.floatPlaceholderActiveColor = constants().COLOR_LightBlue
        self.txtEmailMobile.floatPlaceholderColor = UIColor.lightGray

        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "eyeIcon_Hide"), for: .normal)
        button.frame = CGRect(x: CGFloat(self.txtPassword.frame.origin.x + self.txtPassword.frame.size.width - 30), y: CGFloat(self.txtPassword.frame.origin.y + self.txtPassword.frame.size.height - 40), width: CGFloat(20), height: CGFloat(20))
        button.addTarget(self, action: #selector(self.doPasswordVisible), for: .touchUpInside)
        button.backgroundColor = UIColor.clear
        self.view.addSubview(button)
        self.txtPassword.layer.cornerRadius = 10.0
        self.txtPassword.layer.masksToBounds = true
        self.txtPassword.floatPlaceholderActiveColor = constants().COLOR_LightBlue
        self.txtPassword.floatPlaceholderColor = UIColor.lightGray

        self.btnSignIn.layer.cornerRadius = 27.5
        self.btnSignIn.layer.masksToBounds = true

        self.BtnAppleSignIn.layer.cornerRadius = 20.0
        self.BtnAppleSignIn.layer.masksToBounds = true

        let signUpAttributedString = NSMutableAttributedString(string:NSLocalizedString("donthaveanaccount", comment: ""), attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_REGULAR, size: 16)!, NSAttributedString.Key.foregroundColor: UIColor.white])
        signUpAttributedString.append(NSMutableAttributedString(string:NSLocalizedString("createanaccount", comment: ""), attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_SEMIBOLD, size: 16)!, NSAttributedString.Key.foregroundColor: UIColor.white]))
        self.btnCreateAccount.setAttributedTitle(signUpAttributedString, for: .normal)
    }

    func doApplyLocalisation() {
        self.lblSignIn.text = NSLocalizedString("signin", comment: "")
        self.txtEmailMobile.placeholder = NSLocalizedString("email", comment: "")
        self.txtPassword.placeholder = NSLocalizedString("password", comment: "")
        self.btnSignIn.setTitle(NSLocalizedString("signin", comment: ""), for: .normal)
        self.btnForgetPassword.setTitle(NSLocalizedString("forgotpasswordquestion", comment: ""), for: .normal)
        self.lblOr.text = NSLocalizedString("or", comment: "")
        self.lblContinue.text = NSLocalizedString("orcontinuewith", comment: "")
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

    @IBAction func doSignIn() {
        var aMessage = ""
        if self.txtEmailMobile.text!.isEmpty {
            aMessage = NSLocalizedString("entervalidemail", comment: "")
        } else if self.txtPassword.text!.isEmpty {
            aMessage = NSLocalizedString("enterpassword", comment: "")
        }
        
        if rememberMe {
            constants().doSaveUsername(sUsername: self.txtEmailMobile.text!)
            constants().doSavePassword(sPassword: self.txtPassword.text!)
        } else {
            constants().doSaveUsername(sUsername: "")
            constants().doSavePassword(sPassword: "")
        }

        if aMessage.isEmpty {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }

            let param: [String: Any] = ["email_mobile": self.txtEmailMobile.text!, "password": self.txtPassword.text!]
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().LoginAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(data, forKey:"userdata")
                        constants().doSaveLoginStatus(sStatus: "true")
                        constants().doSendDEviceToken()
                        if (mDict.value(forKey: "user_type") as! String) == constants().USERTYPE_ORGANIZATION {
                            constants().doSaveUserType(uType: constants().USERTYPE_ORGANIZATION)
                            if (mDict.value(forKey: "is_fee_paid") as! String) == "false" {
                                constants().doSaveActiveOrganisation(uActive: "false")
                            } else {
                                constants().doSaveActiveOrganisation(uActive: "true")
                            }
                        } else {
                            constants().doSaveUserType(uType: constants().USERTYPE_INDIVIDUAL)
                        }

                        if constants().doGetUserType() == constants().USERTYPE_INDIVIDUAL {
                            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                            constants().APPDEL.window?.rootViewController = ivc
                        } else {
                            if constants().doGetActiveOrganisation() == "false" {
                                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "organisationactivation") as! OrganisationActivation
                                constants().APPDEL.window?.rootViewController = ivc
                            } else {
                                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                                constants().APPDEL.window?.rootViewController = ivc
                            }
                        }
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
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: aMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func doFaceID() {
        if constants().doGetLoginStatus() == "true" {
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                            constants().APPDEL.window?.rootViewController = ivc
                        } else {
                            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("biometricfailed", comment: ""), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                            }
                            alertController.addAction(okAction)
                            self!.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
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

    @IBAction func doForgetPassword() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "forgotpassword") as! ForgotPassword
        constants().APPDEL.window?.rootViewController = ivc
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
                print("Login Failed %@", error)
            }
        }
    }

    @IBAction func doGoogle() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().signIn()
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

                    if (fEmail.isEmpty) {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Unable to get your Email ID. Please change your privacy settings & try again.", preferredStyle: .alert)
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
                        apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile":fMobile, "type":""], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                            DispatchQueue.main.async {
                                if success == true {
                                    let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                                    let userDefaults = UserDefaults.standard
                                    userDefaults.set(data, forKey:"userdata")
                                    constants().doSendDEviceToken()
                                    constants().doSaveSocial(sStr: "true")
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
            })
        }
    }

    @IBAction func doCreateAccount() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "createaccount") as! CreateAccount
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

                if (fEmail.isEmpty) {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Unable to get your Email ID. Please change your privacy settings & try again.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if constants().APPDEL.isInternetOn(currentController: self) == false {
                        return
                    }

                    constants().APPDEL.doStartSpinner()
                    apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile":"", "type":""], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                        DispatchQueue.main.async {
                            if success == true {
                                let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                                let userDefaults = UserDefaults.standard
                                userDefaults.set(data, forKey:"userdata")
                                constants().doSendDEviceToken()
                                constants().doSaveSocial(sStr: "true")
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

extension SignIn: ASAuthorizationControllerDelegate {
    //MARK:- did_complete_authorization
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
            if (fEmail.isEmpty) {
                let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("allowtoaccessemail", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                if constants().APPDEL.isInternetOn(currentController: self) == false {
                    return
                }

                constants().APPDEL.doStartSpinner()
                apiClass().doNormalAPI(param: ["first_name":fName, "email":fEmail, "mobile":"", "type":""], APIName: apiClass().SocialLoginAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                            let userDefaults = UserDefaults.standard
                            userDefaults.set(data, forKey:"userdata")
                            constants().doSendDEviceToken()
                            constants().doSaveSocial(sStr: "true")
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
        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            print(username)
        default:
            break
        }
    }

    //MARK:- did_complete_error
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }
}

extension SignIn: ASAuthorizationControllerPresentationContextProviding {
    //MARK:- provide_presentation_anchor
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
