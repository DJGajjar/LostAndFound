//  NotificationsPage.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class NotificationsPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var mycollection : UICollectionView!
    @IBOutlet weak var vwNoNotifications : UIView!
    var ListRefresher : UIRefreshControl!
    var ArrNotiticationsList = NSMutableArray()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        self.doSetFrames()
        self.doConfigureRefreshControl()

        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        self.doFetchNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Configure Refresh Control
    func doConfigureRefreshControl() {
        self.ListRefresher = UIRefreshControl()
        self.mycollection!.alwaysBounceVertical = true
        self.ListRefresher.tintColor = UIColor.white
        self.ListRefresher.addTarget(self, action: #selector(self.doFetchNotifications), for: .valueChanged)
        self.mycollection.refreshControl = self.ListRefresher
    }

    func stopRefresher() {
        self.mycollection!.refreshControl?.endRefreshing()
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.lblTitle.text = NSLocalizedString("notifications", comment: "")
        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.topView.frame
                frame.size.height = 80
                self.topView.frame = frame

                frame = self.btnBack.frame
                frame.origin.y = 40
                self.btnBack.frame = frame

                frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.mycollection.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.mycollection.frame = frame

                frame = self.vwNoNotifications.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.vwNoNotifications.frame = frame
            }
        }
    }

    @objc func doFetchNotifications() {
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetUserNotificationAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.ArrNotiticationsList = (mDict.value(forKey: "notification") as! NSArray).mutableCopy() as! NSMutableArray
                    self.mycollection.reloadData()
                    self.vwNoNotifications.isHidden = true
                    self.doResetNotificationsList()
                } else {
                    self.vwNoNotifications.isHidden = false
                }
                self.stopRefresher()
            }
        }
    }

    func doResetNotificationsList() {
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().ResetNotificationAPI, method: "POST") { (success, errMessage, mDict) in
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK:- UICollectionview Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 5)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrNotiticationsList.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 15.0

        let ImgIcon = cell.viewWithTag(101) as! UIImageView
        let lblNotificationTitle = cell.viewWithTag(102) as! UITextView
        let lblDate = cell.viewWithTag(103) as! UILabel
        let IconView = cell.viewWithTag(104)
        IconView!.layer.cornerRadius = IconView!.frame.size.width / 2
        IconView!.layer.masksToBounds = true

        let mDict = self.ArrNotiticationsList.object(at: indexPath.row) as! NSDictionary

        IconView!.backgroundColor = constants().NotificationTypeColor(nType: (mDict.value(forKey: "type") as! String))
        ImgIcon.image = constants().NotificationTypeIcon(nType: (mDict.value(forKey: "type") as! String))
        lblDate.text = (mDict.value(forKey: "created_at") as! String)

        lblNotificationTitle.text = (mDict.value(forKey: "notification") as! String)
        let newSize = lblNotificationTitle.sizeThatFits(CGSize(width: constants().SCREENSIZE.width - 115, height: CGFloat.greatestFiniteMagnitude))
        var frame = lblNotificationTitle.frame
        frame.size.width = constants().SCREENSIZE.width - 115
        frame.size.height = max(newSize.height, 30)
        lblNotificationTitle.frame = frame

        frame = lblDate.frame
        frame.origin.y = lblNotificationTitle.frame.origin.y + lblNotificationTitle.frame.size.height + 5
        lblDate.frame = frame
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mSize = constants().SCREENSIZE.width-40
        let mDict = self.ArrNotiticationsList.object(at: indexPath.row) as! NSDictionary
        return CGSize(width: mSize, height: labelHeight(mString: mDict.value(forKey: "notification") as! String) + 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    //MARK:- Dynamic Label Height
    func labelHeight(mString: String) -> CGFloat {
        let mlabel = UITextView()
        mlabel.frame = CGRect(x: 0, y: 0, width: constants().SCREENSIZE.width - 115, height: 10)
        mlabel.font = UIFont(name: constants().FONT_REGULAR, size: 17)
        mlabel.textAlignment = .left
        mlabel.text = mString
        let newSize = mlabel.sizeThatFits(CGSize(width: constants().SCREENSIZE.width - 115, height: CGFloat.greatestFiniteMagnitude))
        return max(newSize.height, 30)
    }
}
