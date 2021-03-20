//  myTabController.swift
//  LostAndFound
//  Created by Revamp on 23/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
class myTabController: UITabBarController {

    //MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.semanticContentAttribute = .forceLeftToRight
        self.setupMiddleButton()
    }

    //MARK:- Setups
    func setupMiddleButton() {
        var yPadd : CGFloat = 20
        if (constants().userinterface == .pad) {
            yPadd = 22
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                yPadd = 45
            }
        }
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
        menuButton.tag = 1111
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height - yPadd
        menuButtonFrame.origin.x = view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame

        menuButton.backgroundColor = UIColor.red
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        view.addSubview(menuButton)
        menuButton.setImage(UIImage(named: "tab_addItem"), for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)

        view.layoutIfNeeded()
    }

    //MARK:- Actions
    @objc private func menuButtonAction(sender: UIButton) {
        self.tabBar.isHidden = true
        selectedIndex = 2
    }
}
