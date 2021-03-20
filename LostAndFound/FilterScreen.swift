//  FilterScreen.swift
//  LostAndFound
//  Created by Revamp on 21/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import DropDown
import TPKeyboardAvoiding

class FilterScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UISearchBarDelegate {
    @IBOutlet weak var TopView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var btnReset : UIButton!

    @IBOutlet weak var MyScroll : TPKeyboardAvoidingScrollView!
    @IBOutlet weak var mySearch : UISearchBar!

    @IBOutlet weak var LocationView : UIView!
    @IBOutlet weak var lblLocationTitle : UILabel!
    @IBOutlet weak var lblSelectedLocation : UILabel!
    @IBOutlet weak var btnLocation : UIButton!

    @IBOutlet weak var CategoryView : UIView!
    @IBOutlet weak var lblCategoryTitle : UILabel!
    @IBOutlet weak var lblCategoryText : UILabel!
    @IBOutlet weak var btnCategory : UIButton!

    @IBOutlet weak var BrandView : UIView!
    @IBOutlet weak var lblBrandTitle : UILabel!
    @IBOutlet weak var txtBrand : AutocompleteTextField!

    @IBOutlet weak var ColorView : UIView!
    @IBOutlet weak var lblColorTitle : UILabel!
    @IBOutlet weak var ColorCollection : UICollectionView!

    @IBOutlet weak var DateView : UIView!
    @IBOutlet weak var lblFromTitle : UILabel!
    @IBOutlet weak var TxtFromDate : UITextField!
    @IBOutlet weak var lblEndTitle : UILabel!
    @IBOutlet weak var TxtEndDate : UITextField!

    @IBOutlet weak var BottomView : UIView!
    @IBOutlet weak var btnApply : UIButton!

    @IBOutlet weak var CategorySelectionView : UIView!
    @IBOutlet weak var CategoryCollection : UICollectionView!

    let DateFromPicker = UIDatePicker()
    let DateEndPicker = UIDatePicker()

    var selectedColorIndex = -1
    var selectedCategoryName = ""
    var DateFlag = 0
    var keyboardHEIGHT : CGFloat = 240.0

    @IBOutlet weak var CustomToolbar : UIView!
    @IBOutlet weak var CustomDone : UIButton!

    let SuggestionDropDown = DropDown()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    self.doApplyLocalisation()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        self.doCustomToolHide()
        self.doSetFrames()
        self.setupChooseArticleDropDown()
        self.doSetupDatePicker()
        self.CategorySelectionView.isHidden = true
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }

        apiClass().doNormalAPI(param: [:], APIName: apiClass().ColorListAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    constants().APPDEL.ColorList = (mDict.value(forKey: "color") as! NSArray).mutableCopy() as! NSMutableArray
                }
                self.ColorCollection.reloadData()
            }
        }
        DispatchQueue.main.async {
            apiClass().doNormalAPI(param: [:], APIName: apiClass().CategoryListAPI, method: "GET") { (success, errMessage, mDict) in
                DispatchQueue.main.async {
                    if success == true {
                        constants().APPDEL.CategoryList = (mDict.value(forKey: "category") as! NSArray).mutableCopy() as! NSMutableArray
                    }
                    self.CategoryCollection.reloadData()
                }
            }
        }
        self.doSetDefaultValues()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lblSelectedLocation.text = constants().APPDEL.strFilterLocation
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHEIGHT = keyboardRectangle.height
        }
    }

    func doSetDefaultValues() {
        self.mySearch.text = constants().APPDEL.strFilterName
        self.lblSelectedLocation.text = constants().APPDEL.strFilterLocation
        self.txtBrand.text = constants().APPDEL.strFilterBrandString

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = constants().SUBMIT_DATEFORMAT
        let fDate = formatter.date(from: constants().APPDEL.strFilterFromDate)
        formatter.dateFormat = constants().DISPLAY_DATEFORMAT
        if !constants().APPDEL.strFilterFromDate.isEmpty {
            self.TxtFromDate.text = formatter.string(from: fDate!)
        } else {
            self.TxtFromDate.text = ""
            self.TxtFromDate.placeholder = formatter.string(from: constants().FirstDateOfCurrentMonth())
        }

        formatter.dateFormat = constants().SUBMIT_DATEFORMAT
        let eDate = formatter.date(from: constants().APPDEL.strFilterToDate)
        formatter.dateFormat = constants().DISPLAY_DATEFORMAT
        if !constants().APPDEL.strFilterToDate.isEmpty {
            self.TxtEndDate.text = formatter.string(from: eDate!)
        } else {
            self.TxtEndDate.text = ""
            self.TxtEndDate.placeholder = formatter.string(from: Date())
        }
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.mySearch.semanticContentAttribute = .forceLeftToRight
        self.mySearch.searchTextField.textAlignment = .left

        self.txtBrand.padding = 15
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

                frame = self.btnReset.frame
                frame.origin.y = 40
                self.btnReset.frame = frame

                frame = self.MyScroll.frame
                frame.origin.y = self.TopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.MyScroll.frame = frame

                frame = self.CategorySelectionView.frame
                frame.origin.y = self.TopView.frame.origin.y + self.TopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.CategorySelectionView.frame = frame
            }
        }
    }

    func doApplyLocalisation() {
        self.mySearch.searchTextField.placeholder = NSLocalizedString("searchitemname", comment: "")
        self.lblTitle.text = NSLocalizedString("filters", comment: "")
        self.btnReset.setTitle(NSLocalizedString("reset", comment: ""), for: .normal)
        self.btnApply.setTitle(NSLocalizedString("apply", comment: ""), for: .normal)
        self.lblLocationTitle.text = NSLocalizedString("currentlocation", comment: "")
        self.lblCategoryTitle.text = NSLocalizedString("selectcategory", comment: "")
        self.lblBrandTitle.text = NSLocalizedString("selectbrand", comment: "")
        self.lblColorTitle.text = NSLocalizedString("selectcolor", comment: "")
        self.lblFromTitle.text = NSLocalizedString("fromdate", comment: "")
        self.lblEndTitle.text = NSLocalizedString("enddate", comment: "")
    }

    //MARK:- Configure Filter Suggestion
    func setupChooseArticleDropDown() {
        self.SuggestionDropDown.anchorView = self.mySearch
        self.SuggestionDropDown.bottomOffset = CGPoint(x: 0, y: self.mySearch.bounds.height)
        self.SuggestionDropDown.dataSource = []
        self.SuggestionDropDown.selectionAction = { [weak self] (index, item) in
            self!.mySearch.text = item
            self?.mySearch.resignFirstResponder()
        }
    }

    //MARK:- Setup Date Picker
    func doSetupDatePicker() {
        self.DateFromPicker.datePickerMode = .date
        DateFromPicker.locale = Locale(identifier: "en_US")
        self.DateFromPicker.date = constants().FirstDateOfCurrentMonth()
        self.DateFromPicker.maximumDate = Date()
        self.TxtFromDate.inputView = DateFromPicker

        self.DateEndPicker.datePickerMode = .date
        DateEndPicker.locale = Locale(identifier: "en_US")
        self.DateEndPicker.date = Date()
        self.DateEndPicker.minimumDate = self.DateFromPicker.date
        self.DateEndPicker.maximumDate = Date()
        self.TxtEndDate.inputView = DateEndPicker
    }

    //MARK:- IBAction Methods
    @IBAction func doClosePage() {
        if self.CategorySelectionView.isHidden == false {
            self.CategorySelectionView.isHidden = true
        } else {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            ivc.selectedIndex = 0
            constants().APPDEL.window?.rootViewController = ivc
        }
    }

    @IBAction func doReset() {
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().ClearLocationAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                constants().ResetFilters()
                self.selectedColorIndex = -1
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                ivc.selectedIndex = 0
                constants().APPDEL.window?.rootViewController = ivc
            }
        }
    }

    @IBAction func doApply() {
        constants().APPDEL.strFilterBrandString = self.txtBrand.text!
        constants().APPDEL.strFilterName = self.mySearch.text!
        if constants().APPDEL.strFilterName.isEmpty && constants().APPDEL.strFilterCatID.isEmpty && constants().APPDEL.strFilterBrandString.isEmpty && constants().APPDEL.strFilterColorID.isEmpty && constants().APPDEL.strFilterFromDate.isEmpty && constants().APPDEL.strFilterToDate.isEmpty && constants().APPDEL.strFilterLocation.isEmpty {
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("choosefilter", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            ivc.selectedIndex = 0
            constants().APPDEL.window?.rootViewController = ivc
        }
    }

    @IBAction func doClickCategory() {
        self.CategoryCollection.reloadData()
        self.CategorySelectionView.isHidden = false
    }

    @IBAction func doClickLocation() {
        constants().APPDEL.LocationitemName = ""
        constants().APPDEL.LocationItemAddress = ""
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "addlocation") as! AddLocation
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doMoreColorScroll() {
        let index = IndexPath(item: constants().APPDEL.ColorList.count - 1, section: 0)
        self.ColorCollection?.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }

    func doFetchSearchSuggestions(skey:String) {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        let searchString = (skey.replacingOccurrences(of: " ", with: "%20"))
        apiClass().doAutoSuggestAPI(strKeyword: searchString) { (success, errMessage) in
            DispatchQueue.main.async {
                if success == true {
                    self.SuggestionDropDown.dataSource = constants().APPDEL.ArrAutosuggestionsList as! [String]
                    self.SuggestionDropDown.show()
                }
            }
        }
    }

    //MARK:- UISearchBar delegate methods
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if searchBar == self.mySearch {
            if text == "\n" {
                self.mySearch.endEditing(true)
                searchBar.resignFirstResponder()
                self.SuggestionDropDown.dataSource = []
                self.SuggestionDropDown.hide()
            } else {
                if let text = searchBar.text, let textRange = Range(range, in: text) {
                    let updatedText = text.replacingCharacters(in: textRange, with: text)
                    self.doFetchSearchSuggestions(skey: updatedText)
                }
            }
        }
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.mySearch.endEditing(true)
        searchBar.resignFirstResponder()
        self.SuggestionDropDown.dataSource = []
        self.SuggestionDropDown.hide()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mySearch.endEditing(true)
        searchBar.resignFirstResponder()
        self.SuggestionDropDown.dataSource = []
        self.SuggestionDropDown.hide()
    }

    func doFetchAutoSuggestions(sKey:String) {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        let searchString = (sKey.replacingOccurrences(of: " ", with: "%20"))
        apiClass().doAutoSuggestAPI(strKeyword: searchString) { (success, errMessage) in
            DispatchQueue.main.async {
                if success == true {
                    self.txtBrand.suggestions = constants().APPDEL.ArrAutosuggestionsList as! [String]
                }
            }
        }
    }

    //MARK:- Custom toolbar Methods
    func doCustomToolShow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.CustomToolbar.isHidden = false
            var frame = self.CustomToolbar.frame
            frame.origin.y = constants().SCREENSIZE.height - self.keyboardHEIGHT - 50
            self.CustomToolbar.frame = frame
        })
    }

    func doCustomToolHide() {
        self.CustomToolbar.isHidden = true
        self.view.endEditing(true)
        self.DateFlag = 0
    }

    @IBAction func doToolbarDone() {
        if self.DateFlag == 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = constants().DISPLAY_DATEFORMAT
            formatter.locale = Locale(identifier: "en_US")
            self.TxtFromDate.text = formatter.string(from: DateFromPicker.date)
            self.view.endEditing(true)

            self.DateEndPicker.minimumDate = self.DateFromPicker.date
            formatter.dateFormat = constants().SUBMIT_DATEFORMAT
            constants().APPDEL.strFilterFromDate = formatter.string(from: DateFromPicker.date)
        } else if self.DateFlag == 2  {
            let formatter = DateFormatter()
            formatter.dateFormat = constants().DISPLAY_DATEFORMAT
            formatter.locale = Locale(identifier: "en_US")
            self.TxtEndDate.text = formatter.string(from: DateEndPicker.date)
            self.view.endEditing(true)

            formatter.dateFormat = constants().SUBMIT_DATEFORMAT
            constants().APPDEL.strFilterToDate = formatter.string(from: DateEndPicker.date)
        }
        self.doCustomToolHide()
    }

    //MARK:- UITextField delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtBrand {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                self.doFetchAutoSuggestions(sKey: updatedText)
            }
        }
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.doCustomToolHide()
        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.TxtFromDate {
            self.DateFlag = 1
            self.doCustomToolShow()
        }
        if textField == self.TxtEndDate {
            if self.TxtFromDate.text!.isEmpty {
                self.view.endEditing(true)
                let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("selectformdate", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                self.DateFlag = 2
                self.doCustomToolShow()
            }
        }
    }

    //MARK:- UICollectionview Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == self.ColorCollection {
            return CGSize(width: 5, height: 5)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.ColorCollection {
            return constants().APPDEL.ColorList.count
        } else {
            return constants().APPDEL.CategoryList.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.ColorCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 17.5
            cell.layer.masksToBounds = true
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 0.7
            cell.layer.masksToBounds = true

            let lblColor = cell.viewWithTag(101) as! UILabel
            lblColor.layer.cornerRadius = 10.5
            lblColor.layer.masksToBounds = true

            let mDict = constants().APPDEL.ColorList.object(at: indexPath.row) as! NSDictionary
            lblColor.backgroundColor = constants().hexStringToUIColor(hex: mDict.value(forKey: "color_code") as! String)
            if (self.selectedColorIndex == indexPath.row) || (constants().APPDEL.strFilterColorID == mDict.value(forKey: "color_id") as! String) {
                cell.backgroundColor = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0)
            } else {
                cell.backgroundColor = UIColor.white
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.layer.cornerRadius = 10

            let imgProductImage = cell.viewWithTag(101) as! UIImageView
            imgProductImage.backgroundColor = UIColor.white
            imgProductImage.contentMode = .scaleAspectFill

            let lblCategory = cell.viewWithTag(102) as! UILabel
            let mDict = constants().APPDEL.CategoryList.object(at: indexPath.row) as! NSDictionary
            lblCategory.text = (mDict.value(forKey: "name") as! String)
            imgProductImage.sd_setImage(with: URL(string: (mDict.value(forKey: "image") as! String)), completed: nil)

            let imgTick = cell.viewWithTag(105) as! UIImageView

            if constants().APPDEL.strFilterCatID == (mDict.value(forKey: "category_id") as! String) {
                self.lblCategoryText.text = (mDict.value(forKey: "name") as! String)
                imgTick.isHidden = false
            } else {
                imgTick.isHidden = true
            }

            let lblBottomStatus = cell.viewWithTag(103) as! UILabel
            let lblOtherText = cell.viewWithTag(104) as! UIButton
            lblOtherText.layer.cornerRadius = lblOtherText.frame.size.width/2
            lblOtherText.layer.masksToBounds = true
            lblOtherText.addTarget(self, action: #selector(OtherButtonPressed(_:)), for: .touchUpInside)

            if indexPath.row == constants().APPDEL.CategoryList.count - 1 {
                imgProductImage.isHidden = true
                lblBottomStatus.isHidden = true
                lblOtherText.isHidden = false
                lblCategory.isHidden = true
            } else {
                cell.layer.borderWidth = 0.2
                cell.layer.borderColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
                imgProductImage.isHidden = false
                lblBottomStatus.isHidden = false
                lblOtherText.isHidden = true
                lblCategory.isHidden = false
            }

            return cell
        }
    }

    @objc func OtherButtonPressed(_ sender: UIButton) {
        let mDict = constants().APPDEL.CategoryList.object(at: (constants().APPDEL.CategoryList.count - 1)) as! NSDictionary
        constants().APPDEL.strFilterCatID = mDict.value(forKey: "category_id") as! String
        self.selectedCategoryName = mDict.value(forKey: "name") as! String
        self.lblCategoryText.text = self.selectedCategoryName
        self.CategorySelectionView.isHidden = true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.ColorCollection {
            return CGSize(width: 35, height: 35)
        } else {
            if indexPath.row == constants().APPDEL.CategoryList.count - 1 {
                let mSize = constants().SCREENSIZE.width - 40
                return CGSize(width: mSize, height: mSize/2)
            } else {
                let mSize = (constants().SCREENSIZE.width - 60)/2
                return CGSize(width: mSize, height: mSize)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.ColorCollection {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        } else {
            return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.ColorCollection {
            return 10
        } else {
            return 20
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.ColorCollection {
            return 10
        } else {
            return 20
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.ColorCollection {
            let mDict = constants().APPDEL.ColorList.object(at: indexPath.row) as! NSDictionary
            constants().APPDEL.strFilterColorID = mDict.value(forKey: "color_id") as! String
            self.selectedColorIndex = indexPath.row
            self.ColorCollection.reloadData()
        }
        if collectionView == self.CategoryCollection {
            if indexPath.row == constants().APPDEL.CategoryList.count - 1 {
            } else {
                let mDict = constants().APPDEL.CategoryList.object(at: indexPath.row) as! NSDictionary
                constants().APPDEL.strFilterCatID = mDict.value(forKey: "category_id") as! String
                self.selectedCategoryName = mDict.value(forKey: "name") as! String
                self.lblCategoryText.text = self.selectedCategoryName
                self.CategorySelectionView.isHidden = true
            }
        }
    }
}
