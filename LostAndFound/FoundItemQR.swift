//  FoundItemQR.swift
//  LostAndFound
//  Created by Revamp on 07/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import GoogleMobileAds

class FoundItemQR: UIViewController, GADBannerViewDelegate {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDesc : UILabel!
    @IBOutlet weak var QrCodeView : UIView!
    @IBOutlet weak var QrCodeImageview : UIImageView!
    @IBOutlet weak var btnShare : UIButton!
    @IBOutlet weak var btnPrint : UIButton!
    @IBOutlet weak var btnDownload : UIButton!
    @IBOutlet weak var lblShare : UILabel!
    @IBOutlet weak var lblPrint : UILabel!
    @IBOutlet weak var lblDownload : UILabel!
    @IBOutlet weak var bannerAdView : UIView!
    @IBOutlet weak var btnLearnHowItWorks : UIButton!
    @IBOutlet weak var btnProceed : UIButton!

    @IBOutlet weak var RatingView : UIView!
    @IBOutlet weak var RatingSubView : UIView!
    @IBOutlet weak var RateControl : SwiftyStarRatingView!
    @IBOutlet weak var btnSubmitRating : UIButton!

    var foundItemID = ""
    var foundItemMobile = ""
    var foundItemUserID = ""
    var qrImageURL = ""

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()

        if constants().APPDEL.isMyItem == 0  && self.qrImageURL.isEmpty {
            self.lblDesc.text = NSLocalizedString("togethandover", comment: "")
            self.QrCodeView.isHidden = true
            self.btnShare.isHidden = true
            self.btnPrint.isHidden = true
            self.btnDownload.isHidden = true
            self.lblShare.isHidden = true
            self.lblPrint.isHidden = true
            self.lblDownload.isHidden = true
            self.btnProceed.isHidden = false
        } else {
            self.lblDesc.text = NSLocalizedString("togivehandover", comment: "")
            self.QrCodeView.isHidden = false
            self.QrCodeImageview.sd_setImage(with: URL(string: self.qrImageURL), completed: nil)
            self.btnShare.isHidden = false
            self.btnPrint.isHidden = false
            self.btnDownload.isHidden = false
            self.lblShare.isHidden = false
            self.lblPrint.isHidden = false
            self.lblDownload.isHidden = false
            self.btnProceed.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doHandoverRequest()
        self.ConfigureAds()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.btnProceed.layer.cornerRadius = 25.0
        self.btnProceed.layer.masksToBounds = true

        self.QrCodeView.layer.cornerRadius = 5.0
        self.QrCodeView.layer.masksToBounds = true

        self.btnShare.layer.cornerRadius = self.btnShare.frame.size.width / 2
        self.btnShare.layer.masksToBounds = true

        self.btnPrint.layer.cornerRadius = self.btnPrint.frame.size.width / 2
        self.btnPrint.layer.masksToBounds = true

        self.btnDownload.layer.cornerRadius = self.btnDownload.frame.size.width / 2
        self.btnDownload.layer.masksToBounds = true

        self.RatingSubView.layer.cornerRadius = 10.0
        self.RatingSubView.layer.masksToBounds = true

        self.btnSubmitRating.layer.cornerRadius = 25.0
        self.btnSubmitRating.layer.masksToBounds = true

        let attributeString = NSMutableAttributedString(string: NSLocalizedString("learnhowhandoverwork", comment: ""), attributes: [.font: UIFont(name: constants().FONT_REGULAR, size: 15.0)!, .foregroundColor: UIColor.white, .underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnLearnHowItWorks.setAttributedTitle(attributeString, for: .normal)

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.lblTitle.frame
                frame.origin.y = 30
                self.lblTitle.frame = frame

                frame = self.lblDesc.frame
                frame.origin.y = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height
                self.lblDesc.frame = frame

                frame = self.btnBack.frame
                frame.origin.y = 30
                self.btnBack.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("qrcodedetails", comment: "")
        self.btnProceed.setTitle(NSLocalizedString("proceed", comment: ""), for: .normal)
        self.lblShare.text = NSLocalizedString("share", comment: "")
        self.lblPrint.text = NSLocalizedString("print", comment: "")
        self.lblDownload.text = NSLocalizedString("download", comment: "")
    }

    //MARK:- Configure BannerAd
    func ConfigureAds() {
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "c8e57533a5d7eea436427dde6db1f4ac" ]
        let bannerView: GADBannerView! = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.delegate = self
        bannerView.frame = CGRect(x: 0, y: 0, width: self.bannerAdView.frame.size.width, height: self.bannerAdView.frame.size.height)
        bannerView.adUnitID = constants().AD_BANNER_ID
        bannerView.rootViewController = self
        self.bannerAdView.addSubview(bannerView)
        bannerView.load(GADRequest())
    }

    func doHandoverRequest() {
        if constants().APPDEL.isCodeScanDone == true {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "item_id":self.foundItemID, "mobile":self.foundItemMobile], APIName: apiClass().HandoverOTPRequestAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.doVerifyHandoverOTP()
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
            if !constants().APPDEL.ScanError.isEmpty {
                let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: constants().APPDEL.ScanError, preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func doVerifyHandoverOTP() {
        let ac = UIAlertController(title: NSLocalizedString("verifyotp", comment: ""), message: NSLocalizedString("collectotp", comment: ""), preferredStyle: .alert)
        ac.addTextField { (textfield) in
            textfield.placeholder = NSLocalizedString("otprequest", comment: "")
        }
        let submitAction = UIAlertAction(title: NSLocalizedString("submit", comment: ""), style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            answer.keyboardType = .numberPad
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "item_id":self.foundItemID, "otp":answer.text!], APIName: apiClass().VerifyHandoverOTPAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.RatingView.isHidden = false
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
        ac.addAction(submitAction)
        self.present(ac, animated: true)
    }

    //MARK:- IBAction Methods
    @IBAction func doSubmitRating() {
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["from_user_id":constants().doGetUserId(), "to_user_id": self.foundItemUserID, "rating":"\(self.RateControl.value)"], APIName: apiClass().SubmitUserRatingAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("ratingsubmitted", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
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

    @IBAction func doProceed() {
        constants().APPDEL.isCodeScanDone = false
        constants().APPDEL.ScanError = ""
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "qrscan") as! QRScannerController
        ivc.modalPresentationStyle = .fullScreen
        ivc.SelfoundItemID = self.foundItemID
        self.present(ivc, animated: true, completion: nil)
    }

    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "founditemdetail") as! FoundItemDetailPage
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doLearnHowItWorks() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "howqrworks") as! HowQRWorks
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    @IBAction func doShare() {
        let foundItemDesc = "Please check the QR of Item i have found"
        let activityViewController = UIActivityViewController(activityItems: [self.QrCodeImageview.image!, foundItemDesc] , applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.print]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func doPrint() {
        let activityViewController = UIActivityViewController(activityItems: [self.QrCodeImageview.image!] , applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.assignToContact, .saveToCameraRoll, .copyToPasteboard, .postToFacebook, .postToTwitter, .postToVimeo, .postToFlickr, .message, .mail, .addToReadingList, .postToTencentWeibo, .airDrop, .openInIBooks]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func doDownload() {
        UIImageWriteToSavedPhotosAlbum(self.QrCodeImageview.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: NSLocalizedString("saved", comment: ""), message: NSLocalizedString("qrdownloaded", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default))
            present(ac, animated: true)
        }
    }

    //MARK:- Admob Delegate
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
