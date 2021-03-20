//  LostItemDetailPage.swift
//  LostAndFound
//  Created by Revamp on 04/11/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import PageControls
import MapKit
import MessageUI

class LostItemDetailPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var MainScroll : UIScrollView!
    @IBOutlet weak var imgItemCollection : UICollectionView!
    @IBOutlet weak var myPageControl: ZPageControl!
    @IBOutlet weak var AllContentView : UIView!

    @IBOutlet weak var ItemView: UIView!
    @IBOutlet weak var ItemName: UILabel!
    @IBOutlet weak var ItemCategory: UILabel!
    @IBOutlet weak var ItemBrandTitle: UILabel!
    @IBOutlet weak var ItemBrand: UILabel!
    @IBOutlet weak var ItemColorTitle: UILabel!
    @IBOutlet weak var ItemColor: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnViews: UIButton!
    @IBOutlet weak var imgRewardIcon: UIImageView!
    @IBOutlet weak var lblRewardAmount: UILabel!
    @IBOutlet weak var lblRewardAmountTitle: UILabel!

    @IBOutlet weak var DateLocationView: UIView!
    @IBOutlet weak var imgDateIcon: UIImageView!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblDateTimeTitle: UILabel!
    @IBOutlet weak var LocationMapView: MKMapView!
    @IBOutlet weak var imgPinIcon: UIImageView!
    @IBOutlet weak var lblAddressTitle: UILabel!
    @IBOutlet weak var txtAddressDesc: UITextView!

    @IBOutlet weak var OwnerView: UIView!
    @IBOutlet weak var OwnerImage: UIImageView!
    @IBOutlet weak var OwnerName: UILabel!
    @IBOutlet weak var OwnerLocation: UILabel!
    @IBOutlet weak var BtnOwnerCall: UIButton!
    @IBOutlet weak var BtnOwnerMail: UIButton!
    @IBOutlet weak var BtnOwnerChatMessage: UIButton!
    @IBOutlet weak var BtnOwnerPin: UIButton!

    @IBOutlet weak var DescriptionView: UIView!
    @IBOutlet weak var DescriptionText: UITextView!

    @IBOutlet weak var TagView: UIView!
    @IBOutlet weak var TagsDescription: UITextView!

    var ArrItemImages = NSMutableArray()
    var lostItemID = ""
    var SharableImage = UIImage(named: "place_holder")
    var ScreenshotImage = UIImage()
    var dictLostDetail = NSDictionary()

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        // Set Frames
        self.doSetFrames()

        // Configure Page Control
        self.doConfigurePageControl()

        // Reachability Test
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }

        // Fetch Detail Data
        self.doFetchData()

        // Increase View Counts
        apiClass().doNormalAPI(param: ["lost_id":self.lostItemID], APIName: apiClass().LostViewCountAPI, method: "POST") { (success, errMessage, mDict) in
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Fetch Data
    func doFetchData() {
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "lost_id":self.lostItemID], APIName: apiClass().LostItemDetailAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.dictLostDetail = mDict.value(forKey: "lost_item") as! NSDictionary
                    self.ItemName.text = (self.dictLostDetail.value(forKey: "item_name") as! String)
                    self.ItemCategory.text = (self.dictLostDetail.value(forKey: "category_item_name") as! String)
                    self.ItemBrand.text = (self.dictLostDetail.value(forKey: "brand_name") as! String)
                    if (self.ItemBrand.text?.count == 0) {
                        self.ItemBrand.text = NSLocalizedString("no_info_short", comment: "")
                    }
                    self.ItemColor.backgroundColor = constants().hexStringToUIColor(hex: (self.dictLostDetail.value(forKey: "color_code") as! String))

                    if (self.dictLostDetail.value(forKey: "reward") as! String).isEmpty {
                        self.lblRewardAmount.isHidden = true
                        self.lblRewardAmountTitle.isHidden = true
                        self.imgRewardIcon.isHidden = true
                    } else {
                        self.lblRewardAmount.isHidden = false
                        self.lblRewardAmountTitle.isHidden = false
                        self.lblRewardAmount.text = "$\(self.dictLostDetail.value(forKey: "reward") as! String)"
                    }
                    self.btnViews.setTitle("\(self.dictLostDetail.value(forKey: "no_of_view") as! String) Views", for: .normal)
                    self.OwnerName.text = "\(self.dictLostDetail.value(forKey: "first_name") as! String) \(self.dictLostDetail.value(forKey: "last_name") as! String)"

                    self.OwnerLocation.text = (self.dictLostDetail.value(forKey: "address1") as! String)
                    if !(self.dictLostDetail.value(forKey: "address2") as! String).isEmpty {
                        self.OwnerLocation.text?.append(", \(self.dictLostDetail.value(forKey: "address2") as! String)")
                    }
                    if !(self.dictLostDetail.value(forKey: "city") as! String).isEmpty {
                        self.OwnerLocation.text?.append(", \(self.dictLostDetail.value(forKey: "city") as! String)")
                    }
                    if !(self.dictLostDetail.value(forKey: "country") as! String).isEmpty {
                        self.OwnerLocation.text?.append(", \(self.dictLostDetail.value(forKey: "country") as! String)")
                    }

                    self.OwnerImage.contentMode = .scaleAspectFill
                    self.OwnerImage.loadProfileImage(url: (self.dictLostDetail.value(forKey: "image") as! String))
                    self.ArrItemImages = (self.dictLostDetail.value(forKey: "lost_images") as! NSArray).mutableCopy() as! NSMutableArray
                    self.myPageControl.numberOfPages = self.ArrItemImages.count
                    self.imgItemCollection.reloadData()

                    self.lblDateTime.text = (self.dictLostDetail.value(forKey: "lost_date") as! String)
                    self.txtAddressDesc.text = (self.dictLostDetail.value(forKey: "location") as! String)
                    self.DescriptionText.text = (self.dictLostDetail.value(forKey: "description") as! String)
                    
                    if (self.DescriptionText.text?.count == 0) {
                        self.DescriptionText.text = NSLocalizedString("no_info_long", comment: "")
                    }
                    let newSize = self.DescriptionText.sizeThatFits(CGSize(width: self.DescriptionView.frame.size.width - 20, height: CGFloat.greatestFiniteMagnitude))
                    var frame = self.DescriptionText.frame
                    frame.size = newSize
                    self.DescriptionText.frame = frame

                    frame = self.DescriptionView.frame
                    frame.size.height = self.DescriptionText.frame.size.height + 55
                    self.DescriptionView.frame = frame

                    var tagArray =  (self.dictLostDetail.value(forKey: "tag") as! String).components(separatedBy: ",")
                    if tagArray.count > 0 {
                        tagArray =    (((tagArray.map { "#\($0)" }) as NSArray).mutableCopy() as! NSMutableArray) as! [String]
                        self.TagsDescription.text = tagArray.joined(separator: ",")
                    }

                    if (tagArray.count == 0 || self.TagsDescription.text.count < 2) {
                        self.TagsDescription.text = NSLocalizedString("no_info_long", comment: "")
                    }

                    let newTagSize = self.TagsDescription.sizeThatFits(CGSize(width: self.TagsDescription.frame.size.width - 20, height: CGFloat.greatestFiniteMagnitude))
                    frame = self.TagsDescription.frame
                    frame.size = newTagSize
                    self.TagsDescription.frame = frame

                    frame = self.TagView.frame
                    frame.origin.y = self.DescriptionView.frame.origin.y + self.DescriptionView.frame.size.height + 15
                    frame.size.height = self.TagsDescription.frame.size.height + 55
                    self.TagView.frame = frame

                    frame  = self.AllContentView.frame
                    frame.size.height = self.TagView.frame.origin.y + self.TagView.frame.size.height + 20
                    self.AllContentView.frame = frame

                    self.MainScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.AllContentView.frame.origin.y + self.AllContentView.frame.size.height)

                    self.doSetupMapLocation()

                    if (self.dictLostDetail.value(forKey: "text_chat_status") as! String) == "OFF" {
                        self.BtnOwnerChatMessage.isEnabled = false
                        self.BtnOwnerChatMessage.backgroundColor = UIColor.lightGray
                    } else {
                        self.BtnOwnerChatMessage.isEnabled = true
                        self.BtnOwnerChatMessage.backgroundColor = constants().COLOR_LightBlue
                    }

                    if (self.dictLostDetail.value(forKey: "user_mobile") as! String).isEmpty {
                        self.BtnOwnerCall.isEnabled = false
                        self.BtnOwnerCall.backgroundColor = UIColor.lightGray
                    } else {
                        if (self.dictLostDetail.value(forKey: "display_mobile_status") as! String) == "OFF" {
                            self.BtnOwnerCall.isEnabled = false
                            self.BtnOwnerCall.backgroundColor = UIColor.lightGray
                        } else {
                            self.BtnOwnerCall.isEnabled = true
                            self.BtnOwnerCall.backgroundColor = constants().COLOR_LightBlue
                        }
                    }

                    if (self.dictLostDetail.value(forKey: "user_email") as! String).isEmpty {
                        self.BtnOwnerMail.isEnabled = false
                        self.BtnOwnerMail.backgroundColor = UIColor.lightGray
                    } else {
                        self.BtnOwnerMail.isEnabled = true
                        self.BtnOwnerMail.backgroundColor = constants().COLOR_LightBlue
                    }

                    if constants().APPDEL.isMyItem == 0 {
                        if constants().doGetUserId() == (self.dictLostDetail.value(forKey: "user_id") as! String) {
                            self.doHideOwnerControls()
                        }
                    } else {
                        self.doHideOwnerControls()
                    }
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                        self.doBack()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    //MARK:- Other Methods
    func doConfigurePageControl() {
        self.myPageControl.numberOfPages = self.ArrItemImages.count
        self.myPageControl.currentPage = 0
        self.myPageControl.dotSize = CGSize(width: 15.0, height: 4.0)
        self.myPageControl.dotRadius = 2.0
        self.myPageControl.pageIndicatorTintColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        self.myPageControl.currentPageIndicatorTintColor = constants().COLOR_LightBlue
    }

    func doSetupMapLocation() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(txtAddressDesc.text) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                    return
            }

            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.LocationMapView.setRegion(region, animated: true)

            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = self.ItemName.text
            annotation.subtitle = self.txtAddressDesc.text
            self.LocationMapView.addAnnotation(annotation)
        }
    }

    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.MainScroll.semanticContentAttribute = .forceLeftToRight
        self.AllContentView.semanticContentAttribute = .forceLeftToRight
        self.ItemView.semanticContentAttribute = .forceLeftToRight

        self.btnBack.layer.cornerRadius = 20.0
        self.btnBack.layer.masksToBounds = true
    
        self.ItemView.layer.cornerRadius = 10.0
        self.ItemView.layer.masksToBounds = true

        self.OwnerView.layer.cornerRadius = 10.0
        self.OwnerView.layer.masksToBounds = true

        self.DateLocationView.layer.cornerRadius = 10.0
        self.DateLocationView.layer.masksToBounds = true

        self.DescriptionView.layer.cornerRadius = 10.0
        self.DescriptionView.layer.masksToBounds = true

        self.TagView.layer.cornerRadius = 10.0
        self.TagView.layer.masksToBounds = true

        self.btnShare.layer.cornerRadius = self.btnShare.frame.size.height / 2
        self.btnShare.layer.masksToBounds = true

        self.btnViews.layer.cornerRadius = self.btnViews.frame.size.height / 2
        self.btnViews.layer.masksToBounds = true

        self.ItemColor.layer.borderColor = UIColor.lightGray.cgColor
        self.ItemColor.layer.borderWidth  = 1.0
        self.ItemColor.layer.cornerRadius = self.ItemColor.frame.size.width / 2
        self.ItemColor.layer.masksToBounds = true

        self.OwnerImage.layer.cornerRadius = self.OwnerImage.frame.size.width / 2
        self.OwnerImage.layer.masksToBounds = true

        self.BtnOwnerCall.layer.cornerRadius = self.BtnOwnerCall.frame.size.width / 2
        self.BtnOwnerCall.layer.masksToBounds = true

        self.BtnOwnerMail.layer.cornerRadius = self.BtnOwnerMail.frame.size.width / 2
        self.BtnOwnerMail.layer.masksToBounds = true

        self.BtnOwnerChatMessage.layer.cornerRadius = self.BtnOwnerChatMessage.frame.size.width / 2
        self.BtnOwnerChatMessage.layer.masksToBounds = true

        self.BtnOwnerPin.layer.cornerRadius = self.BtnOwnerPin.frame.size.width / 2
        self.BtnOwnerPin.layer.masksToBounds = true

        if (constants().userinterface == .pad) {
            var frame = self.imgItemCollection.frame
            frame.size.height = constants().SCREENSIZE.height * 0.42
            self.imgItemCollection.frame = frame

            frame = self.AllContentView.frame
            frame.origin.y = self.imgItemCollection.frame.size.height - 60
            self.AllContentView.frame = frame

            frame = self.myPageControl.frame
            frame.origin.y = self.AllContentView.frame.origin.y - 30
            self.myPageControl.frame = frame
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.btnBack.frame
                frame.origin.y = 35
                self.btnBack.frame = frame
            }
        }

        var frame  = self.AllContentView.frame
        frame.size.height = self.TagView.frame.origin.y + self.TagView.frame.size.height + 20
        self.AllContentView.frame = frame

        self.MainScroll.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.AllContentView.frame.origin.y + self.AllContentView.frame.size.height)
    }

    func doApplyLocalisation() {
        self.ItemBrandTitle.text = NSLocalizedString("brand", comment: "")
        self.ItemColorTitle.text = NSLocalizedString("color", comment: "")
    }

    func doHideOwnerControls() {
//        self.BtnOwnerCall.isHidden = true
//        self.BtnOwnerMail.isHidden = true
//        self.BtnOwnerChatMessage.isHidden = true
//        self.BtnOwnerPin.isHidden = true
    }

    //MARK:- UIScrollView Delegate Method
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var swipeValue:CGFloat = -70
        if (constants().userinterface == .pad) {
            swipeValue = -120
        }
        if scrollView.contentOffset.y < swipeValue {
            self.view.window!.layer.add(constants().pushFromBottomTransition(), forKey: kCATransition)
            self.doBack()
        }
    }

    func screenshot() {
        let savedContentOffset = self.MainScroll.contentOffset
        let savedFrame = self.MainScroll.frame
        UIGraphicsBeginImageContext(self.MainScroll.contentSize)
        self.MainScroll.contentOffset = .zero
        self.MainScroll.frame = CGRect(x: 0, y: 0, width: self.MainScroll.contentSize.width, height: self.MainScroll.contentSize.height)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        self.MainScroll.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        self.MainScroll.contentOffset = savedContentOffset
        self.MainScroll.frame = savedFrame
        self.ScreenshotImage = image!
    }

    //MARK:- IBAction Methods
    @IBAction func pageControlSelectionAction(_ sender: UIPageControl) {
    }

    @IBAction func doBack() {
        if constants().APPDEL.isMyItem == 0 {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            ivc.selectedIndex = 0
            constants().APPDEL.window?.rootViewController = ivc
        } else if constants().APPDEL.isMyItem == 1 {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "myitems") as! MyItems
            constants().APPDEL.window?.rootViewController = ivc
        }
    }

    @IBAction func doShare() {
        let lostItemDesc = "Lost Item - \(self.ItemName.text!)"
        var shareItems : [Any] = [lostItemDesc]
        if self.SharableImage != nil {
            shareItems = [lostItemDesc, self.SharableImage!]
        }
        let activityViewController = UIActivityViewController(activityItems: shareItems , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func doOwnerCall() {
        constants().doCallNumber(phoneNumber: self.dictLostDetail.value(forKey: "user_mobile") as! String)
    }

    @IBAction func doOwnerMail() {
        self.screenshot()
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }

    @IBAction func doOwnerChat() {
        constants().APPDEL.doGetQuickBloxUser(nLogin: (self.dictLostDetail.value(forKey: "user_id") as! String))
    }

    @IBAction func doOwnerPinview() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "maplocationview") as! MapLocationView
        ivc.myLocation = self.txtAddressDesc.text
        ivc.modalPresentationStyle = .fullScreen
        self.present(ivc, animated: true, completion: nil)
    }

    //MARK:- Mail Configure
    func configureMailComposer() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([(self.dictLostDetail.value(forKey: "user_email") as! String)])
        mailComposeVC.addAttachmentData(self.ScreenshotImage.jpegData(compressionQuality: 1.0)!, mimeType: "image/jpeg", fileName:  "LostItem.jpeg")
        mailComposeVC.setSubject("Lost & Found - Lost Item")
        mailComposeVC.setMessageBody("Hi \(self.OwnerName.text!),\n\nI would like to inquire about this Lost Item.\n\n", isHTML: false)
        return mailComposeVC
    }

    //MARK:- MFMailComposeViewController Delegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "map_pin")
        return annotationView
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrItemImages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.clear

        let mDict = self.ArrItemImages.object(at: indexPath.row) as! NSDictionary
        let imgProductImage = cell.viewWithTag(101) as! UIImageView
        imgProductImage.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        imgProductImage.sd_setImage(with: URL(string: mDict.value(forKey: "image") as! String), completed: nil)
        if indexPath.row == 0 {
            SharableImage = imgProductImage.image
        }
        imgProductImage.contentMode = .scaleAspectFit
        imgProductImage.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: constants().SCREENSIZE.width, height: self.imgItemCollection.frame.size.height)
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.myPageControl.currentPage = indexPath.row
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
