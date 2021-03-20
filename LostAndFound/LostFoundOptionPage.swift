//  LostFoundOptionPage.swift
//  LostAndFound
//  Created by Revamp on 23/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit

class LostFoundOptionPage: UIViewController {
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var btnLostItem : UIButton!
    @IBOutlet weak var btnFoundItem : UIButton!
    @IBOutlet weak var imgLostView : UIImageView!
    @IBOutlet weak var imgFoundView : UIImageView!

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        view.addGestureRecognizer(panGesture)

        self.doSetFrames()
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        var frame = self.view.frame
        frame.origin.y = translation.y
        self.view.frame = frame
        if translation.y >= constants().swipeCloseArea() {
            frame.origin.y = constants().SCREENSIZE.height
            self.view.frame = frame
            self.doClosePage()
        } else {
            if(gesture.state == UIGestureRecognizer.State.ended) {
                var frame = self.view.frame
                frame.origin.y = 0
                self.view.frame = frame
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let btnPlus = self.tabBarController?.view.viewWithTag(1111) as! UIButton
        btnPlus.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        let btnPlus = self.tabBarController?.view.viewWithTag(1111) as! UIButton
        btnPlus.isHidden = false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
    }

    //MARK:- IBAction Methods
    @IBAction func doClosePage() {
        self.tabBarController?.selectedIndex = 0
        self.tabBarController?.tabBar.isHidden = false
        let btnPlus = self.tabBarController?.view.viewWithTag(1111) as! UIButton
        btnPlus.isHidden = false
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func doLostItem() {
        constants().APPDEL.LocationitemName = ""
        constants().APPDEL.LocationItemAddress = ""
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "addlostitem") as! AddLostItem
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doFoundItem() {
        constants().APPDEL.LocationitemName = ""
        constants().APPDEL.LocationItemAddress = ""
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "addfounditem") as! AddFoundItem
        constants().APPDEL.window?.rootViewController = ivc
    }
}
