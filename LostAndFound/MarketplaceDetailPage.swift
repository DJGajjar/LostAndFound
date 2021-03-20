//  MarketplaceDetailPage.swift
//  LostAndFound
//  Created by Revamp on 15/11/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import MessageUI
import PageControls

class MarketplaceDetailPage: UIViewController, MFMailComposeViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnFavorite : UIButton!
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

    @IBOutlet weak var OwnerView: UIView!
    @IBOutlet weak var lblOFdetail: UILabel!
    @IBOutlet weak var OwnerImage: UIImageView!
    @IBOutlet weak var OwnerName: UILabel!
    @IBOutlet weak var OwnerLocation: UILabel!
    @IBOutlet weak var BtnOwnerCall: UIButton!
    @IBOutlet weak var BtnOwnerMail: UIButton!
    @IBOutlet weak var BtnOwnerChatMessage: UIButton!
    @IBOutlet weak var BtnOwnerPin: UIButton!

    var dictMarketplaceDetail = NSDictionary()
    var ArrItemImages = NSMutableArray()
    var SharableImage = UIImage(named: "place_holder")
    var ScreenshotImage = UIImage()
    var FavToMarket = "0"

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.doConfigurePageControl()
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        apiClass().doNormalAPI(param: ["found_id":(self.dictMarketplaceDetail.value(forKey: "found_id") as! String)], APIName: apiClass().FoundViewCountAPI, method: "POST") { (success, errMessage, mDict) in
        }
        DispatchQueue.main.async {
            self.ItemName.text = (self.dictMarketplaceDetail.value(forKey: "item_name") as! String)
            self.ItemCategory.text = (self.dictMarketplaceDetail.value(forKey: "category_item_name") as! String)
            self.ItemBrand.text = (self.dictMarketplaceDetail.value(forKey: "brand_name") as! String)
            self.ItemColor.backgroundColor = constants().hexStringToUIColor(hex: (self.dictMarketplaceDetail.value(forKey: "color_code") as! String))
            self.lblRewardAmount.text = (self.dictMarketplaceDetail.value(forKey: "expected_reward") as! String)
            self.btnViews.setTitle("\(self.dictMarketplaceDetail.value(forKey: "no_of_view") as! String) Views", for: .normal)
            self.OwnerName.text = "\(self.dictMarketplaceDetail.value(forKey: "first_name") as! String) \(self.dictMarketplaceDetail.value(forKey: "last_name") as! String)"

            self.OwnerLocation.text = (self.dictMarketplaceDetail.value(forKey: "address1") as! String)
            if !(self.dictMarketplaceDetail.value(forKey: "address2") as! String).isEmpty {
                self.OwnerLocation.text?.append(", \(self.dictMarketplaceDetail.value(forKey: "address2") as! String)")
            }
            if !(self.dictMarketplaceDetail.value(forKey: "city") as! String).isEmpty {
                self.OwnerLocation.text?.append(", \(self.dictMarketplaceDetail.value(forKey: "city") as! String)")
            }
            if !(self.dictMarketplaceDetail.value(forKey: "country") as! String).isEmpty {
                self.OwnerLocation.text?.append(", \(self.dictMarketplaceDetail.value(forKey: "country") as! String)")
            }

            self.OwnerImage.loadProfileImage(url: (self.dictMarketplaceDetail.value(forKey: "image") as! String))
            self.ArrItemImages = (self.dictMarketplaceDetail.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray
            self.myPageControl.numberOfPages = self.ArrItemImages.count
            self.imgItemCollection.reloadData()

            if (self.dictMarketplaceDetail.value(forKey: "text_chat_status") as! String) == "OFF" {
                self.BtnOwnerChatMessage.isEnabled = false
                self.BtnOwnerChatMessage.backgroundColor = UIColor.lightGray
            } else {
                self.BtnOwnerChatMessage.isEnabled = true
                self.BtnOwnerChatMessage.backgroundColor = constants().COLOR_LightBlue
            }

            if (self.dictMarketplaceDetail.value(forKey: "user_mobile") as! String).isEmpty {
                self.BtnOwnerCall.isEnabled = false
                self.BtnOwnerCall.backgroundColor = UIColor.lightGray
            } else {
                if (self.dictMarketplaceDetail.value(forKey: "display_mobile_status") as! String) == "OFF" {
                    self.BtnOwnerCall.isEnabled = false
                    self.BtnOwnerCall.backgroundColor = UIColor.lightGray
                } else {
                    self.BtnOwnerCall.isEnabled = true
                    self.BtnOwnerCall.backgroundColor = constants().COLOR_LightBlue
                }
            }
            if (self.dictMarketplaceDetail.value(forKey: "user_email") as! String).isEmpty {
                self.BtnOwnerMail.isEnabled = false
                self.BtnOwnerMail.backgroundColor = UIColor.lightGray
            } else {
                self.BtnOwnerMail.isEnabled = true
                self.BtnOwnerMail.backgroundColor = constants().COLOR_LightBlue
            }

            if constants().doGetLoginStatus() == "true" {
                self.btnFavorite.isHidden = false
                if self.FavToMarket == "1" {
                    self.btnFavorite.setImage(UIImage(named: "favRed"), for: .normal)
                } else {
                    if (self.dictMarketplaceDetail.value(forKey: "is_favourite") as! String) == "0" {
                        self.btnFavorite.setImage(UIImage(named: "favWhite"), for: .normal)
                    } else {
                        self.btnFavorite.setImage(UIImage(named: "favRed"), for: .normal)
                    }
                }
            } else {
                self.btnFavorite.isHidden = true
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
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

    //MARK:- Other Methods
    func doConfigurePageControl() {
        self.myPageControl.numberOfPages = self.ArrItemImages.count
        self.myPageControl.currentPage = 0
        self.myPageControl.dotSize = CGSize(width: 15.0, height: 4.0)
        self.myPageControl.dotRadius = 2.0
        self.myPageControl.pageIndicatorTintColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        self.myPageControl.currentPageIndicatorTintColor = constants().COLOR_LightBlue
    }

    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.MainScroll.semanticContentAttribute = .forceLeftToRight
        self.AllContentView.semanticContentAttribute = .forceLeftToRight
        self.ItemView.semanticContentAttribute = .forceLeftToRight

        self.btnBack.layer.cornerRadius = 20.0
        self.btnBack.layer.masksToBounds = true

        self.btnFavorite.layer.cornerRadius = 20.0
        self.btnFavorite.layer.masksToBounds = true

        self.ItemView.layer.cornerRadius = 10.0
        self.ItemView.layer.masksToBounds = true

        self.OwnerView.layer.cornerRadius = 10.0
        self.OwnerView.layer.masksToBounds = true

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

                frame = self.btnFavorite.frame
                frame.origin.y = 35
                self.btnFavorite.frame = frame
            }
        }

        var frame  = self.AllContentView.frame
        frame.size.height = self.OwnerView.frame.origin.y + self.OwnerView.frame.size.height + 20
        self.AllContentView.frame = frame

        self.MainScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.AllContentView.frame.origin.y + self.AllContentView.frame.size.height)
    }

    func doApplyLocalisation() {
        self.ItemBrandTitle.text = NSLocalizedString("brand", comment: "")
        self.ItemColorTitle.text = NSLocalizedString("color", comment: "")
    }

    //MARK:- IBAction Methods
    @IBAction func pageControlSelectionAction(_ sender: UIPageControl) {
//        let page: Int? = sender.currentPage
    }

    @IBAction func doBack() {
        if self.FavToMarket == "1" {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "favorites") as! FavoritesScreen
            constants().APPDEL.window?.rootViewController = ivc
        } else {
            if constants().APPDEL.isMyItem == 0 {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                ivc.selectedIndex = 1
                constants().APPDEL.window?.rootViewController = ivc
            } else {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myitems") as! MyItems
                constants().APPDEL.window?.rootViewController = ivc
            }
        }
    }

    @IBAction func doFavoriteClicked() {
        if self.btnFavorite.imageView?.image == UIImage(named: "favRed") {
            self.btnFavorite.setImage(UIImage(named: "favWhite"), for: .normal)
        } else {
            self.btnFavorite.setImage(UIImage(named: "favRed"), for: .normal)
        }
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "item_id":(self.dictMarketplaceDetail.value(forKey: "found_id") as! String)], APIName: apiClass().AddFavoriteItemAPI, method: "POST") { (success, errMessage, mDict) in
        }
    }

    @IBAction func doFlagClicked() {
    }

    @IBAction func doShare() {
        let foundItemDesc = "Marketplace Item - \(self.ItemName.text!)"
        var shareItems : [Any] = [foundItemDesc]
        if self.SharableImage != nil {
            shareItems = [foundItemDesc, self.SharableImage!]
        }
        let activityViewController = UIActivityViewController(activityItems: shareItems , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func doOwnerCall() {
        constants().doCallNumber(phoneNumber: self.dictMarketplaceDetail.value(forKey: "user_mobile") as! String)
    }

    @IBAction func doOwnerMail() {
        self.screenshot()
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail() {
            mailComposeViewController.modalPresentationStyle = .fullScreen
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
        }
    }

    @IBAction func doOwnerChat() {
        constants().APPDEL.doGetQuickBloxUser(nLogin: (self.dictMarketplaceDetail.value(forKey: "user_id") as! String))
    }

    @IBAction func doOwnerPinview() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "maplocationview") as! MapLocationView
        ivc.myLocation =  (self.dictMarketplaceDetail.value(forKey: "location") as! String)
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    //MARK:- Mail Configure
    func configureMailComposer() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([(self.dictMarketplaceDetail.value(forKey: "user_email") as! String)])
        mailComposeVC.addAttachmentData(self.ScreenshotImage.jpegData(compressionQuality: 1.0)!, mimeType: "image/jpeg", fileName:  "FoundItem.jpeg")
        mailComposeVC.setSubject("Lost & Found - Marketplace Item")
        mailComposeVC.setMessageBody("Hi \(self.OwnerName.text!),\n\nI would like to inquire about this Marketplace item added by you.\n\n", isHTML: false)
        return mailComposeVC
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

    //MARK:- MFMailComposeViewController Delegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrItemImages.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: constants().SCREENSIZE.width, height: self.imgItemCollection.frame.size.height)
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
        self.myPageControl.currentPage = indexPath.row
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
