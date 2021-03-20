//  MyItems.swift
//  LostAndFound
//  Created by Revamp on 10/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import GoogleMobileAds

class MyItems: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADInterstitialDelegate {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!

    @IBOutlet weak var OptionsView : UIView!
    @IBOutlet weak var btnLostItems : UIButton!
    @IBOutlet weak var btnFoundItems : UIButton!
    @IBOutlet weak var btnMarketPlace : UIButton!

    @IBOutlet weak var LostItemCollection : UICollectionView!
    @IBOutlet weak var FoundItemCollection : UICollectionView!
    @IBOutlet weak var MarketPlaceCollection : UICollectionView!

    @IBOutlet weak var vwNoItems : UIView!

    var LostRefresher: UIRefreshControl!
    var FoundRefresher: UIRefreshControl!
    var MarketplaceRefresher: UIRefreshControl!
    var ArrMarketPlaceList = NSMutableArray()
    var FoundItemsList = NSMutableArray()
    var LostItemList = NSMutableArray()

    var interstitial: GADInterstitial!

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.doConfigureRefreshControl()

        if constants().APPDEL.myItemSelectedSegment == 1 {
            self.doLostItems()
        } else if constants().APPDEL.myItemSelectedSegment == 2 {
            self.doFoundItems()
        } else {
            self.doMarketPlace()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.LostRefresher = UIRefreshControl()
        self.LostItemCollection!.alwaysBounceVertical = true
        self.LostRefresher.tintColor = UIColor.white
        self.LostRefresher.addTarget(self, action: #selector(self.doLostItems), for: .valueChanged)
        self.LostItemCollection.refreshControl = self.LostRefresher

        self.FoundRefresher = UIRefreshControl()
        self.FoundItemCollection!.alwaysBounceVertical = true
        self.FoundRefresher.tintColor = UIColor.white
        self.FoundRefresher.addTarget(self, action: #selector(self.doFoundItems), for: .valueChanged)
        self.FoundItemCollection.refreshControl = self.FoundRefresher

        self.MarketplaceRefresher = UIRefreshControl()
        self.MarketPlaceCollection!.alwaysBounceVertical = true
        self.MarketplaceRefresher.tintColor = UIColor.white
        self.MarketplaceRefresher.addTarget(self, action: #selector(self.doMarketPlace), for: .valueChanged)
        self.MarketPlaceCollection.refreshControl = self.MarketplaceRefresher
    }

    func stopLostRefresher() {
        self.LostItemCollection!.refreshControl?.endRefreshing()
    }

    func stopFoundRefresher() {
        self.FoundItemCollection!.refreshControl?.endRefreshing()
    }

    func stopMarketplaceRefresher() {
        self.MarketPlaceCollection!.refreshControl?.endRefreshing()
    }

    //MARK:- Other Methods
    func doSetFrames() {
        var frame = self.btnLostItems.frame
        frame.origin.x = 0
        frame.size.width = constants().SCREENSIZE.width / 3
        self.btnLostItems.frame = frame

        frame = self.btnFoundItems.frame
        frame.origin.x = self.btnLostItems.frame.size.width
        frame.size.width = constants().SCREENSIZE.width / 3
        self.btnFoundItems.frame = frame

        frame = self.btnMarketPlace.frame
        frame.origin.x = self.btnFoundItems.frame.origin.x + self.btnFoundItems.frame.size.width
        frame.size.width = constants().SCREENSIZE.width / 3
        self.btnMarketPlace.frame = frame

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

                frame = self.OptionsView.frame
                frame.origin.y = self.topView.frame.size.height
                self.OptionsView.frame = frame

                frame = self.vwNoItems.frame
                frame.origin.y = self.OptionsView.frame.origin.y + self.OptionsView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.vwNoItems.frame = frame

                frame = self.LostItemCollection.frame
                frame.origin.y = self.OptionsView.frame.origin.y + self.OptionsView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.LostItemCollection.frame = frame

                frame = self.FoundItemCollection.frame
                frame.origin.y = self.OptionsView.frame.origin.y + self.OptionsView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.FoundItemCollection.frame = frame

                frame = self.MarketPlaceCollection.frame
                frame.origin.y = self.OptionsView.frame.origin.y + self.OptionsView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.MarketPlaceCollection.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("myitems", comment: "")
        self.btnLostItems.setTitle(NSLocalizedString("lost", comment: ""), for: .normal)
        self.btnFoundItems.setTitle(NSLocalizedString("found", comment: ""), for: .normal)
        self.btnMarketPlace.setTitle(NSLocalizedString("marketplace", comment: ""), for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myprofile") as! MyProfile
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doTakeHandoverItem() {
    }

    @IBAction func doLostItems() {
        constants().APPDEL.myItemSelectedSegment = 1
        self.LostItemCollection.isHidden = false
        self.FoundItemCollection.isHidden = true
        self.MarketPlaceCollection.isHidden = true

        self.btnLostItems.alpha = 1.0
        self.btnFoundItems.alpha = 0.5
        self.btnMarketPlace.alpha = 0.5

        if constants().doGetLoginStatus() == "true" {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetUserLostItemsListAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.LostItemList = (mDict.value(forKey: "lost_item") as! NSArray).mutableCopy() as! NSMutableArray
                        if self.LostItemList.count == 0 {
                            self.vwNoItems.isHidden = false
                        } else {
                            self.vwNoItems.isHidden = true
                            self.LostItemCollection.reloadData()
                        }
                    } else {
                        self.vwNoItems.isHidden = false
                    }
                }
            }
        } else {
            constants().doLoginFirst(mControl: self)
        }
    }

    @IBAction func doFoundItems() {
        constants().APPDEL.myItemSelectedSegment = 2
        self.FoundItemCollection.reloadData()
        self.LostItemCollection.isHidden = true
        self.FoundItemCollection.isHidden = false
        self.MarketPlaceCollection.isHidden = true

        self.btnLostItems.alpha = 0.5
        self.btnFoundItems.alpha = 1.0
        self.btnMarketPlace.alpha = 0.5

        if constants().doGetLoginStatus() == "true" {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetFoundItemListAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.FoundItemsList = (mDict.value(forKey: "found_item") as! NSArray).mutableCopy() as! NSMutableArray
                        if self.FoundItemsList.count == 0 {
                            self.vwNoItems.isHidden = false
                        } else {
                            self.vwNoItems.isHidden = true
                            self.FoundItemCollection.reloadData()
                        }
                    } else {
                        self.vwNoItems.isHidden = false
                    }
                }
            }
        } else {
            constants().doLoginFirst(mControl: self)
        }
    }

    @IBAction func doMarketPlace() {
        constants().APPDEL.myItemSelectedSegment = 3
        self.MarketPlaceCollection.reloadData()
        self.LostItemCollection.isHidden = true
        self.FoundItemCollection.isHidden = true
        self.MarketPlaceCollection.isHidden = false

        self.btnLostItems.alpha = 0.5
        self.btnFoundItems.alpha = 0.5
        self.btnMarketPlace.alpha = 1.0

        if constants().doGetLoginStatus() == "true" {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetMyMarketplaceAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.ArrMarketPlaceList = (mDict.value(forKey: "marketplace_item") as! NSArray).mutableCopy() as! NSMutableArray
                        if self.ArrMarketPlaceList.count == 0 {
                            self.vwNoItems.isHidden = false
                        } else {
                            self.vwNoItems.isHidden = true
                            self.MarketPlaceCollection.reloadData()
                        }
                    } else {
                        self.vwNoItems.isHidden = false
                    }
                }
            }
        } else {
            constants().doLoginFirst(mControl: self)
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
        if collectionView == self.LostItemCollection {
            return self.LostItemList.count
        } else if collectionView == self.FoundItemCollection {
            return self.FoundItemsList.count
        } else {
            return self.ArrMarketPlaceList.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.LostItemCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 0.2
            cell.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
            cell.layer.shadowColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
            cell.layer.shadowOffset = CGSize(width: 1.5, height: 5.0)
            cell.layer.shadowOpacity = 0.7
            cell.layer.shadowRadius = 4.0

            let imgProductImage = cell.viewWithTag(101) as! UIImageView
            let lblCategory = cell.viewWithTag(102) as! UILabel
            let lblItemTitle = cell.viewWithTag(103) as! UILabel
            let lblItemAddress = cell.viewWithTag(104) as! UILabel
            let lblItemDate = cell.viewWithTag(105) as! UILabel
            let lblItemReward = cell.viewWithTag(106) as! UILabel
            let giftIcon = cell.viewWithTag(107) as! UIImageView
            let btnEdit = cell.viewWithTag(109) as! UIButton

            btnEdit.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.1)
            btnEdit.layer.cornerRadius = btnEdit.frame.size.height / 2
            btnEdit.layer.masksToBounds = true
            btnEdit.addTarget(self, action: #selector(MyItems.doEditMyLostItem(sender:)), for: .touchUpInside)

            let mDict = self.LostItemList.object(at: indexPath.row) as! NSDictionary
            let pImages = (mDict.value(forKey: "lost_images") as! NSArray).mutableCopy() as! NSMutableArray
            lblItemDate.text = (mDict.value(forKey: "lost_date") as! String)
            if pImages.count > 0 {
                imgProductImage.sd_setImage(with: URL(string: (pImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
            }
            imgProductImage.contentMode = .scaleAspectFit
            imgProductImage.backgroundColor = UIColor.white
            
            let rewardAttrString = NSMutableAttributedString(string:"Rewards Offered ", attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            rewardAttrString.append(NSMutableAttributedString(string: "$\(mDict.value(forKey: "reward") as! String)", attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_BOLD, size: 13)!, NSAttributedString.Key.foregroundColor: constants().COLOR_LightBlue]))
            lblItemReward.attributedText = rewardAttrString

            if (mDict.value(forKey: "reward") as! String).isEmpty {
                giftIcon.isHidden = true
                lblItemReward.isHidden = true
            } else {
                giftIcon.isHidden = false
                lblItemReward.isHidden = false
            }

            lblCategory.layer.cornerRadius = 12.5
            lblCategory.layer.masksToBounds = true
            lblCategory.text = (mDict.value(forKey: "category_item_name") as! String)
            if indexPath.row % 2 == 0 {
                lblCategory.backgroundColor = UIColor(red: 99.0/255.0, green: 199.0/255.0, blue: 144.0/255.0, alpha: 1.0)
            } else {
                lblCategory.backgroundColor = UIColor(red: 243.0/255.0, green: 197.0/255.0, blue: 49.0/255.0, alpha: 1.0)
            }

            lblItemTitle.text = (mDict.value(forKey: "item_name") as! String)
            lblItemAddress.text = (mDict.value(forKey: "location") as! String)

            var frame = lblCategory.frame
            let newSize = lblCategory.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height))
            frame.size.width = newSize.width + 10
            frame.size.height = 25
            lblCategory.frame = frame
            return cell
        } else if collectionView == self.FoundItemCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 0.2
            cell.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
            cell.layer.shadowColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
            cell.layer.shadowOffset = CGSize(width: 1.5, height: 5.0)
            cell.layer.shadowOpacity = 0.7
            cell.layer.shadowRadius = 4.0

            let imgProductImage = cell.viewWithTag(101) as! UIImageView
            let lblCategory = cell.viewWithTag(102) as! UILabel
            let lblItemTitle = cell.viewWithTag(103) as! UILabel
            let lblItemAddress = cell.viewWithTag(104) as! UILabel
            let lblItemDate = cell.viewWithTag(105) as! UILabel
            let lblItemReward = cell.viewWithTag(106) as! UILabel
            let giftIcon = cell.viewWithTag(107) as! UIImageView
            let btnEdit = cell.viewWithTag(109) as! UIButton

            btnEdit.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.1)
            btnEdit.layer.cornerRadius = btnEdit.frame.size.height / 2
            btnEdit.layer.masksToBounds = true
            btnEdit.addTarget(self, action: #selector(MyItems.doEditMyFoundItem(sender:)), for: .touchUpInside)

            let mDict = self.FoundItemsList.object(at: indexPath.row) as! NSDictionary
            let pImages = (mDict.value(forKey: "found_images") as! NSArray).mutableCopy() as! NSMutableArray
            lblItemDate.text = (mDict.value(forKey: "found_date") as! String)

            if pImages.count > 0 {
                imgProductImage.sd_setImage(with: URL(string: (pImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
            }
            imgProductImage.contentMode = .scaleAspectFit
            imgProductImage.backgroundColor = UIColor.white
            
            let rewardAttrString = NSMutableAttributedString(string:"Reward Expected ", attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_Medium, size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            rewardAttrString.append(NSMutableAttributedString(string: "$\(mDict.value(forKey: "expected_reward") as! String)", attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_BOLD, size: 13)!, NSAttributedString.Key.foregroundColor: constants().COLOR_LightBlue]))
            lblItemReward.attributedText = rewardAttrString

            if ((mDict.value(forKey: "expected_reward") as! String).isEmpty || (mDict.value(forKey: "expected_reward") as! String) == "0") {
                lblItemReward.isHidden = true
                giftIcon.isHidden = true
            } else {
                lblItemReward.isHidden = false
                giftIcon.isHidden = false
            }

            lblCategory.layer.cornerRadius = 12.5
            lblCategory.layer.masksToBounds = true
            lblCategory.text = (mDict.value(forKey: "category_item_name") as! String)
            if indexPath.row % 2 == 0 {
                lblCategory.backgroundColor = UIColor(red: 99.0/255.0, green: 199.0/255.0, blue: 144.0/255.0, alpha: 1.0)
            } else {
                lblCategory.backgroundColor = UIColor(red: 243.0/255.0, green: 197.0/255.0, blue: 49.0/255.0, alpha: 1.0)
            }

            lblItemTitle.text = (mDict.value(forKey: "item_name") as! String)
            lblItemAddress.text = (mDict.value(forKey: "location") as! String)

            var frame = lblCategory.frame
            let newSize = lblCategory.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.size.height))
            frame.size.width = newSize.width + 10
            frame.size.height = 25
            lblCategory.frame = frame
            return cell
        } else {
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
            if fImages.count > 0 {
                imgProductImage.sd_setImage(with: URL(string: (fImages.object(at: 0) as! NSDictionary).value(forKey: "image") as! String), completed: nil)
            }
            imgProductImage.contentMode = .scaleAspectFit
            imgProductImage.backgroundColor = UIColor.white

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
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.LostItemCollection {
            if (constants().userinterface == .pad) {
                return CGSize(width: constants().SCREENSIZE.width - 60, height: 350)
            }
            return CGSize(width: constants().SCREENSIZE.width - 30, height: 240)
        } else if collectionView == self.FoundItemCollection {
            if (constants().userinterface == .pad) {
                return CGSize(width: constants().SCREENSIZE.width - 60, height: 350)
            }
            return CGSize(width: constants().SCREENSIZE.width - 30, height: 240)
        } else {
            if (constants().userinterface == .pad) {
                return CGSize(width: constants().SCREENSIZE.width - 60, height: 220)
            }
            return CGSize(width: constants().SCREENSIZE.width - 30, height: 170)
        }
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
        constants().APPDEL.isMyItem = 1
        if collectionView == self.LostItemCollection {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "lostitemdetail") as! LostItemDetailPage
            ivc.lostItemID = (self.LostItemList.object(at: indexPath.row) as! NSDictionary).value(forKey: "lost_id") as! String
            constants().APPDEL.window?.rootViewController = ivc
        }

        if collectionView == self.FoundItemCollection {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "founditemdetail") as! FoundItemDetailPage
            ivc.SelectedFoundItemID = (self.FoundItemsList.object(at: indexPath.row) as! NSDictionary).value(forKey: "found_id") as! String
            constants().APPDEL.window?.rootViewController = ivc
        }

        if collectionView == self.MarketPlaceCollection {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "marketplacedetail") as! MarketplaceDetailPage
            ivc.FavToMarket = "0"
            ivc.dictMarketplaceDetail = self.ArrMarketPlaceList.object(at: indexPath.row) as! NSDictionary
            constants().APPDEL.window?.rootViewController = ivc
        }
    }

    //MARK:- Edit Found Item
    @objc func doEditMyFoundItem(sender: UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.FoundItemCollection)
        let indexPath = self.FoundItemCollection.indexPathForItem(at: buttonPosition)
        let alertController = UIAlertController(title: "Lost & Found", message: "", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: NSLocalizedString("editdetails", comment: ""), style: .default) { (action:UIAlertAction) in
            let mDict = self.FoundItemsList.object(at: indexPath!.row) as! NSDictionary
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.LocationitemName = ""
            constants().APPDEL.LocationItemAddress = ""
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "addfounditem") as! AddFoundItem
            ivc.DictFoundItemEdit = mDict.mutableCopy() as! NSMutableDictionary
            constants().APPDEL.window?.rootViewController = ivc
        }
        let action2 = UIAlertAction(title: NSLocalizedString("share", comment: ""), style: .default) { (action:UIAlertAction) in
            let lCell = self.FoundItemCollection.cellForItem(at: indexPath!)
            let imgProductImage = lCell!.viewWithTag(101) as! UIImageView
            let lblItemTitle = lCell!.viewWithTag(103) as! UILabel
            if imgProductImage.image != nil {
                self.doShareItem(sImage: imgProductImage.image!, sText: "Found Item - \(lblItemTitle.text!)")
            } else {
                self.doShareItem(sImage: UIImage(named: "place_holder")!, sText: "Found Item - \(lblItemTitle.text!)")
            }
        }
        let action3 = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (action:UIAlertAction) in
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
    }

    //MARK:- Edit Lost Item
    @objc func doEditMyLostItem(sender: UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.LostItemCollection)
        let indexPath = self.LostItemCollection.indexPathForItem(at: buttonPosition)
        let alertController = UIAlertController(title: "Lost & Found", message: "", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: NSLocalizedString("editdetails", comment: ""), style: .default) { (action:UIAlertAction) in
            let mDict = self.LostItemList.object(at: indexPath!.row) as! NSDictionary
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "addlostitem") as! AddLostItem
            ivc.DictLostItemEdit = mDict.mutableCopy() as! NSMutableDictionary
            constants().APPDEL.LocationitemName = ""
            constants().APPDEL.LocationItemAddress = ""
            constants().APPDEL.window?.rootViewController = ivc
        }
        let action2 = UIAlertAction(title: NSLocalizedString("share", comment: ""), style: .default) { (action:UIAlertAction) in
            let lCell = self.LostItemCollection.cellForItem(at: indexPath!)
            let imgProductImage = lCell!.viewWithTag(101) as! UIImageView
            let lblItemTitle = lCell!.viewWithTag(103) as! UILabel
            if imgProductImage.image != nil {
                self.doShareItem(sImage: imgProductImage.image!, sText: "Lost Item - \(lblItemTitle.text!)")
            } else {
                self.doShareItem(sImage: UIImage(named: "place_holder")!, sText: "Lost Item - \(lblItemTitle.text!)")
            }
        }
        let action3 = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (action:UIAlertAction) in
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
    }

    //MARK:- Share Item
    func doShareItem(sImage: UIImage, sText: String) {
        var shareItems : [Any] = [sText]
        shareItems = [sText, sImage]
        let activityViewController = UIActivityViewController(activityItems: shareItems , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    //MARK:- Full Ad Delegate
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            constants().APPDEL.isAdJustClosed = false
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
