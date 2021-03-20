//  EditProfile.swift
//  LostAndFound
//  Created by Revamp on 09/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import YangMingShan
import TPKeyboardAvoiding
class EditProfile: UIViewController, UITextFieldDelegate, YMSPhotoPickerViewControllerDelegate {
    @IBOutlet weak var TopView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnDone : UIButton!
    @IBOutlet weak var btnProfileImage : UIButton!
    @IBOutlet weak var imgProfile : UIImageView!
    
    @IBOutlet weak var ContentView : TPKeyboardAvoidingScrollView!
    
    @IBOutlet weak var ChangeProfileView : UIView!
    @IBOutlet weak var lblChangeProfile : UILabel!
    
    @IBOutlet weak var txtFirstName : UITextField!
    @IBOutlet weak var txtLastName : UITextField!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtMobile : UITextField!
    @IBOutlet weak var txtAddress1 : UITextField!
    @IBOutlet weak var txtAddress2 : UITextField!
    @IBOutlet weak var txtCity : UITextField!
    @IBOutlet weak var txtCountry : UITextField!
    
    let pickerViewController = YMSPhotoPickerViewController.init()
    
    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.doApplyLocalisation()
        self.SetupPhotoPicker()
        self.doSetFrames()
        DispatchQueue.main.async {
            self.imgProfile.loadProfileImage(url: (constants().APPDEL.dictUserProfile.value(forKey: "image") as! String))
            self.txtFirstName.text = (constants().APPDEL.dictUserProfile.value(forKey: "first_name") as! String)
            self.txtLastName.text = (constants().APPDEL.dictUserProfile.value(forKey: "last_name") as! String)
            self.txtEmail.text = (constants().APPDEL.dictUserProfile.value(forKey: "email") as! String)
            self.txtMobile.text = (constants().APPDEL.dictUserProfile.value(forKey: "mobile") as! String)
            self.txtAddress1.text = (constants().APPDEL.dictUserProfile.value(forKey: "address1") as! String)
            self.txtAddress2.text = (constants().APPDEL.dictUserProfile.value(forKey: "address2") as! String)
            self.txtCity.text = (constants().APPDEL.dictUserProfile.value(forKey: "city") as! String)
            self.txtCountry.text = (constants().APPDEL.dictUserProfile.value(forKey: "country") as! String)
            
            if constants().doGetUserType() == constants().USERTYPE_ORGANIZATION {
                self.txtEmail.isEnabled = false
                self.txtMobile.isEnabled = true
            } else {
                self.txtEmail.isEnabled = true
                self.txtMobile.isEnabled = false
            }
            self.txtEmail.isEnabled = true
            self.txtMobile.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.ContentView.semanticContentAttribute = .forceLeftToRight
        self.txtFirstName.semanticContentAttribute = .forceLeftToRight
        self.txtLastName.semanticContentAttribute = .forceLeftToRight
        self.txtEmail.semanticContentAttribute = .forceLeftToRight
        self.txtMobile.semanticContentAttribute = .forceLeftToRight
        self.txtCity.semanticContentAttribute = .forceLeftToRight
        self.txtCountry.semanticContentAttribute = .forceLeftToRight
        self.txtAddress1.semanticContentAttribute = .forceLeftToRight
        self.txtAddress2.semanticContentAttribute = .forceLeftToRight
        
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2
        self.imgProfile.layer.masksToBounds = true
        
        self.ChangeProfileView.layer.cornerRadius = 8.0
        self.ChangeProfileView.layer.masksToBounds = true
        
        let paddingFName = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtFirstName.frame.height))
        paddingFName.backgroundColor = UIColor.clear
        self.txtFirstName.leftView = paddingFName
        self.txtFirstName.leftViewMode = .always
        self.txtFirstName.layer.cornerRadius = 8.0
        self.txtFirstName.layer.masksToBounds = true
        
        let paddingLName = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtLastName.frame.height))
        paddingLName.backgroundColor = UIColor.clear
        self.txtLastName.leftView = paddingLName
        self.txtLastName.leftViewMode = .always
        self.txtLastName.layer.cornerRadius = 8.0
        self.txtLastName.layer.masksToBounds = true
        
        let paddingEmail = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtEmail.frame.height))
        paddingEmail.backgroundColor = UIColor.clear
        self.txtEmail.leftView = paddingEmail
        self.txtEmail.leftViewMode = .always
        self.txtEmail.layer.cornerRadius = 8.0
        self.txtEmail.layer.masksToBounds = true
        
        let paddingMobile = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtMobile.frame.height))
        paddingMobile.backgroundColor = UIColor.clear
        self.txtMobile.leftView = paddingMobile
        self.txtMobile.leftViewMode = .always
        self.txtMobile.layer.cornerRadius = 8.0
        self.txtMobile.layer.masksToBounds = true
        
        let paddingAddress1 = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtAddress1.frame.height))
        paddingAddress1.backgroundColor = UIColor.clear
        self.txtAddress1.leftView = paddingAddress1
        self.txtAddress1.leftViewMode = .always
        self.txtAddress1.layer.cornerRadius = 8.0
        self.txtAddress1.layer.masksToBounds = true
        
        let paddingAddress2 = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtAddress2.frame.height))
        paddingAddress2.backgroundColor = UIColor.clear
        self.txtAddress2.leftView = paddingAddress2
        self.txtAddress2.leftViewMode = .always
        self.txtAddress2.layer.cornerRadius = 8.0
        self.txtAddress2.layer.masksToBounds = true
        
        let paddingCity = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtCity.frame.height))
        paddingCity.backgroundColor = UIColor.clear
        self.txtCity.leftView = paddingCity
        self.txtCity.leftViewMode = .always
        self.txtCity.layer.cornerRadius = 8.0
        self.txtCity.layer.masksToBounds = true
        
        let paddingCountry = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtCountry.frame.height))
        paddingCountry.backgroundColor = UIColor.clear
        self.txtCountry.leftView = paddingCountry
        self.txtCountry.leftViewMode = .always
        self.txtCountry.layer.cornerRadius = 8.0
        self.txtCountry.layer.masksToBounds = true
        
        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.TopView.frame
                frame.size.height = 80
                self.TopView.frame = frame
                
                frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame
                
                frame = self.btnBack.frame
                frame.origin.y = 40
                self.btnBack.frame = frame
                
                frame = self.btnDone.frame
                frame.origin.y = 40
                self.btnDone.frame = frame
                
                frame = self.ContentView.frame
                frame.origin.y = self.TopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.ContentView.frame = frame
            }
        }
    }
    
    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("editprofile", comment: "")
        self.btnDone.setTitle(NSLocalizedString("done", comment: ""), for: .normal)
        self.lblChangeProfile.text = NSLocalizedString("changeprofile", comment: "")
        self.txtFirstName.placeholder = NSLocalizedString("firstname", comment: "")
        self.txtLastName.placeholder = NSLocalizedString("lastname", comment: "")
        self.txtEmail.placeholder = NSLocalizedString("email", comment: "")
        self.txtMobile.placeholder = NSLocalizedString("mobilenumber", comment: "")
        self.txtAddress1.placeholder = NSLocalizedString("addressline1", comment: "")
        self.txtAddress2.placeholder = NSLocalizedString("addressline2", comment: "")
        self.txtCity.placeholder = NSLocalizedString("city", comment: "")
        self.txtCountry.placeholder = NSLocalizedString("country", comment: "")
    }
    
    func SetupPhotoPicker() {
        self.pickerViewController.delegate = self
        self.pickerViewController.numberOfPhotoToSelect = 1
        pickerViewController.theme.titleLabelTextColor = UIColor.black
        pickerViewController.theme.navigationBarBackgroundColor = UIColor.white
        pickerViewController.theme.tintColor = UIColor.black
        pickerViewController.theme.orderTintColor = constants().COLOR_LightBlue
        pickerViewController.theme.cameraVeilColor = constants().COLOR_LightBlue
        pickerViewController.theme.cameraIconColor = UIColor.white
        pickerViewController.theme.statusBarStyle = .lightContent
    }
    
    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doDone() {
        var aMessage = ""
        if self.txtFirstName.text!.isEmpty {
            aMessage = NSLocalizedString("enterfirstname", comment: "")
        } else if self.txtLastName.text!.isEmpty {
            aMessage = NSLocalizedString("enterlastname", comment: "")
        } else if self.txtAddress1.text!.isEmpty {
            aMessage = NSLocalizedString("enteraddress1", comment: "")
        } else if self.txtAddress2.text!.isEmpty {
            aMessage = NSLocalizedString("enteraddress2", comment: "")
        } else if self.txtCity.text!.isEmpty {
            aMessage = NSLocalizedString("entercity", comment: "")
        } else if (constants().isValidEmail(testStr: self.txtEmail.text!) == false) {
            aMessage = NSLocalizedString("entervalidemail", comment: "")
        } else if (constants().isValidPhone(phone: self.txtMobile.text!) == false) {
            aMessage = NSLocalizedString("entervalidmobile", comment: "")
        } else if self.txtCountry.text!.isEmpty {
            aMessage = NSLocalizedString("entercountry", comment: "")
        }
        
        if aMessage.isEmpty {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            var param: [String: Any] = ["user_id":constants().doGetUserId(), "first_name":self.txtFirstName.text!, "last_name":self.txtLastName.text!, "address1":self.txtAddress1.text!, "address2":self.txtAddress2.text!, "city":self.txtCity.text!, "country":self.txtCountry.text!]
            if let imageToUpload = self.imgProfile.image {
                param["profile_pic"] = imageToUpload
            }
            param["mobile"] = self.txtMobile.text!
            param["email"] = self.txtEmail.text!
            if constants().doGetUserType() == constants().USERTYPE_ORGANIZATION {
                param["mobile"] = self.txtMobile.text!
            } else {
                param["email"] = self.txtEmail.text!
            }
            
            constants().APPDEL.doStartSpinner()
            apiClass().doUploadAPI(param: param, APIName: apiClass().UpdateProfileAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("profileupdated", comment: ""), preferredStyle: .alert)
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                            self.doBack()
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
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: aMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func doProfileImage() {
        pickerViewController.modalPresentationStyle = .fullScreen
        self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
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
    
    func photoPickerViewController(_ picker: YMSPhotoPickerViewController!, didFinishPicking image: UIImage) {
        picker.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.imgProfile.image = image
            }
        }
    }
    
    //MARK:- UITextField delegate methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtMobile {
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
