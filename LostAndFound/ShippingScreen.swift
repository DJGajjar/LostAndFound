//  ShippingScreen.swift
//  LostAndFound
//  Created by Revamp on 04/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class ShippingScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnContinue : UIButton!
    @IBOutlet weak var mycollection : UICollectionView!

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        self.doSetFrames()
        self.mycollection.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.btnContinue.layer.cornerRadius = self.btnContinue.frame.size.height / 2
        self.btnContinue.layer.masksToBounds = true
    }

    //MARK:- IBAction Methods
    @IBAction func doContinue() {
    }

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
        return 5
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 15.0

        let imgIcon = cell.viewWithTag(101) as! UIImageView
        let imgCheckMark = cell.viewWithTag(102) as! UIImageView
        
        if indexPath.row == 0 {
            imgIcon.image = UIImage(named: "shipping_1.png")
            imgCheckMark.image = UIImage(named: "CheckboxSelected")
        } else if indexPath.row == 1 {
            imgIcon.image = UIImage(named: "shipping_2.png")
            imgCheckMark.image = UIImage(named: "CheckboxEmpty")
        } else if indexPath.row == 2 {
            imgIcon.image = UIImage(named: "shipping_3.png")
            imgCheckMark.image = UIImage(named: "CheckboxEmpty")
        } else if indexPath.row == 3 {
            imgIcon.image = UIImage(named: "shipping_4.png")
            imgCheckMark.image = UIImage(named: "CheckboxEmpty")
        } else if indexPath.row == 4 {
            imgIcon.image = UIImage(named: "shipping_5.png")
            imgCheckMark.image = UIImage(named: "CheckboxEmpty")
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var mSize = (constants().SCREENSIZE.width - 60) / 2
        if (constants().userinterface == .pad) {
            mSize = (constants().SCREENSIZE.width - 120) / 2
        }
        return CGSize(width: mSize, height: mSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if (constants().userinterface == .pad) {
            return UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        }
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if (constants().userinterface == .pad) {
            return 40
        }
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (constants().userinterface == .pad) {
            return 40
        }
        return 20
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
