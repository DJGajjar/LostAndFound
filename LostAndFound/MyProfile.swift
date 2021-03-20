//  MyProfile.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class MyProfile: UIViewController {
    @IBOutlet weak var TopView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnNotification : UIButton!
    @IBOutlet weak var btnEditProfile : UIButton!
    @IBOutlet weak var imgProfile : UIImageView!

    @IBOutlet weak var ContentView : UIView!

    @IBOutlet weak var vwProfileView : UIView!
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblEmail : UILabel!
    @IBOutlet weak var lblMobile : UILabel!

    @IBOutlet weak var vwAddressView : UIView!
    @IBOutlet weak var lblAddress : UILabel!
    @IBOutlet weak var txtAddress : UITextView!

    @IBOutlet weak var MyItemsView : UIView!
    @IBOutlet weak var lblItemsTitle : UILabel!
    @IBOutlet weak var btnItems : UIButton!

    @IBOutlet weak var FavoritesView : UIView!
    @IBOutlet weak var lblFavoritesTitle : UILabel!
    @IBOutlet weak var btnFavorites : UIButton!

    @IBOutlet weak var SettingsView : UIView!
    @IBOutlet weak var lblSettingsTitle : UILabel!
    @IBOutlet weak var btnSettings : UIButton!

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doFetchProfile()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2
        self.imgProfile.layer.masksToBounds = true

        self.vwProfileView.layer.cornerRadius = 10.0
        self.vwProfileView.layer.masksToBounds = true

        self.vwAddressView.layer.cornerRadius = 10.0
        self.vwAddressView.layer.masksToBounds = true

        self.MyItemsView.layer.cornerRadius = 10.0
        self.MyItemsView.layer.masksToBounds = true

        self.FavoritesView.layer.cornerRadius = 10.0
        self.FavoritesView.layer.masksToBounds = true

        self.SettingsView.layer.cornerRadius = 10.0
        self.SettingsView.layer.masksToBounds = true

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

                frame = self.btnNotification.frame
                frame.origin.y = 40
                self.btnNotification.frame = frame

                frame = self.ContentView.frame
                frame.origin.y = self.TopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.ContentView.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("profile", comment: "")
        self.lblAddress.text = NSLocalizedString("address", comment: "")
        self.lblItemsTitle.text = NSLocalizedString("myitems", comment: "")
        self.lblFavoritesTitle.text = NSLocalizedString("favorites", comment: "")
        self.lblSettingsTitle.text = NSLocalizedString("settings", comment: "")
    }

    func doFetchProfile() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }

        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetProfileAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    constants().APPDEL.dictUserProfile = mDict.value(forKey: "user_profile") as! NSDictionary
                    self.imgProfile.loadProfileImage(url: (constants().APPDEL.dictUserProfile.value(forKey: "image") as! String))
                    self.lblStatus.text = "As \(constants().APPDEL.dictUserProfile.value(forKey: "type") as! String)"
                    self.lblName.text = "\(constants().APPDEL.dictUserProfile.value(forKey: "first_name") as! String) \(constants().APPDEL.dictUserProfile.value(forKey: "last_name") as! String)"
                    self.lblEmail.text = (constants().APPDEL.dictUserProfile.value(forKey: "email") as! String)
                    self.lblMobile.text = (constants().APPDEL.dictUserProfile.value(forKey: "mobile") as! String)
                    self.txtAddress.text = "\(constants().APPDEL.dictUserProfile.value(forKey: "address1") as! String) \(constants().APPDEL.dictUserProfile.value(forKey: "address2") as! String) \(constants().APPDEL.dictUserProfile.value(forKey: "city") as! String) \(constants().APPDEL.dictUserProfile.value(forKey: "country") as! String)"
                }
            }
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        ivc.selectedIndex = 0
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doEditProfile() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "editprofile") as! EditProfile
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    @IBAction func doNotifications() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "notifications") as! NotificationsPage
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    @IBAction func doMyItems() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myitems") as! MyItems
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doFavorites() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "favorites") as! FavoritesScreen
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doSettings() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "settings") as! SettingsPage
        constants().APPDEL.window?.rootViewController = ivc
    }
}
