//  MemberDetailPage.swift
//  LostAndFound
//  Created by Revamp on 11/05/20.
//  Copyright © 2020 Revamp. All rights reserved.

import UIKit
import QuartzCore
import AVKit
import AVFoundation
class MemberDetailPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var imgTopImage1 : UIImageView!
    @IBOutlet weak var imgTopImage2 : UIImageView!
    @IBOutlet weak var ContentView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var lblFoundItemTitle : UILabel!
    @IBOutlet weak var lblFoundItems : UILabel!
    @IBOutlet weak var lblPointsTitle : UILabel!
    @IBOutlet weak var lblPoints : UILabel!
    @IBOutlet weak var MemberRewardsCollection : UICollectionView!
    @IBOutlet weak var MemberWinnerCollection : UICollectionView!
    @IBOutlet weak var btnRewardUsers : UIButton!
    @IBOutlet weak var btnWinner : UIButton!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnDeleteMember : UIButton!
    @IBOutlet weak var lblUsername : UILabel!

    @IBOutlet weak var CertificateView : UIView!
    @IBOutlet weak var CertificateImage : UIImageView!
    @IBOutlet weak var BtnCloseCertificate : UIButton!
    @IBOutlet weak var BtnShareCertificate : UIButton!

    @IBOutlet weak var starRatingView: SwiftyStarRatingView!
    @IBOutlet weak var btnOpenRatingList: UIButton!

    var MemberRewardRefresher : UIRefreshControl!
    var RewardRefresher : UIRefreshControl!
    var strSelectedMemberID = ""
    var ArrMemberRewards = NSMutableArray()
    var arrMemberWinnerList = NSMutableArray()

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
        self.doFetchMemberDetail()
        self.doMemberRewards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.CertificateView.isHidden = true
    }

    override var prefersStatusBarHidden: Bool {
        return true
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
        self.MemberRewardRefresher = UIRefreshControl()
        self.MemberRewardsCollection!.alwaysBounceVertical = true
        self.MemberRewardRefresher.tintColor = UIColor.white
        self.MemberRewardRefresher.addTarget(self, action: #selector(self.doFetchMemberDetail), for: .valueChanged)
        self.MemberRewardsCollection.refreshControl = self.MemberRewardRefresher

        self.RewardRefresher = UIRefreshControl()
        self.MemberWinnerCollection!.alwaysBounceVertical = true
        self.RewardRefresher.tintColor = UIColor.white
        self.RewardRefresher.addTarget(self, action: #selector(self.doFetchMemberDetail), for: .valueChanged)
        self.MemberWinnerCollection.refreshControl = self.RewardRefresher
    }

    func stopFinderRefresher() {
        self.MemberRewardsCollection!.refreshControl?.endRefreshing()
    }

    func stopRewardRefresher() {
        self.MemberWinnerCollection!.refreshControl?.endRefreshing()
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight

        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2.0
        self.imgProfile.layer.masksToBounds = true

        var frame = self.btnRewardUsers.frame
        frame.origin.x = 0
        frame.size.width = constants().SCREENSIZE.width / 2
        self.btnRewardUsers.frame = frame

        frame = self.btnWinner.frame
        frame.origin.x = self.btnRewardUsers.frame.size.width
        frame.size.width = constants().SCREENSIZE.width / 2
        self.btnWinner.frame = frame

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.ContentView.frame
                frame.origin.y = 20
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 65
                self.ContentView.frame = frame

                frame = self.imgTopImage1.frame
                frame.size.height = 280
                self.imgTopImage1.frame = frame

                frame = self.imgTopImage2.frame
                frame.size.height = 280
                self.imgTopImage2.frame = frame

                frame = self.MemberRewardsCollection.frame
                frame.origin.y = self.btnRewardUsers.frame.origin.y + self.btnRewardUsers.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.MemberRewardsCollection.frame = frame

                frame = self.MemberWinnerCollection.frame
                frame.origin.y = self.btnRewardUsers.frame.origin.y + self.btnRewardUsers.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.MemberWinnerCollection.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("memberdetail", comment: "")
        self.lblFoundItemTitle.text = NSLocalizedString("founditems", comment: "")
        self.lblPointsTitle.text = NSLocalizedString("points", comment: "")
        self.btnRewardUsers.setTitle(NSLocalizedString("rewards", comment: ""), for: .normal)
        self.btnWinner.setTitle(NSLocalizedString("winner", comment: ""), for: .normal)
    }

    @objc func doFetchMemberDetail() {
        let param: [String: Any] = ["organization_id": constants().doGetUserId(), "user_id": self.strSelectedMemberID]
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: param, APIName: apiClass().GetOrganisationMemberDetailAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                self.stopFinderRefresher()
                self.stopRewardRefresher()
                if success == true {
                    let fDict = mDict.value(forKey: "data") as! NSDictionary
                    self.imgProfile.loadProfileImage(url: (fDict.value(forKey: "image") as! String))
                    self.lblFoundItems.text = (fDict.value(forKey: "total_found_item") as? String)
                    self.lblPoints.text = (fDict.value(forKey: "total_points") as? String)
                    self.lblUsername.text = "\(fDict.value(forKey: "first_name") as! String) \(fDict.value(forKey: "last_name") as! String)"

                    if let RString = fDict.value(forKey: "user_rating") as? String {
                        if RString.isEmpty {
                            self.starRatingView.value = 0.0
                        } else {
                            self.starRatingView.value = CGFloat(Double(RString) ?? 0)
                        }
                    } else {
                        self.starRatingView.value = 0.0
                    }

                    self.arrMemberWinnerList = ((mDict.value(forKey: "data") as! NSDictionary).value(forKey: "winner") as! NSArray).mutableCopy() as! NSMutableArray
                    self.ArrMemberRewards = ((mDict.value(forKey: "data") as! NSDictionary).value(forKey: "reward") as! NSArray).mutableCopy() as! NSMutableArray
                    self.MemberRewardsCollection.reloadData()
                    self.MemberWinnerCollection.reloadData()
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    alertController.view.tintColor = constants().COLOR_LightBlue
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        self.doBack()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doDeleteMember() {
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Are you sure want to Remove this Member from your Organisation ?", preferredStyle: .alert)
        alertController.view.tintColor = constants().COLOR_LightBlue
        let okAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { (action) in
            let param: [String: Any] = ["organization_id":constants().doGetUserId(), "user_id":  self.strSelectedMemberID]
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().DeleteOrganisationMemberAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.doBack()
                    } else {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                        alertController.view.tintColor = constants().COLOR_LightBlue
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        alertController.addAction(okAction)
        let noAction = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default) { (action) in
        }
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func doMemberRewards() {
        self.MemberRewardsCollection.isHidden = false
        self.MemberWinnerCollection.isHidden = true
        self.btnRewardUsers.alpha = 1.0
        self.btnWinner.alpha = 0.5
    }

    @IBAction func doWinner() {
        self.MemberRewardsCollection.isHidden = true
        self.MemberWinnerCollection.isHidden = false
        self.btnRewardUsers.alpha = 0.5
        self.btnWinner.alpha = 1.0
    }

    @IBAction func doCloseCertificate() {
        self.CertificateView.isHidden = true
    }

    @IBAction func doShareCertificate() {
        let winnerDesc = "Certificate of Winner of the Month"
        let activityViewController = UIActivityViewController(activityItems: [self.CertificateImage!.image!, winnerDesc] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc func doClickCertificatexButton(sender: UIButton!) {
        self.CertificateView.isHidden = false
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.MemberWinnerCollection)
        let indexPath = self.MemberWinnerCollection.indexPathForItem(at: buttonPosition)
        let mDict = self.arrMemberWinnerList.object(at: indexPath!.row) as! NSDictionary
        self.CertificateImage.sd_setImage(with: URL(string: (mDict.value(forKey: "certificate") as! String)), completed: nil)
    }

    @objc func doPlayVideo(sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.MemberWinnerCollection)
        let indexPath = self.MemberWinnerCollection.indexPathForItem(at: buttonPosition)
        let mDict = self.arrMemberWinnerList.object(at: indexPath!.row) as! NSDictionary
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
        if collectionView == MemberRewardsCollection {
            return self.ArrMemberRewards.count
        } else {
            return self.arrMemberWinnerList.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == MemberRewardsCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true

            let imgIcon  = cell.viewWithTag(101) as! UIImageView
            let lblFinderName = cell.viewWithTag(102) as! UILabel
            let lblReward  = cell.viewWithTag(103) as! UILabel

            imgIcon.layer.cornerRadius = 20.0
            imgIcon.layer.masksToBounds = true
            imgIcon.contentMode = .scaleAspectFill
            imgIcon.backgroundColor = UIColor.lightGray

            let mDict = self.ArrMemberRewards.object(at: indexPath.row) as! NSDictionary
            imgIcon.sd_setImage(with: URL(string: (mDict.value(forKey: "image") as! String)), completed: nil)
            lblFinderName.text = "\(mDict.value(forKey: "first_name") as! String) \(mDict.value(forKey: "last_name") as! String)"
            lblReward.text = "$ "
            lblReward.text?.append(mDict.value(forKey: "reward") as! String)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true

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

            let mDict = self.arrMemberWinnerList.object(at: indexPath.row) as! NSDictionary

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
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == MemberRewardsCollection {
            return CGSize(width: constants().SCREENSIZE.width - 30, height: 80)
        } else {
            return CGSize(width: constants().SCREENSIZE.width - 30, height: 150)
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
    }
}
