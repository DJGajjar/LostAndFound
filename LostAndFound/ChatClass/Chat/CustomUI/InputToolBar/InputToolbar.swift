//  InputToolbar.swift
//  Swift-ChatViewController
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.

import UIKit
protocol InputToolbarDelegate: UIToolbarDelegate {
    func messagesInputToolbar(_ toolbar: InputToolbar, didPressRightBarButton sender: UIButton)
    func messagesInputToolbar(_ toolbar: InputToolbar, didPressLeftBarButton sender: UIButton)
}

class InputToolbar: UIToolbar {
    private var rightButtonStatusObserver:NSKeyValueObservation?
    private var leftButtonStatusObserver:NSKeyValueObservation?
    weak var inputToolbarDelegate: InputToolbarDelegate?

    override weak var delegate: UIToolbarDelegate? {
        didSet{
            inputToolbarDelegate = delegate as? InputToolbarDelegate
        }
    }
    lazy public private(set) var contentView = loadToolbarContentView()
    var sendButtonOnRight = true
    var preferredDefaultHeight: CGFloat = 44.0 {
        didSet {
            assert(preferredDefaultHeight > 0.0, "Invalid parameter not satisfying: preferredDefaultHeight > 0.0")
        }
    }

    func setupBarButtonsEnabled(left: Bool, right: Bool) {
        contentView.rightBarButtonItem?.isEnabled = right
        contentView.leftBarButtonItem?.isEnabled = left
    }

    func toggleSendButtonEnabled(isUploaded: Bool) {
        let hasText = contentView.textView.hasText
        let hasTextAttachment = contentView.textView.hasTextAttachment()
        if sendButtonOnRight == true || isUploaded == true {
            contentView.rightBarButtonItem?.isEnabled = hasText || isUploaded
        } else {
            contentView.leftBarButtonItem?.isHidden = !(hasText || hasTextAttachment)
        }
    }

    open func loadToolbarContentView() -> ToolbarContentView {
        let nibName = String(describing:ToolbarContentView.self)
        let objects = Bundle.main.loadNibNamed(nibName, owner: nil)
        let toolbarContentView = objects!.first as! ToolbarContentView
        return toolbarContentView
    }

    // MARK:- Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
//        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        layoutIfNeeded()
        let toolbarContentView: ToolbarContentView? = loadToolbarContentView()
        if let toolbarContentView = toolbarContentView {
            addSubview(toolbarContentView)
            contentView = toolbarContentView
        }
        pinAllEdges(ofSubview: toolbarContentView)
//        setNeedsUpdateConstraints()
        addObservers()
        toggleSendButtonEnabled(isUploaded: false)
    }

    deinit {
        removeObservers()
        contentView.removeFromSuperview()
    }

    //MARK:- Actions
    @objc func leftBarButtonPressed(_ sender: UIButton) {
        inputToolbarDelegate?.messagesInputToolbar(self, didPressLeftBarButton: sender)
    }

    @objc func rightBarButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        inputToolbarDelegate?.messagesInputToolbar(self, didPressRightBarButton: sender)
    }

    //MARK:- Input toolbar
    func toggleButtons() {
        let hasText = contentView.textView.text.isEmpty == false
        let hasTextAttachment = contentView.textView.hasTextAttachment()
        let hasDataToSend: Bool = hasText || hasTextAttachment
        var buttonToUpdate = UIButton()

        if sendButtonOnRight == true {
            if let rightBarButtonItem = contentView.rightBarButtonItem {
                buttonToUpdate = rightBarButtonItem
                buttonToUpdate.isHidden = !hasDataToSend
                buttonToUpdate.isEnabled = contentView.textView.hasText
            }
        } else {
            if let leftBarButtonItem = contentView.leftBarButtonItem {
                buttonToUpdate = leftBarButtonItem
                buttonToUpdate.isHidden = !hasDataToSend
                buttonToUpdate.isEnabled = contentView.textView.hasText
            }
        }
    }

    //MARK:- observing
    func addObservers() {
        leftButtonStatusObserver = contentView.observe(\ToolbarContentView.leftBarButtonItem, options: [.new, .old], changeHandler: {[weak self] (contentView, change) in
            guard let self = self else {
                return
            }
            guard let leftButton = change.newValue  as? UIButton else {
                return
            }
            leftButton.addTarget(self, action: #selector(self.leftBarButtonPressed(_:)), for: .touchUpInside)})
            rightButtonStatusObserver = contentView.observe(\ToolbarContentView.rightBarButtonItem, options: [.new, .old], changeHandler: {[weak self] (contentView, change) in
                guard let self = self else {
                    return
                }
                guard let leftButton = change.newValue  as? UIButton else {
                    return
                }
                leftButton.addTarget(self, action: #selector(self.rightBarButtonPressed(_:)), for: .touchUpInside)
        })
    }

    func removeObservers() {
        if let leftButtonObserver = leftButtonStatusObserver {
            leftButtonObserver.invalidate()
            leftButtonStatusObserver = nil
        }
        if let rightButtonObserver = rightButtonStatusObserver {
            rightButtonObserver.invalidate()
            rightButtonStatusObserver = nil
        }
    }
}
