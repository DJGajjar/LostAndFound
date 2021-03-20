//  LeaderboardStats.swift
//  LostAndFound
//  Created by Revamp on 07/10/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class LeaderboardStats: UIViewController {
    @IBOutlet weak var imgTopImage1 : UIImageView!
    @IBOutlet weak var imgTopImage2 : UIImageView!
    @IBOutlet weak var ContentView : UIScrollView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var lblFoundItemTitle : UILabel!
    @IBOutlet weak var lblFoundItems : UILabel!
    @IBOutlet weak var lblPointsTitle : UILabel!
    @IBOutlet weak var lblPoints : UILabel!
    @IBOutlet weak var lblUsername : UILabel!
    @IBOutlet weak var lblUserLocation : UILabel!
    @IBOutlet weak var starRatingView: SwiftyStarRatingView!

    @IBOutlet weak var vwFoundedItems: UIView!
    @IBOutlet weak var lblFoundedTitle: UILabel!
    @IBOutlet weak var lblLastSixMonthTitle: UILabel!
    @IBOutlet weak var lblTotalFoundedItems: UILabel!
    @IBOutlet weak var foundItemChart: PXLineChartView!

    @IBOutlet weak var vwFoundedItemsCategory: UIView!
    @IBOutlet weak var lblFoundedCategorywise: UILabel!
    @IBOutlet weak var CategoryItemChart: UIView!

    var lines: [[PointItemProtocol]]!
    var xElements: [String]!
    var yElements: [String]!

    var finderID = ""
    var dictUserLeaderboard = NSDictionary()

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doApplyLocalisation()
        self.doSetFrames()
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id": self.finderID], APIName: apiClass().GetMyLeaderboardAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.dictUserLeaderboard = mDict.value(forKey: "leaderboard") as! NSDictionary
                    self.imgProfile.loadProfileImage(url: (self.dictUserLeaderboard.value(forKey: "image") as! String))
                    self.lblFoundItems.text = (self.dictUserLeaderboard.value(forKey: "total_find_item") as? String)
                    self.lblTotalFoundedItems.text = (self.dictUserLeaderboard.value(forKey: "total_find_item") as? String)
                    self.lblPoints.text = (self.dictUserLeaderboard.value(forKey: "total_point") as? String)
                    self.lblUsername.text = "\(self.dictUserLeaderboard.value(forKey: "first_name") as! String) \(self.dictUserLeaderboard.value(forKey: "last_name") as! String)"
                    self.lblUserLocation.text = (self.dictUserLeaderboard.value(forKey: "address1") as! String)

                    if let RString = self.dictUserLeaderboard.value(forKey: "user_rating") as? String {
                        if RString.isEmpty {
                            self.starRatingView.value = 0.0
                        } else {
                            self.starRatingView.value = CGFloat(Double(RString) ?? 0)
                        }
                    } else {
                        self.starRatingView.value = 0.0
                    }

                    self.doConfigureChart()
                    self.doConfigureItemChart()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func doConfigureChart() {
        lines = lineData()
        foundItemChart.delegate = self
        xElements = ["Jan","Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        yElements = ["1","5","10"]
        foundItemChart.reloadData()
    }

    func lineData() -> [[PointItemProtocol]] {
        let fArray = self.dictUserLeaderboard.value(forKey: "founded_item") as! NSArray
        var firstLineItems: [PointItemProtocol] = []
        for i in 0..<fArray.count {
            var item = PointItem()
            let itemDic = fArray[i] as! NSDictionary
            item.price = itemDic["total_found_item"]! as! String
            item.time = itemDic["found_month"]! as! String
            item.chartLineColor = constants().COLOR_LightBlue
            item.chartPointColor = constants().COLOR_LightBlue
            item.pointValueColor = constants().COLOR_LightBlue
            item.chartFillColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 0.15)
            item.chartFill = true
            firstLineItems.append(item)
        }
        return [firstLineItems]
    }

    func doConfigureItemChart() {
        let fArray = self.dictUserLeaderboard.value(forKey: "founded_item_category") as! NSArray
        let colorArray = [UIColor.yellow, UIColor.cyan, UIColor.purple, UIColor.green, UIColor.gray, UIColor.red, UIColor.magenta, UIColor.black, UIColor.brown, UIColor.orange, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.purple, UIColor.green, UIColor.gray, UIColor.red, UIColor.magenta, UIColor.black, UIColor.brown, UIColor.orange, UIColor.blue]
        var catItems = [] as Array
        for i in 0..<fArray.count {
            let itemDict = fArray[i] as! NSDictionary
            let cRatio = uint(itemDict.value(forKey: "total_found_item") as! String)!
            let firstItem: RKPieChartItem = RKPieChartItem(ratio: cRatio, color: colorArray[i], title: (itemDict.value(forKey: "category_name") as! String))
            catItems.append(firstItem)
        }

        let chartView = RKPieChartView(items: catItems as! [RKPieChartItem], centerTitle: "Category wise")
        chartView.frame = CGRect(x: 0, y: 0, width: 345, height: 300)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.arcWidth = 30
        chartView.style = .butt
        chartView.isTitleViewHidden = false
        chartView.isIntensityActivated = false
        chartView.isAnimationActivated = true
        chartView.circleColor = constants().COLOR_LightBlue
        chartView.backgroundColor = UIColor.clear
        self.CategoryItemChart.addSubview(chartView)

        chartView.widthAnchor.constraint(equalToConstant: 345).isActive = true
        chartView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight

        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2.0
        self.imgProfile.layer.borderColor = UIColor(red: 119.0/255.0, green: 157.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor
        self.imgProfile.layer.borderWidth = 2.5
        self.imgProfile.layer.masksToBounds = true

        self.vwFoundedItems.layer.shadowColor = UIColor(red:220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0).cgColor
        self.vwFoundedItems.layer.shadowOffset = CGSize(width: 1.5, height: 3.0)
        self.vwFoundedItems.layer.shadowOpacity = 0.7
        self.vwFoundedItems.layer.shadowRadius = 3.0
        self.vwFoundedItems.layer.cornerRadius = 10.0

        self.vwFoundedItemsCategory.layer.shadowColor = UIColor(red:220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0).cgColor
        self.vwFoundedItemsCategory.layer.shadowOffset = CGSize(width: 1.5, height: 3.0)
        self.vwFoundedItemsCategory.layer.shadowOpacity = 0.7
        self.vwFoundedItemsCategory.layer.shadowRadius = 3.0
        self.vwFoundedItemsCategory.layer.cornerRadius = 10.0

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.ContentView.frame
                frame.origin.y = 20
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.ContentView.frame = frame
            }
        }

        self.ContentView.contentSize = CGSize(width: constants().SCREENSIZE.width, height: self.vwFoundedItemsCategory.frame.origin.y + self.vwFoundedItemsCategory.frame.size.height + 20)
    }

    func doApplyLocalisation() {
        self.lblTitle.text = NSLocalizedString("leaderboardstates", comment: "")
        self.lblFoundItemTitle.text = NSLocalizedString("founditems", comment: "")
        self.lblPointsTitle.text = NSLocalizedString("points", comment: "")
        self.lblFoundedTitle.text = NSLocalizedString("foundeditems", comment: "")
        self.lblLastSixMonthTitle.text = NSLocalizedString("lastsixmonth", comment: "")
        self.lblFoundedCategorywise.text = NSLocalizedString("foundeditemcategorywise", comment: "")
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LeaderboardStats: PXLineChartViewDataSource {
    func numberOfChartlines() -> Int {
        return lines.count
    }

    func lineChartViewAxisAttributes() -> AxisAttributes {
        return (nil, Float(40), Float(40), Float(50), Float(25), UIColor(red: 200.0/255, green: 200.0/255, blue: 200.0/255, alpha: 1), UIColor(red: 200.0/255, green: 200.0/255, blue: 200.0/255, alpha: 1), UIColor(red: 244.0/255, green: 244.0/255, blue: 244.0/255, alpha: 1), false, UIFont.systemFont(ofSize: 10), false, true, true, Float(2))
    }

    func plotsOflineIndex(_ lineIndex: Int) -> [PointItemProtocol] {
        return lines[lineIndex]
    }

    func numberOfElementsCountWithAxisType(_ axisType: AxisType) -> Int {
        return (axisType == .AxisTypeY) ?  yElements.count : xElements.count;
    }

    func elementWithAxisType(_ axisType: AxisType, _ axisIndex: Int) -> UILabel {
        let label = UILabel()
        var axisValue = ""
        if axisType == .AxisTypeX {
            axisValue = xElements[axisIndex]
            label.textAlignment = .center
        } else {
            axisValue = yElements[axisIndex]
            label.textAlignment = .right
        }
        label.text = axisValue
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.black
        return label
    }
}
