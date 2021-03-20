//  FoundItemDetailPage.swift
//  LostAndFound
//  Created by Revamp on 04/11/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import PageControls
import MapKit
import CoreLocation
import MessageUI
import BraintreeDropIn
import Braintree

class FoundItemDetailPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var MainScroll : UIScrollView!
    @IBOutlet weak var imgItemCollection : UICollectionView!
    @IBOutlet weak var myPageControl: ZPageControl!
    @IBOutlet weak var AllContentView : UIView!

    @IBOutlet weak var ItemView: UIView!
    @IBOutlet weak var ItemName: UILabel!
    @IBOutlet weak var ItemCategory: UILabel!
    @IBOutlet weak var ItemBrandTitle: UILabel!
    @IBOutlet weak var ItemBrand: UILabel!
    @IBOutlet weak var ItemColorTitle: UILabel!
    @IBOutlet weak var ItemColor: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnViews: UIButton!
    @IBOutlet weak var imgRewardIcon: UIImageView!
    @IBOutlet weak var lblRewardAmount: UILabel!
    @IBOutlet weak var lblRewardAmountTitle: UILabel!

    @IBOutlet weak var DateLocationView: UIView!
    @IBOutlet weak var imgDateIcon: UIImageView!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblDateTimeTitle: UILabel!
    @IBOutlet weak var LocationMapView: MKMapView!
    @IBOutlet weak var imgPinIcon: UIImageView!
    @IBOutlet weak var lblAddressTitle: UILabel!
    @IBOutlet weak var txtAddressDesc: UITextView!

    @IBOutlet weak var OwnerView: UIView!
    @IBOutlet weak var OwnerImage: UIImageView!
    @IBOutlet weak var OwnerName: UILabel!
    @IBOutlet weak var OwnerLocation: UILabel!
    @IBOutlet weak var BtnOwnerCall: UIButton!
    @IBOutlet weak var BtnOwnerMail: UIButton!
    @IBOutlet weak var BtnOwnerChatMessage: UIButton!
    @IBOutlet weak var BtnOwnerPin: UIButton!
    @IBOutlet weak var OwnerLockView: UIView!
    @IBOutlet weak var OwnerPayToAccess: UIButton!

    @IBOutlet weak var FoundItemTrackingView: UIView!
    @IBOutlet weak var FoundItemTrackingCollection: UICollectionView!

    @IBOutlet weak var TagView: UIView!
    @IBOutlet weak var TagsDescription: UITextView!

    @IBOutlet weak var btnPayNow: UIButton!
    @IBOutlet weak var btnTakeHandover: UIButton!
    @IBOutlet weak var btnLearnHowHandoverWorks: UIButton!

    var ArrItemImages = NSMutableArray()
    var arrFoundTracking = NSMutableArray()
    var SharableImage = UIImage(named: "place_holder")
    var ScreenshotImage = UIImage()
    var isReward = false
    var SelectedFoundItemID = ""
    var dictFoundDetail = NSDictionary()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.doConfigurePageControl()

        // Reachability Check
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }

        // Fetch All Data
        self.doFetchData()
    
        // Increase View Counts
        apiClass().doNormalAPI(param: ["found_id":self.SelectedFoundItemID], APIName: apiClass().FoundViewCountAPI, method: "POST") { (success, errMessage, mDict) in
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Fetch Data
    func doFetchData() {
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "found_id":self.SelectedFoundItemID], APIName: apiClass().FoundItemDetailAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.dictFoundDetail = mDict.value(forKey: "found_item") as! NSDictionary
                    self.ItemName.text = (self.dictFoundDetail.value(forKey: "item_name") as! String)
                    self.ItemCategory.text = (self.dictFoundDetail.value(forKey: "category_item_name") as! String)
                    self.ItemBrand.text = (self.dictFoundDetail.value(forKey: "brand_name") as? String)
                    if (self.ItemBrand.text?.count == 0) {
                        self.ItemBrand.text = NSLocalizedString("no_info_short", comment: "")
                    }
                    self.ItemColor.backgroundColor = constants().hexStringToUIColor(hex: (self.dictFoundDetail.value(forKey: "color_code") as! String))

                    if ((self.dictFoundDetail.value(forKey: "expected_reward") as! String).isEmpty || (self.dictFoundDetail.value(forKey: "expected_reward") as! String) == "0") {
                        self.lblRewardAmountTitle.isHidden = true
                        self.lblRewardAmount.isHidden = true
                        self.imgRewardIcon.isHidden = true
                        self.btnPayNow.isHidden = true
                    } else {
                        self.lblRewardAmount.text = (self.dictFoundDetail.value(forKey: "expected_reward") as! String)
                    }

                    self.btnViews.setTitle("\(self.dictFoundDetail.value(forKey: "no_of_view") as! String) Views", for: .normal)
                    self.OwnerName.text = "\(self.dictFoundDetail.value(forKey: "first_name") as! String) \(self.dictFoundDetail.value(forKey: "last_name") as! String)"
                    self.OwnerLocation.text = (self.dictFoundDetail.value(forKey: "address1") as! String)
                    if !(self.dictFoundDetail.value(forKey: "address2") as! String).isEmpty {
                        self.OwnerLocation.text?.append(", \(self.dictFoundDetail.value(forKey: "address2") as! String)")
                    }
                    if !(self.dictFoundDetail.value(forKey: "city") as! String).isEmpty {
                        self.OwnerLocation.text?.append(", \(self.dictFoundDetail.value(forKey: "city") as! String)")
                    }
                    if !(self.dictFoundDetail.value(forKey: "country") as! String).isEmpty {
                        self.OwnerLocation.text?.append(", \(self.dictFoundDetail.value(forKey: "country") as! String)")
                    }

                    if (self.OwnerLocation.text?.count == 0) {
                        self.OwnerLocation.text = NSLocalizedString("no_info_short", comment: "")
                    }

                    self.OwnerImage.contentMode = .scaleAspectFill
                    self.ArrItemImages = (self.dictFoundDetail.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray
                    self.myPageControl.numberOfPages = self.ArrItemImages.count
                    self.imgItemCollection.reloadData()

                    self.lblDateTime.text = (self.dictFoundDetail.value(forKey: "found_date") as! String)
                    self.txtAddressDesc.text = (self.dictFoundDetail.value(forKey: "location") as! String)

                    self.doSetupMapLocation()
                    var tagArray =  (self.dictFoundDetail.value(forKey: "tag") as! String).components(separatedBy: ",")
                    tagArray =    (((tagArray.map { "#\($0)" }) as NSArray).mutableCopy() as! NSMutableArray) as! [String]
                    self.TagsDescription.text = tagArray.joined(separator: ",")

                    /*
                    if self.dictFoundDetail.value(forKey: "is_payed") as! String == "0" {
                        self.OwnerImage.sd_setImage(with: URL(string: (self.dictFoundDetail.value(forKey: "image") as! String)), completed: nil)

                        if (self.dictFoundDetail.value(forKey: "text_chat_status") as! String) == "OFF" {
                            self.BtnOwnerChatMessage.isEnabled = false
                            self.BtnOwnerChatMessage.backgroundColor = UIColor.lightGray
                        } else {
                            self.BtnOwnerChatMessage.isEnabled = true
                            self.BtnOwnerChatMessage.backgroundColor = constants().COLOR_LightBlue
                        }

                        if (self.dictFoundDetail.value(forKey: "user_mobile") as! String).isEmpty {
                            self.BtnOwnerCall.isEnabled = false
                            self.BtnOwnerCall.backgroundColor = UIColor.lightGray
                        } else {
                            if (self.dictFoundDetail.value(forKey: "display_mobile_status") as! String) == "OFF" {
                                self.BtnOwnerCall.isEnabled = false
                                self.BtnOwnerCall.backgroundColor = UIColor.lightGray
                            } else {
                                self.BtnOwnerCall.isEnabled = true
                                self.BtnOwnerCall.backgroundColor = constants().COLOR_LightBlue
                            }
                        }
                        if (self.dictFoundDetail.value(forKey: "user_email") as! String).isEmpty {
                            self.BtnOwnerMail.isEnabled = false
                            self.BtnOwnerMail.backgroundColor = UIColor.lightGray
                        } else {
                            self.BtnOwnerMail.isEnabled = true
                            self.BtnOwnerMail.backgroundColor = constants().COLOR_LightBlue
                        }
                        self.OwnerLockView.isHidden = true

                        var frame = self.OwnerView.frame
                        frame.size.height = 155
                        self.OwnerView.frame = frame
                    } else {
                        self.OwnerLockView.isHidden = false
                        self.doProfileAccessGesture()

                        var frame = self.OwnerView.frame
                        frame.size.height = 220
                        self.OwnerView.frame = frame
                    }
                    */

                    var frame = self.FoundItemTrackingView.frame
                    frame.origin.y = self.OwnerView.frame.origin.y + self.OwnerView.frame.size.height + 20
                    self.FoundItemTrackingView.frame = frame

                    frame = self.TagView.frame
                    frame.origin.y = self.FoundItemTrackingView.frame.origin.y + self.FoundItemTrackingView.frame.size.height + 20
                    self.TagView.frame = frame

                    frame = self.btnPayNow.frame
                    frame.origin.y = self.TagView.frame.origin.y + self.TagView.frame.size.height + 20
                    self.btnPayNow.frame = frame

                    frame = self.btnTakeHandover.frame
                    frame.origin.y = self.btnPayNow.frame.origin.y + self.btnPayNow.frame.size.height + 20
                    self.btnTakeHandover.frame = frame

                    frame = self.btnLearnHowHandoverWorks.frame
                    frame.origin.y = self.btnTakeHandover.frame.origin.y + self.btnTakeHandover.frame.size.height + 20
                    self.btnLearnHowHandoverWorks.frame = frame

                    self.ArrItemImages = (self.dictFoundDetail.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray
                    self.myPageControl.numberOfPages = self.ArrItemImages.count
                    self.imgItemCollection.reloadData()

                    self.arrFoundTracking = (self.dictFoundDetail.value(forKey: "found_track") as! NSArray).mutableCopy() as! NSMutableArray
                    self.FoundItemTrackingCollection.reloadData()

                    let trackingHeight = CGFloat(self.arrFoundTracking.count * 90)
                    frame = self.FoundItemTrackingCollection.frame
                    frame.size.height = trackingHeight
                    self.FoundItemTrackingCollection.frame = frame

                    frame = self.FoundItemTrackingView.frame
                    frame.size.height = trackingHeight + 50
                    self.FoundItemTrackingView.frame = frame

                    frame = self.TagView.frame
                    frame.origin.y = self.FoundItemTrackingView.frame.origin.y + self.FoundItemTrackingView.frame.size.height + 20
                    self.TagView.frame = frame

                    frame = self.btnPayNow.frame
                    frame.origin.y = self.TagView.frame.origin.y + self.TagView.frame.size.height + 20
                    self.btnPayNow.frame = frame

                    frame = self.btnTakeHandover.frame
                    if constants().doGetUserId() == (self.dictFoundDetail.value(forKey: "user_id") as! String) {
                        frame.origin.y = self.btnPayNow.frame.origin.y
                    } else {
                        frame.origin.y = self.btnPayNow.frame.origin.y + self.btnPayNow.frame.size.height + 15
                    }
                    self.btnTakeHandover.frame = frame

                    frame = self.btnLearnHowHandoverWorks.frame
                    frame.origin.y = self.btnTakeHandover.frame.origin.y + self.btnTakeHandover.frame.size.height + 15
                    self.btnLearnHowHandoverWorks.frame = frame

                    frame = self.AllContentView.frame
                    frame.size.height = self.btnLearnHowHandoverWorks.frame.origin.y + self.btnLearnHowHandoverWorks.frame.size.height + 10
                    self.AllContentView.frame = frame

                    self.MainScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.AllContentView.frame.origin.y + self.AllContentView.frame.size.height)

                    if constants().APPDEL.isMyItem == 0 {
                        if constants().doGetUserId() == (self.dictFoundDetail.value(forKey: "user_id") as! String) {
                            self.doHideOwnerControls()
                            self.btnTakeHandover.setTitle(NSLocalizedString("qrcodedetails", comment: ""), for: .normal)
                            self.btnTakeHandover.setImage(UIImage(named: "qrIcon"), for: .normal)
                        } else {
                            self.btnTakeHandover.setTitle(NSLocalizedString("takehandover", comment: ""), for: .normal)
                            self.btnTakeHandover.setImage(UIImage(named: "handoverIcon"), for: .normal)
                        }
                    } else {
                        self.doHideOwnerControls()
                        self.btnTakeHandover.setTitle(NSLocalizedString("qrcodedetails", comment: ""), for: .normal)
                        self.btnTakeHandover.setImage(UIImage(named: "qrIcon"), for: .normal)
                    }
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        self.doBack()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    //MARK:- 1$ Pay Gesture
    func doProfileAccessGesture() {
        self.BtnOwnerCall.isEnabled = false
        self.BtnOwnerCall.backgroundColor = UIColor.lightGray

        self.BtnOwnerMail.isEnabled = false
        self.BtnOwnerMail.backgroundColor = UIColor.lightGray

        self.BtnOwnerChatMessage.isEnabled = false
        self.BtnOwnerChatMessage.backgroundColor = UIColor.lightGray

        self.BtnOwnerPin.isEnabled = false
        self.BtnOwnerPin.backgroundColor = UIColor.lightGray

        self.OwnerImage.image = UIImage(named: "userNoimage")
    }

    //MARK:- Other Methods
    func doConfigurePageControl() {
        self.myPageControl.numberOfPages = self.ArrItemImages.count
        self.myPageControl.currentPage = 0
        self.myPageControl.dotSize = CGSize(width: 15.0, height: 4.0)
        self.myPageControl.dotRadius = 2.0
        self.myPageControl.pageIndicatorTintColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        self.myPageControl.currentPageIndicatorTintColor = constants().COLOR_LightBlue
    }

    func doSetupMapLocation() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(txtAddressDesc.text) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    return
            }

            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.LocationMapView.setRegion(region, animated: true)

            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = self.ItemName.text
            annotation.subtitle = self.txtAddressDesc.text
            self.LocationMapView.addAnnotation(annotation)
        }
    }

    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.MainScroll.semanticContentAttribute = .forceLeftToRight
        self.AllContentView.semanticContentAttribute = .forceLeftToRight
        self.ItemView.semanticContentAttribute = .forceLeftToRight

        self.btnBack.layer.cornerRadius = 20.0
        self.btnBack.layer.masksToBounds = true

        self.ItemView.layer.cornerRadius = 10.0
        self.ItemView.layer.masksToBounds = true

        self.DateLocationView.layer.cornerRadius = 10.0
        self.DateLocationView.layer.masksToBounds = true

        self.OwnerView.layer.cornerRadius = 10.0
        self.OwnerView.layer.masksToBounds = true

        self.OwnerLockView.layer.cornerRadius = 25.0
        self.OwnerLockView.layer.masksToBounds = true

        self.OwnerPayToAccess.layer.cornerRadius = self.OwnerPayToAccess.frame.size.height / 2
        self.OwnerPayToAccess.layer.masksToBounds = true

        self.FoundItemTrackingView.layer.cornerRadius = 10.0
        self.FoundItemTrackingView.layer.masksToBounds = true

        self.TagView.layer.cornerRadius = 10.0
        self.TagView.layer.masksToBounds = true

        self.btnShare.layer.cornerRadius = self.btnShare.frame.size.height / 2
        self.btnShare.layer.masksToBounds = true

        self.btnViews.layer.cornerRadius = self.btnViews.frame.size.height / 2
        self.btnViews.layer.masksToBounds = true

        self.ItemColor.layer.cornerRadius = self.ItemColor.frame.size.width / 2
        self.ItemColor.layer.masksToBounds = true

        self.OwnerImage.layer.cornerRadius = self.OwnerImage.frame.size.width / 2
        self.OwnerImage.layer.masksToBounds = true

        self.BtnOwnerCall.layer.cornerRadius = self.BtnOwnerCall.frame.size.width / 2
        self.BtnOwnerCall.layer.masksToBounds = true

        self.BtnOwnerMail.layer.cornerRadius = self.BtnOwnerMail.frame.size.width / 2
        self.BtnOwnerMail.layer.masksToBounds = true

        self.BtnOwnerChatMessage.layer.cornerRadius = self.BtnOwnerChatMessage.frame.size.width / 2
        self.BtnOwnerChatMessage.layer.masksToBounds = true

        self.BtnOwnerPin.layer.cornerRadius = self.BtnOwnerPin.frame.size.width / 2
        self.BtnOwnerPin.layer.masksToBounds = true

        let attributeString = NSMutableAttributedString(string: NSLocalizedString("learnhowhandoverwork", comment: ""), attributes: [.font: UIFont(name: constants().FONT_REGULAR, size: 16.0)!, .foregroundColor: constants().COLOR_LightBlue, .underlineStyle: NSUnderlineStyle.single.rawValue])
        self.btnLearnHowHandoverWorks.setAttributedTitle(attributeString, for: .normal)

        if (constants().userinterface == .pad) {
            var frame = self.imgItemCollection.frame
            frame.size.height = constants().SCREENSIZE.height * 0.42
            self.imgItemCollection.frame = frame

            frame = self.AllContentView.frame
            frame.origin.y = self.imgItemCollection.frame.size.height - 60
            self.AllContentView.frame = frame

            frame = self.myPageControl.frame
            frame.origin.y = self.AllContentView.frame.origin.y - 30
            self.myPageControl.frame = frame
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.btnBack.frame
                frame.origin.y = 35
                self.btnBack.frame = frame
            }
        }

        var frame  = self.AllContentView.frame
        frame.size.height = self.btnLearnHowHandoverWorks.frame.origin.y + self.btnLearnHowHandoverWorks.frame.size.height + 20
        self.AllContentView.frame = frame

        self.MainScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.AllContentView.frame.origin.y + self.AllContentView.frame.size.height)
    }

    func doApplyLocalisation() {
        self.ItemBrandTitle.text = NSLocalizedString("brand", comment: "")
        self.ItemColorTitle.text = NSLocalizedString("color", comment: "")
    }

    //MARK:- UIScrollView Delegate Method
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var swipeValue:CGFloat = -70
        if (constants().userinterface == .pad) {
            swipeValue = -120
        }
        if scrollView.contentOffset.y < swipeValue {
            self.view.window!.layer.add(constants().pushFromBottomTransition(), forKey: kCATransition)
            self.doBack()
        }
    }

    func doHideOwnerControls() {
//        self.BtnOwnerCall.isHidden = true
//        self.BtnOwnerMail.isHidden = true
//        self.BtnOwnerChatMessage.isHidden = true
//        self.BtnOwnerPin.isHidden = true
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
                if self.isReward == false {
                    constants().APPDEL.doStartSpinner()
                    apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "paymentMethodNonce":strPaymentNonce, "found_id":self.SelectedFoundItemID, "total":"1"], APIName: apiClass().BraintreeCreateOrderAPI, method: "POST") { (success, errMessage, mDict) in
                        DispatchQueue.main.async {
                            if success == true {
                                self.doFetchData()
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
                    constants().APPDEL.doStartSpinner()
                    apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "paymentMethodNonce":strPaymentNonce, "found_id":self.SelectedFoundItemID, "reward_amount":(self.dictFoundDetail.value(forKey: "expected_reward") as! String)], APIName: apiClass().CreateRewardOrderAPI, method: "POST") { (success, errMessage, mDict) in
                        DispatchQueue.main.async {
                            if success == true {
                                let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("rewardpaidsuccess", comment: ""), preferredStyle: .alert)
                                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
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
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }

    //MARK:- IBAction Methods
    @IBAction func doPayForOwnerAccess() {
        self.isReward = false
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().ClientTokenAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    let strClientToken = mDict.value(forKey: "clientToken") as! String
                    self.showDropIn(clientTokenOrTokenizationKey: strClientToken)
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        self.doBack()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func doBack() {
        if constants().APPDEL.isMyItem == 0 {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            ivc.selectedIndex = 0
            constants().APPDEL.window?.rootViewController = ivc
        } else if constants().APPDEL.isMyItem == 1 {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myitems") as! MyItems
            constants().APPDEL.window?.rootViewController = ivc
        }
    }

    @IBAction func doShare() {
        let foundItemDesc = "Found Item - \(self.ItemName.text!)"
        var shareItems : [Any] = [foundItemDesc]
        if self.SharableImage != nil {
            shareItems = [foundItemDesc, self.SharableImage!]
        }
        let activityViewController = UIActivityViewController(activityItems: shareItems , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func doPayNow() {
        self.isReward = true
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().ClientTokenAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    var strClientToken = mDict.value(forKey: "clientToken") as! String
                    self.showDropIn(clientTokenOrTokenizationKey: strClientToken)
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        self.doBack()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func doTakeHandover() {
        constants().APPDEL.isCodeScanDone = false
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "founditemqr") as! FoundItemQR
        if constants().doGetUserId() == (self.dictFoundDetail.value(forKey: "user_id") as! String) {
            ivc.qrImageURL = (self.dictFoundDetail.value(forKey: "qr_image") as! String)
        }
        ivc.foundItemID =  (self.dictFoundDetail.value(forKey: "found_id") as! String)
        ivc.foundItemMobile = (self.dictFoundDetail.value(forKey: "user_mobile") as! String)
        ivc.foundItemUserID =  (self.dictFoundDetail.value(forKey: "user_id") as! String)
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doLearnHowHandoverWorks() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "howqrworks") as! HowQRWorks
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    @IBAction func doOwnerCall() {
        constants().doCallNumber(phoneNumber: self.dictFoundDetail.value(forKey: "user_mobile") as! String)
    }

    @IBAction func doOwnerMail() {
        self.screenshot()
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail() {
            mailComposeViewController.modalPresentationStyle = .fullScreen
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }

    @IBAction func doOwnerChat() {
        constants().APPDEL.doGetQuickBloxUser(nLogin: (self.dictFoundDetail.value(forKey: "user_id") as! String))
    }

    @IBAction func doOwnerPinview() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "maplocationview") as! MapLocationView
        ivc.myLocation = self.txtAddressDesc.text
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    func screenshot() {
        let savedContentOffset = self.MainScroll.contentOffset
        let savedFrame = self.MainScroll.frame
        UIGraphicsBeginImageContext(self.MainScroll.contentSize)
        self.MainScroll.contentOffset = .zero
        self.MainScroll.frame = CGRect(x: 0, y: 0, width: self.MainScroll.contentSize.width, height: self.MainScroll.contentSize.height)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        self.MainScroll.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        self.MainScroll.contentOffset = savedContentOffset
        self.MainScroll.frame = savedFrame
        self.ScreenshotImage = image!
    }

    //MARK:- Mail Configure
    func configureMailComposer() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([(self.dictFoundDetail.value(forKey: "user_email") as! String)])
        mailComposeVC.addAttachmentData(self.ScreenshotImage.jpegData(compressionQuality: 1.0)!, mimeType: "image/jpeg", fileName:  "FoundItem.jpeg")
        mailComposeVC.setSubject("Lost & Found - Found Item")
        mailComposeVC.setMessageBody("Hi \(self.OwnerName.text!),\n\nI would like to inquire about this Found Item added by you.\n\n", isHTML: false)
        return mailComposeVC
    }

    //MARK:- MFMailComposeViewController Delegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    //MARK:- Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "map_pin")
        return annotationView
    }

    //MARK:- UICollectionview Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.imgItemCollection {
            return self.ArrItemImages.count
        }
        if collectionView == self.FoundItemTrackingCollection {
            return self.arrFoundTracking.count
        }
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.imgItemCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.clear

            let mDict = self.ArrItemImages.object(at: indexPath.row) as! NSDictionary
            let imgProductImage = cell.viewWithTag(101) as! UIImageView
            imgProductImage.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            imgProductImage.sd_setImage(with: URL(string: mDict.value(forKey: "image") as! String), completed: nil)
            if indexPath.row == 0 {
                SharableImage = imgProductImage.image
            }
            imgProductImage.contentMode = .scaleAspectFit
            imgProductImage.backgroundColor = UIColor.clear

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.clear

            let lblTrackingTitle = cell.viewWithTag(101) as! UILabel
            let uImage = cell.viewWithTag(102) as! UIImageView
            let lblUName = cell.viewWithTag(103) as! UILabel
            let lblTrackingDate = cell.viewWithTag(104) as! UILabel
            let imgCheckmark = cell.viewWithTag(105) as! UIImageView
            let imgVerticalLine = cell.viewWithTag(106) as! UIImageView

            if indexPath.row == self.arrFoundTracking.count-1 {
                imgVerticalLine.isHidden = true
            } else {
                imgVerticalLine.isHidden = false
            }

            imgCheckmark.layer.cornerRadius = uImage.frame.size.width / 2
            imgCheckmark.layer.masksToBounds = true

            uImage.layer.cornerRadius = uImage.frame.size.width / 2
            uImage.layer.masksToBounds = true
            uImage.backgroundColor = UIColor.lightGray

            let mDict = self.arrFoundTracking.object(at: indexPath.row) as! NSDictionary
            lblTrackingTitle.text = mDict.value(forKey: "title") as? String
            lblTrackingDate.text = mDict.value(forKey: "datetime") as? String
            uImage.loadProfileImage(url: mDict.value(forKey: "image") as! String)

            if let val = mDict["name"] {
                let attributeString = NSMutableAttributedString(string: "\(mDict.value(forKey: "name") as! String)", attributes: [.font: UIFont(name: constants().FONT_REGULAR, size: 13)!, .foregroundColor: constants().COLOR_LightBlue, .underlineStyle: NSUnderlineStyle.single.rawValue])
                lblUName.attributedText = attributeString
            } else {
                print("key is not present in dict")
            }
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.imgItemCollection {
            return CGSize(width: constants().SCREENSIZE.width, height: self.imgItemCollection.frame.size.height)
        }
        let mSize = self.FoundItemTrackingCollection.frame.size.width
        return CGSize(width: mSize, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.imgItemCollection {
            self.myPageControl.currentPage = indexPath.row
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
