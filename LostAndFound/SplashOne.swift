//  SplashOne.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class SplashOne: UIViewController {

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doSetFrames()
        constants().ValidateLanguageCode()
        NotificationCenter.default.addObserver(self, selector: #selector(onPause), name:
                UIApplication.willResignActiveNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(onResume), name:
                UIApplication.didBecomeActiveNotification, object: nil)
        
    }

    @objc func onPause() {
        
    }

    @objc func onResume() {
        if (showingAlert) {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//            self.doGoToNextSplash()
            self.checkIfUpdateRequired()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    var showingAlert = false
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func doGoToNextSplash() {
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "splashtwo") as! SplashTwo
            constants().APPDEL.window?.rootViewController = ivc
        })
        */
        
        DispatchQueue.main.async {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }

            if constants().isLanguageDone() == true {
                if constants().doGetLoginStatus() == "true" {
                    if constants().doGetBiometricStatus() == "face" || constants().doGetBiometricStatus() == "touch"  {
                        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "signin") as! SignIn
                        constants().APPDEL.window?.rootViewController = ivc
                    } else {
                        if constants().doGetUserType() == constants().USERTYPE_ORGANIZATION && constants().doGetActiveOrganisation() == "false" {
                            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "organisationactivation") as! OrganisationActivation
                            constants().APPDEL.window?.rootViewController = ivc
                        } else {
                            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                            constants().APPDEL.window?.rootViewController = ivc
                        }
                    }
                } else {
                    let ivc = constants().storyboard.instantiateViewController(withIdentifier: "signin") as! SignIn
                    constants().APPDEL.window?.rootViewController = ivc
                }
            } else {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "selectlanguage") as! SelectLanguage
                ivc.navFlag = 1
                constants().APPDEL.window?.rootViewController = ivc
            }
        }
        
    }

    func checkIfUpdateRequired() {
        print("checkIfUpdateRequired")
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        
        let param: [String: Any] = ["appType": "Android", "versionNumber": "5"]
//        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: param, APIName: apiClass().GetAppVersion, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    print("need to update the app")
                    let data = NSKeyedArchiver.archivedData(withRootObject: mDict)
                    print(data)
                    let alert=UIAlertController(title: "New Version Available", message: "Please update to continue using this app", preferredStyle: UIAlertController.Style.alert);
                    alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                            UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/id1509659336?mt=8")!, options: [:], completionHandler: nil)
                        self.showingAlert = false
                    }))
//                    if isForce != true{
//                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                    }
                    self.present(alert, animated: true, completion: {})
                    self.showingAlert = true
                } else {
                    self.doGoToNextSplash()
                }
            }
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
    }
}
