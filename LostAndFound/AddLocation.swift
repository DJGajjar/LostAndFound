//  AddLocation.swift
//  LostAndFound
//  Created by Revamp on 22/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import UICollectionViewLeftAlignedLayout
class AddLocation: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var TopView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var btnApply : UIButton!
    @IBOutlet weak var mySearch : UISearchBar!
    @IBOutlet weak var LocationCollection : UICollectionView!

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        self.LocationCollection.collectionViewLayout = UICollectionViewLeftAlignedLayout()
        self.doFetchItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !constants().APPDEL.LocationitemName.isEmpty {
            if constants().APPDEL.isInternetOn(currentController: self) == false {
                return
            }
            constants().APPDEL.doStartSpinner()
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "location": constants().APPDEL.LocationitemName], APIName: apiClass().AddLocationAPI, method: "POST") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        self.doFetchItems()
                    } else {
                        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    constants().APPDEL.LocationitemName = ""
                    constants().APPDEL.LocationItemAddress = ""
                }
            }
        }
        self.doRefreshCollection()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doFetchItems() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetMyFavLocationsAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    constants().APPDEL.ArrFavLocations = (mDict.value(forKey: "location") as! NSArray).mutableCopy() as! NSMutableArray
                    constants().doCreateLocationFilterJoint()
                    self.LocationCollection.reloadData()
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.TopView.frame
                frame.size.height = 80
                self.TopView.frame = frame

                frame = self.lblTitle.frame
                frame.origin.y = 40
                self.lblTitle.frame = frame

                frame = self.btnClose.frame
                frame.origin.y = 40
                self.btnClose.frame = frame

                frame = self.btnApply.frame
                frame.origin.y = 40
                self.btnApply.frame = frame

                frame = self.mySearch.frame
                frame.origin.y = self.TopView.frame.size.height
                self.mySearch.frame = frame

                frame = self.LocationCollection.frame
                frame.origin.y = self.mySearch.frame.origin.y + self.mySearch.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y - 60
                self.LocationCollection.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("addlocation", comment: "")
        self.btnApply.setTitle(NSLocalizedString("apply", comment: ""), for: .normal)
        self.mySearch.searchTextField.placeholder = NSLocalizedString("searchcity", comment: "")
    }

    func doRefreshCollection()  {
        DispatchQueue.main.async {
            self.LocationCollection.reloadData()
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doClosePage() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "filter") as! FilterScreen
        constants().APPDEL.window?.rootViewController = ivc
    }

    @objc func doCloseLocation(_ sender: UIButton) {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.LocationCollection)
        let indexPath = self.LocationCollection.indexPathForItem(at: buttonPosition)
        let mDict = constants().APPDEL.ArrFavLocations.object(at: indexPath!.row) as! NSDictionary
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "location_id": mDict.value(forKey: "location_id") as! String], APIName: apiClass().DeleteLocationAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.doFetchItems()
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.doRefreshCollection()
                }
            }
        }
    }

    func doYourLocation() {
        let IVCPicker = CustomLocationPicker()
        let navigationController = UINavigationController(rootViewController: IVCPicker)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false, completion: nil)
    }

    //MARK:- UISearchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar == self.mySearch {
            constants().APPDEL.LocationitemName = ""
            constants().APPDEL.LocationItemAddress = ""
            self.view.endEditing(true)
            self.doYourLocation()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mySearch.endEditing(true)
        searchBar.resignFirstResponder()
    }

    //MARK:- UICollectionview Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: constants().SCREENSIZE.width, height: 10)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return constants().APPDEL.ArrFavLocations.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 25.0
        cell.layer.masksToBounds = true

        let mDict = constants().APPDEL.ArrFavLocations.object(at: indexPath.row) as! NSDictionary

        let txtLocation = cell.viewWithTag(101) as! UITextView
        txtLocation.backgroundColor = UIColor.clear
        txtLocation.text = (mDict.value(forKey: "location") as! String)

        let fixedHeight: CGFloat = 30
        txtLocation.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight))
        let newSize = txtLocation.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight))
        var newFrame = txtLocation.frame
        newFrame.size = CGSize(width: newSize.width + 20, height: max(newSize.height, fixedHeight))
        newFrame.origin.x = 0
        newFrame.origin.y = (50 - newFrame.size.height) / 2
        txtLocation.frame = newFrame

        let btnCloseLocation = cell.viewWithTag(102) as! UIButton
        btnCloseLocation.addTarget(self, action: #selector(self.doCloseLocation(_:)), for: .touchUpInside)

        if (mDict.value(forKey: "is_filter") as! String) == "TRUE" {
            cell.backgroundColor = constants().COLOR_LightBlue
            txtLocation.textColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor.white
            txtLocation.textColor = UIColor.black
        }
        cell.layoutSubviews()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mDict = constants().APPDEL.ArrFavLocations.object(at: indexPath.row) as! NSDictionary
        let mWidth = constants().labelWidth(mString: (mDict.value(forKey: "location") as! String))
        return CGSize(width: mWidth + 50, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var isFavStatus = ""
        let mDict = constants().APPDEL.ArrFavLocations.object(at: indexPath.row) as! NSDictionary
        if (mDict.value(forKey: "is_filter") as! String) == "TRUE" {
            isFavStatus = "FALSE"
        } else {
            isFavStatus = "TRUE"
        }

        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["location_id":mDict.value(forKey: "location_id") as! String, "is_filter":isFavStatus], APIName: apiClass().UpdateFavLocationAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.doFetchItems()
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.doRefreshCollection()
                }
            }
         }
    }
}
