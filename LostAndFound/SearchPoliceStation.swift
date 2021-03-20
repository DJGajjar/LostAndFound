//  SearchPoliceStation.swift
//  LostAndFound
//  Created by Revamp on 24/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import LocalAuthentication
import MapKit

class SearchPoliceStation: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var mySearchBar : UISearchBar!
    @IBOutlet weak var vwSeparator : UIView!
    @IBOutlet weak var SearchCollection : UICollectionView!
    var arrPoliceStations = NSMutableArray()
    var PoliceStationArray = NSMutableArray()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        self.doSetFrames()
        self.DoFetchAllList()
        DispatchQueue.main.async {
            self.SearchCollection.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.mySearchBar.searchTextField.semanticContentAttribute = .forceLeftToRight
        self.mySearchBar.searchTextField.textAlignment = .left

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.btnBack.frame
                frame.origin.y = 40
                self.btnBack.frame = frame

                frame = self.mySearchBar.frame
                frame.origin.y = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height
                self.mySearchBar.frame = frame

                frame = self.vwSeparator.frame
                frame.origin.y = self.mySearchBar.frame.origin.y + self.mySearchBar.frame.size.height
                self.vwSeparator.frame = frame

                frame = self.SearchCollection.frame
                frame.origin.y = self.vwSeparator.frame.origin.y + self.vwSeparator.frame.size.height
                self.SearchCollection.frame = frame
            }
        }
    }

    func DoFetchAllList() {
        apiClass().doNormalAPI(param: [:], APIName: apiClass().GetPoliceStationListAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.PoliceStationArray = (mDict.value(forKey: "data") as! NSArray).mutableCopy() as! NSMutableArray
                    self.doResetList()
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
    
    func doResetList() {
        self.arrPoliceStations.removeAllObjects()
        self.arrPoliceStations = self.PoliceStationArray.mutableCopy() as! NSMutableArray
        self.SearchCollection.reloadData()
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    func doSearchPoliceStation(sLocationName: String) {
        self.arrPoliceStations.removeAllObjects()
        for i in 0..<(self.PoliceStationArray.count) {
            let mDict = self.PoliceStationArray.object(at: i) as! NSDictionary
            let mCity = (mDict.value(forKey: "city") as! String).lowercased()
            let mDictrict = (mDict.value(forKey: "district") as! String).lowercased()
            let mState = (mDict.value(forKey: "state") as! String).lowercased()
            let mCuntry = (mDict.value(forKey: "country") as! String).lowercased()
            if mCity.contains(sLocationName.lowercased()) ||
               mDictrict.contains(sLocationName.lowercased()) ||
               mState.contains(sLocationName.lowercased()) ||
               mCuntry.contains(sLocationName.lowercased()) {
                self.arrPoliceStations.add(mDict)
            }
        }
        self.SearchCollection.reloadData()
    }

    //MARK:- UISearchBar delegate Methods
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.doSearchPoliceStation(sLocationName: searchBar.text!)
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.doResetList()
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 1)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrPoliceStations.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let lblLocationName  = cell.viewWithTag(101) as! UILabel
        let lblLocationAddress  = cell.viewWithTag(102) as! UILabel

        let mDict = self.arrPoliceStations.object(at: indexPath.row)  as! NSDictionary
        lblLocationName.text = (mDict.value(forKey: "city") as! String) + " Police Station"
        lblLocationAddress.text = (mDict.value(forKey: "city") as! String) + ", " + (mDict.value(forKey: "state") as! String) + ", " + (mDict.value(forKey: "country") as! String)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: constants().SCREENSIZE.width, height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mDict = self.arrPoliceStations.object(at: indexPath.row)  as! NSDictionary
        constants().APPDEL.psTitle = (mDict.value(forKey: "city") as! String) + " Police Station"
        constants().APPDEL.psLocation = (mDict.value(forKey: "city") as! String) + ", " + (mDict.value(forKey: "state") as! String) + ", " + (mDict.value(forKey: "country") as! String)
        constants().APPDEL.psEmail = (mDict.value(forKey: "email") as! String)
        self.dismiss(animated: true, completion: nil)
    }
}
