//  SelectLanguage.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

//https://medium.com/swift2go/forcing-ios-localization-at-runtime-the-right-way-8afa0569162a
import UIKit
class SelectLanguage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var mycollection : UICollectionView!
    @IBOutlet weak var btnNext : UIButton!
    var navFlag = 0
    var spacePadding : CGFloat  = 20.0

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        constants().ValidateLanguageCode()
        DispatchQueue.main.async {
            self.mycollection.reloadData()
        }
        self.doApplyLocalisation()
        self.doSetFrames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.btnNext.layer.cornerRadius = 27.5
        self.btnNext.layer.masksToBounds = true

        if (constants().userinterface == .pad) {
            spacePadding = 40.0
            var frame = self.mycollection.frame
            frame.size.height = constants().SCREENSIZE.height - 60
            self.mycollection.frame = frame
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                spacePadding = 20.0
            }
        }
    }

    func doApplyLocalisation() {
        self.btnNext.setTitle("Next", for: .normal)
    }

    //MARK:- IBAction Methods
    @IBAction func doNext() {
        LocaleManager.apply(identifier: constants().APPDEL.selectedCode)
        constants().APPDEL.doStartLanguageSpinner()
        constants().LanguageDone()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            constants().APPDEL.doStopSpinner()
            if self.navFlag == 1 {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "createaccount") as! CreateAccount
                constants().APPDEL.window?.rootViewController = ivc
            } else {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "settings") as! SettingsPage
                constants().APPDEL.window?.rootViewController = ivc
            }
        })
    }

    //MARK:- UICollectionview Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let objHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "languageHeader", for: indexPath) as? languageHeader {
            objHeader.sectionHeaderTitle.text = "Select language"
            objHeader.sectionHeaderDesc.text = "Please choose preferred language"
            objHeader.sectionHeaderTitle.font = UIFont(name: constants().FONT_BOLD, size: 28)
            objHeader.sectionHeaderDesc.font = UIFont(name: constants().FONT_REGULAR, size: 22)
            return objHeader
        }
        return UICollectionReusableView()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return constants().arrLanguages.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 15.0

        let dict = constants().arrLanguages[indexPath.row] as NSDictionary
        let imgIcon = cell.viewWithTag(101) as! UIImageView
        let imgCheckMark = cell.viewWithTag(102) as! UIImageView
        let lblText = cell.viewWithTag(103) as! UILabel

        imgIcon.image = UIImage(named: dict["image"] as! String)

        if constants().userinterface == .pad {
            lblText.font = UIFont(name: lblText.font.fontName, size: 28)
        }

        if (dict["code"] as! String) == constants().APPDEL.selectedCode {
            imgCheckMark.image = UIImage(named: "CheckboxSelected")
        } else {
            imgCheckMark.image = UIImage(named: "CheckboxEmpty")
        }
        lblText.text = dict["name"] as? String
        lblText.textColor = UIColor.black
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mWidth = (constants().SCREENSIZE.width-self.spacePadding*3) / 2
        var mHeight = (constants().SCREENSIZE.height - 120 - (self.spacePadding*3) - 87)/3
        if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
            mHeight = (constants().SCREENSIZE.height - 250 - (self.spacePadding*3) - 87)/3
        }
//        if (constants().userinterface == .pad) {
//            mWidth =
//        }
        return CGSize(width: mWidth, height: mHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.spacePadding, left: self.spacePadding, bottom: self.spacePadding, right: self.spacePadding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.spacePadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (constants().userinterface == .pad) {
            return 20
        }
        return self.spacePadding
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        constants().APPDEL.selectedCode = constants().arrLanguages[indexPath.row]["code"]!
        DispatchQueue.main.async {
            self.mycollection.reloadData()
        }
    }
}
