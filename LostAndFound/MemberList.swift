//  MemberList.swift
//  LostAndFound
//  Created by Revamp on 09/05/20.
//  Copyright © 2020 Revamp. All rights reserved.

import UIKit
class MemberList: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnAddNewMember : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var MemberCollection : UICollectionView!
    @IBOutlet weak var vwNoMembers : UIView!
    var ListRefresher : UIRefreshControl!
    var ArrMemberList = NSMutableArray()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.doConfigureRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doFetchData()
    }

    override var prefersStatusBarHidden: Bool {
        return true
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

                frame = self.btnAddNewMember.frame
                frame.origin.y = 42
                self.btnAddNewMember.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("memberlist", comment: "")
    }

    @objc func doFetchData() {
        let param: [String: Any] = ["organization_id": constants().doGetUserId()]
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: param, APIName: apiClass().GetOrganisationInvitationAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                self.ArrMemberList.removeAllObjects()
                if success == true {
                    self.ArrMemberList = (mDict.value(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray
                    if self.ArrMemberList.count > 0 {
                        self.vwNoMembers.isHidden = true
                    } else {
                        self.vwNoMembers.isHidden = false
                    }
                } else {
                    self.vwNoMembers.isHidden = false
                }
                self.MemberCollection.reloadData()
                self.stopRefresher()
            }
        }
    }

    //MARK:- Configure Refresh Control
    func doConfigureRefreshControl() {
        self.ListRefresher = UIRefreshControl()
        self.MemberCollection!.alwaysBounceVertical = true
        self.ListRefresher.tintColor = UIColor.white
        self.ListRefresher.addTarget(self, action: #selector(self.doFetchData), for: .valueChanged)
        self.MemberCollection.refreshControl = self.ListRefresher
    }

    func stopRefresher() {
        self.MemberCollection!.refreshControl?.endRefreshing()
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doAddNewMember() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "addnewmember") as! AddNewMember
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: false, completion: nil)
    }

    @objc func doCancelInvitation(_ button: UIButton) {
        let buttonPosition:CGPoint = button.convert(CGPoint.zero, to: self.MemberCollection)
        let indexPath = self.MemberCollection.indexPathForItem(at: buttonPosition)
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Are you sure want to cancel Invitation ?", preferredStyle: .alert)
        alertController.view.tintColor = constants().COLOR_LightBlue
        let okAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { (action) in
            let param: [String: Any] = ["invite_id": (self.ArrMemberList.object(at: indexPath!.row) as! NSDictionary).value(forKey: "invite_id") as! String]
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().CancelOrganisationInvitationAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.doFetchData()
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

    @objc func doResendInvitation(_ button: UIButton) {
        let buttonPosition:CGPoint = button.convert(CGPoint.zero, to: self.MemberCollection)
        let indexPath = self.MemberCollection.indexPathForItem(at: buttonPosition)
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Are you sure want to Resend Invitation ?", preferredStyle: .alert)
        alertController.view.tintColor = constants().COLOR_LightBlue
        let okAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default) { (action) in
            let param: [String: Any] = ["organization_id":constants().doGetUserId(), "invite_id": (self.ArrMemberList.object(at: indexPath!.row) as! NSDictionary).value(forKey: "invite_id") as! String]
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: param, APIName: apiClass().ResendOrganisationInvitationAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("passwordchanged", comment: ""), preferredStyle: .alert)
                            
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                                                                       
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                        self.doFetchData()
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

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: constants().SCREENSIZE.width, height: 0)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrMemberList.count
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 10.0
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
        cell.layer.masksToBounds = true

        let imgPic = cell.viewWithTag(101) as! UIImageView
        let lblMemberName  = cell.viewWithTag(102) as! UILabel
        let btnStatus = cell.viewWithTag(103) as! UIButton
        let btnResend = cell.viewWithTag(104) as! UIButton

        imgPic.layer.cornerRadius = 25.0
        imgPic.layer.masksToBounds = true
        imgPic.contentMode = .scaleAspectFill
        imgPic.backgroundColor = UIColor.lightGray

        btnResend.layer.cornerRadius = 15.0
        btnResend.layer.masksToBounds = true

        let mDict = self.ArrMemberList.object(at: indexPath.row) as! NSDictionary
        lblMemberName.text = (mDict.value(forKey: "first_name") as! String) + " " + (mDict.value(forKey: "last_name") as! String)
        imgPic.sd_setImage(with: URL(string: (mDict.value(forKey: "image") as! String)), completed: nil)

        switch (mDict.value(forKey: "status") as! String) {
        case constants().MEMBER_INVITATION_STATUS_ACCEPTED:
            btnStatus.setImage(UIImage(named: "accepted"), for: .normal)
            btnResend.isHidden = true
            break
        case constants().MEMBER_INVITATION_STATUS_PENDING:
            btnStatus.setImage(UIImage(named: "cancel"), for: .normal)
            btnResend.isHidden = false
            btnStatus.addTarget(self, action: #selector(self.doCancelInvitation(_:)), for: .touchUpInside)
            btnResend.addTarget(self, action: #selector(self.doResendInvitation(_:)), for: .touchUpInside)
            break
        default:
            break
        }

        imgPic.layer.cornerRadius = 25.0
        imgPic.layer.masksToBounds = true

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let nWidth = constants().SCREENSIZE.width - 30
        return CGSize(width: nWidth, height: 70)
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
        let mDict = self.ArrMemberList.object(at: indexPath.row) as! NSDictionary
        if (mDict.value(forKey: "status") as! String) == constants().MEMBER_INVITATION_STATUS_PENDING {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Member has not accepted invitation yet. So you will not be able to see Detail Page.", preferredStyle: .alert)
            alertController.view.tintColor = constants().COLOR_LightBlue
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "memberdetail") as! MemberDetailPage
            ivc.modalPresentationStyle = .fullScreen
            ivc.strSelectedMemberID = (self.ArrMemberList.object(at: indexPath.row) as! NSDictionary).value(forKey: "user_id") as! String
            self.present(ivc, animated: false, completion: nil)
        }
    }
}
