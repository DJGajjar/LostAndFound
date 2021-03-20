//  NoPermissionViewController.swift
//  VoiceOverlay
//  Created by Guy Daher on 28/06/2018.
//  Copyright © 2018 Algolia. All rights reserved.

import UIKit

@available(iOS 10.0, *)
public class NoPermissionViewController: UIViewController {
    
    var dismissHandler: (() -> ())? = nil
    var voiceConstants: NoPermissionScreenConstants!
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
  
  
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let margins = view.layoutMarginsGuide

        let goToSettingsButton = FirstPermissionButton(startColor: voiceConstants.startGradientColor, endColor: voiceConstants.endGradientColor)
        let doneWithSettingsButton = UIButton()
        let closeView = CloseView()
        
        let subViews = [titleLabel, subtitleLabel, goToSettingsButton, doneWithSettingsButton, closeView]
        
        ViewHelpers.translatesAutoresizingMaskIntoConstraintsFalse(for: subViews)
        ViewHelpers.addSubviews(for: subViews, in: view)
        
        view.backgroundColor = voiceConstants.backgroundColor
        ViewHelpers.setConstraintsForTitleLabel(titleLabel, margins, voiceConstants.title, voiceConstants.textColor)
        ViewHelpers.setConstraintsForSubtitleLabel(subtitleLabel, titleLabel, margins, voiceConstants.subtitle, voiceConstants.textColor)
        ViewHelpers.setConstraintsForCloseView(closeView, margins, backgroundColor: voiceConstants.backgroundColor)
        ViewHelpers.setConstraintsForFirstButton(goToSettingsButton, margins, voiceConstants.permissionEnableText, voiceConstants.textColor)
        ViewHelpers.setConstraintsForSecondButton(doneWithSettingsButton, goToSettingsButton, margins, voiceConstants.doneText, voiceConstants.textColor)

        goToSettingsButton.addTarget(self, action: #selector(goToSettingsTapped), for: .touchUpInside)
        doneWithSettingsButton.addTarget(self, action: #selector(doneWithSettingsTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeButtonTapped(_:)))
        closeView.addGestureRecognizer(tap)
    }
  
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.preferredMaxLayoutWidth = self.view.frame.width - VoiceUIInternalConstants.sideMarginConstant * 2
        subtitleLabel.preferredMaxLayoutWidth = self.view.frame.width - VoiceUIInternalConstants.sideMarginConstant * 2
        self.view.layoutIfNeeded()
    }

    @objc func goToSettingsTapped() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                
            })
        }
    }

    @objc func doneWithSettingsTapped() {
        dismissMe(animated: true) {
            self.dismissHandler?()
        }
    }

    @objc func closeButtonTapped(_ sender: UITapGestureRecognizer) {
        dismissMe(animated: true)
    }
}
