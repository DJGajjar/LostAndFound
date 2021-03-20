//  EditOrganisation.swift
//  LostAndFound
//  Created by Revamp on 12/05/20.
//  Copyright © 2020 Revamp. All rights reserved.

import UIKit
import YangMingShan
import TPKeyboardAvoiding
class EditOrganisation: UIViewController, UITextFieldDelegate, YMSPhotoPickerViewControllerDelegate {
    @IBOutlet weak var TopView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnDone : UIButton!
    @IBOutlet weak var btnProfileImage : UIButton!
    @IBOutlet weak var imgProfile : UIImageView!

    @IBOutlet weak var ContentView : TPKeyboardAvoidingScrollView!

    @IBOutlet weak var ChangeProfileView : UIView!
    @IBOutlet weak var lblChangeProfile : UILabel!

    @IBOutlet weak var txtOrgName : UITextField!
    @IBOutlet weak var txtRegNumber : UITextField!
    @IBOutlet weak var txtWebsite : UITextField!

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
        self.doFetchOrganisationDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func doFetchOrganisationDetail() {
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["organization_id":constants().doGetUserId()], APIName: apiClass().GetOrganisationDetailAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    let DictOrganisationDetail = mDict.value(forKey: "data") as! NSDictionary
                    self.imgProfile.loadProfileImage(url: (DictOrganisationDetail.value(forKey: "orgonization_image") as! String))
                    self.txtOrgName.text = (DictOrganisationDetail.value(forKey: "organization_name") as! String)
                    self.txtRegNumber.text = (DictOrganisationDetail.value(forKey: "registration_number") as! String)
                    self.txtWebsite.text = (DictOrganisationDetail.value(forKey: "website") as! String)
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

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.ContentView.semanticContentAttribute = .forceLeftToRight
        self.txtOrgName.semanticContentAttribute = .forceLeftToRight
        self.txtRegNumber.semanticContentAttribute = .forceLeftToRight
        self.txtWebsite.semanticContentAttribute = .forceLeftToRight

        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2
        self.imgProfile.layer.masksToBounds = true

        self.ChangeProfileView.layer.cornerRadius = 8.0
        self.ChangeProfileView.layer.masksToBounds = true

        let paddingFName = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtOrgName.frame.height))
        paddingFName.backgroundColor = UIColor.clear
        self.txtOrgName.leftView = paddingFName
        self.txtOrgName.leftViewMode = .always
        self.txtOrgName.layer.cornerRadius = 8.0
        self.txtOrgName.layer.masksToBounds = true

        let paddingLName = UIView(frame: CGRect(x:0, y:0, width:10, height: self.txtRegNumber.frame.height))
        paddingLName.backgroundColor = UIColor.clear
        self.txtRegNumber.leftView = paddingLName
        self.txtRegNumber.leftViewMode = .always
        self.txtRegNumber.layer.cornerRadius = 8.0
        self.txtRegNumber.layer.masksToBounds = true

        let paddingEmail = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtWebsite.frame.height))
        paddingEmail.backgroundColor = UIColor.clear
        self.txtWebsite.leftView = paddingEmail
        self.txtWebsite.leftViewMode = .always
        self.txtWebsite.layer.cornerRadius = 8.0
        self.txtWebsite.layer.masksToBounds = true

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
        self.lblTitle.text = NSLocalizedString("editorganisation", comment: "")
        self.btnDone.setTitle(NSLocalizedString("done", comment: ""), for: .normal)
        self.lblChangeProfile.text = NSLocalizedString("changelogo", comment: "")
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
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func doDone() {
        var aMessage = ""
        if self.txtOrgName.text!.isEmpty {
            aMessage = NSLocalizedString("enterorganisationname", comment: "")
        }

        if aMessage.isEmpty {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doUploadAPI(param: ["organization_id":constants().doGetUserId(), "organization_name":self.txtOrgName.text!, "registration_number":self.txtRegNumber.text!, "website":self.txtWebsite.text!, "org_img":self.imgProfile.image!], APIName: apiClass().UpdateOrganisationAPI, method: "POST") { (success, errMessage, mDict) in
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
}
