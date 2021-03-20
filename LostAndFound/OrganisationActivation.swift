//  OrganisationActivation.swift
//  LostAndFound
//  Created by Revamp on 10/05/20.
//  Copyright © 2020 Revamp. All rights reserved.

import UIKit
import BraintreeDropIn
import Braintree

class OrganisationActivation: UIViewController {
    @IBOutlet weak var lblOrganisationActication : UILabel!
    @IBOutlet weak var lblJustStep : UILabel!
    @IBOutlet weak var lblPayUSD : UILabel!
    @IBOutlet weak var btnPayNow : UIButton!
    @IBOutlet weak var btnLogout : UIButton!

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
        self.btnPayNow.layer.cornerRadius = 27.5
        self.btnPayNow.layer.masksToBounds = true

        self.btnLogout.layer.cornerRadius = 27.5
        self.btnLogout.layer.masksToBounds = true
    }

    func doApplyLocalisation() {
        self.lblOrganisationActication.text = NSLocalizedString("organisation", comment: "")
        self.lblJustStep.text = NSLocalizedString("justonestep", comment: "")
        self.lblPayUSD.text = NSLocalizedString("payusd", comment: "")
        self.btnPayNow.setTitle(NSLocalizedString("paynow", comment: ""), for: .normal)
        self.btnLogout.setTitle(NSLocalizedString("logout", comment: ""), for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doPayNow() {
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().ClientTokenAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    let strClientToken = mDict.value(forKey: "clientToken") as! String
                    self.showDropIn(clientTokenOrTokenizationKey: strClientToken)
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

    @IBAction func doLogout() {
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("areyousurelogout", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { (action) in
            constants().doCleanUpUserData()
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "signin") as! SignIn
            constants().APPDEL.window?.rootViewController = ivc
        }
        alertController.addAction(okAction)
        let noAction = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default) { (action) in
        }
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }

    //MARK:- Payment Dropin Method
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                let strPaymentNonce : String = (result.paymentMethod?.nonce)!
                constants().APPDEL.doStartSpinner()
                apiClass().doNormalAPI(param: ["organization_id":constants().doGetUserId(), "paymentMethodNonce":strPaymentNonce, "fee":"10"], APIName: apiClass().PayOrganisationFeeAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            constants().doSaveActiveOrganisation(uActive: "true")
                            let alertController = UIAlertController(title: NSLocalizedString("congratulations", comment: ""), message: NSLocalizedString("youraccountactivated", comment: ""), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("proceed", comment: ""), style: .default) { (action) in
                                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                                ivc.selectedIndex = 2
                                constants().APPDEL.window?.rootViewController = ivc
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
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
}
