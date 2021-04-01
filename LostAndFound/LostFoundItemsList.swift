//  LostFoundItemsList.swift
//  LostAndFound
//  Created by Revamp on 23/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import MapKit
import LocalAuthentication
import GoogleMobileAds

class LostFoundItemsList: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate, GADInterstitialDelegate {
    @IBOutlet weak var vwTopView : UIView!
    @IBOutlet weak var btnSearch : UIButton!
    @IBOutlet weak var btnTitle : UIButton!
    @IBOutlet weak var btnProfile : UIButton!
    @IBOutlet weak var lblNotification : UILabel!
    @IBOutlet weak var vwOptionsView : UIView!
    @IBOutlet weak var btnList : UIButton!
    @IBOutlet weak var btnFilter : UIButton!
    @IBOutlet weak var btnMap : UIButton!
    @IBOutlet weak var LostCollection : UICollectionView!
    @IBOutlet weak var FoundCollection : UICollectionView!
    @IBOutlet weak var myMapView : MKMapView!
    @IBOutlet weak var vwNoItems : UIView!

    @IBOutlet weak var BiometricView : UIView!
    @IBOutlet weak var BiometricSubview : UIView!
    @IBOutlet weak var lblBiometricTitle : UILabel!
    @IBOutlet weak var btnFaceID : UIButton!
    @IBOutlet weak var btnTouchID : UIButton!
    @IBOutlet weak var btnNotNow : UIButton!

    @IBOutlet weak var LostPinView : UIView!
    @IBOutlet weak var btnLostPin : UIButton!
    @IBOutlet weak var FoundPinView : UIView!
    @IBOutlet weak var btnFoundPin : UIButton!

    @IBOutlet weak var BottomWhite : UIView!
    @IBOutlet weak var BottomCircle : UIView!

    @IBOutlet weak var OptionView : UIView!
    @IBOutlet weak var OptionSubView : UIView!
    @IBOutlet weak var BtnOptionLost : UIButton!
    @IBOutlet weak var BtnOptionFound : UIButton!
    @IBOutlet weak var ImgOptionLost : UIImageView!
    @IBOutlet weak var ImgOptionFound : UIImageView!

    var interstitial: GADInterstitial!
    var selectedPinIndex = -1
    var LostRefresher:UIRefreshControl!
    var FoundRefresher:UIRefreshControl!
    var adLoader : GADAdLoader!
    var NativeAdView : GADUnifiedNativeAdView!

    var FoundItemsList = NSMutableArray()
    var LostItemList = NSMutableArray()

    private var lastContentOffset: CGFloat = 0

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.myMapView.isHidden = true
        self.doConfigureRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if constants().APPDEL.isMapMode == true {
            self.doMapView()
        } else {
            self.doListView()
        }

        self.doFetchItems()
        Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.doBiometricConfigure), userInfo: nil, repeats: false)
        self.doConfigureFullAd()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func doConfigureRefreshControl() {
        self.LostRefresher = UIRefreshControl()
        self.LostCollection!.alwaysBounceVertical = true
        self.LostRefresher.tintColor = UIColor.white
        self.LostRefresher.addTarget(self, action: #selector(self.doFetchItems), for: .valueChanged)
        self.LostCollection.refreshControl = self.LostRefresher

        self.FoundRefresher = UIRefreshControl()
        self.FoundCollection!.alwaysBounceVertical = true
        self.FoundRefresher.tintColor = UIColor.white
        self.FoundRefresher.addTarget(self, action: #selector(self.doFetchItems), for: .valueChanged)
        self.FoundCollection!.addSubview(self.FoundRefresher)
        self.FoundCollection.refreshControl = self.FoundRefresher
    }

    func stopRefresher() {
        self.LostCollection!.refreshControl?.endRefreshing()
        self.FoundCollection!.refreshControl?.endRefreshing()
    }

    //MARK:- Configure Full Ad
    func doConfigureFullAd() {
        if constants().APPDEL.isAdJustClosed == true {
            constants().APPDEL.isAdJustClosed = false
            return
        }
        if constants().isAdRandomNo() == 3 {
            self.interstitial = GADInterstitial(adUnitID: constants().AD_FULL_ID)
            interstitial.delegate = self
            let request = GADRequest()
            interstitial.load(request)
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.BiometricView.semanticContentAttribute = .forceLeftToRight

        self.OptionSubView.layer.cornerRadius = 15.0
        self.OptionSubView.layer.masksToBounds = true

        self.LostPinView.layer.cornerRadius = 15.0
        self.LostPinView.layer.borderWidth = 0.2
        self.LostPinView.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
        self.LostPinView.layer.shadowColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
        self.LostPinView.layer.shadowOffset = CGSize(width: 1.5, height: 5.0)
        self.LostPinView.layer.shadowOpacity = 0.7
        self.LostPinView.layer.shadowRadius = 4.0

        self.FoundPinView.layer.cornerRadius = 15.0
        self.FoundPinView.layer.borderWidth = 0.2
        self.FoundPinView.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
        self.FoundPinView.layer.shadowColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
        self.FoundPinView.layer.shadowOffset = CGSize(width: 1.5, height: 5.0)
        self.FoundPinView.layer.shadowOpacity = 0.7
        self.FoundPinView.layer.shadowRadius = 4.0

        self.BiometricSubview.layer.cornerRadius = 20.0
        self.BiometricSubview.layer.masksToBounds = true

        self.vwOptionsView.layer.cornerRadius = 27.0
        self.vwOptionsView.layer.masksToBounds = true
        self.vwOptionsView.layer.borderColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5).cgColor
        self.vwOptionsView.layer.borderWidth = 1.0
        self.vwOptionsView.layer.shadowColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
        self.vwOptionsView.layer.shadowOffset = CGSize(width: 1.5, height: 5.0)
        self.vwOptionsView.layer.shadowOpacity = 0.7
        self.vwOptionsView.layer.shadowRadius = 4.0

        self.btnProfile.layer.cornerRadius = 15.0
        self.btnProfile.layer.masksToBounds = true

        self.lblNotification.layer.cornerRadius = 7.5
        self.lblNotification.layer.masksToBounds = true

        self.BottomCircle.layer.cornerRadius = 40.0
        self.BottomCircle.layer.masksToBounds = true

        if (constants().userinterface == .pad) {
            var frame = self.LostPinView.frame
            frame.size.height = 350
            frame.origin.y = constants().SCREENSIZE.height - frame.size.height - (self.tabBarController?.tabBar.frame.size.height)! - 20
            self.LostPinView.frame = frame

            frame = self.FoundPinView.frame
            frame.size.height = 375
            frame.origin.y = constants().SCREENSIZE.height - frame.size.height - (self.tabBarController?.tabBar.frame.size.height)! - 20
            self.FoundPinView.frame = frame
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.vwTopView.frame
                frame.size.height = 80
                self.vwTopView.frame = frame

                frame = self.btnTitle.frame
                frame.origin.y = 35
                self.btnTitle.frame = frame

                frame = self.btnSearch.frame
                frame.origin.y = 40
                self.btnSearch.frame = frame

                frame = self.btnProfile.frame
                frame.origin.y = 35
                self.btnProfile.frame = frame

                frame = self.lblNotification.frame
                frame.origin.y = self.btnProfile.frame.origin.y + self.btnProfile.frame.size.height - (frame.size.height / 1.2)
                frame.origin.x = self.btnProfile.frame.origin.x + self.btnProfile.frame.size.width - (frame.size.width / 1.2)
                self.lblNotification.frame = frame

                frame = self.btnTitle.frame
                frame.origin.y = 35
                self.btnTitle.frame = frame

                frame = self.vwOptionsView.frame
                frame.origin.y = self.vwTopView.frame.origin.y + self.vwTopView.frame.size.height + 15
                self.vwOptionsView.frame = frame

                frame = self.LostCollection.frame
                frame.origin.y = self.vwTopView.frame.origin.y + self.vwTopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.LostCollection.frame = frame

                frame = self.FoundCollection.frame
                frame.origin.y = self.vwTopView.frame.origin.y + self.vwTopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.FoundCollection.frame = frame

                frame = self.myMapView.frame
                frame.origin.y = self.vwTopView.frame.origin.y + self.vwTopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.myMapView.frame = frame

                frame = self.vwNoItems.frame
                frame.origin.y = self.vwTopView.frame.origin.y + self.vwTopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.vwNoItems.frame = frame

                frame = self.BottomWhite.frame
                frame.size.height = 90
                frame.origin.y = constants().SCREENSIZE.height - frame.size.height
                self.BottomWhite.frame = frame

                frame = self.BottomCircle.frame
                frame.origin.y = constants().SCREENSIZE.height - frame.size.height - 40
                self.BottomCircle.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblBiometricTitle.text = NSLocalizedString("doyouconfigurebiometric", comment: "")
        self.btnFaceID.setTitle(NSLocalizedString("faceid", comment: ""), for: .normal)
        self.btnTouchID.setTitle(NSLocalizedString("touchid", comment: ""), for: .normal)
        self.btnNotNow.setTitle(NSLocalizedString("notnow", comment: ""), for: .normal)
    }

    @objc func doFetchItems() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        if constants().APPDEL.isLostOrFound == 1 {
            self.LostCollection.contentOffset = constants().APPDEL.LostCollectionContentOffSet
            constants().APPDEL.LostCollectionContentOffSet = CGPoint(x: 0.0, y: 0.0)

            self.btnTitle.setTitle("Lost", for: .normal)
            self.LostCollection.isHidden = false
            self.FoundCollection.isHidden = true
            
            var param: [String: String] = [:]
            if !constants().APPDEL.strFilterName.isEmpty {
                param["item_name"] = constants().APPDEL.strFilterName
            }
            if !constants().APPDEL.strFilterLocation.isEmpty {
                param["location"] = constants().APPDEL.strFilterLocation
            }
            if !constants().APPDEL.strFilterCatID.isEmpty {
                param["category_id"] = constants().APPDEL.strFilterCatID
            }
            if !constants().APPDEL.strFilterColorID.isEmpty {
                param["color_id"] = constants().APPDEL.strFilterColorID
            }
            if !constants().APPDEL.strFilterFromDate.isEmpty {
                param["from_date"] = constants().APPDEL.strFilterFromDate
            }
            if !constants().APPDEL.strFilterToDate.isEmpty {
                param["to_date"] = constants().APPDEL.strFilterToDate
            }
            if !constants().APPDEL.strFilterBrandString.isEmpty {
                param["brand_name"] = constants().APPDEL.strFilterBrandString
            }
            if !constants().APPDEL.StrLattitude.isEmpty && !constants().APPDEL.StrLongitude.isEmpty {
                param["latitude"] = constants().APPDEL.StrLattitude
                param["longitude"] = constants().APPDEL.StrLongitude
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().LostItemListAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.LostItemList = (mDict.value(forKey: "lost_item") as! NSArray).mutableCopy() as! NSMutableArray
                        if self.LostItemList.count == 0 {
                            self.vwNoItems.isHidden = false
                        } else {
                            self.vwNoItems.isHidden = true
                            self.doSetupMapLocation(iType: "Lost")
                        }
                    } else {
                        self.vwNoItems.isHidden = false
                    }
                    self.LostCollection.reloadData()
                    self.doUpateUserProfile()
                    self.stopRefresher()
                }
            }
        } else {
            self.FoundCollection.contentOffset = constants().APPDEL.FoundCollectionContentOffSet
            constants().APPDEL.FoundCollectionContentOffSet = CGPoint(x: 0.0, y: 0.0)

            self.btnTitle.setTitle("Found", for: .normal)
            self.LostCollection.isHidden = true
            self.FoundCollection.isHidden = false
            var param: [String: Any] = [:]
            if !constants().APPDEL.strFilterName.isEmpty {
                param["item_name"] = constants().APPDEL.strFilterName
            }
            if !constants().APPDEL.strFilterLocation.isEmpty {
                param["location"] = constants().APPDEL.strFilterLocation
            }
            if !constants().APPDEL.strFilterCatID.isEmpty {
                param["category_id"] = constants().APPDEL.strFilterCatID
            }
            if !constants().APPDEL.strFilterColorID.isEmpty {
                param["color_id"] = constants().APPDEL.strFilterColorID
            }
            if !constants().APPDEL.strFilterFromDate.isEmpty {
                param["from_date"] = constants().APPDEL.strFilterFromDate
            }
            if !constants().APPDEL.strFilterToDate.isEmpty {
                param["to_date"] = constants().APPDEL.strFilterToDate
            }
            if !constants().APPDEL.strFilterBrandString.isEmpty {
                param["brand_name"] = constants().APPDEL.strFilterBrandString
            }
            if !constants().APPDEL.StrLattitude.isEmpty && !constants().APPDEL.StrLongitude.isEmpty {
                param["latitude"] = constants().APPDEL.StrLattitude
                param["longitude"] = constants().APPDEL.StrLongitude
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().GetAllFoundItemAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.FoundItemsList = (mDict.value(forKey: "found_item") as! NSArray).mutableCopy() as! NSMutableArray
                        if self.FoundItemsList.count == 0 {
                            self.vwNoItems.isHidden = false
                        } else {
                            self.doSetupMapLocation(iType: "Found")
                            self.vwNoItems.isHidden = true
                        }
                    } else {
                        self.vwNoItems.isHidden = false
                    }
                    self.FoundCollection.reloadData()
                    self.stopRefresher()
                }
            }
        }
    }

    func doUpateUserProfile() {
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetProfileAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    constants().APPDEL.dictUserProfile = mDict.value(forKey: "user_profile") as! NSDictionary
                    self.btnProfile.imageView?.contentMode = .scaleAspectFill
                    self.btnProfile.sd_setImage(with: URL(string: (constants().APPDEL.dictUserProfile.value(forKey: "image") as! String)), for: .normal, completed: nil)
                    self.doNotificationCount()
                }
            }
        }
    }

    func doNotificationCount() {
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetUserNotificationAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.lblNotification.text = (mDict.value(forKey: "un_read") as! String)
                }
            }
        }
    }

    @objc func doBiometricConfigure()  {
        var isShow = true
        if let myDate = UserDefaults.standard.object(forKey: "BiometricReminderDate") as? Date {
            let calendar = NSCalendar.current
            let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: myDate), to: calendar.startOfDay(for: Date()))
            if components.day! >= 15 {
                isShow = true
            } else {
                isShow = false
            }
        } else {
            isShow = true
        }

        if isShow == true {
            if constants().doGetLoginStatus() == "true" {
                if constants().doGetBiometricStatus() == ""  {
                    if constants().APPDEL.isPopup == false {
                        constants().APPDEL.isPopup = true
                        self.BiometricView.isHidden = false
                    } else {
                        constants().APPDEL.isPopup = false
                    }
                }  else {
                    self.BiometricView.isHidden = true
                }
            } else {
                self.BiometricView.isHidden = true
            }
        }
    }

    func doSetupMapLocation(iType : String) {
        self.doCleanMap()
        if iType == "Lost" {
            for i in 0..<self.LostItemList.count {
                let mDict = self.LostItemList.object(at: i) as! NSDictionary
                let itemName = mDict.value(forKey: "item_name") as! String
                let locationName = mDict.value(forKey: "location") as! String
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(locationName) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                        else {
                            return
                    }

                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: location.coordinate, span: span)
                    self.myMapView.setRegion(region, animated: true)

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    annotation.title = itemName
                    annotation.subtitle = locationName
                    annotation.accessibilityHint = "\(i)"
                    self.myMapView.addAnnotation(annotation)
                }
            }
        } else {
            for i in 0..<self.FoundItemsList.count {
                let mDict = self.FoundItemsList.object(at: i) as! NSDictionary
                let itemName = mDict.value(forKey: "item_name") as! String
                let locationName = mDict.value(forKey: "location") as! String
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(locationName) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                        else {
                            return
                    }

                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: location.coordinate, span: span)
                    self.myMapView.setRegion(region, animated: true)

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    annotation.title = itemName
                    annotation.subtitle = locationName
                    annotation.accessibilityHint = "\(i)"
                    self.myMapView.addAnnotation(annotation)
                }
            }
        }
    }

    func doCleanMap() {
        self.myMapView.removeAnnotations(self.myMapView.annotations)
    }

    //MARK:- IBAction Methods
    @IBAction func doClickTitle() {
        self.LostPinView.isHidden = true
        self.FoundPinView.isHidden = true
        self.OptionView.isHidden = false

        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.OptionSubView.isHidden = false
        })

        if constants().APPDEL.isLostOrFound == 1 {
            self.ImgOptionLost.image = UIImage(named: "CheckboxSelected")
            self.ImgOptionFound.image = UIImage(named: "CheckboxEmpty")
        } else {
            self.ImgOptionLost.image = UIImage(named: "CheckboxEmpty")
            self.ImgOptionFound.image = UIImage(named: "CheckboxSelected")
        }
    }

    @IBAction func doOptionLost() {
        self.OptionView.isHidden = true
        constants().APPDEL.isLostOrFound = 1
        self.doFetchItems()
    }
    @IBAction func doOptionFound() {
        self.OptionView.isHidden = true
        constants().APPDEL.isLostOrFound = 2
        self.doFetchItems()
    }

    @IBAction func doFaceID() {
        constants().APPDEL.isPopup = false
        var error: NSError?
        let mContext = LAContext()
        if mContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            self.BiometricView.isHidden = true
            constants().doSaveBiometricStatus(bStatus: "face")
            constants().doSaveBiometricStatusOnOff(bStatus: "On")
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("biometriedenabled", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            constants().doSaveBiometricStatusOnOff(bStatus: "Off")
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("makesurefaceidenabled", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                self.BiometricView.isHidden = true
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func doTouchID() {
        constants().APPDEL.isPopup = false
        var error: NSError?
        if  LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            self.BiometricView.isHidden = true
            constants().doSaveBiometricStatus(bStatus: "touch")
            constants().doSaveBiometricStatusOnOff(bStatus: "On")
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("biometriedenabled", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            constants().doSaveBiometricStatusOnOff(bStatus: "Off")
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("makesuretouchidenabled", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                self.BiometricView.isHidden = true
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func doNotNow() {
        constants().APPDEL.isPopup = false
        UserDefaults.standard.set(Date(), forKey: "BiometricReminderDate")
        constants().doSaveBiometricStatus(bStatus: "")
        self.BiometricView.isHidden = true
    }

    @IBAction func doSearch() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "searchpage") as! SearchPage
        constants().APPDEL.strOptionSearch = self.btnTitle.titleLabel!.text!
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doMyProfile() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myprofile") as! MyProfile
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doListView() {
        constants().APPDEL.isMapMode = false
        self.myMapView.isHidden = true
        self.LostPinView.isHidden = true
        self.FoundPinView.isHidden = true
        self.btnList.setImage(UIImage(named: "ListIcon_selected"), for: .normal)
        self.btnMap.setImage(UIImage(named: "MapIcon_unselected"), for: .normal)
    }

    @IBAction func doMapView() {
        constants().APPDEL.isMapMode = true
        self.myMapView.isHidden = false
        self.btnList.setImage(UIImage(named: "ListIcon_unselected"), for: .normal)
        self.btnMap.setImage(UIImage(named: "MapIcon_selected"), for: .normal)
    }

    @IBAction func doGoToFilterPage() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "filter") as! FilterScreen
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doClickLostPin() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "lostitemdetail") as! LostItemDetailPage
        ivc.lostItemID = (self.LostItemList.object(at: self.selectedPinIndex) as! NSDictionary).value(forKey: "lost_id") as! String
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doClickFoundPin() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "founditemdetail") as! FoundItemDetailPage
        ivc.SelectedFoundItemID = (self.FoundItemsList.object(at: self.selectedPinIndex) as! NSDictionary).value(forKey: "found_id") as! String
        constants().APPDEL.window?.rootViewController = ivc
    }

    func doLoadLostItemPinview() {
        self.LostPinView.isHidden = false
        self.FoundPinView.isHidden = true
        let imgProductImage = self.LostPinView.viewWithTag(101) as! UIImageView
        let lblCategory = self.LostPinView.viewWithTag(102) as! UILabel
        let lblItemTitle = self.LostPinView.viewWithTag(103) as! UILabel
        let lblItemAddress = self.LostPinView.viewWithTag(104) as! UILabel
        let lblItemDate = self.LostPinView.viewWithTag(105) as! UILabel
        let lblItemReward = self.LostPinView.viewWithTag(106) as! UILabel

        let mDict = self.LostItemList.object(at: self.selectedPinIndex) as! NSDictionary
        let pImages = (mDict.value(forKey: "lost_images") as! NSArray).mutableCopy() as! NSMutableArray
        lblItemDate.text = (mDict.value(forKey: "lost_date") as! String)
        if pImages.count > 0 {
            imgProductImage.sd_setImage(with: URL(string: (pImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
        }
        imgProductImage.contentMode = .scaleAspectFit
        imgProductImage.backgroundColor = UIColor.white

        let rewardAttrString = NSMutableAttributedString(string:"Rewards Offered ", attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        rewardAttrString.append(NSMutableAttributedString(string: "$\(mDict.value(forKey: "reward") as! String)", attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_BOLD, size: 13)!, NSAttributedString.Key.foregroundColor: constants().COLOR_LightBlue]))
        lblItemReward.attributedText = rewardAttrString

        lblCategory.layer.cornerRadius = 12.5
        lblCategory.layer.masksToBounds = true
        lblCategory.text = (mDict.value(forKey: "category_item_name") as! String)
        if self.selectedPinIndex % 2 == 0 {
            lblCategory.backgroundColor = UIColor(red: 99.0/255.0, green: 199.0/255.0, blue: 144.0/255.0, alpha: 1.0)
        } else {
            lblCategory.backgroundColor = UIColor(red: 243.0/255.0, green: 197.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        }

        lblItemTitle.text = (mDict.value(forKey: "item_name") as! String)
        lblItemAddress.text = (mDict.value(forKey: "location") as! String)

        var frame = lblCategory.frame
        let newSize = lblCategory.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height))
        frame.size.width = newSize.width + 10
        frame.size.height = 25
        lblCategory.frame = frame

        if (constants().userinterface == .pad) {
            var frame = imgProductImage.frame
            frame.size.height = 250
            imgProductImage.frame = frame
        }
    }

    func doLoadFoundItemPinview() {
        self.LostPinView.isHidden = true
        self.FoundPinView.isHidden = false
        let imgProductImage = self.FoundPinView.viewWithTag(101) as! UIImageView
        let lblCategory = self.FoundPinView.viewWithTag(102) as! UILabel
        let lblItemTitle = self.FoundPinView.viewWithTag(103) as! UILabel
        let lblItemAddress = self.FoundPinView.viewWithTag(104) as! UILabel
        let lblItemDate = self.FoundPinView.viewWithTag(105) as! UILabel
        let lblItemReward = self.FoundPinView.viewWithTag(106) as! UILabel

        let mDict = self.FoundItemsList.object(at: self.selectedPinIndex) as! NSDictionary
        let pImages = (mDict.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray
        lblItemDate.text = (mDict.value(forKey: "found_date") as! String)

        if pImages.count > 0 {
            imgProductImage.sd_setImage(with: URL(string: (pImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
        }
        imgProductImage.contentMode = .scaleAspectFit
        imgProductImage.backgroundColor = UIColor.white

        let rewardAttrString = NSMutableAttributedString(string:"Reward Expected ", attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        rewardAttrString.append(NSMutableAttributedString(string: "$\(mDict.value(forKey: "expected_reward") as! String)", attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_BOLD, size: 13)!, NSAttributedString.Key.foregroundColor: constants().COLOR_LightBlue]))
        lblItemReward.attributedText = rewardAttrString

        lblCategory.layer.cornerRadius = 12.5
        lblCategory.layer.masksToBounds = true
        lblCategory.text = (mDict.value(forKey: "category_item_name") as! String)
        if self.selectedPinIndex % 2 == 0 {
            lblCategory.backgroundColor = UIColor(red: 99.0/255.0, green: 199.0/255.0, blue: 144.0/255.0, alpha: 1.0)
        } else {
            lblCategory.backgroundColor = UIColor(red: 243.0/255.0, green: 197.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        }

        lblItemTitle.text = (mDict.value(forKey: "item_name") as! String)
        lblItemAddress.text = (mDict.value(forKey: "location") as! String)

        var frame = lblCategory.frame
        let newSize = lblCategory.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height))
        frame.size.width = newSize.width + 10
        frame.size.height = 25
        lblCategory.frame = frame

        if (constants().userinterface == .pad) {
            var frame = imgProductImage.frame
            frame.size.height = 250
            imgProductImage.frame = frame
        }
    }

    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = false
            annotationView?.image = UIImage(named: "map_pin")
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            let mIndex = Int(annotation.accessibilityHint!)
            self.selectedPinIndex = mIndex!
            if self.btnTitle.titleLabel?.text == "Lost" {
                self.doLoadLostItemPinview()
            } else {
                self.doLoadFoundItemPinview()
            }
        } else {
            self.LostPinView.isHidden = true
            self.FoundPinView.isHidden = true
        }
    }

    //MARK:- Touch Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch : UITouch = touches.first!
        if self.FoundPinView.isHidden == false {
            if touch.view != self.FoundPinView {
                FoundPinView.isHidden = true
            }
        }
        if self.LostPinView.isHidden == false {
            if touch.view != self.LostPinView {
                LostPinView.isHidden = true
            }
        }
    }

    //MARK:- UIScrollView Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if lastContentOffset > scrollView.contentOffset.y && lastContentOffset < scrollView.contentSize.height - scrollView.frame.height {
            self.vwOptionsView.isHidden = false
        } else if lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y > 0 {
            self.vwOptionsView.isHidden = true
        }
        lastContentOffset = scrollView.contentOffset.y
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (section > 0 && section % (constants().APPDEL.NativeAdPosition-1) == 0) {
            if (constants().userinterface == .pad) {
                return CGSize(width: constants().SCREENSIZE.width, height: 370)
            }
            return CGSize(width: constants().SCREENSIZE.width, height: 260)
        }
        return CGSize(width: constants().SCREENSIZE.width, height: 1)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "adheader", for: indexPath)
                headerView.backgroundColor = UIColor.clear
                if (indexPath.section > 0 && indexPath.section % (constants().APPDEL.NativeAdPosition-1) == 0) {
                    let AdContainerView = UIView(frame: CGRect(x: 15, y: 10, width: constants().SCREENSIZE.width - 30, height: headerView.frame.size.height-20))
                    AdContainerView.backgroundColor = UIColor.white
                    AdContainerView.layer.cornerRadius = 10.0
                    AdContainerView.layer.masksToBounds = true

                    guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil), let adView = nibObjects.first as? GADUnifiedNativeAdView else {
                        assert(false, "Could not load nib file for adView")
                    }
                    self.NativeAdView = adView
                    AdContainerView.addSubview(NativeAdView)
                    headerView.addSubview(AdContainerView)
                    self.RefreshNativeAd()
                }
                return headerView
            default:
                assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.LostCollection {
            return self.LostItemList.count
        } else {
            return self.FoundItemsList.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.LostCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 0.2
            cell.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
            cell.layer.shadowColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
            cell.layer.shadowOffset = CGSize(width: 1.5, height: 5.0)
            cell.layer.shadowOpacity = 0.7
            cell.layer.shadowRadius = 4.0

            let imgProductImage = cell.viewWithTag(101) as! UIImageView
            let lblCategory = cell.viewWithTag(102) as! UILabel
            let lblItemTitle = cell.viewWithTag(103) as! UILabel
            let lblItemAddress = cell.viewWithTag(104) as! UILabel
            let lblItemDate = cell.viewWithTag(105) as! UILabel
            let lblItemReward = cell.viewWithTag(106) as! UILabel
            let giftIcon = cell.viewWithTag(107) as! UIImageView

            let mDict = self.LostItemList.object(at: indexPath.section) as! NSDictionary
            let pImages = (mDict.value(forKey: "lost_images") as! NSArray).mutableCopy() as! NSMutableArray
            lblItemDate.text = (mDict.value(forKey: "lost_date") as! String)
            if pImages.count > 0 {
                imgProductImage.sd_imageTransition = .fade
                imgProductImage.sd_setImage(with: URL(string: (pImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
            }
            imgProductImage.contentMode = .scaleAspectFit
            imgProductImage.backgroundColor = UIColor.white

            let rewardAttrString = NSMutableAttributedString(string:"Rewards Offered ", attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            rewardAttrString.append(NSMutableAttributedString(string: "$\(mDict.value(forKey: "reward") as! String)", attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_BOLD, size: 13)!, NSAttributedString.Key.foregroundColor: constants().COLOR_LightBlue]))
            lblItemReward.attributedText = rewardAttrString

            if (mDict.value(forKey: "reward") as! String).isEmpty {
                giftIcon.isHidden = true
                lblItemReward.isHidden = true
            } else {
                giftIcon.isHidden = false
                lblItemReward.isHidden = false
            }

            lblCategory.layer.cornerRadius = 12.5
            lblCategory.layer.masksToBounds = true
            lblCategory.text = (mDict.value(forKey: "category_item_name") as! String)
            if indexPath.section % 2 == 0 {
                lblCategory.backgroundColor = UIColor(red: 99.0/255.0, green: 199.0/255.0, blue: 144.0/255.0, alpha: 1.0)
            } else {
                lblCategory.backgroundColor = UIColor(red: 243.0/255.0, green: 197.0/255.0, blue: 49.0/255.0, alpha: 1.0)
            }

            lblItemTitle.text = (mDict.value(forKey: "item_name") as! String)
            lblItemAddress.text = (mDict.value(forKey: "location") as! String)

            var frame = lblCategory.frame
            let newSize = lblCategory.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height))
            frame.size.width = newSize.width + 10
            frame.size.height = 25
            lblCategory.frame = frame

            if (constants().userinterface == .pad) {
                var frame = imgProductImage.frame
                frame.size.height = 250
                imgProductImage.frame = frame
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 0.2
            cell.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
            cell.layer.shadowColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
            cell.layer.shadowOffset = CGSize(width: 1.5, height: 5.0)
            cell.layer.shadowOpacity = 0.7
            cell.layer.shadowRadius = 4.0

            let imgProductImage = cell.viewWithTag(101) as! UIImageView
            let lblCategory = cell.viewWithTag(102) as! UILabel
            let lblItemTitle = cell.viewWithTag(103) as! UILabel
            let lblItemAddress = cell.viewWithTag(104) as! UILabel
            let lblItemDate = cell.viewWithTag(105) as! UILabel
            let lblItemReward = cell.viewWithTag(106) as! UILabel
            let giftIcon = cell.viewWithTag(107) as! UIImageView

            let mDict = self.FoundItemsList.object(at: indexPath.section) as! NSDictionary
            let pImages = (mDict.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray
            lblItemDate.text = (mDict.value(forKey: "found_date") as! String)

            if pImages.count > 0 {
                imgProductImage.sd_imageTransition = .fade
                imgProductImage.sd_setImage(with: URL(string: (pImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
            }
            imgProductImage.backgroundColor = UIColor.white
            imgProductImage.contentMode = .scaleAspectFit

            if ((mDict.value(forKey: "expected_reward") as! String).isEmpty || (mDict.value(forKey: "expected_reward") as! String) == "0") {
                lblItemReward.isHidden = true
                giftIcon.isHidden = true
            } else {
                lblItemReward.isHidden = false
                giftIcon.isHidden = false
                let rewardAttrString = NSMutableAttributedString(string:"Reward Expected ", attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                rewardAttrString.append(NSMutableAttributedString(string: "$\(mDict.value(forKey: "expected_reward") as! String)", attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_BOLD, size: 13)!, NSAttributedString.Key.foregroundColor: constants().COLOR_LightBlue]))
                lblItemReward.attributedText = rewardAttrString
            }

            lblCategory.layer.cornerRadius = 12.5
            lblCategory.layer.masksToBounds = true
            lblCategory.text = (mDict.value(forKey: "category_item_name") as! String)
            if indexPath.section % 2 == 0 {
                lblCategory.backgroundColor = UIColor(red: 99.0/255.0, green: 199.0/255.0, blue: 144.0/255.0, alpha: 1.0)
            } else {
                lblCategory.backgroundColor = UIColor(red: 243.0/255.0, green: 197.0/255.0, blue: 49.0/255.0, alpha: 1.0)
            }

            lblItemTitle.text = (mDict.value(forKey: "item_name") as! String)
            lblItemAddress.text = (mDict.value(forKey: "location") as! String)

            var frame = lblCategory.frame
            let newSize = lblCategory.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height))
            frame.size.width = newSize.width + 10
            frame.size.height = 25
            lblCategory.frame = frame
            
            if (constants().userinterface == .pad) {
                var frame = imgProductImage.frame
                frame.size.height = 250
                imgProductImage.frame = frame
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (constants().userinterface == .pad) {
            return CGSize(width: constants().SCREENSIZE.width - 60, height: 350)
        }
        return CGSize(width: constants().SCREENSIZE.width - 30, height: 240)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if (constants().userinterface == .pad) {
            return UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        }
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if (constants().userinterface == .pad) {
            return 30
        }
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (constants().userinterface == .pad) {
            return 30
        }
        return 15
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        constants().APPDEL.isMyItem = 0
        if collectionView == self.LostCollection {
            constants().APPDEL.LostCollectionContentOffSet = self.LostCollection.contentOffset
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "lostitemdetail") as! LostItemDetailPage
            ivc.lostItemID = (self.LostItemList.object(at: indexPath.section) as! NSDictionary).value(forKey: "lost_id") as! String
            constants().APPDEL.window?.rootViewController = ivc
        } else {
            constants().APPDEL.FoundCollectionContentOffSet = self.FoundCollection.contentOffset
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "founditemdetail") as! FoundItemDetailPage
            ivc.SelectedFoundItemID = (self.FoundItemsList.object(at: indexPath.section) as! NSDictionary).value(forKey: "found_id") as! String
            constants().APPDEL.window?.rootViewController = ivc
        }
    }

    //MARK:- Full Ad Delegate
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if interstitial.isReady {
            constants().APPDEL.isAdJustClosed = false
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
        constants().APPDEL.isPopup = true
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
        constants().APPDEL.isAdJustClosed = true
        constants().APPDEL.isPopup = false
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        constants().APPDEL.isAdJustClosed = true
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }

    //MARK:- Actions
    func RefreshNativeAd() {
        adLoader = GADAdLoader(adUnitID: constants().AD_NATIVE_ID, rootViewController: self, adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
}

extension LostFoundItemsList : GADVideoControllerDelegate {
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    }
}

extension LostFoundItemsList : GADAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    }
}

extension LostFoundItemsList : GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        NativeAdView.nativeAd = nativeAd
        nativeAd.delegate = self

        (NativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        NativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
            mediaContent.videoController.delegate = self
        }

        (NativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        NativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (NativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        NativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

        (NativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        NativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (NativeAdView.storeView as? UILabel)?.text = nativeAd.store
        NativeAdView.storeView?.isHidden = nativeAd.store == nil

        (NativeAdView.priceView as? UILabel)?.text = nativeAd.price
        NativeAdView.priceView?.isHidden = nativeAd.price == nil

        (NativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        NativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

        NativeAdView.callToActionView?.isUserInteractionEnabled = false
    }
}

//MARK:- GADUnifiedNativeAdDelegate implementation
extension LostFoundItemsList : GADUnifiedNativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
    }
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
    }
    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
    }
    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    }
    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    }
    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
    }
}
