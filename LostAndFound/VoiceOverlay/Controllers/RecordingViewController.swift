//  ListeningViewController.swift
//  VoiceUI
//  Created by Guy Daher on 25/06/2018.
//  Copyright © 2018 Algolia. All rights reserved.

import UIKit
@available(iOS 10.0, *)
class InputViewController: UIViewController {
    var speechController: Recordable?
    var speechTextHandler: SpeechTextHandler?
    var speechErrorHandler: SpeechErrorHandler?
    var speechResultScreenHandler: SpeechResultScreenHandler?
    weak var delegate: VoiceOverlayDelegate?

    let titleLabel = UILabel()
    let recordingButton = RecordingButton()
    var isRecording: Bool = false
    var autoStopTimer: Timer = Timer()

    var speechText: String?
    var customData: Any?
    var speechError: Error?

    var voiceConstants: InputScreenConstants!
    var settings: VoiceUISettings!

    var dismissHandler: ((Bool) -> ())? = nil
    var resultScreentimer: Timer?

    override func viewDidLoad() {
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

        let lineLabel = UILabel()
        lineLabel.frame = CGRect(x: 0, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, width: constants().SCREENSIZE.width, height: 1)
        lineLabel.textColor = UIColor.clear
        lineLabel.backgroundColor = UIColor.lightGray
        self.view.addSubview(lineLabel)

        let listeningLabel = UILabel()
        listeningLabel.frame = CGRect(x: 0, y: ((constants().SCREENSIZE.height - 60)/2), width: constants().SCREENSIZE.width, height: 60)
        listeningLabel.textColor = UIColor.black
        listeningLabel.font = UIFont(name: constants().FONT_LIGHT, size: 30)
        listeningLabel.text = "I am Listening..."
        listeningLabel.textAlignment = .center
        self.view.addSubview(listeningLabel)

        let imgIcon = UIImageView(image: UIImage(named: "voiceIcon"))
        imgIcon.frame = CGRect(x: (constants().SCREENSIZE.width - 200)/2, y: constants().SCREENSIZE.height - 250, width: 200, height: 200)
        imgIcon.contentMode = .scaleAspectFit
        self.view.addSubview(imgIcon)

        if settings.autoStart {
            titleLabel.text = voiceConstants.titleListening
            toggleRecording(recordingButton)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

  // This is a fix for labels not always showing the current intrinsic multiline height
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.view.layoutIfNeeded()
  }
  
  @objc func recordingButtonTapped() {
    if isRecording {
      speechController?.stopRecording()
    } else {
      toggleRecording(recordingButton)
    }
  }
  
  @objc func closeButtonTapped(_ sender: UITapGestureRecognizer) {
    self.delegate = nil
    self.speechTextHandler = nil
    self.speechErrorHandler = nil
    self.speechResultScreenHandler = nil
    speechController?.stopRecording()
    dismissMe(animated: true) {
      self.dismissHandler?(false)
    }
  }
  
  func toggleRecording(_ recordingButton: RecordingButton, dismiss: Bool = true) {
    isRecording = !isRecording
    recordingButton.animate(isRecording)
    recordingButton.setimage(isRecording)
    
    if isRecording {
    } else {
      speechController?.stopRecording()
      self.delegate?.recording(text: self.speechText, final: true, error: self.speechError)
      
      if let speechText = self.speechText {
        self.speechTextHandler?(speechText, true, self.customData)
      } else {
        self.speechErrorHandler?(self.speechError)
      }
      if dismiss {
        if settings.showResultScreen {
          speechController = nil
        } else {
          dismissMe(animated: true) {
            self.dismissHandler?(false)
          }
        }
      }
      return
    }

    // TODO: Playing sound is crashing. probably because we re not stopping play, or interfering with speech controller, or setActive true/false in playSound
    //recordingButton.playSound(with: isRecording ? .startRecording : .endRecording)
    
    speechController?.startRecording(textHandler: {[weak self] (text, final, customData) in
      guard let strongSelf = self else { return }
      
      strongSelf.speechText = text
      strongSelf.customData = customData
      strongSelf.speechError = nil
    
      if final {
        strongSelf.autoStopTimer.invalidate()
        strongSelf.toggleRecording(recordingButton)
        return
      } else {
        if strongSelf.isRecording {
          strongSelf.delegate?.recording(text: text, final: final, error: nil)
          strongSelf.speechTextHandler?(text, final, customData)
        }
      }

      if strongSelf.settings.autoStop && !text.isEmpty {
        strongSelf.autoStopTimer.invalidate()
        strongSelf.autoStopTimer = Timer.scheduledTimer(withTimeInterval: strongSelf.settings.autoStopTimeout, repeats: false, block: { (_) in
          strongSelf.toggleRecording(recordingButton)
        })
      }
      
      }, errorHandler: { [weak self] error in
        guard let strongSelf = self else { return }
        
        strongSelf.speechText = nil
        strongSelf.customData = nil
        strongSelf.speechError = error
        strongSelf.delegate?.recording(text: nil, final: nil, error: error)
        strongSelf.speechErrorHandler?(error)
        strongSelf.handleVoiceError(error)
    })
  }

  func handleVoiceError(_ error: Error?) {
    toggleRecording(recordingButton, dismiss: false)
  }
}
