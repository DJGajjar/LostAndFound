//  SettingsPage.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import StoreKit

class SettingsPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        self.doSetFrames()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.SettingsCollection.layer.cornerRadius = 10.0
        self.SettingsCollection.layer.masksToBounds = true

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
        self.lblTitle.text = NSLocalizedString("settings", comment: "")
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myprofile") as! MyProfile
        constants().APPDEL.window?.rootViewController = ivc
    }

    @objc func doSWitchClick(_ sender: UISwitch) {
        var mOn = ""
        if (sender.isOn == true) {
            mOn = "ON"
        } else {
            mOn = "OFF"
        }
        let param: [String: Any] = ["user_id":constants().doGetUserId(), "notification_status":mOn]
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: param, APIName: apiClass().ChangeNotificationStatusAPI, method: "POST") { (success, errMessage, mDict) in
        }
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 2  {
            if (constants().APPDEL.dictUserProfile.count > 0) && ((constants().APPDEL.dictUserProfile.value(forKey: "type") as! String) == constants().USERTYPE_ORGANIZATION) {
                return CGSize(width: constants().SCREENSIZE.width, height: 50)
            }
            return CGSize(width: constants().SCREENSIZE.width, height: 0)
        }
        if section == 3  {
            return CGSize(width: constants().SCREENSIZE.width, height: 0)
        }
        return CGSize(width: constants().SCREENSIZE.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let objHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionheader", for: indexPath) as? settingHeader {
            objHeader.backgroundColor = UIColor.clear
            switch indexPath.section {
            case 0:
                objHeader.sectionHeaderlabel.text = NSLocalizedString("accounts", comment: "")
                break
            case 1:
                objHeader.sectionHeaderlabel.text = NSLocalizedString("general", comment: "")
                break
            case 2:
                if (constants().APPDEL.dictUserProfile.count > 0) && ((constants().APPDEL.dictUserProfile.value(forKey: "type") as! String) == constants().USERTYPE_ORGANIZATION) {
                    objHeader.sectionHeaderlabel.text = NSLocalizedString("organisation", comment: "")
                } else {
                    objHeader.sectionHeaderlabel.text = NSLocalizedString("", comment: "")
                }
                break
            case 3:
                objHeader.sectionHeaderlabel.text = NSLocalizedString("", comment: "")
                break
            default:
                break
            }
            return objHeader
        }
        return UICollectionReusableView()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 4
        case 2:
            if (constants().APPDEL.dictUserProfile.count > 0) && ((constants().APPDEL.dictUserProfile.value(forKey: "type") as! String) == constants().USERTYPE_ORGANIZATION) {
                return 2
            }
            return 0
        case 3:
            return 2
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
        let imgArrow  = cell.viewWithTag(102) as! UIImageView
        let mSwitch = cell.viewWithTag(103) as! UISwitch
        let CustomSeparator = cell.viewWithTag(106) as! UILabel

        imgArrow.isHidden = false
        mSwitch.isHidden = true
        CustomSeparator.isHidden = false
        lblName.textColor = UIColor.black

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                mSwitch.addTarget(self, action: #selector(self.doSWitchClick(_:)), for: .valueChanged)
                lblName.text = NSLocalizedString("pushnotification", comment: "")
                imgArrow.isHidden = true
                if (constants().APPDEL.dictUserProfile.count > 0) && (constants().APPDEL.dictUserProfile.value(forKey: "notification_status") as! String) == "ON" {
                    mSwitch.isOn = true
                } else {
                    mSwitch.isOn = false
                }
                mSwitch.isHidden = false
                break
            case 1:
                lblName.text = NSLocalizedString("changepassword", comment: "")
                break
            case 2:
                lblName.text = NSLocalizedString("privacysettings", comment: "")
                break
            case 3:
                lblName.text = NSLocalizedString("termsconditions", comment: "")
                break
            case 4:
                lblName.text = NSLocalizedString("changelanguage", comment: "")
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                lblName.text = NSLocalizedString("aboutus", comment: "")
                break
            case 1:
                lblName.text = NSLocalizedString("tributeto", comment: "")
                break
            case 2:
                lblName.text = NSLocalizedString("support", comment: "")
                break
            case 3:
                lblName.text = NSLocalizedString("rateapp", comment: "")
                break
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                lblName.text = NSLocalizedString("editorganisation", comment: "")
                break
            case 1:
                lblName.text = NSLocalizedString("memberlist", comment: "")
                break
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.backgroundColor = UIColor.clear
                imgArrow.isHidden = true
                lblName.text = NSLocalizedString("logout", comment: "")
                CustomSeparator.isHidden = true
                lblName.textColor = UIColor.red
                break
            case 1:
                cell.backgroundColor = UIColor.clear
                imgArrow.isHidden = true
                lblName.text = NSLocalizedString("deleteaccount", comment: "")
                CustomSeparator.isHidden = true
                lblName.textColor = UIColor.red
                break
            default:
                break
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let nWidth = constants().SCREENSIZE.width - 30
        if indexPath.section == 2 {
            if (constants().APPDEL.dictUserProfile.count > 0) && ((constants().APPDEL.dictUserProfile.value(forKey: "type") as! String) == constants().USERTYPE_ORGANIZATION) {
                return CGSize(width: nWidth, height: 55)
            } else {
                return CGSize(width: nWidth, height: 0)
            }
        }
        return CGSize(width: nWidth, height: 55)
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
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                break
            case 1:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "changepassword") as! ChangePassword
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: true, completion: nil)
                break
            case 2:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "privacysettings") as! PrivacySettings
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: true, completion: nil)
                break
            case 3:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "terms") as! TermsConditions
                ivc.isFromSignUp = false
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: true, completion: nil)
                break
            case 4:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "selectlanguage") as! SelectLanguage
                ivc.navFlag = 2
                constants().APPDEL.window?.rootViewController = ivc
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "aboutus") as! AboutUs
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: true, completion: nil)
                break
            case 1:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tribute") as! TributeScreen
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: true, completion: nil)
                break
            case 2:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "support") as! SupportPage
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: true, completion: nil)
                break
            case 3:
                SKStoreReviewController.requestReview()
                break
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "editorganisation") as! EditOrganisation
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: false, completion: nil)
                break
            case 1:
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "memberlist") as! MemberList
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: false, completion: nil)
                break
            default:
                break
            }
        } else {
            switch indexPath.row {
                case 0:
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("areyousurelogout", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { (action) in
                        constants().doCleanUpUserData()
                        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "signin") as! SignIn
                        constants().APPDEL.window?.rootViewController = ivc
                    }
                    alertController.addAction(okAction)
                    let noAction = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default) { (action) in
                    }
                    alertController.addAction(noAction)
                    self.present(alertController, animated: true, completion: nil)
                    break
                case 1:
                    let ivc = constants().storyboard.instantiateViewController(withIdentifier: "deleteaccount") as! DeleteAccount
                    constants().APPDEL.window?.rootViewController = ivc
                    break
                default:
                    break
            }
        }
    }
}
