//  FavoritesScreen.swift
//  LostAndFound
//  Created by Revamp on 07/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class FavoritesScreen: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var myCollection : UICollectionView!
    @IBOutlet weak var vwNoItems : UIView!
    @IBOutlet weak var lblNoItemsyet : UILabel!
    @IBOutlet weak var lblLooksNoItems : UILabel!
    var ListRefresher : UIRefreshControl!
    var ArrFavoriteItemsList = NSMutableArray()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doConfigureRefreshControl()
        self.doSetFrames()
        self.doLoadFavoriteItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func doLoadFavoriteItems() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }

        self.ArrFavoriteItemsList.removeAllObjects()
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetMyFavoriteItemAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.ArrFavoriteItemsList = (mDict.value(forKey: "my_favorite_item") as! NSArray).mutableCopy() as! NSMutableArray
                    self.myCollection.reloadData()
                    if (self.ArrFavoriteItemsList.count == 0) {
                        self.vwNoItems.isHidden = false
                    } else {
                        self.vwNoItems.isHidden = true
                    }
                } else {
                    self.vwNoItems.isHidden = false
                }
                self.stopRefresher()
            }
        }
    }

    //MARK:- Configure Refresh Control
    func doConfigureRefreshControl() {
        self.ListRefresher = UIRefreshControl()
        self.myCollection!.alwaysBounceVertical = true
        self.ListRefresher.tintColor = UIColor.white
        self.ListRefresher.addTarget(self, action: #selector(self.doLoadFavoriteItems), for: .valueChanged)
        self.myCollection.refreshControl = self.ListRefresher
    }

    func stopRefresher() {
        self.myCollection!.refreshControl?.endRefreshing()
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

                frame = self.myCollection.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.myCollection.frame = frame

                frame = self.vwNoItems.frame
                frame.origin.y = self.topView.frame.origin.y + self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.vwNoItems.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("favorites", comment: "")
        self.lblNoItemsyet.text = NSLocalizedString("noitemsfavorites", comment: "")
        self.lblLooksNoItems.text = NSLocalizedString("looksnoitemsfavorites", comment: "")
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myprofile") as! MyProfile
        constants().APPDEL.window?.rootViewController = ivc
    }

    @objc func doClickFavoriteButton(sender: UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.myCollection)
        let indexPath = self.myCollection.indexPathForItem(at: buttonPosition)
        let mDict = self.ArrFavoriteItemsList.object(at: indexPath!.row) as! NSDictionary
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "item_id":(mDict.value(forKey: "found_id") as! String)], APIName: apiClass().AddFavoriteItemAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                self.doLoadFavoriteItems()
            }
        }
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 5)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrFavoriteItemsList.count
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

        let mDict = self.ArrFavoriteItemsList.object(at: indexPath.row) as! NSDictionary
        let fImages = (mDict.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray

        let imgProductImage = cell.viewWithTag(101) as! UIImageView
        if fImages.count > 0 {
            imgProductImage.sd_setImage(with: URL(string: (fImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
        }
        imgProductImage.contentMode = .scaleAspectFit
        imgProductImage.backgroundColor = UIColor.white

        let btnFavorite = cell.viewWithTag(103) as! UIButton
        btnFavorite.layer.cornerRadius = 20.0
        btnFavorite.addTarget(self, action: #selector(FavoritesScreen.doClickFavoriteButton(sender:)), for: .touchUpInside)
        btnFavorite.setImage(UIImage(named: "favRed"), for: .normal)

        let lblCategory = cell.viewWithTag(102) as! UILabel
        lblCategory.layer.cornerRadius = 12.5
        lblCategory.layer.masksToBounds = true
        if indexPath.row % 2 == 0 {
            lblCategory.backgroundColor = UIColor(red: 99.0/255.0, green: 199.0/255.0, blue: 144.0/255.0, alpha: 1.0)
        } else {
            lblCategory.backgroundColor = UIColor(red: 243.0/255.0, green: 197.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        }

        lblCategory.text = (mDict.value(forKey: "category_item_name") as! String)
        lblCategory.sizeToFit()
        lblCategory.numberOfLines = 0
        lblCategory.textAlignment = .center
        var frame = lblCategory.frame
        frame.size.width = frame.size.width + 10
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
            return CGSize(width: constants().SCREENSIZE.width - 60, height: 170)
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
        ivc.FavToMarket = "1"
        ivc.dictMarketplaceDetail = self.ArrFavoriteItemsList.object(at: indexPath.row) as! NSDictionary
        constants().APPDEL.window?.rootViewController = ivc
    }
}
