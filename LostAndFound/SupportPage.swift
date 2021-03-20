//  SupportPage.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import MessageUI

class SupportPage: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var ContentView : UIView!
    @IBOutlet weak var txtReason : UITextField!
    @IBOutlet weak var txtMessage : UITextField!
    @IBOutlet weak var btnSubmit : UIButton!
    @IBOutlet weak var lblReachUs : UILabel!
    @IBOutlet weak var btnCall1 : UIButton!
    @IBOutlet weak var btnMail1 : UIButton!

    @IBOutlet weak var CustomToolbar : UIView!
    @IBOutlet weak var CustomDone : UIButton!

    var reasonPicker: UIPickerView!
    var keyboardHEIGHT : CGFloat = 240.0
    var dictSupportSettings = NSDictionary()
    var ArrSupportReasonsList = NSMutableArray()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        // Set Hidden By Default
        self.btnCall1.isHidden = true
        self.btnMail1.isHidden = true

        self.doConfigureSuggestionPicker()
        self.doSetFrames()

        apiClass().doNormalAPI(param: [:], APIName: apiClass().SupportSettingAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.dictSupportSettings = mDict
                    if (self.dictSupportSettings.value(forKey: "visiblity_status") as! String) == "OFF" {
                        self.btnCall1.isHidden = true
                        self.btnMail1.isHidden = true
                    } else {
                        self.btnCall1.isHidden = false
                        self.btnMail1.isHidden = false
                    }
                }
            }
        }

        apiClass().doNormalAPI(param: [:], APIName: apiClass().SupportReasonsAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.ArrSupportReasonsList = (mDict.value(forKey: "reason_list") as! NSArray).mutableCopy() as! NSMutableArray
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHEIGHT = keyboardRectangle.height
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.ContentView.semanticContentAttribute = .forceLeftToRight
        self.txtReason.semanticContentAttribute = .forceLeftToRight
        self.txtMessage.semanticContentAttribute = .forceLeftToRight

        let paddingRight = UIView(frame: CGRect(x:self.txtReason.frame.size.width - 30, y:0, width:30, height: self.txtReason.frame.height))
        paddingRight.backgroundColor = UIColor.clear
        let arrowImage = UIImageView(image: UIImage(named: "DownLineArrow"))
        arrowImage.contentMode = .center
        arrowImage.frame = CGRect(x:0, y:10, width:30, height:30)
        paddingRight.addSubview(arrowImage)
        self.txtReason.rightView = paddingRight
        self.txtReason.rightViewMode = .always

        let paddingReason = UIView(frame: CGRect(x:0, y:0, width:15, height: self.txtReason.frame.height))
        paddingReason.backgroundColor = UIColor.clear
        self.txtReason.leftView = paddingReason
        self.txtReason.leftViewMode = .always
        self.txtReason.layer.cornerRadius = 10.0
        self.txtReason.layer.masksToBounds = true

        let paddingMessage = UIView(frame: CGRect(x:0, y:0, width:20, height: self.txtMessage.frame.height))
        paddingMessage.backgroundColor = UIColor.clear
        self.txtMessage.leftView = paddingMessage
        self.txtMessage.leftViewMode = .always
        self.txtMessage.layer.cornerRadius = 10.0
        self.txtMessage.layer.masksToBounds = true

        self.btnCall1.layer.cornerRadius = self.btnCall1.frame.size.width / 2
        self.btnCall1.layer.masksToBounds = true

        self.btnMail1.layer.cornerRadius = self.btnMail1.frame.size.width / 2
        self.btnMail1.layer.masksToBounds = true

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
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.ContentView.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("support", comment: "")
        self.txtReason.placeholder = NSLocalizedString("choosereason", comment: "")
        self.txtMessage.placeholder = NSLocalizedString("messagecomments", comment: "")
        self.btnSubmit.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        self.lblReachUs.text = NSLocalizedString("orreachby", comment: "")
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
        self.doCustomToolHide()
    }

    @objc func doConfigureSuggestionPicker() {
        self.reasonPicker = UIPickerView()
        self.reasonPicker.dataSource = self
        self.reasonPicker.delegate = self
        self.txtReason.inputView = self.reasonPicker
    }

    //MARK:- IBAction Methods
    @IBAction func doSubmit() {
        self.doCustomToolHide()
        var aMessage = ""
        if txtReason.text!.isEmpty {
            aMessage = NSLocalizedString("selectreason", comment: "")
        } else if txtMessage.text!.isEmpty {
            aMessage = NSLocalizedString("entermessage", comment: "")
        }

        if aMessage.isEmpty {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "reason":self.txtReason.text!, "message":self.txtMessage.text!], APIName: apiClass().ContactSupportAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("messagesent", comment: ""), preferredStyle: .alert)
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

    @IBAction func doCall() {
        constants().doCallNumber(phoneNumber: self.dictSupportSettings.value(forKey: "support_contact") as! String)
    }

    @IBAction func doMail() {
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail() {
            mailComposeViewController.modalPresentationStyle = .fullScreen
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }

    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK:- Mail Configure
    func configureMailComposer() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([(self.dictSupportSettings.value(forKey: "support_email") as! String)])
        mailComposeVC.setSubject("Lost&Found - Support")
        mailComposeVC.setMessageBody("Hi Lost&Found Support Team,\n\nI have used this Application. I have some doubts / suggestions which i am writing here.\n\n", isHTML: false)
        return mailComposeVC
    }

    //MARK:- MFMailComposeViewController Delegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    //MARK:- UITextField delegate methods
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        constants().doMoveViewToDown(mView: self.view)
        self.doCustomToolHide()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtReason {
            self.doCustomToolShow()
        }
    }

    //MARK:- UIPickerView delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.ArrSupportReasonsList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ((self.ArrSupportReasonsList.object(at: row) as! NSDictionary).value(forKey: "description") as! String)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txtReason.text = ((self.ArrSupportReasonsList.object(at: row) as! NSDictionary).value(forKey: "description") as! String)
    }
}
