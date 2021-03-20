//  TributeScreen.swift
//  LostAndFound
//  Created by Revamp on 09/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class TributeScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var imgTopLogo : UIImageView!
    @IBOutlet weak var myCollection : UICollectionView!
    @IBOutlet weak var vwNoItems : UIView!
    var ArrTributesList = NSMutableArray()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        self.doSetFrames()
        self.doFetchContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func doFetchContent() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: [:], APIName: apiClass().TributeAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.ArrTributesList = (mDict.value(forKey: "tribute") as! NSArray).mutableCopy() as! NSMutableArray
                    self.myCollection.reloadData()
                    self.vwNoItems.isHidden = true
                } else {
                    self.vwNoItems.isHidden = false
                }
            }
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.imgTopLogo.frame
                frame.origin.y = 35
                self.imgTopLogo.frame = frame

                frame = self.btnClose.frame
                frame.origin.y = 40
                self.btnClose.frame = frame

                frame = self.myCollection.frame
                frame.origin.y = self.imgTopLogo.frame.origin.y + self.imgTopLogo.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.myCollection.frame = frame

                frame = self.vwNoItems.frame
                frame.origin.y = self.imgTopLogo.frame.origin.y + self.imgTopLogo.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.vwNoItems.frame = frame
            }
        }
    }

    func doContentSizeCalculate(tText: NSAttributedString) -> CGFloat {
        let mlabel = UITextView()
        mlabel.frame = CGRect(x: 10, y: 10, width: constants().SCREENSIZE.width - 50, height: 20)
        mlabel.textAlignment = .left
        mlabel.attributedText = tText
        let newSize = mlabel.sizeThatFits(CGSize(width: constants().SCREENSIZE.width - 50, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }

    //MARK:- IBAction Methods
    @IBAction func doClose() {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 0)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrTributesList.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layer.cornerRadius = 12.0
        cell.layer.masksToBounds = true
        cell.backgroundColor = constants().tributeBackgroundColor(indexRow: indexPath.row)

        let lblTitle = cell.viewWithTag(101) as! UILabel
        let txtContent = cell.viewWithTag(102) as! UITextView
        let backImageview = cell.viewWithTag(103) as! UIImageView

        let mDict = self.ArrTributesList.object(at: indexPath.row) as! NSDictionary

        backImageview.image = constants().tributeBackgroundImage(indexRow: indexPath.row)

        let attributedStringColor = [NSAttributedString.Key.foregroundColor : indexPath.row == 0 ? UIColor.black : UIColor.white]
        lblTitle.attributedText = NSAttributedString(string: mDict.value(forKey: "title") as! String, attributes: attributedStringColor)
        txtContent.attributedText = NSAttributedString(string: mDict.value(forKey: "description") as! String, attributes: [NSAttributedString.Key.foregroundColor : indexPath.row == 0 ? UIColor.black : UIColor.white, NSAttributedString.Key.font : UIFont(name: constants().FONT_REGULAR, size: 18)!])
        txtContent.textAlignment = .left
        let newSize = txtContent.sizeThatFits(CGSize(width: constants().SCREENSIZE.width - 50, height: CGFloat.greatestFiniteMagnitude))
        var frame = txtContent.frame
        frame.size = newSize
        txtContent.frame = frame

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mDict = self.ArrTributesList.object(at: indexPath.row) as! NSDictionary
        let attFont = [NSAttributedString.Key.font : UIFont(name: constants().FONT_REGULAR, size: 18)]
        let attributedText = NSAttributedString(string: mDict.value(forKey: "description") as! String, attributes: attFont as [NSAttributedString.Key : Any])

        if indexPath.row == 7 || indexPath.row == 8 {
            return CGSize(width: (constants().SCREENSIZE.width - 45)/2, height: self.doContentSizeCalculate(tText: attributedText) + 55)
        } else {
            return CGSize(width: constants().SCREENSIZE.width - 30, height: self.doContentSizeCalculate(tText: attributedText) + 55)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
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
