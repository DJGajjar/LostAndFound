//
//  ResultViewController.swift
//  VoiceOverlay
//
//  Created by Guy Daher on 10/07/2018.
//  Copyright © 2018 Algolia. All rights reserved.

import UIKit

@available(iOS 10.0, *)
public class ResultViewController: UIViewController {
  
  public var voiceConstants: ResultScreenConstants!
  
  public let titleLabel = UILabel()
  public let subtitleLabel = UILabel()
  public let startAgainButton = UIButton()
  
  // The bool specifies whether we dismiss with retry or not
  public var dismissHandler: ((Bool) -> ())? = nil
  public var timerTimer: TimeInterval = 3
  public var timer = Timer()
  
  var voiceOutputText: NSAttributedString? {
    didSet {
      titleLabel.text = voiceConstants.titleProcessed
      subtitleLabel.attributedText = voiceOutputText
    }
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    timer = Timer.scheduledTimer(withTimeInterval: timerTimer, repeats: false, block: {[weak self] _  in
      self?.dismissHandler?(false)
    })
    let margins = view.layoutMarginsGuide
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.titleProcessedReceived(_:)), name: NSNotification.Name(rawValue: "titleProcessedNotification"), object: nil)
    
    let subViews = [titleLabel, subtitleLabel, startAgainButton]
    
    ViewHelpers.translatesAutoresizingMaskIntoConstraintsFalse(for: subViews)
    ViewHelpers.addSubviews(for: subViews, in: view)
    
    view.backgroundColor = voiceConstants.backgroundColor
    ViewHelpers.setConstraintsForTitleLabel(titleLabel, margins, voiceConstants.title, voiceConstants.textColor)
    ViewHelpers.setConstraintsForSubtitleLabel(subtitleLabel, titleLabel, margins, voiceConstants.subtitle, voiceConstants.textColor)
    ViewHelpers.setConstraintsForFirstButton(startAgainButton, margins, voiceConstants.startAgainText, voiceConstants.textColor)
    startAgainButton.backgroundColor = .clear
    startAgainButton.layer.cornerRadius = 7
    startAgainButton.layer.borderWidth = 1
    startAgainButton.layer.borderColor = voiceConstants.textColor.cgColor
    
    startAgainButton.addTarget(self, action: #selector(startAgainTapped), for: .touchUpInside)
  }
  
  @objc func startAgainTapped() {
    timer.invalidate()
    dismissHandler?(true)
  }
  
  @objc func titleProcessedReceived(_ notification: NSNotification) {
    if let titleProcessed = notification.userInfo?["titleProcessed"] as? String {
      titleLabel.text = titleProcessed
    }
  }
}
