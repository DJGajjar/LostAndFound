//  RelatedProducts.swift
//  LostAndFound
//  Created by Revamp on 10/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class RelatedProducts: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var Mycollection : UICollectionView!
    @IBOutlet weak var vwNoItems : UIView!
    @IBOutlet weak var lblNoItems : UILabel!
    @IBOutlet weak var lblLooksNoItems : UILabel!
    var strItemName = ""
    var ListRefresher : UIRefreshControl!
    var FoundItemsList = NSMutableArray()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.doConfigureRefreshControl()
        self.doFetchItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func doFetchItems() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "item_name":self.strItemName], APIName: apiClass().RelatedProductAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.FoundItemsList = (mDict.value(forKey: "related_item") as! NSArray).mutableCopy() as! NSMutableArray
                    if self.FoundItemsList.count == 0 {
                        self.vwNoItems.isHidden = false
                    } else {
                        self.vwNoItems.isHidden = true
                    }
                } else {
                    self.vwNoItems.isHidden = false
                }
                self.Mycollection.reloadData()
                self.stopRefresher()
            }
        }
    }

    //MARK:- Configure Refresh Control
    func doConfigureRefreshControl() {
        self.ListRefresher = UIRefreshControl()
        self.Mycollection!.alwaysBounceVertical = true
        self.ListRefresher.tintColor = UIColor.white
        self.ListRefresher.addTarget(self, action: #selector(self.doFetchItems), for: .valueChanged)
        self.Mycollection.refreshControl = self.ListRefresher
    }

    func stopRefresher() {
        self.Mycollection!.refreshControl?.endRefreshing()
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

                frame = self.btnClose.frame
                frame.origin.y = 40
                self.btnClose.frame = frame

                frame = self.Mycollection.frame
                frame.origin.y = self.topView.frame.size.height
                self.Mycollection.frame = frame

                frame = self.vwNoItems.frame
                frame.origin.y = self.topView.frame.size.height
                self.vwNoItems.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("relatedproducts", comment: "")
        self.lblNoItems.text = NSLocalizedString("noitemsyet", comment: "")
        self.lblLooksNoItems.text = NSLocalizedString("looksnoitems", comment: "")
    }

    //MARK:- IBAction Methods
    @IBAction func doClose() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
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
        return self.FoundItemsList.count
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
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (constants().userinterface == .pad) {
            return CGSize(width: constants().SCREENSIZE.width - 60, height: 240)
        }
        return CGSize(width: constants().SCREENSIZE.width - 30, height: 240)
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
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "founditemdetail") as! FoundItemDetailPage
        ivc.SelectedFoundItemID = (self.FoundItemsList.object(at: indexPath.row) as! NSDictionary).value(forKey: "found_id") as! String
        constants().APPDEL.window?.rootViewController = ivc
    }
}
