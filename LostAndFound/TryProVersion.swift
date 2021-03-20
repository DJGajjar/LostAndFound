//  TryProVersion.swift
//  LostAndFound
//  Created by Revamp on 10/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import StoreKit
//Sandbox User :
//lftest@test.com
//Lost@123

class TryProVersion: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var ContentView : UIView!
    @IBOutlet weak var bottomView : UIView!
    @IBOutlet weak var btnUpdgradeToPro : UIButton!
    @IBOutlet weak var processview: UIActivityIndicatorView!

    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()

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
        self.fetchAvailableProducts()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.ContentView.layer.cornerRadius = 10.0
        self.ContentView.layer.masksToBounds = true

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
                frame.origin.y = self.topView.frame.size.height + 20
                self.ContentView.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("trypro", comment: "")
        self.btnUpdgradeToPro.setTitle(NSLocalizedString("upgradetopro", comment: ""), for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doUpgradeToPro() {
        // For Testing
//        self.doChangeToPro()

        if self.iapProducts.count > 0 {
            // Original
            self.processview.startAnimating()
            purchaseMyProduct(product: iapProducts[0])
        }
    }

    func doChangeToPro() {
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "plan_type":"Pro"], APIName: apiClass().UpdateUserSubscriptionAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("upgradeprosuccess", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        self.dismissMe(animated: true)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: - InApp purchase Methods
    func fetchAvailableProducts()  {
        let productIdentifiers = NSSet(objects: constants().PREMIUM_PRODUCT_ID)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }

    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        processview.stopAnimating()
        iapProducts = response.products
    }

    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("purchasesdisabled", comment: ""), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                self.processview.stopAnimating()
                switch trans.transactionState {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if productID == constants().PREMIUM_PRODUCT_ID {
                        UserDefaults.standard.set("true", forKey: "isPro")
                        self.doChangeToPro()
                    }
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                default: break
                }
            }
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.processview.stopAnimating()
        UserDefaults.standard.set("true", forKey: "isPro")
    }
}
