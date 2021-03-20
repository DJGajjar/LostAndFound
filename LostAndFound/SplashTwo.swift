//  SplashTwo.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class SplashTwo: UIViewController {

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doSetFrames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.doGoToNextScreen()
        })
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func doGoToNextScreen() {
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

    //MARK:- Other Methods
    func doSetFrames() {
    }
}
