//  AddLostItem.swift
//  LostAndFound
//  Created by Revamp on 31/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import YangMingShan
import TPKeyboardAvoiding

class AddLostItem: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate, YMSPhotoPickerViewControllerDelegate, LocationPickerDelegate, VoiceOverlayDelegate {
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var TopProgressLine : UIProgressView!
    @IBOutlet weak var btnWhat : UIButton!
    @IBOutlet weak var btnWhere : UIButton!

    @IBOutlet weak var WhatScroll : TPKeyboardAvoidingScrollView!
    @IBOutlet weak var txtDateTime : UITextField!
    @IBOutlet weak var txtLostItem : UITextField!
    @IBOutlet weak var btnUploadPhotos : UIButton!
    @IBOutlet weak var PhotoCollection : UICollectionView!
    @IBOutlet weak var ColorView : UIView!
    @IBOutlet weak var lblColorTitle : UILabel!
    @IBOutlet weak var ColorCollection : UICollectionView!
    @IBOutlet weak var btnMoreColor : UIButton!
    @IBOutlet weak var txtDescription : UITextView!
    @IBOutlet weak var txtSelectBrand : AutocompleteTextField!
    @IBOutlet weak var RewardView : UIView!
    @IBOutlet weak var lblWouldLikeReward : UILabel!
    @IBOutlet weak var RewardSwitch : UISwitch!
    @IBOutlet weak var TxtRewardPrice : UITextField!
    @IBOutlet weak var btnNext : UIButton!

    @IBOutlet weak var CategoryView : UIView!
    @IBOutlet weak var CategoryCollection : UICollectionView!

    @IBOutlet weak var WhereScroll : TPKeyboardAvoidingScrollView!
    @IBOutlet weak var TxtSearchPlaces : UITextField!
    @IBOutlet weak var BtnYourLocation : UIButton!
    @IBOutlet weak var lblLocationText : UILabel!
    @IBOutlet weak var BtnLastLogLocation : UIButton!
    @IBOutlet weak var BtnAddManualAddress : UIButton!
    @IBOutlet weak var AddressOptionsCollection : UICollectionView!
    @IBOutlet weak var txtAddress1 : UITextField!
    @IBOutlet weak var txtAddress2 : UITextField!
    @IBOutlet weak var txtAddress3 : UITextField!
    @IBOutlet weak var txtAddress4 : UITextField!
    @IBOutlet weak var btnSubmit : UIButton!

    @IBOutlet weak var LostSuccessView : UIView!
    @IBOutlet weak var LostSuccessSubview : UIView!
    @IBOutlet weak var LostSuccessOK : UIButton!

    @IBOutlet weak var CustomToolbar : UIView!
    @IBOutlet weak var CustomDone : UIButton!
    var keyboardHEIGHT : CGFloat = 240.0

    let datePicker = UIDatePicker()
    var arrItemPhotos = NSMutableArray()

    var selectedColorID = ""
    var selectedCategoryID = ""
    var selectedPlaceID = ""
    var selectedPlaceName = ""

    let pickerViewController = YMSPhotoPickerViewController.init()

    let voiceOverlayController = VoiceOverlayController()
    var speechLocationString = ""

    var PlaceList = NSMutableArray()
    var DeleteLostImages = NSMutableArray()
    var DictLostItemEdit = NSMutableDictionary()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.doCustomToolHide()

        self.doSetFrames()
        self.doSetupDatePicker()
        self.doWhat()
        self.LostSuccessView.isHidden = true

        self.pickerViewController.delegate = self
        self.pickerViewController.numberOfPhotoToSelect = 10
        pickerViewController.theme.titleLabelTextColor = UIColor.black
        pickerViewController.theme.navigationBarBackgroundColor = UIColor.white
        pickerViewController.theme.tintColor = UIColor.black
        pickerViewController.theme.orderTintColor = constants().COLOR_LightBlue
        pickerViewController.theme.cameraVeilColor = constants().COLOR_LightBlue
        pickerViewController.theme.cameraIconColor = UIColor.white
        pickerViewController.theme.statusBarStyle = .lightContent

        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }

        DispatchQueue.main.async {
            apiClass().doNormalAPI(param: [:], APIName: apiClass().ColorListAPI, method: "GET") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        constants().APPDEL.ColorList = (mDict.value(forKey: "color") as! NSArray).mutableCopy() as! NSMutableArray
                        let firstColor = constants().APPDEL.ColorList.object(at: 0) as! NSDictionary
                        self.selectedColorID = firstColor.value(forKey: "color_id") as! String
                    }
                    self.ColorCollection.reloadData()
                }
            }

            // Call Category List API
            apiClass().doNormalAPI(param: [:], APIName: apiClass().CategoryListAPI, method: "GET") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        constants().APPDEL.CategoryList = (mDict.value(forKey: "category") as! NSArray).mutableCopy() as! NSMutableArray
                    }
                    self.CategoryCollection.reloadData()
                }
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: [:], APIName: apiClass().GetPlaceListAPI, method: "GET") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.PlaceList = (mDict.value(forKey: "place") as! NSArray).mutableCopy() as! NSMutableArray
                        self.AddressOptionsCollection.reloadData()
                    }
                }
            }
        }

        self.doManualAddressControl(isHidden: false)
        self.doEditMode()
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHEIGHT = keyboardRectangle.height
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            if (constants().APPDEL.LocationitemName.isEmpty) && (constants().APPDEL.LocationItemAddress.isEmpty) {
            } else {
                self.lblLocationText.text = "\(constants().APPDEL.LocationitemName) \(constants().APPDEL.LocationItemAddress)"
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func doEditMode() {
        if self.DictLostItemEdit.count > 0 {
            self.lblTitle.text = NSLocalizedString("editlostitem", comment: "")
            self.txtLostItem.text = (self.DictLostItemEdit.value(forKey: "item_name") as! String)

            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy 'at' HH:mm"

            let lastDate = formatter.date(from: (self.DictLostItemEdit.value(forKey: "lost_date") as! String))!
            formatter.dateFormat = constants().SUBMIT_DATETIMEFORMAT
            let strDate = formatter.string(from: lastDate)
            let finalDate = formatter.date(from: strDate)
            formatter.dateFormat = constants().DISPLAY_DATETIMEFORMAT
            self.txtDateTime.text = formatter.string(from: finalDate!)

            self.txtSelectBrand.text = (self.DictLostItemEdit.value(forKey: "brand_name") as! String)
            self.TxtRewardPrice.text = (self.DictLostItemEdit.value(forKey: "reward") as! String)

            self.selectedColorID = self.DictLostItemEdit.value(forKey: "color") as! String
            self.ColorCollection.reloadData()

            self.txtDescription.text = (self.DictLostItemEdit.value(forKey: "description") as! String)

            self.lblLocationText.text = (self.DictLostItemEdit.value(forKey: "location") as! String)

            if let arrPlace = self.DictLostItemEdit.value(forKey: "place") {
                if (arrPlace as AnyObject).count > 0 {
                    let dictPlace = (arrPlace as! NSArray).object(at: 0) as! NSDictionary
                    self.selectedPlaceID = (dictPlace.value(forKey: "place_id") as! String)
                    self.selectedPlaceName = (dictPlace.value(forKey: "name") as! String)
                    self.txtAddress1.text = (dictPlace.value(forKey: "field_1") as! String)
                    self.txtAddress2.text = (dictPlace.value(forKey: "field_2") as! String)
                    self.txtAddress3.text = (dictPlace.value(forKey: "field_3") as! String)
                    self.txtAddress4.text = (dictPlace.value(forKey: "field_4") as! String)
                }
            }
            self.AddressOptionsCollection.reloadData()
        } else {
            self.lblTitle.text = NSLocalizedString("addlostitemtitle", comment: "")
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.WhatScroll.semanticContentAttribute = .forceLeftToRight
        self.WhereScroll.semanticContentAttribute = .forceLeftToRight

        self.txtDateTime.semanticContentAttribute = .forceLeftToRight
        self.txtDateTime.textAlignment = NSTextAlignment.left

        self.txtLostItem.semanticContentAttribute = .forceLeftToRight
        self.txtLostItem.textAlignment = NSTextAlignment.left

        self.txtSelectBrand.semanticContentAttribute = .forceLeftToRight
        self.txtSelectBrand.textAlignment = NSTextAlignment.left

        self.TxtRewardPrice.semanticContentAttribute = .forceLeftToRight
        self.TxtRewardPrice.textAlignment = NSTextAlignment.left

        self.TxtSearchPlaces.semanticContentAttribute = .forceLeftToRight
        self.TxtSearchPlaces.textAlignment = NSTextAlignment.left

        self.txtAddress1.semanticContentAttribute = .forceLeftToRight
        self.txtAddress1.textAlignment = NSTextAlignment.left

        self.txtAddress2.semanticContentAttribute = .forceLeftToRight
        self.txtAddress2.textAlignment = NSTextAlignment.left

        self.txtAddress3.semanticContentAttribute = .forceLeftToRight
        self.txtAddress3.textAlignment = NSTextAlignment.left

        self.txtAddress4.semanticContentAttribute = .forceLeftToRight
        self.txtAddress4.textAlignment = NSTextAlignment.left

        self.LostSuccessSubview.layer.cornerRadius = 15.0
        self.LostSuccessSubview.layer.masksToBounds = true

        self.LostSuccessOK.layer.cornerRadius = 25.0
        self.LostSuccessOK.layer.masksToBounds = true

        self.txtDateTime.layer.cornerRadius = 10.0
        self.txtDateTime.layer.masksToBounds = true

        self.btnUploadPhotos.layer.cornerRadius = 10.0
        self.btnUploadPhotos.layer.masksToBounds = true

        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "CalendarIcon"), for: .normal)
        button.frame = CGRect(x: CGFloat(self.txtDateTime.frame.origin.x + self.txtDateTime.frame.size.width - 30), y: CGFloat(self.txtDateTime.frame.origin.y + self.txtDateTime.frame.size.height - 37), width: CGFloat(20), height: CGFloat(20))
        button.backgroundColor = UIColor.clear
        self.WhatScroll.addSubview(button)

        let paddingDateTime = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtDateTime.frame.height))
        paddingDateTime.backgroundColor = UIColor.clear
        self.txtDateTime.leftView = paddingDateTime
        self.txtDateTime.leftViewMode = .always

        let paddingLostItem = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtLostItem.frame.height))
        paddingLostItem.backgroundColor = UIColor.clear
        self.txtLostItem.leftView = paddingLostItem
        self.txtLostItem.leftViewMode = .always
        self.txtLostItem.layer.cornerRadius = 10.0
        self.txtLostItem.layer.masksToBounds = true

        self.ColorView.layer.cornerRadius = 10.0
        self.ColorView.layer.masksToBounds = true

        self.txtDescription.textColor = UIColor.lightGray
        self.txtDescription.layer.cornerRadius = 10.0
        self.txtDescription.layer.masksToBounds = true

        let paddingSelectBrand = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtSelectBrand.frame.height))
        paddingSelectBrand.backgroundColor = UIColor.clear
        self.txtSelectBrand.leftView = paddingSelectBrand
        self.txtSelectBrand.leftViewMode = .always
        self.txtSelectBrand.layer.cornerRadius = 10.0
        self.txtSelectBrand.layer.masksToBounds = true

        self.txtSelectBrand.padding = 15

        let lblUSD = UILabel.init()
        lblUSD.frame = CGRect(x: CGFloat(self.TxtRewardPrice.frame.origin.x + self.TxtRewardPrice.frame.size.width - 60), y: CGFloat(self.TxtRewardPrice.frame.origin.y + self.TxtRewardPrice.frame.size.height - 35), width: CGFloat(50), height: CGFloat(20))
        lblUSD.backgroundColor = UIColor.clear
        lblUSD.text = " USD "
        lblUSD.font = UIFont(name: constants().FONT_REGULAR, size: 15)
        lblUSD.textColor = UIColor.lightGray
        self.WhatScroll.addSubview(lblUSD)

        let paddingRewardPrice = UIView(frame: CGRect(x:0, y:0, width:15, height: self.TxtRewardPrice.frame.height))
        paddingRewardPrice.backgroundColor = UIColor.clear
        self.TxtRewardPrice.leftView = paddingRewardPrice
        self.TxtRewardPrice.leftViewMode = .always
        self.TxtRewardPrice.layer.cornerRadius = 10.0
        self.TxtRewardPrice.layer.masksToBounds = true

        let paddingSearchPlaces = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: self.TxtSearchPlaces.frame.height))
        paddingSearchPlaces.backgroundColor = UIColor.clear
        let imSearchPlaces = UIImageView(frame: CGRect(x: 15, y: 17.5, width: 20, height: 20))
        imSearchPlaces.image = UIImage(named: "searchIconGray")
        paddingSearchPlaces.addSubview(imSearchPlaces)
        self.TxtSearchPlaces.leftView = paddingSearchPlaces
        self.TxtSearchPlaces.leftViewMode = .always
        let buttonAudio = UIButton(type: .custom)
        buttonAudio.setImage(UIImage(named: "micIcon"), for: .normal)
        buttonAudio.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        buttonAudio.frame = CGRect(x: CGFloat(self.TxtSearchPlaces.frame.size.width - 75), y: CGFloat(17.5), width: CGFloat(20), height: CGFloat(20))
        buttonAudio.addTarget(self, action: #selector(self.doAudioSearchButtonClicked(button:)), for: .touchUpInside)
        self.TxtSearchPlaces.rightView = buttonAudio
        self.TxtSearchPlaces.rightViewMode = .always
        self.TxtSearchPlaces.layer.cornerRadius = 10.0
        self.TxtSearchPlaces.layer.masksToBounds = true

        self.BtnYourLocation.layer.cornerRadius = 10.0
        self.BtnYourLocation.layer.masksToBounds = true

        self.BtnLastLogLocation.layer.cornerRadius = 27.5
        self.BtnLastLogLocation.layer.masksToBounds = true

        self.BtnAddManualAddress.layer.cornerRadius = 27.5
        self.BtnAddManualAddress.layer.masksToBounds = true

        let paddingAddr1 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtAddress1.frame.height))
        paddingAddr1.backgroundColor = UIColor.clear
        self.txtAddress1.leftView = paddingAddr1
        self.txtAddress1.leftViewMode = .always
        self.txtAddress1.layer.cornerRadius = 10.0
        self.txtAddress1.layer.masksToBounds = true

        let paddingAddr2 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtAddress2.frame.height))
        paddingAddr2.backgroundColor = UIColor.clear
        self.txtAddress2.leftView = paddingAddr2
        self.txtAddress2.leftViewMode = .always
        self.txtAddress2.layer.cornerRadius = 10.0
        self.txtAddress2.layer.masksToBounds = true

        let paddingAddr3 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtAddress3.frame.height))
        paddingAddr3.backgroundColor = UIColor.clear
        self.txtAddress3.leftView = paddingAddr3
        self.txtAddress3.leftViewMode = .always
        self.txtAddress3.layer.cornerRadius = 10.0
        self.txtAddress3.layer.masksToBounds = true

        let paddingAddr4 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtAddress4.frame.height))
        paddingAddr4.backgroundColor = UIColor.clear
        self.txtAddress4.leftView = paddingAddr4
        self.txtAddress4.leftViewMode = .always
        self.txtAddress4.layer.cornerRadius = 10.0
        self.txtAddress4.layer.masksToBounds = true

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.btnBack.frame
                frame.origin.y = 35
                self.btnBack.frame = frame

                frame = self.btnWhat.frame
                frame.origin.y = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height
                self.btnWhat.frame = frame

                frame = self.btnWhere.frame
                frame.origin.y = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height
                self.btnWhere.frame = frame

                frame = self.TopProgressLine.frame
                frame.origin.y = self.btnWhat.frame.origin.y + self.btnWhat.frame.size.height - 2
                self.TopProgressLine.frame = frame

                frame = self.WhatScroll.frame
                frame.origin.y = self.btnWhat.frame.origin.y + self.btnWhat.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 95
                self.WhatScroll.frame = frame

                frame = self.CategoryView.frame
                frame.origin.y = self.btnWhat.frame.origin.y + self.btnWhat.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.CategoryView.frame = frame

                frame = self.WhereScroll.frame
                frame.origin.y = self.btnWhat.frame.origin.y + self.btnWhat.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.WhereScroll.frame = frame
            }
        }

        var frame = self.btnWhat.frame
        frame.origin.x = 0
        frame.origin.y = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height
        frame.size.width = constants().SCREENSIZE.width / 2
        self.btnWhat.frame = frame

        frame = self.btnWhere.frame
        frame.origin.x = constants().SCREENSIZE.width/2
        frame.origin.y = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height
        frame.size.width = constants().SCREENSIZE.width / 2
        self.btnWhere.frame = frame

        self.WhatScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.TxtRewardPrice.frame.origin.y + self.TxtRewardPrice.frame.size.height + 20)
        self.WhereScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.btnSubmit.frame.origin.y + self.btnSubmit.frame.size.height + 20)
    }

    func doApplyLocalisation() {
        self.btnNext.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        self.btnWhat.setTitle(NSLocalizedString("what", comment: ""), for: .normal)
        self.btnWhere.setTitle(NSLocalizedString("where", comment: ""), for: .normal)
        self.btnSubmit.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        self.txtDateTime.placeholder = NSLocalizedString("selectdatetime", comment: "")
        self.txtDateTime.attributedPlaceholder = StringUtils().addRedStar(msg: NSLocalizedString("selectdatetime", comment: ""))
        self.txtLostItem.placeholder = NSLocalizedString("addlostitem", comment: "")
        self.txtLostItem.attributedPlaceholder = StringUtils().addRedStar(msg: NSLocalizedString("addlostitem", comment: ""))
        self.btnUploadPhotos.setTitle(NSLocalizedString("uploadphotos", comment: ""), for: .normal)
        self.lblColorTitle.text = NSLocalizedString("selectcolor", comment: "")
        self.txtSelectBrand.placeholder = NSLocalizedString("selectbrand", comment: "")
        self.lblWouldLikeReward.text = NSLocalizedString("wouldlikerewards", comment: "")
        self.TxtRewardPrice.placeholder = NSLocalizedString("rewardprice", comment: "")
    }

    //MARK:- Setup Date Picker
    func doSetupDatePicker() {
        datePicker.locale = Locale(identifier: "en_US")
        datePicker.datePickerMode = .dateAndTime
        datePicker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        } else {
            // Fallback on earlier versions
        }
        self.txtDateTime.inputView = datePicker
        self.txtDateTime.autoresizingMask = .flexibleHeight
    }

    func doManualAddressControl(isHidden:Bool) {
        DispatchQueue.main.async {
            if isHidden == true {
                self.AddressOptionsCollection.isHidden = true
                self.txtAddress1.isHidden = true
                self.txtAddress2.isHidden = true
                self.txtAddress3.isHidden = true
                self.txtAddress4.isHidden = true
            } else {
                self.AddressOptionsCollection.isHidden = false
                self.txtAddress1.isHidden = false
                self.txtAddress2.isHidden = false
                self.txtAddress3.isHidden = false
                self.txtAddress4.isHidden = false
            }
        }
    }

    //MARK:- IBAction Methods
    @objc func doAudioSearchButtonClicked(button: UIButton) {
        self.speechLocationString = ""
        voiceOverlayController.start(on: self, textHandler: { (text, final, extraInfo) in
            self.speechLocationString = text
            if final {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                    let myString = text
                    let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
                    let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
                    self.voiceOverlayController.settings.resultScreenText = myAttrString
                    self.voiceOverlayController.settings.layout.resultScreen.titleProcessed = "BLA BLA"
                    if !text.isEmpty {
                        self.speechLocationString = text
                        self.doYourLocation()
                    }
                })
            }
        }, errorHandler: { (error) in
            print("callback: error \(String(describing: error))")
        }, resultScreenHandler: { (text) in
            print("Result Screen: \(text)")
        })
    }

    @IBAction func doBack() {
        if self.CategoryView.isHidden == false {
            self.doWhat()
        } else if self.WhereScroll.isHidden == false {
            self.doWhat()
        } else {
            if self.DictLostItemEdit.count > 0 {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myitems") as! MyItems
                constants().APPDEL.window?.rootViewController = ivc
            } else {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                ivc.selectedIndex = 2
                constants().APPDEL.window?.rootViewController = ivc
            }
        }
    }

    @IBAction func doWhat() {
        self.WhatScroll.isHidden = false
        self.WhereScroll.isHidden = true
        self.btnNext.isHidden = false
        self.CategoryView.isHidden = true
        self.btnWhat.setTitleColor(UIColor.black, for: .normal)
        self.btnWhere.setTitleColor(UIColor.lightGray, for: .normal)
    }

    @IBAction func doMoreColorScroll() {
        let index = IndexPath(item: constants().APPDEL.ColorList.count - 1, section: 0)
        self.ColorCollection?.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }

    @IBAction func doWhere() {
    }

    @IBAction func doUploadPhotos() {
        pickerViewController.modalPresentationStyle = .fullScreen
        self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
    }

    @IBAction func doYourLocation() {
        let IVCPicker = CustomLocationPicker()
        if !self.speechLocationString.isEmpty {
            IVCPicker.searchBar.becomeFirstResponder()
            IVCPicker.searchBar.text = self.speechLocationString
            IVCPicker.searchBar(IVCPicker.searchBar, textDidChange: self.speechLocationString)
        }
        let navigationController = UINavigationController(rootViewController: IVCPicker)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false, completion: nil)
    }

    @IBAction func doLastLogLocation() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "maproutes") as! MapRouteView
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    @IBAction func doAddManualAddress() {
        let ac = UIAlertController(title: NSLocalizedString("manualaddress", comment: ""), message: "", preferredStyle: .alert)
        ac.addTextField { (textfield) in
            textfield.placeholder = NSLocalizedString("manualaddresslocation", comment: "")
        }
        let CancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .destructive) { _ in
        }
        ac.addAction(CancelAction)
        let submitAction = UIAlertAction(title: NSLocalizedString("submit", comment: ""), style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            if answer.text!.isEmpty {
                self.doAddManualAddress()
            } else {
                self.lblLocationText.text = answer.text
            }
        }
        ac.addAction(submitAction)
        self.present(ac, animated: true)
    }

    @IBAction func doNext() {
        var aMessage = ""
        if self.txtDateTime.text!.isEmpty {
            aMessage = NSLocalizedString("selectlostitemdate", comment: "")
        } else if self.txtLostItem.text!.isEmpty {
            aMessage = NSLocalizedString("enteritemname", comment: "")
        }

        if aMessage.isEmpty {
            self.doCustomToolHide()
            self.CategoryView.isHidden = false
            self.CategoryCollection.reloadData()
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: aMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func doRewardSwitch(_ sender: UISwitch) {
        if sender.isOn == true {
            self.TxtRewardPrice.alpha = 1.0
            self.TxtRewardPrice.isEnabled = true
        } else {
            self.TxtRewardPrice.alpha = 0.4
            self.TxtRewardPrice.isEnabled = false
        }
    }

    @IBAction func doSubmit() {
        var aMessage = ""
        if self.txtDateTime.text!.isEmpty {
           // aMessage = NSLocalizedString("selectlostitemdate", comment: "")
        } else if self.txtLostItem.text!.isEmpty {
           // aMessage = NSLocalizedString("enteritemname", comment: "")
        } else if self.lblLocationText.text!.isEmpty || self.lblLocationText.text! == "--" {
           // aMessage = NSLocalizedString("selectlocation", comment: "")
        } else if !self.selectedPlaceID.isEmpty {
            if self.selectedPlaceName.contains("Other") {
                self.txtAddress1.text = "-"
                self.txtAddress2.text = "-"
                self.txtAddress3.text = "-"
                self.txtAddress4.text = "-"
            } else {
//                if self.txtAddress1.text!.isEmpty {
//                    aMessage = "Please enter " + self.txtAddress1.placeholder!
//                } else if self.txtAddress2.text!.isEmpty {
//                    aMessage = "Please enter " + self.txtAddress2.placeholder!
//                } else if self.txtAddress3.text!.isEmpty {
//                    aMessage = "Please enter " + self.txtAddress3.placeholder!
//                } else if self.txtAddress4.text!.isEmpty {
//                    aMessage = "Please enter " + self.txtAddress4.placeholder!
//                }
            }
        }
    
        if aMessage.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = constants().DISPLAY_DATETIMEFORMAT
            let lastDate = formatter.date(from: self.txtDateTime.text!)!
            formatter.dateFormat = constants().SUBMIT_DATETIMEFORMAT
            let finalLDate = formatter.string(from: lastDate)

            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }

            if self.DictLostItemEdit.count > 0 {
                apiClass().doEditLostItemAPICall(lostID: self.DictLostItemEdit.value(forKey: "lost_id") as! String, lostDate: finalLDate, itemName: self.txtLostItem.text!, colorID: self.selectedColorID, desc: self.txtDescription.text, mBrandName: self.txtSelectBrand.text!, mCatID: self.selectedCategoryID, imgArray: self.arrItemPhotos, mReward: self.TxtRewardPrice.text!, addr1: self.txtAddress1.text!, addr2: self.txtAddress2.text!, addr3: self.txtAddress3.text!, addr4: self.txtAddress4.text!, strPlaceID: self.selectedPlaceID, strPlaceName: self.selectedPlaceName, mLocation: self.lblLocationText.text!, delImage: self.DeleteLostImages.componentsJoined(by: ",")) { (success, errMessage) in
                    DispatchQueue.main.async {
                        if success == true {
                            let alertCont = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("lostitemupdated", comment: ""), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                                self.doBack()
                            }
                            alertCont.addAction(okAction)
                            self.present(alertCont, animated: true, completion: nil)
                        } else {
                            let alertCont = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                            }
                            alertCont.addAction(okAction)
                            self.present(alertCont, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                apiClass().doAddLostItemAPICall(lostDate: finalLDate, itemName: self.txtLostItem.text!, colorID: self.selectedColorID, desc: self.txtDescription.text, mBrandName: self.txtSelectBrand.text!, mCatID: self.selectedCategoryID, imgArray: self.arrItemPhotos, mReward: self.TxtRewardPrice.text!, addr1: self.txtAddress1.text!, addr2: self.txtAddress2.text!, addr3: self.txtAddress3.text!, addr4: self.txtAddress4.text!, strPlaceID: self.selectedPlaceID, strPlaceName: selectedPlaceName, mLocation: self.lblLocationText.text!) { (success, errMessage) in
                    DispatchQueue.main.async {
                        if success == true {
                            self.LostSuccessView.isHidden = false
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
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: aMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func doLostSuccessOk() {
        self.LostSuccessView.isHidden = false
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "relatedproducts") as! RelatedProducts
        ivc.strItemName = self.txtLostItem.text!
        constants().APPDEL.window?.rootViewController = ivc
    }

    @objc func doDeletePhoto(sender: UIButton!) {
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("yousuredeleteitem", comment: ""), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { (action) in
            let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.PhotoCollection)
            let indexPath = self.PhotoCollection.indexPathForItem(at: buttonPosition)

            if self.DictLostItemEdit.count > 0 {
                let liveArray = (self.DictLostItemEdit.value(forKey: "lost_images") as! NSArray).mutableCopy() as! NSMutableArray
                if indexPath!.row >= liveArray.count {
                    self.arrItemPhotos.removeObject(at: indexPath!.row)
                } else {
                    self.DeleteLostImages.add((liveArray.object(at: indexPath!.row) as! NSDictionary).value(forKey: "image_id") as! String)
                    liveArray.removeObject(at: indexPath!.row)
                    self.DictLostItemEdit.setValue(liveArray, forKey: "lost_images")
                }
            } else {
                self.arrItemPhotos.removeObject(at: indexPath!.row)
            }

            DispatchQueue.main.async {
                self.PhotoCollection.reloadData()
            }
        }
        alertController.addAction(yesAction)
        let NoAction = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default) { (action) in
        }
        alertController.addAction(NoAction)
        self.present(alertController, animated: true, completion: nil)
    }

    //MARK:- Voice Delegate
    func recording(text: String?, final: Bool?, error: Error?) {
        if let error = error {
            print("delegate: error \(error)")
        }
        if error == nil {
//            self.TxtSearchPlaces.text = text
        }
    }

    //MARK:- YMSPhotoPickerViewController Delegate Methods
    func photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController(title: NSLocalizedString("allowphotoalbumaccess", comment: ""), message: NSLocalizedString("permissionphotoalbum", comment: ""), preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: NSLocalizedString("settings", comment: ""), style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func photoPickerViewControllerDidReceiveCameraAccessDenied(_ picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController(title: NSLocalizedString("allowcameraaccess", comment: ""), message: NSLocalizedString("permissioncamera", comment: ""), preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: NSLocalizedString("settings", comment: ""), style: .default) { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)
        picker.present(alertController, animated: true, completion: nil)
    }

    func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPickingImages photoAssets: [PHAsset]!) {
        picker.dismiss(animated: true) {
            let imageManager = PHImageManager.init()
            let options = PHImageRequestOptions.init()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .none
            options.isSynchronous = true

            let mutableImages: NSMutableArray! = []
            for asset: PHAsset in photoAssets {
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 500), contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
                    mutableImages.add(image!)
                })
            }
            self.arrItemPhotos = mutableImages
            DispatchQueue.main.async {
                self.PhotoCollection.reloadData()
            }
        }
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == self.ColorCollection {
            return CGSize(width: 5, height: 5)
        }
        if collectionView == self.PhotoCollection {
            return CGSize(width: 0, height: 0)
        }
        if collectionView == self.CategoryCollection {
            return CGSize(width: 0, height: 0)
        }
        if collectionView == self.AddressOptionsCollection {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: collectionView.frame.size.width, height: 5)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.ColorCollection {
            return constants().APPDEL.ColorList.count
        }
        if collectionView == self.PhotoCollection {
            if self.DictLostItemEdit.count > 0 {
                return (self.DictLostItemEdit.value(forKey: "lost_images") as! NSArray).count + self.arrItemPhotos.count
            } else {
                if self.arrItemPhotos.count == 0 {
                    return 3
                } else {
                    return self.arrItemPhotos.count
                }
            }
        }
        if collectionView == self.CategoryCollection {
            return constants().APPDEL.CategoryList.count
        }
        if collectionView == self.AddressOptionsCollection {
            return self.PlaceList.count
        }
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.ColorCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 17.5
            cell.layer.masksToBounds = true
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 0.7
            cell.layer.masksToBounds = true

            let lblColor = cell.viewWithTag(101) as! UILabel
            lblColor.layer.cornerRadius = 10.5
            lblColor.layer.masksToBounds = true

            let mDict = constants().APPDEL.ColorList.object(at: indexPath.row) as! NSDictionary
            lblColor.backgroundColor = constants().hexStringToUIColor(hex: mDict.value(forKey: "color_code") as! String)

            if self.selectedColorID == mDict.value(forKey: "color_id") as! String {
                cell.backgroundColor = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)
            }
            return cell
        } else if collectionView == self.PhotoCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            cell.layer.cornerRadius = 10.0

            let imgItemImage = cell.viewWithTag(101) as! UIImageView
            let btnDelete = cell.viewWithTag(102) as! UIButton

            if self.DictLostItemEdit.count > 0 {
                btnDelete.addTarget(self, action: #selector(AddLostItem.doDeletePhoto(sender:)), for: .touchUpInside)
                btnDelete.isHidden = false
                imgItemImage.contentMode = .scaleAspectFill
                let liveArray = self.DictLostItemEdit.value(forKey: "lost_images") as! NSArray
                if indexPath.row >= liveArray.count {
                    imgItemImage.image = (self.arrItemPhotos.object(at: indexPath.row - liveArray.count) as! UIImage)
                } else {
                    let liveDict = liveArray.object(at: indexPath.row) as! NSDictionary
                    imgItemImage.sd_setImage(with: URL(string: (liveDict.value(forKey: "image") as! String)), completed: nil)
                }
            } else {
                if self.arrItemPhotos.count > 0 {
                    imgItemImage.image = (self.arrItemPhotos.object(at: indexPath.row) as! UIImage)
                    btnDelete.addTarget(self, action: #selector(AddLostItem.doDeletePhoto(sender:)), for: .touchUpInside)
                    btnDelete.isHidden = false
                    imgItemImage.contentMode = .scaleAspectFill
                } else {
                    btnDelete.isHidden = true
                    imgItemImage.contentMode = .scaleToFill
                    imgItemImage.image = UIImage(named: "PlaceholderIcon")
                }
            }
            return cell
        } else if collectionView == self.CategoryCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10

            let imgProductImage = cell.viewWithTag(101) as! UIImageView
            imgProductImage.backgroundColor = UIColor.white
            imgProductImage.contentMode = .scaleAspectFill

            let lblCategory = cell.viewWithTag(102) as! UILabel
            let mDict = constants().APPDEL.CategoryList.object(at: indexPath.row) as! NSDictionary
            lblCategory.text = (mDict.value(forKey: "name") as! String)
            imgProductImage.sd_setImage(with: URL(string: (mDict.value(forKey: "image") as! String)), completed: nil)

            let lblBottomStatus = cell.viewWithTag(103) as! UILabel
            let lblOtherText = cell.viewWithTag(104) as! UIButton
            lblOtherText.layer.cornerRadius = lblOtherText.frame.size.width/2
            lblOtherText.layer.masksToBounds = true
            lblOtherText.addTarget(self, action: #selector(OtherButtonPressed(_:)), for: .touchUpInside)

            let imgTick = cell.viewWithTag(105) as! UIImageView
            if self.selectedCategoryID == (mDict.value(forKey: "category_id") as! String) {
                imgTick.isHidden = false
            } else {
                imgTick.isHidden = true
            }

            if indexPath.row == constants().APPDEL.CategoryList.count - 1 {
                imgProductImage.isHidden = true
                lblBottomStatus.isHidden = true
                lblOtherText.isHidden = false
                lblCategory.isHidden = true
            } else {
                cell.layer.borderWidth = 0.2
                cell.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
                imgProductImage.isHidden = false
                lblBottomStatus.isHidden = false
                lblOtherText.isHidden = true
                lblCategory.isHidden = false
            }

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 25
            cell.layer.masksToBounds = true

            let lblAddressOption = cell.viewWithTag(101) as! UILabel

            let mDict = self.PlaceList.object(at: indexPath.row) as! NSDictionary
            lblAddressOption.text = (mDict.value(forKey: "name") as! String)

            if self.DictLostItemEdit.count > 0 {
                // Edit
            } else {
            }

            if self.selectedPlaceName == (mDict.value(forKey: "name") as! String) {
                cell.backgroundColor = constants().COLOR_LightBlue
                lblAddressOption.textColor = UIColor.white
            } else {
                cell.backgroundColor = UIColor.white
                lblAddressOption.textColor = UIColor.black
            }
            return cell
        }
    }

    @objc func OtherButtonPressed(_ sender: UIButton) {
        let mDict = constants().APPDEL.CategoryList.object(at: (constants().APPDEL.CategoryList.count - 1)) as! NSDictionary
        self.selectedCategoryID = mDict.value(forKey: "category_id") as! String
        self.WhatScroll.isHidden = true
        self.WhereScroll.isHidden = false
        self.btnNext.isHidden = true
        self.CategoryView.isHidden = true
        self.AddressOptionsCollection.reloadData()
        self.btnWhat.setTitleColor(UIColor.lightGray, for: .normal)
        self.btnWhere.setTitleColor(UIColor.black, for: .normal)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.ColorCollection {
            return CGSize(width: 35, height: 35)
        }
        if collectionView == self.PhotoCollection {
            return CGSize(width: 100, height: 100)
        }
        if collectionView == self.CategoryCollection {
            if indexPath.row == constants().APPDEL.CategoryList.count - 1 {
                let mSize = constants().SCREENSIZE.width - 40
                return CGSize(width: mSize, height: mSize/2)
            } else {
                let mSize = (constants().SCREENSIZE.width - 60)/2
                return CGSize(width: mSize, height: mSize)
            }
        }
        if collectionView == self.AddressOptionsCollection {
            return CGSize(width: 120, height: 50)
        }
        return CGSize(width: constants().SCREENSIZE.width - 30, height: 240)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.ColorCollection {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        if collectionView == self.PhotoCollection {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        if collectionView == self.CategoryCollection {
            return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
        if collectionView == self.AddressOptionsCollection {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.ColorCollection {
            return 10
        }
        if collectionView == self.PhotoCollection {
            return 0
        }
        if collectionView == self.CategoryCollection {
            return 20
        }
        if collectionView == self.AddressOptionsCollection {
            return 20
        }
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.ColorCollection {
            return 10
        }
        if collectionView == self.PhotoCollection {
            return 17.5
        }
        if collectionView == self.CategoryCollection {
            return 20
        }
        if collectionView == self.AddressOptionsCollection {
            return 20
        }
        return 15
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.ColorCollection {
            let mDict = constants().APPDEL.ColorList.object(at: indexPath.row) as! NSDictionary
            self.selectedColorID = mDict.value(forKey: "color_id") as! String
            self.ColorCollection.reloadData()
        }
        if collectionView == self.CategoryCollection {
            if indexPath.row == constants().APPDEL.CategoryList.count - 1 {
            } else {
                let mDict = constants().APPDEL.CategoryList.object(at: indexPath.row) as! NSDictionary
                self.selectedCategoryID = mDict.value(forKey: "category_id") as! String
                self.WhatScroll.isHidden = true
                self.WhereScroll.isHidden = false
                self.btnNext.isHidden = true
                self.CategoryView.isHidden = true
                self.AddressOptionsCollection.reloadData()
                self.btnWhat.setTitleColor(UIColor.lightGray, for: .normal)
                self.btnWhere.setTitleColor(UIColor.black, for: .normal)
            }
        }
        if collectionView == self.AddressOptionsCollection {
            let mDict = self.PlaceList.object(at: indexPath.row) as! NSDictionary
            if self.selectedPlaceName == (mDict.value(forKey: "name") as! String) {
                self.selectedPlaceID = ""
                self.selectedPlaceName = ""
                self.txtAddress1.placeholder = "Address Line 1"
                self.txtAddress2.placeholder = "Address Line 2"
                self.txtAddress3.placeholder = "Address Line 3"
                self.txtAddress4.placeholder = "Address Line 4"
            } else {
                self.selectedPlaceID = (mDict.value(forKey: "place_id") as! String)
                self.selectedPlaceName = (mDict.value(forKey: "name") as! String)

                self.txtAddress1.placeholder = (mDict.value(forKey: "field_1") as! String)
                self.txtAddress2.placeholder = (mDict.value(forKey: "field_2") as! String)
                self.txtAddress3.placeholder = (mDict.value(forKey: "field_3") as! String)
                self.txtAddress4.placeholder = (mDict.value(forKey: "field_4") as! String)
            }
            self.AddressOptionsCollection.reloadData()
        }
    }

    func doFetchAutoSuggestions(skey:String) {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        let searchString = (skey.replacingOccurrences(of: " ", with: "%20"))
        apiClass().doAutoSuggestAPI(strKeyword: searchString) { (success, errMessage) in
            DispatchQueue.main.async {
                if success == true {
                    self.txtSelectBrand.suggestions = constants().APPDEL.ArrAutosuggestionsList as! [String]
                }
            }
        }
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
        let formatter = DateFormatter()
        formatter.dateFormat = constants().DISPLAY_DATETIMEFORMAT
        formatter.locale = Locale(identifier: "en_US")
        self.txtDateTime.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        self.doCustomToolHide()
    }

    //MARK:- UITextField delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtSelectBrand {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                self.doFetchAutoSuggestions(skey: updatedText)
            }
        }
        if textField == self.TxtRewardPrice {
            return constants().allowednumberset(str: string)
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtDateTime {
            self.doCustomToolShow()
        }
        if textField == self.TxtSearchPlaces {
            self.view.endEditing(true)
            self.doYourLocation()
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doCustomToolHide()
        return true
    }

    //MARK:- UITextview delegate methods
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
}
