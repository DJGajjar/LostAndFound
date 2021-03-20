//  PrivacySettings.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class PrivacySettings: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var SettingsCollection: UICollectionView!

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.SettingsCollection.reloadData()
        self.doSetFrames()
        self.doLoadSettings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func doLoadSettings() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetProfileAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    constants().APPDEL.dictUserProfile = mDict.value(forKey: "user_profile") as! NSDictionary
                }
                self.SettingsCollection.reloadData()
            }
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
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

                frame = self.SettingsCollection.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.SettingsCollection.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("privacysettings", comment: "")
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func doSWitchClick(_ sender: UISwitch) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.SettingsCollection)
        let indexPath = self.SettingsCollection.indexPathForItem(at: buttonPosition)

        var mOn = ""
        if (sender.isOn == true) {
            mOn = "ON"
        } else {
            mOn = "OFF"
        }
        if indexPath!.section == 0 {
            switch indexPath!.row {
            case 0:
                apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "text_chat_status":mOn], APIName: apiClass().ChangeTextChatStatusAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            self.doLoadSettings()
                        }
                    }
                }
                break
            case 1:
                apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "voice_chat_status":mOn], APIName: apiClass().ChangeVoiceChatStatusAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            self.doLoadSettings()
                        }
                    }
                }
                break
            case 2:
                apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "video_chat_status":mOn], APIName: apiClass().ChangeVideoChatStatusAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            self.doLoadSettings()
                        }
                    }
                }
                break
            default:
                break
            }
        } else {
            switch indexPath!.row {
            case 0:
                apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "display_mobile_status":mOn], APIName: apiClass().ChangeDisplayMobileStatusAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            self.doLoadSettings()
                        }
                    }
                }
                break
            case 1:
                apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "display_photo_status":mOn], APIName: apiClass().ChangeDisplayPhotoStatusAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            self.doLoadSettings()
                        }
                    }
                }
                break
            case 2:
                apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "display_address_status":mOn], APIName: apiClass().ChangeDisplayAddressStatusAPI, method: "POST") { (success, errMessage, mDict) in
                    DispatchQueue.main.async {
                        if success == true {
                            self.doLoadSettings()
                        }
                    }
                }
                break
            default:
                break
            }
        }
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: constants().SCREENSIZE.width, height: 40)
        } else {
            return CGSize(width: constants().SCREENSIZE.width, height: 10)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let objHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionheader", for: indexPath) as? settingHeader {
            objHeader.backgroundColor = UIColor.clear
            switch indexPath.section {
            case 0:
                objHeader.sectionHeaderlabel.text = NSLocalizedString("chat", comment: "")
                break
            case 1:
                objHeader.sectionHeaderlabel.text = ""
                break
            default:
                break
            }
            return objHeader
        }
        return UICollectionReusableView()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        default:
            break
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white

        let lblName = cell.viewWithTag(101) as! UILabel
        let mSwitch = cell.viewWithTag(102) as! UISwitch
        mSwitch.addTarget(self, action: #selector(self.doSWitchClick(_:)), for: .valueChanged)

        mSwitch.isOn = true
        var vKey = ""
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                lblName.text = NSLocalizedString("textchat", comment: "")
                vKey = "text_chat_status"
                break
            case 1:
                lblName.text = NSLocalizedString("voicechat", comment: "")
                vKey = "voice_chat_status"
                break
            case 2:
                lblName.text = NSLocalizedString("videocall", comment: "")
                vKey = "video_chat_status"
                break
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                lblName.text = NSLocalizedString("displaymobile", comment: "")
                vKey = "display_mobile_status"
                break
            case 1:
                lblName.text = NSLocalizedString("displayphoto", comment: "")
                vKey = "display_photo_status"
                break
            case 2:
                lblName.text = NSLocalizedString("displayaddress", comment: "")
                vKey = "display_address_status"
                break
            default:
                break
            }
        }

        if constants().APPDEL.dictUserProfile.allKeys.count != 0 {
            if (constants().APPDEL.dictUserProfile.value(forKey: vKey) as! String) == "ON" {
                mSwitch.isOn = true
            } else {
                mSwitch.isOn = false
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: constants().SCREENSIZE.width-30, height: 65)
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

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
