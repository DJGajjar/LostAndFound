//  AddFoundItem.swift
//  LostAndFound
//  Created by Revamp on 01/11/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import YangMingShan
import UICollectionViewLeftAlignedLayout
import MobileCoreServices
import TPKeyboardAvoiding

class AddFoundItem: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, YMSPhotoPickerViewControllerDelegate, LocationPickerDelegate, VoiceOverlayDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var TopProgressLine : UIProgressView!
    @IBOutlet weak var btnWhat : UIButton!
    @IBOutlet weak var btnWhere : UIButton!

    @IBOutlet weak var WhatScroll : TPKeyboardAvoidingScrollView!
    @IBOutlet weak var txtFoundItem : UITextField!
    @IBOutlet weak var txtDateTime : UITextField!
    @IBOutlet weak var ColorView : UIView!
    @IBOutlet weak var lblSelectColor : UILabel!
    @IBOutlet weak var ColorCollection : UICollectionView!
    @IBOutlet weak var btnMoreColor : UIButton!
    @IBOutlet weak var btnUploadPhotos : UIButton!
    @IBOutlet weak var PhotoCollection : UICollectionView!
    @IBOutlet weak var txtSelectBrand : AutocompleteTextField!
    @IBOutlet weak var selectedTagsView : UIView!
    @IBOutlet weak var lblTagTitle : UILabel!
    @IBOutlet weak var txtSelectedTagsString : UITextView!
    @IBOutlet weak var TagButton : UIButton!
    @IBOutlet weak var lblExpectedRewardTitle : UILabel!
    @IBOutlet weak var TxtExpectedRewardPrice : UITextField!
    @IBOutlet weak var btnNext : UIButton!

    @IBOutlet weak var CategoryView : UIView!
    @IBOutlet weak var CategoryCollection : UICollectionView!

    @IBOutlet weak var TagView : UIView!
    @IBOutlet weak var TagCollection : UICollectionView!
    @IBOutlet weak var btnProceedTag : UIButton!

    @IBOutlet weak var vwAddNewTagView : UIView!
    @IBOutlet weak var vwAddNewTagSubView : UIView!
    @IBOutlet weak var txtAddNewTag : UITextField!
    @IBOutlet weak var btnAddNewTag : UIButton!
    @IBOutlet weak var btnCloseNewTag : UIButton!

    @IBOutlet weak var WhereScroll : TPKeyboardAvoidingScrollView!
    @IBOutlet weak var TxtSearchPlaces : UITextField!
    @IBOutlet weak var BtnYourLocation : UIButton!
    @IBOutlet weak var lblLocationText : UILabel!
    @IBOutlet weak var BtnAddManualAddress : UIButton!
    @IBOutlet weak var lblFoundItemIswith : UILabel!
//    @IBOutlet weak var mySegment: WMSegment!
    @IBOutlet weak var mySegment: UISegmentedControl!
    @IBOutlet weak var btnSubmit : UIButton!

    @IBOutlet weak var FoundSuccessView : UIView!
    @IBOutlet weak var FoundSuccessOK : UIButton!

    @IBOutlet weak var policeView : UIView!
    @IBOutlet weak var lblPoliceTitle : UILabel!
    @IBOutlet weak var lblPoliceAddress : UILabel!

    @IBOutlet weak var BtnUploadItemCopy : UIButton!

    @IBOutlet weak var CustomToolbar : UIView!
    @IBOutlet weak var CustomDone : UIButton!
    var keyboardHEIGHT : CGFloat = 240.0

    let datePicker = UIDatePicker()
    var selectedAddressOptionIndex = -1
    var arrItemPhotos = NSMutableArray()
    var arrTags = NSMutableArray()
    var arrSelectedTags = NSMutableArray()

    var selectedColorID = ""
    var selectedCategoryID = ""
    var strFoundItemWith = "Me"

    let pickerViewController = YMSPhotoPickerViewController.init()
    let voiceOverlayController = VoiceOverlayController()
    var speechLocationString = ""

    var DeleteFoundImages = NSMutableArray()
    var DictFoundItemEdit = NSMutableDictionary()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        self.doCustomToolHide()

        self.doSetupDatePicker()
        self.doSetFrames()
        self.doWhat()
        self.FoundSuccessView.isHidden = true

        self.doConfigurePhotoPicker(pickLimit: 10)

        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }

        self.TagCollection.collectionViewLayout = UICollectionViewLeftAlignedLayout()
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
        }
        self.doEditMode()
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHEIGHT = keyboardRectangle.height
        }
    }

    func doEditMode() {
        if self.DictFoundItemEdit.count > 0 {
            self.lblTitle.text = NSLocalizedString("editfounditem", comment: "")
            self.txtFoundItem.text = (self.DictFoundItemEdit.value(forKey: "item_name") as! String)

            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy 'at' HH:mm"

            let lastDate = formatter.date(from: (self.DictFoundItemEdit.value(forKey: "found_date") as! String))!
            formatter.dateFormat = constants().SUBMIT_DATETIMEFORMAT
            let strDate = formatter.string(from: lastDate)
            let finalDate = formatter.date(from: strDate)
            formatter.dateFormat = constants().DISPLAY_DATETIMEFORMAT
            self.txtDateTime.text = formatter.string(from: finalDate!)

            self.txtSelectBrand.text = (self.DictFoundItemEdit.value(forKey: "brand_name") as! String)
            self.arrSelectedTags = ((self.DictFoundItemEdit.value(forKey: "tag") as! String).components(separatedBy: ",") as NSArray).mutableCopy() as! NSMutableArray
            self.arrTags = ((self.DictFoundItemEdit.value(forKey: "tag") as! String).components(separatedBy: ",") as NSArray).mutableCopy() as! NSMutableArray
            print("---self.arrSelectedTags--- 160 %@", self.arrSelectedTags);
            self.doProceedTag()
            self.TxtExpectedRewardPrice.text = (self.DictFoundItemEdit.value(forKey: "expected_reward") as! String)

            self.selectedColorID = self.DictFoundItemEdit.value(forKey: "color") as! String
            self.ColorCollection.reloadData()

            self.lblLocationText.text = (self.DictFoundItemEdit.value(forKey: "location") as! String)
            if (self.DictFoundItemEdit.value(forKey: "found_with") as! String).lowercased() == "me" {
                self.mySegment.selectedSegmentIndex = 0
            } else if (self.DictFoundItemEdit.value(forKey: "found_with") as! String).lowercased() == "police station" {
                self.mySegment.selectedSegmentIndex = 1
            } else {
                self.mySegment.selectedSegmentIndex = 2
            }
        } else {
            self.lblTitle.text = NSLocalizedString("addfounditem", comment: "")
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
        if self.mySegment.selectedSegmentIndex == 1  {
            self.doShowPoliceView(sStatus: true)
        } else {
            self.doShowPoliceView(sStatus: false)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func doConfigurePhotoPicker(pickLimit: Int) {
        self.pickerViewController.delegate = self
        self.pickerViewController.numberOfPhotoToSelect = UInt(pickLimit)
        pickerViewController.theme.titleLabelTextColor = UIColor.black
        pickerViewController.theme.navigationBarBackgroundColor = UIColor.white
        pickerViewController.theme.tintColor = UIColor.black
        pickerViewController.theme.orderTintColor = constants().COLOR_LightBlue
        pickerViewController.theme.cameraVeilColor = constants().COLOR_LightBlue
        pickerViewController.theme.cameraIconColor = UIColor.white
        pickerViewController.theme.statusBarStyle = .lightContent
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.WhatScroll.semanticContentAttribute = .forceLeftToRight
        self.WhereScroll.semanticContentAttribute = .forceLeftToRight

        self.txtDateTime.semanticContentAttribute = .forceLeftToRight
        self.txtDateTime.textAlignment = NSTextAlignment.left

        self.txtFoundItem.semanticContentAttribute = .forceLeftToRight
        self.txtFoundItem.textAlignment = NSTextAlignment.left

        self.txtSelectBrand.semanticContentAttribute = .forceLeftToRight
        self.txtSelectBrand.textAlignment = NSTextAlignment.left

        self.TxtExpectedRewardPrice.semanticContentAttribute = .forceLeftToRight
        self.TxtExpectedRewardPrice.textAlignment = NSTextAlignment.left

        self.txtAddNewTag.semanticContentAttribute = .forceLeftToRight
        self.txtAddNewTag.textAlignment = NSTextAlignment.left

        self.TxtSearchPlaces.semanticContentAttribute = .forceLeftToRight
        self.TxtSearchPlaces.textAlignment = NSTextAlignment.left

        self.FoundSuccessOK.layer.cornerRadius = 25.0
        self.FoundSuccessOK.layer.masksToBounds = true

        self.txtDateTime.layer.cornerRadius = 10.0
        self.txtDateTime.layer.masksToBounds = true

        self.btnUploadPhotos.layer.cornerRadius = 10.0
        self.btnUploadPhotos.layer.masksToBounds = true

        self.BtnUploadItemCopy.layer.cornerRadius = 20.0
        self.BtnUploadItemCopy.layer.masksToBounds = true

        self.policeView.layer.cornerRadius = 10.0
        self.policeView.layer.masksToBounds = true

        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "CalendarIcon"), for: .normal)
        button.frame = CGRect(x: CGFloat(self.txtDateTime.frame.origin.x + self.txtDateTime.frame.size.width - 30), y: CGFloat(self.txtDateTime.frame.origin.y + self.txtDateTime.frame.size.height - 37), width: CGFloat(20), height: CGFloat(20))
        button.backgroundColor = UIColor.clear
        self.WhatScroll.addSubview(button)

        let paddingDateTime = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtDateTime.frame.height))
        paddingDateTime.backgroundColor = UIColor.clear
        self.txtDateTime.leftView = paddingDateTime
        self.txtDateTime.leftViewMode = .always

        let paddingFoundItem = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtFoundItem.frame.height))
        paddingFoundItem.backgroundColor = UIColor.clear
        self.txtFoundItem.leftView = paddingFoundItem
        self.txtFoundItem.leftViewMode = .always
        self.txtFoundItem.layer.cornerRadius = 10.0
        self.txtFoundItem.layer.masksToBounds = true

        self.ColorView.layer.cornerRadius = 10.0
        self.ColorView.layer.masksToBounds = true

        let lblEUSD = UILabel.init()
        lblEUSD.frame = CGRect(x: CGFloat(self.TxtExpectedRewardPrice.frame.size.width - 70), y: CGFloat(17), width: CGFloat(50), height: CGFloat(20))
        lblEUSD.backgroundColor = UIColor.clear
        lblEUSD.text = "USD   "
        lblEUSD.font = UIFont(name: constants().FONT_REGULAR, size: 15)
        lblEUSD.textColor = UIColor.lightGray
        self.TxtExpectedRewardPrice.rightView = lblEUSD
        self.TxtExpectedRewardPrice.rightViewMode = .always

        let paddingExpectedReward = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.TxtExpectedRewardPrice.frame.height))
        paddingExpectedReward.backgroundColor = UIColor.clear
        self.TxtExpectedRewardPrice.leftView = paddingExpectedReward
        self.TxtExpectedRewardPrice.leftViewMode = .always
        self.TxtExpectedRewardPrice.layer.cornerRadius = 10.0
        self.TxtExpectedRewardPrice.layer.masksToBounds = true

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

        let paddingSelectBrand = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtSelectBrand.frame.height))
        paddingSelectBrand.backgroundColor = UIColor.clear
        self.txtSelectBrand.leftView = paddingSelectBrand
        self.txtSelectBrand.leftViewMode = .always
        self.txtSelectBrand.layer.cornerRadius = 10.0
        self.txtSelectBrand.layer.masksToBounds = true

        self.txtSelectBrand.padding = 15

        let paddingTag = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.txtAddNewTag.frame.height))
        paddingTag.backgroundColor = UIColor.clear
        self.txtAddNewTag.leftView = paddingTag
        self.txtAddNewTag.leftViewMode = .always
        self.txtAddNewTag.layer.cornerRadius = 10.0
        self.txtAddNewTag.layer.masksToBounds = true

        self.selectedTagsView.layer.cornerRadius = 10.0
        self.selectedTagsView.layer.masksToBounds = true

        self.BtnYourLocation.layer.cornerRadius = 10.0
        self.BtnYourLocation.layer.masksToBounds = true

        self.BtnAddManualAddress.layer.cornerRadius = 27.5
        self.BtnAddManualAddress.layer.masksToBounds = true

        self.vwAddNewTagSubView.layer.cornerRadius = 10.0
        self.vwAddNewTagSubView.layer.masksToBounds = true

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

                frame = self.TagView.frame
                frame.origin.y = self.btnWhat.frame.origin.y + self.btnWhat.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.TagView.frame = frame

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

        self.WhatScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.TxtExpectedRewardPrice.frame.origin.y + self.TxtExpectedRewardPrice.frame.size.height + 20)
        self.WhereScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.btnSubmit.frame.origin.y + self.btnSubmit.frame.size.height + 20)
    }

    func doApplyLocalisation() {
        self.btnNext.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        self.btnWhat.setTitle(NSLocalizedString("what", comment: ""), for: .normal)
        self.btnWhere.setTitle(NSLocalizedString("where", comment: ""), for: .normal)
        self.btnProceedTag.setTitle(NSLocalizedString("selectallproceed", comment: ""), for: .normal)
        self.btnSubmit.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        self.txtFoundItem.placeholder = NSLocalizedString("namefounditem", comment: "")
        self.txtFoundItem.attributedPlaceholder = StringUtils().addRedStar(msg: NSLocalizedString("namefounditem", comment: ""))
        self.txtDateTime.placeholder = NSLocalizedString("selectdate", comment: "")
        self.txtDateTime.attributedPlaceholder = StringUtils().addRedStar(msg: NSLocalizedString("selectdate", comment: ""))
        self.lblSelectColor.text = NSLocalizedString("selectcolor", comment: "")
        self.btnUploadPhotos.setTitle(NSLocalizedString("uploadphotosorusecamera", comment: ""), for: .normal)
        self.btnUploadPhotos.setAttributedTitle(StringUtils().addRedStar(msg: NSLocalizedString("uploadphotosorusecamera", comment: "")), for: .normal)
        self.txtSelectBrand.placeholder = NSLocalizedString("selectbrand", comment: "")
        self.lblTagTitle.text = NSLocalizedString("searchtags", comment: "")
        self.lblExpectedRewardTitle.text = NSLocalizedString("rewardexpectedfinder", comment: "")
        self.txtAddNewTag.placeholder = NSLocalizedString("addnewtag", comment: "")
        self.btnAddNewTag.setTitle(NSLocalizedString("addtag", comment: ""), for: .normal)
        self.TxtSearchPlaces.placeholder = NSLocalizedString("searchplaces", comment: "")
        self.lblFoundItemIswith.text = NSLocalizedString("founditemwith", comment: "")
    }

    func doShowPoliceView(sStatus: Bool) {
        if sStatus == true {
            self.policeView.isHidden = false
            self.BtnUploadItemCopy.isHidden = false

            if !constants().APPDEL.psTitle.isEmpty {
                self.lblPoliceTitle.text = constants().APPDEL.psTitle
            }
            if !constants().APPDEL.psLocation.isEmpty {
                self.lblPoliceAddress.text = constants().APPDEL.psLocation
            }

            var frame = self.btnSubmit.frame
            frame.origin.y = self.BtnUploadItemCopy.frame.origin.y + self.BtnUploadItemCopy.frame.size.height + 20
            self.btnSubmit.frame = frame
        } else {
            self.policeView.isHidden = true
            self.BtnUploadItemCopy.isHidden = true

            var frame = self.btnSubmit.frame
            frame.origin.y = self.mySegment.frame.origin.y + self.mySegment.frame.size.height + 20
            self.btnSubmit.frame = frame
        }
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

    @IBAction func doChangeSegmentValue(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                self.strFoundItemWith = "Me"
                self.doShowPoliceView(sStatus: false)
                break
            case 1:
                self.strFoundItemWith = "Police Station"
                self.doShowPoliceView(sStatus: true)
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "searchpolicestation") as! SearchPoliceStation
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: true, completion: nil)
                break
            case 2:
                self.strFoundItemWith = "Others"
                self.doShowPoliceView(sStatus: false)
                break
            default:
                break
        }
    }

    func doViewPoliceStation() {
        self.policeView.isHidden = false
        if !constants().APPDEL.psTitle.isEmpty {
            self.lblPoliceTitle.text = constants().APPDEL.psTitle
        }
        if !constants().APPDEL.psLocation.isEmpty {
            self.lblPoliceAddress.text = constants().APPDEL.psLocation
        }
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        print("segmentTapped")
        doChangeSegmentValue(sender as! UISegmentedControl)
    }
    
    @IBAction func doBack() {
        if self.TagView.isHidden == false {
            self.doWhat()
        } else if self.CategoryView.isHidden == false {
            self.doWhat()
        } else if self.WhereScroll.isHidden == false {
            self.doWhat()
        } else {
            if self.DictFoundItemEdit.count > 0 {
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
        self.TagView.isHidden = true
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
        self.pickerViewController.numberOfPhotoToSelect = UInt(10)
        self.pickerViewController.modalPresentationStyle = .fullScreen
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
        if self.txtFoundItem.text!.isEmpty {
            aMessage = NSLocalizedString("enteritemname", comment: "")
        } else if self.txtDateTime.text!.isEmpty {
            aMessage = NSLocalizedString("selectfounditemdate", comment: "")
        } else {
            if self.DictFoundItemEdit.count > 0 {
                let liveArray = self.DictFoundItemEdit.value(forKey: "found_images") as! NSArray
                if liveArray.count == 0 && self.arrItemPhotos.count == 0 {
                    aMessage = NSLocalizedString("uploadatleastoneimage", comment: "")
                }
            } else {
                if self.arrItemPhotos.count == 0 {
                    aMessage = NSLocalizedString("uploadatleastoneimage", comment: "")
                }
            }
        }
        if aMessage.isEmpty {
            /*if self.arrSelectedTags.count == 0 {
                aMessage = NSLocalizedString("entertags", comment: "")
            }*/
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

    @IBAction func doAddNewTag() {
        if self.txtAddNewTag.text!.isEmpty {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("tagcannotbeempty", comment: ""), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.arrTags.add(self.txtAddNewTag.text!)
            self.doCloseNewTag()
            self.view.endEditing(true)
            self.TagCollection.reloadData()
        }
    }

    @IBAction func doCloseNewTag() {
        self.txtAddNewTag.text = ""
        self.vwAddNewTagView.isHidden = true
        self.view.endEditing(true)
    }

    @IBAction func doTag() {
        self.TagView.isHidden = false
        self.TagCollection.reloadData()
        self.view.endEditing(true)
    }

    @IBAction func doProceedTag() {
        self.doWhat()
//        self.arrSelectedTags.removeAllObjects()
//        for index in 0..<self.arrTags.count {
//            self.arrSelectedTags.add(self.arrTags.object(at: index) as! String)
//        }
        let cars = ((self.arrSelectedTags.map { "#\($0)" }) as NSArray).mutableCopy() as! NSMutableArray
        self.txtSelectedTagsString.text = cars.componentsJoined(by: ",")
    }

    @IBAction func doSubmit() {
        var aMessage = ""
        if self.txtFoundItem.text!.isEmpty {
            aMessage = NSLocalizedString("enteritemname", comment: "")
        } else if self.txtDateTime.text!.isEmpty {
            aMessage = NSLocalizedString("selectfounditemdate", comment: "")
        } else {
            if self.DictFoundItemEdit.count > 0 {
                let liveArray = self.DictFoundItemEdit.value(forKey: "found_images") as! NSArray
                if liveArray.count == 0 && self.arrItemPhotos.count == 0 {
                    aMessage = NSLocalizedString("uploadatleastoneimage", comment: "")
                }
            } else {
                if self.arrItemPhotos.count == 0 {
                    aMessage = NSLocalizedString("uploadatleastoneimage", comment: "")
                }
            }
        }
        if aMessage.isEmpty {
            /*if self.arrSelectedTags.count == 0 {
                aMessage = NSLocalizedString("entertags", comment: "")
            }*/
            if self.lblLocationText.text!.isEmpty {
                aMessage = NSLocalizedString("selectlocation", comment: "")
            }
            if ((self.mySegment.selectedSegmentIndex == 1) && (constants().APPDEL.psData == nil)) {
                aMessage = NSLocalizedString("uploadsubmittedcopypolice", comment: "")
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

            if self.DictFoundItemEdit.count > 0 {
                apiClass().doEditFoundItemAPICall(foundID: self.DictFoundItemEdit.value(forKey: "found_id") as! String, itemName: self.txtFoundItem.text!, foundDate: finalLDate, colorID: self.selectedColorID, lTag: self.arrSelectedTags.componentsJoined(by: ","), mReward: self.TxtExpectedRewardPrice.text!, mLocation: self.lblLocationText.text!, imgArray: self.arrItemPhotos, mFoundWith: self.strFoundItemWith, mCatID: self.selectedCategoryID, mBrandName: self.txtSelectBrand.text!, delImage: self.DeleteFoundImages.componentsJoined(by: ",")) { (success, errMessage) in
                    DispatchQueue.main.async {
                        if success == true {
                            let alertCont = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("founditemupdated", comment: ""), preferredStyle: .alert)
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
                apiClass().doAddFoundItemAPICall(itemName: self.txtFoundItem.text!, foundDate: finalLDate, colorID: self.selectedColorID, lTag: self.arrSelectedTags.componentsJoined(by: ","), mReward: self.TxtExpectedRewardPrice.text!, mLocation: self.lblLocationText.text!, imgArray: self.arrItemPhotos, mFoundWith: self.strFoundItemWith, mCatID: self.selectedCategoryID, mBrandName: self.txtSelectBrand.text!) { (success, errMessage) in
                    DispatchQueue.main.async {
                        if success == true {
                            self.FoundSuccessView.isHidden = false
                        } else {
                            let alertCont = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                            }
                            alertCont.addAction(okAction)
                            self.present(alertCont, animated: true, completion: nil)
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

    @IBAction func doFoundSuccessOk() {
        self.FoundSuccessView.isHidden = false
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doUploadItemCopy() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        self.present(documentPicker, animated: true)
    }

    //MARK:- UIDocumentPickerViewController Method
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        if urls.count > 0 {
            let pickedURL = urls[0]
            do {
                if pickedURL.description.lowercased().contains("pdf") {
                    constants().APPDEL.psDataExtention = "pdf"
                } else if pickedURL.description.lowercased().contains("png") {
                    constants().APPDEL.psDataExtention = "png"
                } else if pickedURL.description.lowercased().contains("jpg") || pickedURL.description.lowercased().contains("jpeg") {
                    constants().APPDEL.psDataExtention = "jpg"
                } else {
                    let alertCont = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("doucmentmustbein", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                    }
                    alertCont.addAction(okAction)
                    self.present(alertCont, animated: true, completion: nil)
                    return
                }
                self.BtnUploadItemCopy.setAttributedTitle(NSAttributedString(string: "Upload Submitted item Copy 📄"), for: .normal)
//                self.BtnUploadItemCopy.setAttributedTitle("Upload Submitted item Copy ✔️", for: .normal)
                constants().APPDEL.psData = try Data(contentsOf: pickedURL)
            } catch {
                print("Unable to load data: \(error)")
            }
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }

    //MARK:- Voice Delegate
    func recording(text: String?, final: Bool?, error: Error?) {
        if let error = error {
            print("delegate: error \(error)")
        }
        if error == nil {
            self.TxtSearchPlaces.text = text
        }
    }

    @objc func doDeletePhoto(sender: UIButton!) {
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("yousuredeleteitem", comment: ""), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { (action) in
            let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.PhotoCollection)
            let indexPath = self.PhotoCollection.indexPathForItem(at: buttonPosition)
            if self.DictFoundItemEdit.count > 0 {
                let liveArray = (self.DictFoundItemEdit.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray
                if indexPath!.row >= liveArray.count {
                    self.arrItemPhotos.removeObject(at: indexPath!.row)
                } else {
                    self.DeleteFoundImages.add((liveArray.object(at: indexPath!.row) as! NSDictionary).value(forKey: "image_id") as! String)
                    liveArray.removeObject(at: indexPath!.row)
                    self.DictFoundItemEdit.setValue(liveArray, forKey: "found_images")
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
        if collectionView == self.TagCollection {
            return CGSize(width: constants().SCREENSIZE.width, height: 10)
        }
        if collectionView == self.CategoryCollection {
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
            if self.DictFoundItemEdit.count > 0 {
                return (self.DictFoundItemEdit.value(forKey: "found_images") as! NSArray).count + self.arrItemPhotos.count
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
        if collectionView == self.TagCollection {
            return self.arrTags.count + 1
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

            if self.DictFoundItemEdit.count > 0 {
                btnDelete.addTarget(self, action: #selector(AddFoundItem.doDeletePhoto(sender:)), for: .touchUpInside)
                btnDelete.isHidden = false
                imgItemImage.contentMode = .scaleAspectFill
                let liveArray = self.DictFoundItemEdit.value(forKey: "found_images") as! NSArray
                if indexPath.row >= liveArray.count {
                    imgItemImage.image = (self.arrItemPhotos.object(at: indexPath.row - liveArray.count) as! UIImage)
                } else {
                    let liveDict = liveArray.object(at: indexPath.row) as! NSDictionary
                    imgItemImage.sd_setImage(with: URL(string: (liveDict.value(forKey: "image") as! String)), completed: nil)
                }
            } else {
                if self.arrItemPhotos.count > 0 {
                    imgItemImage.image = (self.arrItemPhotos.object(at: indexPath.row) as! UIImage)
                    btnDelete.addTarget(self, action: #selector(AddFoundItem.doDeletePhoto(sender:)), for: .touchUpInside)
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
            cell.layer.cornerRadius = 25.0
            cell.layer.masksToBounds = true

            let txtTag = cell.viewWithTag(101) as! UITextView
            txtTag.backgroundColor = UIColor.clear

            if indexPath.row == self.arrTags.count {
                txtTag.text = "+ Add New Tag"
                txtTag.textColor = constants().COLOR_LightBlue
            } else {
                txtTag.text = (self.arrTags.object(at: indexPath.row) as! String)
                if (self.arrSelectedTags.contains(self.arrTags.object(at: indexPath.row) as! String)) {
                    cell.backgroundColor = constants().COLOR_LightBlue
                    txtTag.textColor = UIColor.white
                } else {
                    cell.backgroundColor = UIColor.white
                    txtTag.textColor = UIColor.black
                }
            }

            let fixedHeight: CGFloat = 30
            txtTag.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight))
            let newSize = txtTag.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight))
            var newFrame = txtTag.frame
            newFrame.size = CGSize(width: newSize.width + 20, height: max(newSize.height, fixedHeight))
            newFrame.origin.x = 0
            newFrame.origin.y = (50 - newFrame.size.height) / 2
            txtTag.frame = newFrame
            return cell
        }
    }

    @objc func OtherButtonPressed(_ sender: UIButton) {
        let mDict = constants().APPDEL.CategoryList.object(at: (constants().APPDEL.CategoryList.count - 1)) as! NSDictionary
        self.selectedCategoryID = mDict.value(forKey: "category_id") as! String
        self.WhatScroll.isHidden = true
        self.WhereScroll.isHidden = false
        self.btnNext.isHidden = true
        self.TagView.isHidden = true
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
        if collectionView == self.TagCollection {
            if indexPath.row == self.arrTags.count {
                return CGSize(width: 150, height: 50)
            } else {
                let mWidth = constants().labelWidth(mString: self.arrTags[indexPath.row] as! String)
                return CGSize(width: mWidth + 20, height: 50)
            }
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
        return CGSize(width: constants().SCREENSIZE.width - 30, height: 240)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.ColorCollection {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        if collectionView == self.PhotoCollection {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        if collectionView == self.TagCollection {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        if collectionView == self.CategoryCollection {
            return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
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
        if collectionView == self.TagCollection {
            return 5
        }
        if collectionView == self.CategoryCollection {
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
        if collectionView == self.TagCollection {
            return 5
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
                self.TagView.isHidden = true
                self.btnWhat.setTitleColor(UIColor.lightGray, for: .normal)
                self.btnWhere.setTitleColor(UIColor.black, for: .normal)
            }
        }
        if collectionView == self.TagCollection {
            if indexPath.row == self.arrTags.count {
                self.vwAddNewTagView.isHidden = false
                self.txtAddNewTag.text = ""
                self.txtAddNewTag.becomeFirstResponder()
            } else {
                if (self.arrSelectedTags.contains(self.arrTags.object(at: indexPath.row) as! String)) {
                    self.arrSelectedTags.remove(self.arrTags.object(at: indexPath.row) as! String)
                } else {
                    self.arrSelectedTags.add(self.arrTags.object(at: indexPath.row) as! String)
                }
                self.TagCollection.reloadData()
            }
        }
    }

    func doFetchAutoSuggestions(sKey:String) {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        let searchString = (sKey.replacingOccurrences(of: " ", with: "%20"))
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
                self.doFetchAutoSuggestions(sKey: updatedText)
            }
        }
        if textField == self.TxtExpectedRewardPrice {
            return constants().allowednumberset(str: string)
        }
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doCustomToolHide()
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
}
