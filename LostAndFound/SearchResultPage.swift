//  SearchResultPage.swift
//  LostAndFound
//  Created by Revamp on 25/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import GoogleMobileAds
class SearchResultPage: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADInterstitialDelegate {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var mySegment : UISegmentedControl!
    @IBOutlet weak var LostCollection : UICollectionView!
    @IBOutlet weak var FoundCollection : UICollectionView!
    @IBOutlet weak var MarketplaceCollection : UICollectionView!
    @IBOutlet weak var vwNoItems : UIView!
    @IBOutlet weak var lblNoItems : UILabel!
    @IBOutlet weak var lblLooksNoItems : UILabel!

    var LostRefresher: UIRefreshControl!
    var FoundRefresher: UIRefreshControl!
    var MarketplaceRefresher: UIRefreshControl!
    var ArrMarketPlaceList = NSMutableArray()
    var FoundItemsList = NSMutableArray()
    var LostItemList = NSMutableArray()

    var interstitial: GADInterstitial!

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
            self.mySegment.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
            self.mySegment.layer.borderColor = constants().COLOR_LightBlue.cgColor
            self.mySegment.layer.borderWidth = 1.0
            self.mySegment.layer.masksToBounds = true
            self.mySegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            self.mySegment.selectedSegmentTintColor = constants().COLOR_LightBlue
        } else {
            self.mySegment.backgroundColor = UIColor.white
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.doConfigureRefreshControl()
        self.doSearchProcess()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doConfigureFullAd()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Configure Refresh Control
    func doConfigureRefreshControl() {
        self.LostRefresher = UIRefreshControl()
        self.LostCollection!.alwaysBounceVertical = true
        self.LostRefresher.tintColor = UIColor.white
        self.LostRefresher.addTarget(self, action: #selector(self.doLostSearchProcess), for: .valueChanged)
        self.LostCollection.refreshControl = self.LostRefresher

        self.FoundRefresher = UIRefreshControl()
        self.FoundCollection!.alwaysBounceVertical = true
        self.FoundRefresher.tintColor = UIColor.white
        self.FoundRefresher.addTarget(self, action: #selector(self.doFoundSearchProcess), for: .valueChanged)
        self.FoundCollection.refreshControl = self.FoundRefresher
 
        self.MarketplaceRefresher = UIRefreshControl()
        self.MarketplaceCollection!.alwaysBounceVertical = true
        self.MarketplaceRefresher.tintColor = UIColor.white
        self.MarketplaceRefresher.addTarget(self, action: #selector(self.doMarketplaceSearchProcess), for: .valueChanged)
        self.MarketplaceCollection.refreshControl = self.MarketplaceRefresher
    }

    func stopLostRefresher() {
        self.LostCollection!.refreshControl?.endRefreshing()
    }

    func stopFoundRefresher() {
        self.FoundCollection!.refreshControl?.endRefreshing()
    }

    func stopMarketplaceRefresher() {
        self.MarketplaceCollection!.refreshControl?.endRefreshing()
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

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight

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

                frame = self.mySegment.frame
                frame.origin.y = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height + 5
                self.mySegment.frame = frame

                frame = self.LostCollection.frame
                frame.origin.y = self.mySegment.frame.origin.y + self.mySegment.frame.size.height
                self.LostCollection.frame = frame

                frame = self.FoundCollection.frame
                frame.origin.y = self.mySegment.frame.origin.y + self.mySegment.frame.size.height
                self.FoundCollection.frame = frame

                frame = self.MarketplaceCollection.frame
                frame.origin.y = self.mySegment.frame.origin.y + self.mySegment.frame.size.height
                self.MarketplaceCollection.frame = frame

                frame = self.vwNoItems.frame
                frame.origin.y = self.mySegment.frame.origin.y + self.mySegment.frame.size.height
                self.vwNoItems.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("searchresult", comment: "")
        self.lblNoItems.text = NSLocalizedString("noitemsfound", comment: "")
        self.lblLooksNoItems.text = NSLocalizedString("looksnoitemsfound", comment: "")
    }

    @objc func doSearchProcess() {
        switch constants().APPDEL.strOptionSearch {
        case "Lost":
            self.mySegment.selectedSegmentIndex = 0
            self.doLostSearchProcess()
            break
        case "Found":
            self.mySegment.selectedSegmentIndex = 1
            self.doFoundSearchProcess()
            break
        case "Marketplace":
            self.mySegment.selectedSegmentIndex = 2
            self.doMarketplaceSearchProcess()
            break
        default:
            break
        }
    }

    @objc func doLostSearchProcess() {
        self.LostCollection.isHidden = false
        self.FoundCollection.isHidden = true
        self.MarketplaceCollection.isHidden = true
        self.vwNoItems.isHidden = true
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        self.LostItemList.removeAllObjects()
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["search":constants().APPDEL.strSearchText], APIName: apiClass().SearchLostItemAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.LostItemList = (mDict.value(forKey: "search_item") as! NSArray).mutableCopy() as! NSMutableArray
                    if self.LostItemList.count == 0 {
                        self.vwNoItems.isHidden = false
                    }
                } else {
                    self.vwNoItems.isHidden = false
                }
                self.LostCollection.reloadData()
                self.stopLostRefresher()
            }
        }
    }

    @objc func doFoundSearchProcess() {
        self.LostCollection.isHidden = true
        self.FoundCollection.isHidden = false
        self.MarketplaceCollection.isHidden = true
        self.vwNoItems.isHidden = true
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["search":constants().APPDEL.strSearchText], APIName: apiClass().SearchFoundItemAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.FoundItemsList = (mDict.value(forKey: "search_item") as! NSArray).mutableCopy() as! NSMutableArray
                    if self.FoundItemsList.count == 0 {
                        self.vwNoItems.isHidden = false
                    }
                } else {
                    self.vwNoItems.isHidden = false
                }
                self.FoundCollection.reloadData()
                self.stopFoundRefresher()
            }
        }
    }

    @objc func doMarketplaceSearchProcess() {
        self.LostCollection.isHidden = true
        self.FoundCollection.isHidden = true
        self.MarketplaceCollection.isHidden = false
        self.vwNoItems.isHidden = true
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["search":constants().APPDEL.strSearchText], APIName: apiClass().SearchMarketPlaceItemAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.ArrMarketPlaceList = (mDict.value(forKey: "marketplace_item") as! NSArray).mutableCopy() as! NSMutableArray
                    if self.ArrMarketPlaceList.count == 0 {
                        self.vwNoItems.isHidden = false
                    }
                } else {
                    self.vwNoItems.isHidden = false
                }
                self.MarketplaceCollection.reloadData()
                self.stopMarketplaceRefresher()
            }
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doSegmentSelected() {
        switch self.mySegment.selectedSegmentIndex {
        case 0:
            self.doLostSearchProcess()
            break
        case 1:
            self.doFoundSearchProcess()
            break
        case 2:
            self.doMarketplaceSearchProcess()
            break
        default:
            break
        }
    }

    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "searchpage") as! SearchPage
        constants().APPDEL.window?.rootViewController = ivc
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let objHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "searchTitleHeader", for: indexPath) as? searchTitleHeader {
            objHeader.sectionHeaderTitle.font = UIFont(name: constants().FONT_Medium, size: 18)
            objHeader.sectionHeaderTitle.text = "Search Result having \"\(constants().APPDEL.strSearchText)\""
            return objHeader
        }
        return UICollectionReusableView()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.LostCollection {
            return self.LostItemList.count
        } else if collectionView == self.FoundCollection {
            return self.FoundItemsList.count
        } else {
            return self.ArrMarketPlaceList.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.LostCollection {
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
        } else if collectionView == self.FoundCollection {
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

            let btnFavorite = cell.viewWithTag(103) as! UIButton
            btnFavorite.layer.cornerRadius = 20.0
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
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.LostCollection {
            if (constants().userinterface == .pad) {
                return CGSize(width: constants().SCREENSIZE.width - 60, height: 350)
            }
            return CGSize(width: constants().SCREENSIZE.width - 30, height: 240)
        } else if collectionView == self.FoundCollection {
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
        if collectionView == self.LostCollection {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "lostitemdetail") as! LostItemDetailPage
            ivc.lostItemID = (self.LostItemList.object(at: indexPath.row) as! NSDictionary).value(forKey: "lost_id") as! String
            constants().APPDEL.window?.rootViewController = ivc
        } else if collectionView == self.FoundCollection {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "founditemdetail") as! FoundItemDetailPage
            ivc.SelectedFoundItemID = (self.FoundItemsList.object(at: indexPath.row) as! NSDictionary).value(forKey: "found_id") as! String
            constants().APPDEL.window?.rootViewController = ivc
        } else {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "marketplacedetail") as! MarketplaceDetailPage
            ivc.dictMarketplaceDetail = self.ArrMarketPlaceList.object(at: indexPath.row) as! NSDictionary
            constants().APPDEL.window?.rootViewController = ivc
        }
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
