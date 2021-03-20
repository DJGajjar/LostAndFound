//  SearchPage.swift
//  LostAndFound
//  Created by Revamp on 25/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class SearchPage: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, VoiceOverlayDelegate {
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var mySearchbar : UISearchBar!
    @IBOutlet weak var tblSearchList : UITableView!
    let voiceOverlayController = VoiceOverlayController()

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        constants().APPDEL.ArrAutosuggestionsList.removeAllObjects()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
            self.mySearchbar.searchTextField.clearButtonMode = .never
        }

        self.doSetFrames()
        DispatchQueue.main.async {
            self.mySearchbar.becomeFirstResponder()
            constants().doGetSearchHistory()
            self.tblSearchList.reloadData()
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
        self.mySearchbar.semanticContentAttribute = .forceLeftToRight
        self.mySearchbar.searchTextField.semanticContentAttribute = .forceLeftToRight
        self.mySearchbar.searchTextField.textAlignment = .left

        self.lblTitle.text = NSLocalizedString("search", comment: "")
        self.mySearchbar.searchTextField.placeholder = NSLocalizedString("searchanything", comment: "")

        let buttonAudio = UIButton(type: .custom)
        buttonAudio.backgroundColor = UIColor.clear
        buttonAudio.setImage(UIImage(named: "micIcon"), for: .normal)
        if #available(iOS 13.0, *) {
            buttonAudio.frame = CGRect(x: CGFloat(self.mySearchbar.frame.size.width - 100), y: CGFloat(7.0), width: CGFloat(20), height: CGFloat(40))
        } else {
            buttonAudio.frame = CGRect(x: CGFloat(self.mySearchbar.frame.size.width - 115), y: CGFloat(3.0), width: CGFloat(20), height: CGFloat(40))
        }
        buttonAudio.addTarget(self, action: #selector(self.doAudioSearchButtonClicked(button:)), for: .touchUpInside)
        self.mySearchbar.addSubview(buttonAudio)

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.btnBack.frame
                frame.origin.y = 40
                self.btnBack.frame = frame

                frame = self.mySearchbar.frame
                frame.origin.y = self.lblTitle.frame.origin.y + self.lblTitle.frame.size.height
                self.mySearchbar.frame = frame

                frame = self.tblSearchList.frame
                frame.origin.y = self.mySearchbar.frame.origin.y + self.mySearchbar.frame.size.height
                self.tblSearchList.frame = frame
            }
        }
    }

    func doFetchAutoSuggestions() {
        if constants().APPDEL.isInternetOn(currentController: self) == false {
            return
        }
        let searchString = (self.mySearchbar.text?.replacingOccurrences(of: " ", with: "%20"))!
        apiClass().doAutoSuggestAPI(strKeyword: searchString) { (success, errMessage) in
            DispatchQueue.main.async {
                if success == true {
                    self.tblSearchList.reloadData()
                }
            }
        }
    }

    //MARK:- IBAction Methods
    @objc func doAudioSearchButtonClicked(button: UIButton) {
        voiceOverlayController.start(on: self, textHandler: { (text, final, extraInfo) in
            if final {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                    let myString = text
                    let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
                    let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
                    self.voiceOverlayController.settings.resultScreenText = myAttrString
                    self.voiceOverlayController.settings.layout.resultScreen.titleProcessed = "BLA BLA"
                    if !text.isEmpty {
                        constants().APPDEL.strSearchText = text
                        self.mySearchbar.becomeFirstResponder()
                        self.mySearchbar.text = text
                        self.searchBar(self.mySearchbar, textDidChange: text)
                        self.doGotoSearchResultPage()
                    }
                })
            }
        }, errorHandler: { (error) in
            print("callback: error \(String(describing: error))")
        }, resultScreenHandler: { (text) in
            print("Result Screen: \(text)")
        })
    }

    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        if constants().APPDEL.strOptionSearch == "Marketplace" {
            ivc.selectedIndex = 1
        } else {
            ivc.selectedIndex = 0
        }
        constants().APPDEL.window?.rootViewController = ivc
    }

    func doGotoSearchResultPage() {
        DispatchQueue.main.async {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "searchresult") as! SearchResultPage
            constants().APPDEL.window?.rootViewController = ivc
        }
    }

    //MARK:- Voice Delegate
    func recording(text: String?, final: Bool?, error: Error?) {
        if let error = error {
            print("delegate: error \(error)")
        }
        if error == nil {
//            self.TxtSearchPlaces.text = text
        }
    }

    //MARK:- UISearchBar delegate Methods
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.doFetchAutoSuggestions()
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !constants().APPDEL.ArrSearchHistory.contains(searchBar.text!) {
            constants().APPDEL.ArrSearchHistory.add(searchBar.text!)
            constants().doSaveSearchHistory()
        }
        constants().APPDEL.strSearchText = searchBar.text!
        self.doGotoSearchResultPage()
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        constants().APPDEL.strSearchText = ""
        searchBar.resignFirstResponder()
        constants().APPDEL.ArrAutosuggestionsList.removeAllObjects()
        DispatchQueue.main.async {
            self.tblSearchList.reloadData()
        }
    }

    //MARK:- UITableView delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return constants().APPDEL.ArrAutosuggestionsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white

        let lblSearchText  = cell.viewWithTag(101) as! UILabel
        lblSearchText.text = (constants().APPDEL.ArrAutosuggestionsList.object(at: indexPath.row) as! String)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mySearchbar.text = (constants().APPDEL.ArrAutosuggestionsList.object(at: indexPath.row) as! String)
        constants().APPDEL.strSearchText = self.mySearchbar.text!
        self.doGotoSearchResultPage()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
