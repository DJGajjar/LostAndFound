//  MarketPlaceList.swift
//  LostAndFound
//  Created by Revamp on 23/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import SDWebImage
import GoogleMobileAds

class MarketPlaceList: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADInterstitialDelegate {
    @IBOutlet weak var vwTopView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var myCollection : UICollectionView!
    @IBOutlet weak var vwNoItems : UIView!
    @IBOutlet weak var btnSearch : UIButton!

    @IBOutlet weak var BottomWhite : UIView!
    @IBOutlet weak var BottomCircle : UIView!

    var MarketplaceRefresher : UIRefreshControl!
    var interstitial : GADInterstitial!
    var ArrMarketPlaceList = NSMutableArray()

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        self.myCollection.reloadData()
        self.doConfigureRefreshControl()
        self.doSetFrames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doLoadMarketplaceListing()
        self.doConfigureFullAd()
    }

    override var prefersStatusBarHidden: Bool {
        return true
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

    //MARK:- Configure Refresh Control
    func doConfigureRefreshControl() {
        self.MarketplaceRefresher = UIRefreshControl()
        self.myCollection!.alwaysBounceVertical = true
        self.MarketplaceRefresher.tintColor = UIColor.white
        self.MarketplaceRefresher.addTarget(self, action: #selector(self.doLoadMarketplaceListing), for: .valueChanged)
        self.myCollection.refreshControl = self.MarketplaceRefresher
    }

    func stopRefresher() {
        self.myCollection!.refreshControl?.endRefreshing()
    }

    //MARK:- Fetch Records
    @objc func doLoadMarketplaceListing() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetAllMarketPlaceItemAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.ArrMarketPlaceList = (mDict.value(forKey: "marketplace_item") as! NSArray).mutableCopy() as! NSMutableArray
                    if self.ArrMarketPlaceList.count == 0 {
                        self.vwNoItems.isHidden = false
                    } else {
                        self.vwNoItems.isHidden = true
                    }
                } else {
                    self.vwNoItems.isHidden = false
                }
                self.stopRefresher()
                self.myCollection.reloadData()
            }
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.lblTitle.text = NSLocalizedString("marketplace", comment: "")

        self.BottomCircle.layer.cornerRadius = 40.0
        self.BottomCircle.layer.masksToBounds = true

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.vwTopView.frame
                frame.size.height = 80
                self.vwTopView.frame = frame

                frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.btnSearch.frame
                frame.origin.y = 40
                self.btnSearch.frame = frame

                frame = self.myCollection.frame
                frame.origin.y = self.vwTopView.frame.origin.y + self.vwTopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.myCollection.frame = frame

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

    @objc func doClickFavoriteButton(sender: UIButton!) {
        if sender.imageView?.image == UIImage(named: "favRed") {
            sender.setImage(UIImage(named: "favWhite"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "favRed"), for: .normal)
        }
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.myCollection)
        let indexPath = self.myCollection.indexPathForItem(at: buttonPosition)
        let mDict = self.ArrMarketPlaceList.object(at: indexPath!.row) as! NSDictionary
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "item_id":(mDict.value(forKey: "found_id") as! String)], APIName: apiClass().AddFavoriteItemAPI, method: "POST") { (success, errMessage, mDict) in
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doSearch() {
        constants().APPDEL.strOptionSearch = "Marketplace"
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "searchpage") as! SearchPage
        constants().APPDEL.window?.rootViewController = ivc
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 5)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrMarketPlaceList.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
        cell.layer.shadowColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
        cell.layer.shadowOffset = CGSize(width: 1.5, height: 5.0)
        cell.layer.shadowOpacity = 0.7
        cell.layer.shadowRadius = 4.0

        let mDict = self.ArrMarketPlaceList.object(at: indexPath.row) as! NSDictionary
        let fImages = (mDict.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray

        let imgProductImage = cell.viewWithTag(101) as! UIImageView
        imgProductImage.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        imgProductImage.contentMode = .scaleAspectFill
        if fImages.count > 0 {
            imgProductImage.sd_imageTransition = .fade
            imgProductImage.sd_setImage(with: URL(string: (fImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
        }
        imgProductImage.contentMode = .scaleAspectFit
        imgProductImage.backgroundColor = UIColor.white

        let btnFavorite = cell.viewWithTag(103) as! UIButton
        btnFavorite.layer.cornerRadius = 20.0
        btnFavorite.layer.masksToBounds = true
        btnFavorite.addTarget(self, action: #selector(MarketPlaceList.doClickFavoriteButton(sender:)), for: .touchUpInside)
        if constants().doGetLoginStatus() == "true" {
            btnFavorite.isHidden = false
            if (mDict.value(forKey: "is_favourite") as! String) == "0" {
                btnFavorite.setImage(UIImage(named: "favWhite"), for: .normal)
            } else {
                btnFavorite.setImage(UIImage(named: "favRed"), for: .normal)
            }
        } else {
            btnFavorite.isHidden = true
        }

        let lblCategory = cell.viewWithTag(102) as! UILabel
        lblCategory.layer.cornerRadius = 12.5
        lblCategory.layer.masksToBounds = true
        if indexPath.row % 2 == 0 {
            lblCategory.backgroundColor = UIColor(red: 99.0/255.0, green: 199.0/255.0, blue: 144.0/255.0, alpha: 1.0)
        } else {
            lblCategory.backgroundColor = UIColor(red: 243.0/255.0, green: 197.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        }

        lblCategory.text = (mDict.value(forKey: "category_item_name") as! String)

        var frame = lblCategory.frame
        let newSize = lblCategory.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height))
        frame.size.width = newSize.width + 10
        frame.size.height = 25
        lblCategory.frame = frame

        let lblItemName = cell.viewWithTag(104) as! UILabel
        let lblItemPrices = cell.viewWithTag(105) as! UILabel

        lblItemName.text = (mDict.value(forKey: "item_name") as! String)
        lblItemPrices.text = "$\(mDict.value(forKey: "expected_reward") as! String)"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (constants().userinterface == .pad) {
            return CGSize(width: constants().SCREENSIZE.width - 60, height: 220)
        }
        return CGSize(width: constants().SCREENSIZE.width - 30, height: 170)
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
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "marketplacedetail") as! MarketplaceDetailPage
        ivc.FavToMarket = "0"
        constants().APPDEL.isMyItem = 0
        ivc.dictMarketplaceDetail = self.ArrMarketPlaceList.object(at: indexPath.row) as! NSDictionary
        constants().APPDEL.window?.rootViewController = ivc
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
}
