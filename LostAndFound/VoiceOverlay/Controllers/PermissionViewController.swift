//
//  ViewController.swift
//  VoiceUI
//
//  Created by Guy Daher on 20/06/2018.
//  Copyright © 2018 Algolia. All rights reserved.

import UIKit
import AVFoundation

@available(iOS 10.0, *)
class PermissionViewController: UIViewController {
    
    var dismissHandler: (() -> ())? = nil
    var speechController: Recordable!
  
    var voiceConstants: PermissionScreenConstants!
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.frame = CGRect(x: 0, y: 20, width: constants().SCREENSIZE.width, height: 50)
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: constants().FONT_BOLD, size: 23)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        titleLabel.text = "Voice Search"
        self.view.addSubview(titleLabel)
        view.backgroundColor = UIColor.white

        let btnClose = UIButton(type: .custom)
        btnClose.frame = CGRect(x: 10, y: 20, width: 50, height: 50)
        btnClose.addTarget(self, action: #selector(self.closeButtonTapped(_:)), for: .touchUpInside)
        btnClose.setImage(UIImage(named: "ic_Cancel"), for: .normal)
        self.view.addSubview(btnClose)

        let btnAllowAccess = UIButton(type: .custom)
        btnAllowAccess.frame = CGRect(x: (constants().SCREENSIZE.width - 320)/2, y: constants().SCREENSIZE.height - 350, width: 320, height: 55)
        btnAllowAccess.setBackgroundImage(UIImage(named: "btnBackground"), for: .normal)
        btnAllowAccess.setTitle("Allow microphone access", for: .normal)
        btnAllowAccess.titleLabel?.font = UIFont(name: constants().FONT_BOLD, size: 18)
        btnAllowAccess.addTarget(self, action: #selector(self.allowMicrophoneTapped), for: .touchUpInside)
        self.view.addSubview(btnAllowAccess)

        let btnReject = UIButton(type: .custom)
        btnReject.frame = CGRect(x: (constants().SCREENSIZE.width - 320)/2, y: btnAllowAccess.frame.origin.y + btnAllowAccess.frame.size.height + 20, width: 320, height: 55)
        btnReject.setBackgroundImage(UIImage(named: "btnBackground"), for: .normal)
        btnReject.setTitle("No", for: .normal)
        btnReject.titleLabel?.font = UIFont(name: constants().FONT_BOLD, size: 18)
        btnReject.addTarget(self, action: #selector(self.rejectMicrophoneTapped), for: .touchUpInside)
        self.view.addSubview(btnReject)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func allowMicrophoneTapped() {
        speechController.requestAuthorization { _ in
            AVAudioSession.sharedInstance().requestRecordPermission({ (isGranted) in
                self.dismissMe(animated: true) {
                    self.dismissHandler?()
                }
            })
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.preferredMaxLayoutWidth = self.view.frame.width - VoiceUIInternalConstants.sideMarginConstant * 2
        subtitleLabel.preferredMaxLayoutWidth = self.view.frame.width - VoiceUIInternalConstants.sideMarginConstant * 2
        self.view.layoutIfNeeded()
    }

    @objc func rejectMicrophoneTapped() {
        dismissMe(animated: true)
    }

    @objc func closeButtonTapped(_ sender: UITapGestureRecognizer) {
        dismissMe(animated: true)
    }
}
