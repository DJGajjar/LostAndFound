//  LeaderboardPage.swift
//  LostAndFound
//  Created by Revamp on 23/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import QuartzCore
import AVKit
import AVFoundation
import GoogleMobileAds
class LeaderboardPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {
    @IBOutlet weak var imgTopImage1 : UIImageView!
    @IBOutlet weak var imgTopImage2 : UIImageView!
    @IBOutlet weak var ContentView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var lblFoundItemTitle : UILabel!
    @IBOutlet weak var lblFoundItems : UILabel!
    @IBOutlet weak var lblPointsTitle : UILabel!
    @IBOutlet weak var lblPoints : UILabel!
    @IBOutlet weak var FindersCollection : UICollectionView!
    @IBOutlet weak var RewardsCollection : UICollectionView!
    @IBOutlet weak var RulesCollection : UICollectionView!
    @IBOutlet weak var btnUsers : UIButton!
    @IBOutlet weak var btnRewards : UIButton!
    @IBOutlet weak var btnRules : UIButton!

    @IBOutlet weak var adView : UIView!

    @IBOutlet weak var CertificateView : UIView!
    @IBOutlet weak var CertificateImage : UIImageView!
    @IBOutlet weak var BtnCloseCertificate : UIButton!
    @IBOutlet weak var BtnShareCertificate : UIButton!

    @IBOutlet weak var starRatingView: SwiftyStarRatingView!
    @IBOutlet weak var btnOpenRatingList: UIButton!

    @IBOutlet weak var BottomWhite : UIView!
    @IBOutlet weak var BottomCircle : UIView!

    var FinderRefresher : UIRefreshControl!
    var RewardRefresher : UIRefreshControl!

    var RulesDict = NSDictionary()
    var ArrWinnerList = NSMutableArray()
    var ArrFindersList = NSMutableArray()
    var dictUserLeaderboard = NSDictionary()

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.doConfigureRefreshControl()
        self.ConfigureCertificateGesture()
        self.doUsers()
        if constants().doGetLoginStatus() == "true" {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetMyLeaderboardAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.dictUserLeaderboard = mDict.value(forKey: "leaderboard") as! NSDictionary
                        self.lblPoints.text = (self.dictUserLeaderboard.value(forKey: "total_point") as? String)
                        self.lblFoundItems.text = (self.dictUserLeaderboard.value(forKey: "total_find_item") as? String)
                        self.imgProfile.loadProfileImage(url: (self.dictUserLeaderboard.value(forKey: "image") as! String))

                        if let RString = self.dictUserLeaderboard.value(forKey: "user_rating") as? String {
                            if RString.isEmpty {
                                self.starRatingView.value = 0.0
                            } else {
                                self.starRatingView.value = CGFloat(Double(RString) ?? 0)
                            }
                        } else {
                            self.starRatingView.value = 0.0
                        }
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
            constants().doLoginFirst(mControl: self)
        }
        self.CertificateView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.CertificateView.isHidden = true
        self.ConfigureAds()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Configure BannerAd
    func ConfigureAds() {
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "c8e57533a5d7eea436427dde6db1f4ac" ]
        let bannerView: GADBannerView! = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.delegate = self
        bannerView.frame = CGRect(x: 0, y: 0, width: self.adView.frame.size.width, height: self.adView.frame.size.height)
        bannerView.adUnitID = constants().AD_BANNER_ID
        bannerView.rootViewController = self
        self.adView.addSubview(bannerView)
        bannerView.load(GADRequest())
    }

    //MARK:- Configure Certificate Gesture
    func ConfigureCertificateGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        self.CertificateView.addGestureRecognizer(panGesture)
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.CertificateView)
        if translation.y >= 100 {
            self.doCloseCertificate()
        }
    }

    //MARK:- Configure Refresh Control
    func doConfigureRefreshControl() {
        self.FinderRefresher = UIRefreshControl()
        self.FindersCollection!.alwaysBounceVertical = true
        self.FinderRefresher.tintColor = UIColor.white
        self.FinderRefresher.addTarget(self, action: #selector(self.doUsers), for: .valueChanged)
        self.FindersCollection.refreshControl = self.FinderRefresher

        self.RewardRefresher = UIRefreshControl()
        self.RewardsCollection!.alwaysBounceVertical = true
        self.RewardRefresher.tintColor = UIColor.white
        self.RewardRefresher.addTarget(self, action: #selector(self.doRewards), for: .valueChanged)
        self.RewardsCollection.refreshControl = self.RewardRefresher
    }

    func stopFinderRefresher() {
        self.FindersCollection!.refreshControl?.endRefreshing()
    }

    func stopRewardRefresher() {
        self.RewardsCollection!.refreshControl?.endRefreshing()
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight

        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2.0
        self.imgProfile.layer.masksToBounds = true

        self.BottomCircle.layer.cornerRadius = 40.0
        self.BottomCircle.layer.masksToBounds = true

        var frame = self.btnUsers.frame
        frame.origin.x = 0
        frame.size.width = constants().SCREENSIZE.width / 3
        self.btnUsers.frame = frame

        frame = self.btnRewards.frame
        frame.origin.x = self.btnUsers.frame.size.width
        frame.size.width = constants().SCREENSIZE.width / 3
        self.btnRewards.frame = frame

        frame = self.btnRules.frame
        frame.origin.x = self.btnRewards.frame.origin.x + self.btnRewards.frame.size.width
        frame.size.width = constants().SCREENSIZE.width / 3
        self.btnRules.frame = frame

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.ContentView.frame
                frame.origin.y = 20
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 92
                self.ContentView.frame = frame

                frame = self.imgTopImage1.frame
                frame.size.height = 280
                self.imgTopImage1.frame = frame

                frame = self.imgTopImage2.frame
                frame.size.height = 280
                self.imgTopImage2.frame = frame

                frame = self.FindersCollection.frame
                frame.origin.y = self.btnUsers.frame.origin.y + self.btnUsers.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 120
                self.FindersCollection.frame = frame

                frame = self.RewardsCollection.frame
                frame.origin.y = self.btnUsers.frame.origin.y + self.btnUsers.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 120
                self.RewardsCollection.frame = frame

                frame = self.RulesCollection.frame
                frame.origin.y = self.btnUsers.frame.origin.y + self.btnUsers.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 120
                self.RulesCollection.frame = frame

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

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("leaderboard", comment: "")
        self.lblFoundItemTitle.text = NSLocalizedString("founditems", comment: "")
        self.lblPointsTitle.text = NSLocalizedString("points", comment: "")
        self.btnUsers.setTitle(NSLocalizedString("finders", comment: ""), for: .normal)
        self.btnRewards.setTitle(NSLocalizedString("rewards", comment: ""), for: .normal)
        self.btnRules.setTitle(NSLocalizedString("rules", comment: ""), for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doProfile() {
    }

    @IBAction func doUsers() {
        self.FindersCollection.isHidden = false
        self.RewardsCollection.isHidden = true
        self.RulesCollection.isHidden = true
        self.btnUsers.alpha = 1.0
        self.btnRewards.alpha = 0.5
        self.btnRules.alpha = 0.5

        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: [:], APIName: apiClass().GetAllFindersAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.ArrFindersList = (mDict.value(forKey: "finders") as! NSArray).mutableCopy() as! NSMutableArray
                    self.FindersCollection.reloadData()
                }
                self.stopFinderRefresher()
            }
        }
    }

    @IBAction func doRewards() {
        self.FindersCollection.isHidden = true
        self.RewardsCollection.isHidden = false
        self.RulesCollection.isHidden = true
        self.btnUsers.alpha = 0.5
        self.btnRewards.alpha = 1.0
        self.btnRules.alpha = 0.5

        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param:  [:], APIName: apiClass().WinnerListAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.ArrWinnerList = (mDict.value(forKey: "winner") as! NSArray).mutableCopy() as! NSMutableArray
                }
                self.RewardsCollection.reloadData()
                self.stopRewardRefresher()
            }
        }
    }

    @IBAction func doRules() {
        self.FindersCollection.isHidden = true
        self.RewardsCollection.isHidden = true
        self.RulesCollection.isHidden = false
        self.btnUsers.alpha = 0.5
        self.btnRewards.alpha = 0.5
        self.btnRules.alpha = 1.0

        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        apiClass().doNormalAPI(param: [:], APIName: apiClass().GetRulesAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.RulesDict = (mDict.value(forKey: "rules") as! NSDictionary)
                    self.RulesCollection.reloadData()
                }
            }
        }
    }

    @IBAction func doCloseCertificate() {
        self.CertificateView.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        (self.tabBarController?.view.viewWithTag(1111) as! UIButton).isHidden = false
    }

    @IBAction func doShareCertificate() {
        let winnerDesc = "Certificate of Winner of the Month"
        let activityViewController = UIActivityViewController(activityItems: [self.CertificateImage!.image!, winnerDesc] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc func doClickCertificatexButton(sender: UIButton!) {
        self.tabBarController?.tabBar.isHidden = true
        (self.tabBarController?.view.viewWithTag(1111) as! UIButton).isHidden = true
        self.CertificateView.isHidden = false
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.RewardsCollection)
        let indexPath = self.RewardsCollection.indexPathForItem(at: buttonPosition)
        let mDict = self.ArrWinnerList.object(at: indexPath!.row) as! NSDictionary
        self.CertificateImage.sd_setImage(with: URL(string: (mDict.value(forKey: "certificate") as! String)), completed: nil)
    }

    @objc func doPlayVideo(sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.RewardsCollection)
        let indexPath = self.RewardsCollection.indexPathForItem(at: buttonPosition)
        let mDict = self.ArrWinnerList.object(at: indexPath!.row) as! NSDictionary
        let sURL = (mDict.value(forKey: "video") as! String)
        self.playVideoNow(url: URL(string: sURL)!)
    }

    func playVideoNow(url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true) { vc.player?.play() }
    }

    func doContentSizeCalculate(tText: NSAttributedString) -> CGFloat {
        let mlabel = UITextView()
        mlabel.frame = CGRect(x: 10, y: 10, width: constants().SCREENSIZE.width - 50, height: 20)
        mlabel.textAlignment = .left
        mlabel.attributedText = tText
        let newSize = mlabel.sizeThatFits(CGSize(width: constants().SCREENSIZE.width - 50, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }

    //MARK:- UICollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 5)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == FindersCollection {
            return self.ArrFindersList.count
        } else if collectionView == RewardsCollection {
            return self.ArrWinnerList.count
        } else {
            if self.RulesDict.count == 0 {
                return 0
            }
            return 3
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == FindersCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true

            let mDict = self.ArrFindersList.object(at: indexPath.row) as! NSDictionary

            let imgIcon  = cell.viewWithTag(101) as! UIImageView
            let lblFinderName = cell.viewWithTag(102) as! UILabel
            let lblFinderAddress  = cell.viewWithTag(103) as! UILabel
            let lblFinderPoints  = cell.viewWithTag(104) as! UILabel
            let mRating  = cell.viewWithTag(105) as! SwiftyStarRatingView

            imgIcon.layer.cornerRadius = 20.0
            imgIcon.layer.masksToBounds = true
            imgIcon.contentMode = .scaleAspectFill
            imgIcon.backgroundColor = UIColor.lightGray
            imgIcon.sd_setImage(with: URL(string: (mDict.value(forKey: "image") as! String)), completed: nil)

            lblFinderName.text = "\(mDict.value(forKey: "first_name") as! String) \(mDict.value(forKey: "last_name") as! String)"
            lblFinderAddress.text = (mDict.value(forKey: "address1") as! String)

            let pointAttributedString = NSMutableAttributedString(string:((mDict.value(forKey: "points") as! NSDictionary).value(forKey: "total_point") as! String), attributes:[NSAttributedString.Key.font: UIFont(name: constants().FONT_BOLD, size: 18)!])
            pointAttributedString.append(NSMutableAttributedString(string: "pts", attributes: [NSAttributedString.Key.font: UIFont(name: constants().FONT_REGULAR, size: 14)!]))
            lblFinderPoints.attributedText = pointAttributedString

            if let RString = mDict.value(forKey: "user_rating") as? String {
                if RString.isEmpty {
                    mRating.value = 0.0
                } else {
                    mRating.value = CGFloat(Double(RString) ?? 0)
                }
            } else {
                mRating.value = 0.0
            }
            return cell
        } else if collectionView == RewardsCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true

            let mDict = self.ArrWinnerList.object(at: indexPath.row) as! NSDictionary

            let imgIcon  = cell.viewWithTag(101) as! UIImageView
            let lblFinderName = cell.viewWithTag(102) as! UILabel
            let lblFinderAddress  = cell.viewWithTag(103) as! UILabel
            let lblFinderPrice  = cell.viewWithTag(104) as! UILabel
            let btnCertificate  = cell.viewWithTag(106) as! UIButton
            btnCertificate.addTarget(self, action: #selector(LeaderboardPage.doClickCertificatexButton(sender:)), for: .touchUpInside)
            btnCertificate.layer.cornerRadius = 15.0
            btnCertificate.layer.masksToBounds = true

            let btnWinnerOfMonth  = cell.viewWithTag(107) as! UIButton
            btnWinnerOfMonth.layer.cornerRadius = 12.5
            btnWinnerOfMonth.layer.masksToBounds = true

            let btnPlayVideo  = cell.viewWithTag(108) as! UIButton
            btnPlayVideo.addTarget(self, action: #selector(doPlayVideo(sender:)), for: .touchUpInside)

            imgIcon.layer.cornerRadius = 10.0
            imgIcon.backgroundColor = UIColor.darkGray
            imgIcon.layer.masksToBounds = true
            imgIcon.contentMode = .scaleAspectFill

            DispatchQueue.global(qos: .userInitiated).async {
                if let thumbnailImage = constants().getVideoThumbnailImage(forUrl: URL(string: (mDict.value(forKey: "video") as! String))!) {
                    imgIcon.image = thumbnailImage
                }
            }

            lblFinderName.text = "\(mDict.value(forKey: "first_name") as! String) \(mDict.value(forKey: "last_name") as! String)"
            lblFinderAddress.text = (mDict.value(forKey: "address1") as! String)
            lblFinderPrice.text = "$ "
            lblFinderPrice.text?.append((mDict.value(forKey: "reward") as! String))

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true

            let RuleIcon  = cell.viewWithTag(101) as! UIImageView
            let RuleTitle  = cell.viewWithTag(102) as! UILabel
            let txtRuleDesc  = cell.viewWithTag(103) as! UITextView

            switch indexPath.row {
            case 0:
                RuleIcon.image = UIImage(named: "NotesPurpleIcon")
                RuleTitle.attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "rules_title") as! String)
                txtRuleDesc.attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "rules_description") as! String)
                break
            case 1:
                RuleIcon.image = UIImage(named: "qualificationIcon")
                RuleTitle.attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "qualification_title") as! String)
                txtRuleDesc.attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "qualification_description") as! String)
                break
            case 2:
                RuleIcon.image = UIImage(named: "price_Icon")
                RuleTitle.attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "winners_title") as! String)
                txtRuleDesc.attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "winners_description") as! String)
                break
            default:
                break
            }

            txtRuleDesc.semanticContentAttribute = .forceLeftToRight
            txtRuleDesc.textAlignment = .left

            let newSize = txtRuleDesc.sizeThatFits(CGSize(width: constants().SCREENSIZE.width - 50, height: CGFloat.greatestFiniteMagnitude))
            var frame = txtRuleDesc.frame
            frame.size = newSize
            txtRuleDesc.frame = frame

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == FindersCollection {
            return CGSize(width: constants().SCREENSIZE.width - 30, height: 80)
        } else if collectionView == RewardsCollection {
            return CGSize(width: constants().SCREENSIZE.width - 30, height: 150)
        } else {
            let attFont = [NSAttributedString.Key.font : UIFont(name: constants().FONT_REGULAR, size: 14)]
            var attributedText = NSAttributedString(string: "")

            switch indexPath.row {
            case 0:
                attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "rules_description") as! String, attributes: attFont as [NSAttributedString.Key : Any])
                break
            case 1:
                attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "qualification_description") as! String, attributes: attFont as [NSAttributedString.Key : Any])
                break
            case 2:
                attributedText = NSAttributedString(string: self.RulesDict.value(forKey: "winners_description") as! String, attributes: attFont as [NSAttributedString.Key : Any])
                break
            default:
                break
            }
            return CGSize(width: constants().SCREENSIZE.width - 30, height: self.doContentSizeCalculate(tText: attributedText) + 55)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == FindersCollection {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "leaderboardstats") as! LeaderboardStats
            ivc.finderID = (self.ArrFindersList.object(at: indexPath.row) as! NSDictionary).value(forKey: "user_id") as! String
            ivc.modalPresentationStyle = .fullScreen
            self.present(ivc, animated: true, completion: nil)
        } else if collectionView == RewardsCollection {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "leaderboardstats") as! LeaderboardStats
            ivc.finderID = (self.ArrWinnerList.object(at: indexPath.row) as! NSDictionary).value(forKey: "user_id") as! String
            ivc.modalPresentationStyle = .fullScreen
            self.present(ivc, animated: true, completion: nil)
        }
    }

    //MARK:- Admob Delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
            print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
