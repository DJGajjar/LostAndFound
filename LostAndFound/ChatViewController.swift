//  ChatViewController.swift
//  sample-chat-swift
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.

import UIKit
import Photos
import TTTAttributedLabel
import SafariServices
import CoreTelephony
import QuickbloxWebRTC
import PushKit
import SVProgressHUD

var messageTimeDateFormatter: DateFormatter {
    struct Static {
        static let instance : DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "h:mm a"
            return formatter
        }()
    }
    return Static.instance
}

enum MessageStatus: Int {
    case sent
    case sending
    case notSent
}

struct ChatViewControllerConstant {
    static let messagePadding: CGFloat = 40.0
    static let attachmentBarHeight: CGFloat = 100.0
}

class ChatViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet private weak var collectionView: ChatCollectionView!
    @IBOutlet private weak var BottomToolbar: InputToolbar!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var vwCustomTool: UIView!
    @IBOutlet weak var txtMessageField: UITextView!
    @IBOutlet weak var btnCustomAttachment: UIButton!
    @IBOutlet weak var btnCustomSend: UIButton!
    @IBOutlet weak var btnVideoCall: UIButton!
    @IBOutlet weak var btnAudioCall: UIButton!

    @IBOutlet weak var imgProfileview: UIImageView!
    @IBOutlet weak var lblUserStatus: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTextStatus: UILabel!

    var keyboardHEIGHT : CGFloat = 240.0
    var dictUserSubscription = NSDictionary()

    //MARK:- Properties
    private lazy var chatdatasource: ChatDataSource = {
        let chatdatasource = ChatDataSource()
        chatdatasource.delegate = self
        return chatdatasource
    }()
    private var offsetY: CGFloat = 0.0
    private let blueBubble = UIImage(named: "ios_bubble_blue")
    private let grayBubble = UIImage(named: "ios_bubble_gray")
    private var isDeviceLocked = false
    private var isUploading = false
    private var attachmentMessage: QBChatMessage?

    private var actionsHandler: ChatActionsHandler?
    internal var senderDisplayName = ""
    internal var senderID: UInt = 0
    private var automaticallyScrollsToMostRecentMessage = true
    private var topContentAdditionalInset: CGFloat = 0.0 {
        didSet {
            updateCollectionViewInsets()
        }
    }
    private var enableTextCheckingTypes: NSTextCheckingTypes = NSTextCheckingAllTypes
    private var inputToolBarStartPos: UInt = 0
    private var collectionBottomConstant: CGFloat = 0.0

    //MARK:- Private Properties
    private var isMenuVisible: Bool {
        return selectedIndexPathForMenu != nil && UIMenuController.shared.isMenuVisible
    }

    private lazy var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        return pickerController
    }()

    private var cancel = false
    private var willResignActiveBlock: AnyObject?
    private var willActiveBlock: AnyObject?
    private var selectedIndexPathForMenu: IndexPath?

    private lazy var systemInputToolbar: KVOView = {
        let BottomToolbar = KVOView()
        BottomToolbar.collectionView = collectionView
        BottomToolbar.chatInputView = BottomToolbar
        BottomToolbar.frame = .zero
        BottomToolbar.hostViewFrameChangeBlock = { [weak self] (view: UIView?, animated: Bool) -> Void in
            guard let self = self,
                let superview = self.view.superview else {
                    return
            }

            let inputToolBarStartPos = CGFloat(self.inputToolBarStartPos)
            guard let view = view else {
                self.setupToolbarBottom(constraintValue:inputToolBarStartPos, animated: animated)
                return
            }

            let convertedViewPoint = superview.convert(view.frame.origin, to: view)
            var pos = view.frame.size.height - convertedViewPoint.y
            if self.BottomToolbar.contentView.textView.isFirstResponder, superview.frame.origin.y > 0.0, pos <= 0.0 {
                return
            }
            if pos < inputToolBarStartPos {
                pos = inputToolBarStartPos
            }
        }
        return BottomToolbar
    }()

    private lazy var attachmentBar: AttachmentBar = {
        let attachmentBar = AttachmentBar()
        attachmentBar.setRoundBorderEdgeView(cornerRadius: 0.0, borderWidth: 2.5, borderColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        return attachmentBar
    }()

    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        QBChat.instance.addDelegate(self)

        self.ShowData()

        setupViewMessages()
        chatdatasource.delegate = self
        BottomToolbar.inputToolbarDelegate = self
        BottomToolbar.setupBarButtonsEnabled(left: true, right: false)

        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = [] //same UIRectEdgeNone

        self.txtMessageField.delegate = self
        self.doSetDefaultMessageFieldConfigure()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        CallKitManager.instance.CallToQuser = constants().APPDEL.selectedQuser
    }

    func doSetDefaultMessageFieldConfigure() {
        self.txtMessageField.backgroundColor = UIColor.white
        self.txtMessageField.textColor = UIColor.lightGray
        self.txtMessageField.text = "Type your messages ..."

        var frame = self.txtMessageField.frame
        frame.size.height = 40
        self.txtMessageField.frame = frame

        frame = self.vwCustomTool.frame
        frame.size.height = 60
        frame.origin.y = constants().SCREENSIZE.height - 60
        self.vwCustomTool.frame = frame
    }

    func FetchProStatus() {
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetUserSubscriptionAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.dictUserSubscription = mDict.value(forKey: "subscription") as! NSDictionary
                }
            }
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHEIGHT = keyboardRectangle.height
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.doSetFrames()
        self.FetchProStatus()

        self.btnAudioCall.isEnabled = true
        self.btnVideoCall.isEnabled = true

        QBChat.instance.addDelegate(self)
        let currentUser = Profile()
        guard currentUser.isFull == true else {
                return
        }
        if QBChat.instance.isConnected == true {
            loadMessages()
        }
        senderID = currentUser.ID

        if constants().APPDEL.dialog != nil {
            title = constants().APPDEL.dialog.name ?? ""
        }

        registerForNotifications(true)

        willResignActiveBlock = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.isDeviceLocked = true
        }
        willActiveBlock = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.isDeviceLocked = false
            self?.collectionView.reloadData()
        }

        updateCollectionViewInsets()

        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true, self?.isUploading == true {
                self?.cancelUploadFile()
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        updateConnectionStatus?(Reachability.instance.networkConnectionStatus())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let willResignActive = willResignActiveBlock {
            NotificationCenter.default.removeObserver(willResignActive)
        }
        if let willActiveBlock = willActiveBlock {
            NotificationCenter.default.removeObserver(willActiveBlock)
        }
        NotificationCenter.default.removeObserver(self)
        // clearing typing status blocks
        if constants().APPDEL.dialog != nil {
            constants().APPDEL.dialog.clearTypingStatusBlocks()
        }
        registerForNotifications(false)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight

        self.lblUserName.semanticContentAttribute = .forceLeftToRight
        self.lblTextStatus.semanticContentAttribute = .forceLeftToRight
        self.txtMessageField.semanticContentAttribute = .forceLeftToRight

        self.lblUserStatus.layer.cornerRadius = 7.5
        self.lblUserStatus.layer.masksToBounds = true

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.TopView.frame
                frame.size.height = 90
                self.TopView.frame = frame

                frame = self.collectionView.frame
                frame.origin.y = self.TopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - self.TopView.frame.size.height - self.BottomToolbar.frame.size.height - 5
                self.collectionView.frame = frame
            }
        }
    }

    func ShowData() {
        QBRequest.user(withID: constants().APPDEL.selectedQuser.id, successBlock: { (response, quser) in
            constants().APPDEL.selectedQuser = quser
            CallKitManager.instance.CallToQuser = constants().APPDEL.selectedQuser
            DispatchQueue.main.async {
                self.imgProfileview.image = UIImage(named: "user")
                self.lblUserName.text = constants().APPDEL.selectedQuser.fullName

//                let currentInterval = Date().timeIntervalSince1970
//                let SelectedUserInterval = constants().APPDEL.selectedQuser.lastRequestAt?.timeIntervalSince1970
//                if currentInterval - SelectedUserInterval! > 60 {
//                    self.lblUserStatus.backgroundColor = UIColor.lightGray
//                    self.lblTextStatus.text = "Offline"
//                } else {
//                    self.lblUserStatus.backgroundColor = UIColor(red: 79.0/255.0, green: 179.0/255.0, blue: 121.0/255.0, alpha: 1.0)
//                    self.lblTextStatus.text = "Online"
//                }
                self.lblTextStatus.text = "Offline"
            }
        }) { (response) in
            print(" Error ")
        }
    }

    //MARK:- Setup
    private func setupViewMessages() {
        registerCells()
        collectionView.transform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: 0.0)
        setupInputToolbar()
    }

    private func registerCells() {
        if let headerNib = HeaderCollectionReusableView.nib(),
            let headerIdentifier = HeaderCollectionReusableView.cellReuseIdentifier() {
            collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: headerIdentifier)
        }
        ChatNotificationCell.registerForReuse(inView: collectionView!)
        ChatOutgoingCell.registerForReuse(inView: collectionView!)
        ChatIncomingCell.registerForReuse(inView: collectionView!)
        ChatAttachmentIncomingCell.registerForReuse(inView: collectionView!)
        ChatAttachmentOutgoingCell.registerForReuse(inView: collectionView!)
    }

    private func setupInputToolbar() {
        BottomToolbar.delegate = self
        BottomToolbar.contentView.textView.delegate = self
        let accessoryImage = UIImage(named: "attachment_ic")
        let normalImage = accessoryImage?.imageMasked(color: .lightGray)
        let highlightedImage = accessoryImage?.imageMasked(color: .darkGray)
        let accessorySize = CGSize(width: accessoryImage?.size.width ?? 32.0, height: 32.0)
        let accessoryButton = UIButton(frame: CGRect(origin: .zero, size: accessorySize))
        accessoryButton.setImage(normalImage, for: .normal)
        accessoryButton.setImage(highlightedImage, for: .highlighted)
        accessoryButton.contentMode = .scaleAspectFit
        accessoryButton.backgroundColor = .clear
        accessoryButton.tintColor = .lightGray
        BottomToolbar.contentView.leftBarButtonItem = accessoryButton

        let sendTitle = "Send"
        let titleMaxHeight:CGFloat = 32.0
        let titleMaxSize = CGSize(width: .greatestFiniteMagnitude, height: titleMaxHeight)
        let titleLabel = UILabel(frame: CGRect(origin: .zero, size: titleMaxSize))
        let font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel.font = font
        titleLabel.text = sendTitle
        titleLabel.sizeToFit()
        let titleSize = CGSize(width: titleLabel.frame.width, height: titleMaxHeight)
        let sendButton = UIButton(frame: CGRect(origin: .zero, size: titleSize))
        sendButton.titleLabel?.font = font
        sendButton.setTitle(sendTitle, for: .normal)
        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.setTitleColor(.darkGray, for: .highlighted)
        sendButton.setTitleColor(.lightGray, for: .disabled)
        sendButton.backgroundColor = .clear
        sendButton.tintColor = .blue

        BottomToolbar.contentView.rightBarButtonItem = sendButton
        BottomToolbar.contentView.textView.inputAccessoryView = systemInputToolbar
    }

    private func setupToolbarBottom(constraintValue: CGFloat, animated: Bool) {
        if constraintValue < 0.0 {
            return
        }
        if animated == false {
            let offsetY = collectionView.contentOffset.y + constraintValue
            collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: offsetY)
        }
        if animated {
            view.layoutIfNeeded()
        }
    }

    //MARK:- Actions
    private func cancelUploadFile() {
        hideAttacnmentBar()
        isUploading = false
        let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("failedtoupload", comment: ""), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (action) in
            self.BottomToolbar.setupBarButtonsEnabled(left: true, right: false)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func viewClass(forItem item: QBChatMessage) -> ChatReusableViewProtocol.Type {
        if item.customParameters["notification_type"] != nil || item.customParameters[ChatDataSourceConstant.dateDividerKey] as? Bool == true {
            return ChatNotificationCell.self
        }
        let hasAttachment = item.attachments?.isEmpty == false
        if item.senderID != senderID {
            return hasAttachment ? ChatAttachmentIncomingCell.self : ChatIncomingCell.self
        } else {
            return hasAttachment ? ChatAttachmentOutgoingCell.self : ChatOutgoingCell.self
        }
    }

    private func attributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        guard let text = messageItem.text  else {
            return nil
        }
        var textString = text
        var textColor = messageItem.senderID == senderID ? UIColor.white : .black
        if messageItem.customParameters["notification_type"] != nil || messageItem.customParameters[ChatDataSourceConstant.dateDividerKey] as? Bool == true {
            textColor = .black
        }
        if messageItem.customParameters["notification_type"] != nil {
            if let dateSent = messageItem.dateSent {
                textString = messageTimeDateFormatter.string(from: dateSent) + "\n" + textString
            }
        }
        let font = UIFont(name: "Helvetica", size: 17)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor, .font: font as Any]
        return NSAttributedString(string: textString, attributes: attributes)
    }

    private func topLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        if constants().APPDEL.dialog.type == .private, messageItem.senderID == senderID {
                return nil
        }
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byTruncatingTail
        let color = UIColor(red: 11.0/255.0, green: 96.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let font = UIFont(name: "Helvetica", size: 17)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: font as Any, .paragraphStyle: paragrpahStyle]
        let topLabelString = ChatManager.instance.storage.user(withID: messageItem.senderID)?.fullName ?? "@\(messageItem.senderID)"
        return NSAttributedString(string: topLabelString, attributes: attributes)
    }

    private func bottomLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString {
        let textColor = messageItem.senderID == senderID ? UIColor.white : .black
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byWordWrapping
        let font = UIFont(name: constants().FONT_REGULAR, size: 13)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor, .font: font as Any, .paragraphStyle: paragrpahStyle]
        guard let dateSent = messageItem.dateSent else {
            return NSAttributedString(string: "")
        }
        let text = messageTimeDateFormatter.string(from: dateSent)
        if messageItem.senderID == self.senderID {
//            text = text + "\n" + statusStringFromMessage(message: messageItem)
        }
//        return NSAttributedString(string: "", attributes: attributes)
        return NSAttributedString(string: text, attributes: attributes)
    }

    private func statusStringFromMessage(message: QBChatMessage) -> String {
        var statusString = ""
        var readLogins: [String] = []
        //check and add users who read the message
        if let readIDs = message.readIDs?.filter({ $0 != NSNumber(value: senderID) }),
            readIDs.isEmpty == false {
            for readID in readIDs {
                guard let user = ChatManager.instance.storage.user(withID: readID.uintValue) else {
                    let userLogin = "@\(readID)"
                    readLogins.append(userLogin)
                    continue
                }
                let userName = user.fullName ?? user.login ?? ""
                if readLogins.contains(userName) {
                    continue
                }
                readLogins.append(userName)
            }
            statusString += message.attachments?.isEmpty == false ? "Seen" : "Read";
            statusString += ": " + readLogins.joined(separator: ", ")
        }
        //check and add users to whom the message was delivered
        if let deliveredIDs = message.deliveredIDs?.filter({ $0 != NSNumber(value: senderID) }) {
            var deliveredLogins: [String] = []
            for deliveredID in deliveredIDs {
                guard let user = ChatManager.instance.storage.user(withID: deliveredID.uintValue) else {
                    let userLogin = "@\(deliveredID)"
                    if readLogins.contains(userLogin) == false {
                        deliveredLogins.append(userLogin)
                    }
                    continue
                }
                let userName = user.fullName ?? user.login ?? ""
                if readLogins.contains(userName) {
                    continue
                }
                if deliveredLogins.contains(userName) {
                    continue
                }
                deliveredLogins.append(userName)
            }
            if deliveredLogins.isEmpty == false {
                if statusString.isEmpty == false {
                    statusString += "\n"
                }
                statusString += "Delivered" + ": " + deliveredLogins.joined(separator: ", ")
            }
        }
        return statusString.isEmpty ? "Sent" : statusString
    }

    private func finishSendingMessage() {
        finishSendingMessage(animated: true)
    }

    private func finishSendingMessage(animated: Bool) {
        let textView = BottomToolbar.contentView.textView
        textView?.setupDefaultSettings()
        textView?.text = nil
        textView?.attributedText = nil
        textView?.undoManager?.removeAllActions()
        if attachmentMessage != nil {
            attachmentMessage = nil
        }
        if isUploading == true {
            BottomToolbar.setupBarButtonsEnabled(left: false, right: false)
        } else {
            BottomToolbar.setupBarButtonsEnabled(left: true, right: false)
        }
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: textView)
        if automaticallyScrollsToMostRecentMessage {
            scrollToBottomAnimated(animated)
        }
    }

    private func scrollToBottomAnimated(_ animated: Bool) {
        if collectionView.numberOfItems(inSection: 0) == 0 {
            return
        }
        var contentOffset = collectionView.contentOffset
        if contentOffset.y == 0 {
            return
        }
        contentOffset.y = 0
        collectionView.setContentOffset(contentOffset, animated: animated)
    }

    private func hideKeyboard(animated: Bool) {
        let hideKeyboardBlock = { [weak self] in
            if self?.BottomToolbar.contentView.textView.isFirstResponder == true {
                self?.BottomToolbar.contentView.resignFirstResponder()
            }
        }
        if animated {
            hideKeyboardBlock()
        } else {
            UIView.performWithoutAnimation(hideKeyboardBlock)
        }
    }

    private func loadMessages(with skip: Int = 0) {
        ChatManager.instance.messages(withID: constants().APPDEL.dialogID, skip: skip, successCompletion: { [weak self] (messages, cancel) in
            self?.cancel = cancel
            self?.chatdatasource.addMessages(messages)
            if self?.isUploading == true {
            } else {
                SVProgressHUD.dismiss()
            }
            }, errorHandler: { [weak self] (error) in
                if error == ChatManagerConstant.notFound {
                    self?.chatdatasource.clear()
                    constants().APPDEL.dialog.clearTypingStatusBlocks()
                    self?.BottomToolbar.isUserInteractionEnabled = false
                    self?.collectionView.isScrollEnabled = false
                    self?.collectionView.reloadData()
                    self?.title = ""
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                }
        })
    }

    private func updateCollectionViewInsets() {
        if topContentAdditionalInset > 0.0 {
            var contentInset = collectionView.contentInset
            contentInset.top = topContentAdditionalInset
            collectionView.contentInset = contentInset
            collectionView.scrollIndicatorInsets = contentInset
        }
    }

    private func showPickerController(_ pickerController: UIImagePickerController, withSourceType sourceType: UIImagePickerController.SourceType) {
        pickerController.sourceType = sourceType
        let show: (UIImagePickerController) -> Void = { [weak self] (pickerController) in
            DispatchQueue.main.async {
                pickerController.sourceType = sourceType
                self?.present(pickerController, animated: true, completion: nil)
                self?.BottomToolbar.setupBarButtonsEnabled(left: false, right: false)
            }
        }

        let accessDenied: (_ withSourceType: UIImagePickerController.SourceType) -> Void = { [weak self] (sourceType) in
            let typeName = sourceType == .camera ? "Camera" : "Photos"
            let title = "\(typeName) Access Disabled"
            let message = "You can allow access to \(typeName) in Settings"
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:])
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        if sourceType == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
            }
        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
            default:
                    accessDenied(sourceType)
            }
        }
    }

    private func showAttachmentBar(with image: UIImage) {
        view.addSubview(attachmentBar)
        attachmentBar.isHidden = true
        attachmentBar.delegate = self
        attachmentBar.frame = CGRect(x: 0, y: 300, width: 100, height: 100)
        attachmentBar.uploadAttachmentImage(image, sourceType: pickerController.sourceType)
        attachmentBar.cancelButton.isHidden = true
        collectionBottomConstant = ChatViewControllerConstant.attachmentBarHeight
        isUploading = true
        BottomToolbar.setupBarButtonsEnabled(left: false, right: false)
    }

    private func hideAttacnmentBar() {
        attachmentBar.removeFromSuperview()
        attachmentBar.imageView.image = nil
        collectionBottomConstant = 0.0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    private func createAttachmentMessage(with attachment: QBChatAttachment) -> QBChatMessage {
        let message = QBChatMessage.markable()
        message.text = "[Attachment]"
        message.senderID = senderID
        message.dialogID = constants().APPDEL.dialogID
        message.deliveredIDs = [(NSNumber(value: senderID))]
        message.readIDs = [(NSNumber(value: senderID))]
        message.dateSent = Date()
        message.customParameters["save_to_history"] = true
        message.attachments = [attachment]
        return message
    }

    private func didPressSend(_ button: UIButton) {
        if let attacmentMessage = attachmentMessage, isUploading == false {
            send(withAttachmentMessage: attacmentMessage)
        }
        if let messageText = currentlyComposedMessageText(), messageText.isEmpty == false {
            if !messageText.isEmpty {
                send(withMessageText: messageText)
            }
        }
    }

    private func send(withAttachmentMessage attachmentMessage: QBChatMessage) {
        hideAttacnmentBar()
        sendMessage(message: attachmentMessage)
    }

    private func send(withMessageText text: String) {
        if text.isEmpty {
            return
        }
        let message = QBChatMessage.markable()
        message.text = text
        message.senderID = senderID
        message.dialogID = constants().APPDEL.dialogID
        message.deliveredIDs = [(NSNumber(value: senderID))]
        message.readIDs = [(NSNumber(value: senderID))]
        message.dateSent = Date()
        message.customParameters["save_to_history"] = true
        sendMessage(message: message)
    }

    private func sendMessage(message: QBChatMessage) {
        ChatManager.instance.send(message, to: constants().APPDEL.dialog) { [weak self] (error) in
            if let error = error {
                return
            }
// Call Notification To User
// To send Push Message Forefully
//            let fName = constants().doGetUserFirstName()
//            QBRequest.sendPush(withText: "New Message from " + fName, toUsers: String(constants().APPDEL.dialog!.recipientID), successBlock: { (response, events) in
//            }) { (error) in
//                print(error.debugDescription)
//            }
            self?.chatdatasource.addMessage(message)
            self?.finishSendingMessage(animated: true)
            self?.doSetDefaultMessageFieldConfigure()
            self?.doViewDown()
        }
    }

    private func currentlyComposedMessageText() -> String? {
        //  auto-accept any auto-correct suggestions
        if let inputDelegate = BottomToolbar.contentView.textView.inputDelegate {
            inputDelegate.selectionWillChange(BottomToolbar.contentView.textView)
            inputDelegate.selectionDidChange(BottomToolbar.contentView.textView)
        }
        return BottomToolbar.contentView.textView.text.stringByTrimingWhitespace()
    }

    //MARK:- UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.doViewUp()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.doViewDown()
        textField.resignFirstResponder()
        return true
    }

    //MARK:- View Up / Down
    func doViewUp() {
        var frame = self.view.frame
        frame.origin.y = -self.keyboardHEIGHT
        self.view.frame = frame
    }

    func doViewDown() {
        var frame = self.view.frame
        frame.origin.y = 0
        self.view.frame = frame
        self.view.endEditing(true)
    }

    //MARK:- Notifications
    private func registerForNotifications(_ registerForNotifications: Bool) {
        let defaultCenter = NotificationCenter.default
        if registerForNotifications {
            defaultCenter.addObserver(self, selector: #selector(didReceiveMenuWillShow(notification:)), name: UIMenuController.willShowMenuNotification, object: nil)
            defaultCenter.addObserver(self, selector: #selector(didReceiveMenuWillHide(notification:)), name: UIMenuController.willHideMenuNotification, object: nil)
        } else {
            defaultCenter.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
            defaultCenter.removeObserver(self, name: UIMenuController.willHideMenuNotification, object: nil)
        }
    }

    @objc private func didReceiveMenuWillShow(notification: Notification) {
        guard let selectedIndexPath = selectedIndexPathForMenu,
            let menu = notification.object as? UIMenuController,
            let selectedCell = collectionView.cellForItem(at: selectedIndexPath) else {
                return
        }
        let defaultCenter = NotificationCenter.default
        defaultCenter.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
        menu.setMenuVisible(false, animated: false)

        let selectedMessageBubbleFrame = selectedCell.convert(selectedCell.contentView.frame, to: view)
        menu.setTargetRect(selectedMessageBubbleFrame, in: view)
        menu.setMenuVisible(true, animated: true)
        defaultCenter.addObserver(self, selector: #selector(didReceiveMenuWillShow(notification:)), name: UIMenuController.willShowMenuNotification, object: nil)
    }

    @objc private func didReceiveMenuWillHide(notification: Notification) {
        if selectedIndexPathForMenu == nil {
            return
        }
        selectedIndexPathForMenu = nil
    }

    @IBAction func doCustomAttachment() {
        self.didPressAccessoryButton(self.btnCustomAttachment)
    }

    @IBAction func doCustomSendMessage() {
        if let attacmentMessage = attachmentMessage, isUploading == false {
            send(withAttachmentMessage: attacmentMessage)
        }
        if let messageText = currentlyComposedMessageText(), messageText.isEmpty == false {
            send(withMessageText: messageText)
        }
        self.send(withMessageText: self.txtMessageField.text!)
    }

    @IBAction func doBack() {
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        ivc.selectedIndex = 3
        constants().APPDEL.window?.rootViewController = ivc
    }

    @IBAction func doVoiceCall(_ sender: UIButton) {
        constants().APPDEL.call(with: QBRTCConferenceType.audio)
    }

    var makeEverythingFree = true
    @IBAction func doVideoCall(_ sender: UIButton) {
        if (self.dictUserSubscription.value(forKey: "plan_type") as! String) == "Pro" {
            constants().APPDEL.call(with: QBRTCConferenceType.video)
        } else {
            if !(self.dictUserSubscription.value(forKey: "video_call_count") as! String).isEmpty && Int(self.dictUserSubscription.value(forKey: "video_call_count") as! String)! >= 3 && !makeEverythingFree {
                let ivc = constants().storyboard.instantiateViewController(withIdentifier: "trypro") as! TryProVersion
                ivc.modalPresentationStyle = .fullScreen
                self.present(ivc, animated: true, completion: nil)
            } else {
                constants().APPDEL.call(with: QBRTCConferenceType.video)
            }
        }
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().UpdateUserVideoCountAPI, method: "POST") { (success, errMessage, mDict) in
        }
    }

    //MARK:- Orientation Method
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { [weak self] (context) in
            self?.updateCollectionViewInsets()
        })
        if BottomToolbar.contentView.textView.isFirstResponder, let splitViewController = splitViewController, splitViewController.isCollapsed == false {
            BottomToolbar.contentView.textView.resignFirstResponder()
        }
    }
}

//MARK:- UIScrollView Delegate
extension ChatViewController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
}

//MARK:- UIImagePickerController Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        guard let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else {
            return
        }
        BottomToolbar.setupBarButtonsEnabled(left: false, right: false)
        showAttachmentBar(with: image)
        picker.dismiss(animated: true, completion: nil)
    }

    // Helper function.
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        BottomToolbar.setupBarButtonsEnabled(left: true, right: false)
    }
}

//MARK:- ChatDataSource Delegate
extension ChatViewController: ChatDataSourceDelegate {
    func chatDataSource(_ chatDataSource: ChatDataSource, willChangeWithMessageIDs IDs: [String]) {
        IDs.forEach{ collectionView.chatCollectionViewLayout?.removeSizeFromCache(forItemID: $0) }
    }

    func chatDataSource(_ chatDataSource: ChatDataSource, changeWithMessages messages: [QBChatMessage], action: ChatDataSourceAction) {
        if messages.isEmpty {
            return
        }
        collectionView.performBatchUpdates({ [weak self] in
            guard let self = self else {
                return
            }
            let indexPaths = chatDataSource.performChangesFor(messages: messages, action: action)
            if indexPaths.isEmpty {
                return
            }
            switch action {
                case .add: self.collectionView.insertItems(at: indexPaths)
                case .update: self.collectionView.reloadItems(at: indexPaths)
                case .remove: self.collectionView.deleteItems(at: indexPaths)
            }
        }, completion: nil)
    }
}

//MARK:- InputToolbar Delegate
extension ChatViewController: InputToolbarDelegate {
    func messagesInputToolbar(_ toolbar: InputToolbar, didPressRightBarButton sender: UIButton) {
        if toolbar.sendButtonOnRight {
            didPressSend(sender)
        } else {
            didPressAccessoryButton(sender)
        }
    }

    func messagesInputToolbar(_ toolbar: InputToolbar, didPressLeftBarButton sender: UIButton) {
        if toolbar.sendButtonOnRight {
            didPressAccessoryButton(sender)
        } else {
            didPressSend(sender)
        }
    }

    func didPressAccessoryButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.showPickerController(self.pickerController, withSourceType: .camera)
        }))
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.showPickerController(self.pickerController, withSourceType: .photoLibrary)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        present(alertController, animated: true, completion: nil)
    }
}

//MARK:- UICollectionView Delegate
extension ChatViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        selectedIndexPathForMenu = indexPath
        return true
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action != #selector(copy(_:)) {
            return false
        }
        guard let item = chatdatasource.messageWithIndexPath(indexPath) else {
            return false
        }
        if  self.viewClass(forItem: item) === ChatNotificationCell.self {
            return false
        }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        guard let message = chatdatasource.messageWithIndexPath(indexPath) else {
            return
        }
        if message.attachments?.isEmpty == false {
            return
        }
        if message.text == nil {
            return
        }
        UIPasteboard.general.string = message.text
    }
}

//MARK:- ChatCollectionView DataSource
extension ChatViewController: ChatCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatdatasource.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:ChatIncomingCell.self), for: indexPath)
        guard let message = chatdatasource.messageWithIndexPath(indexPath) else {
            return cell
        }
        let cellClass = viewClass(forItem: message)
        guard let identifier = cellClass.cellReuseIdentifier() else {
            return cell
        }

        let chatCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let chatCollectionView = collectionView as? ChatCollectionView {
            self.collectionView(chatCollectionView, configureCell: chatCell, for: indexPath)
        }
        chatCell.backgroundColor = UIColor.clear
        let lastSection = collectionView.numberOfSections - 1
        let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        if indexPath.section == lastSection,
            indexPath.item == lastItem,
            cancel == false  {
            loadMessages(with: chatdatasource.loadMessagesCount)
        }
        return chatCell
    }

    func collectionView(_ collectionView: ChatCollectionView, itemIdAt indexPath: IndexPath) -> String {
        guard let message = chatdatasource.messageWithIndexPath(indexPath), let ID = message.id else {
            return "0"
        }
        return ID
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // marking message as read if needed
        if isDeviceLocked == true {
            return
        }
        guard let message = chatdatasource.messageWithIndexPath(indexPath) else {
            return
        }
        if message.readIDs?.contains(NSNumber(value: senderID)) == false {
            ChatManager.instance.read([message], dialog: constants().APPDEL.dialog, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = chatdatasource.messageWithIndexPath(indexPath), let attachment = item.attachments?.first, let attachmentID = attachment.id else {
            return
        }
        let attachmentDownloadManager = AttachmentDownloadManager()
        attachmentDownloadManager.slowDownloadAttachment(attachmentID)
    }

    private func collectionView(_ collectionView: ChatCollectionView, configureCell cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let item = chatdatasource.messageWithIndexPath(indexPath) else {
            return
        }
        if let notificationCell = cell as? ChatNotificationCell {
            notificationCell.isUserInteractionEnabled = false
            notificationCell.notificationLabel.attributedText = attributedString(forItem: item)
            return
        }

        guard let chatCell = cell as? ChatCell else {
            return
        }
        if cell is ChatIncomingCell || cell is ChatOutgoingCell {
            chatCell.textView.enabledTextCheckingTypes = enableTextCheckingTypes
        }
        chatCell.topLabel.text = topLabelAttributedString(forItem: item)
        chatCell.bottomLabel.text = bottomLabelAttributedString(forItem: item)
        if let textView = chatCell.textView {
            textView.text = attributedString(forItem: item)
        }
        chatCell.delegate = self
        chatCell.containerView.bubbleImageView.layer.cornerRadius = 10.0
        chatCell.containerView.bubbleImageView.layer.masksToBounds = true

        if let attachmentCell = cell as? ChatAttachmentCell {
            guard let attachment = item.attachments?.first,
                let attachmentID = attachment.id,
                attachment.type == "image" else {
                    return
            }
            // setup image to attachmentCell
            attachmentCell.setupAttachmentWithID(attachmentID)
            if attachmentCell is ChatAttachmentIncomingCell {
                chatCell.containerView.bubbleImageView.backgroundColor = UIColor.white
            } else if attachmentCell is ChatAttachmentOutgoingCell {
                chatCell.containerView.bubbleImageView.backgroundColor = constants().COLOR_LightBlue
            }
        } else if chatCell is ChatIncomingCell {
            chatCell.containerView.bubbleImageView.backgroundColor = UIColor.white
        } else if chatCell is ChatOutgoingCell {
            chatCell.containerView.bubbleImageView.backgroundColor = constants().COLOR_LightBlue
        }
    }
}

//MARK:- ChatCollectionView Delegate FlowLayout
extension ChatViewController: ChatCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chatLayout = collectionViewLayout as? ChatCollectionViewFlowLayout else {
            return .zero
        }
        return chatLayout.sizeForItem(at: indexPath)
    }

    func collectionView(_ collectionView: ChatCollectionView, layoutModelAt indexPath: IndexPath) -> ChatCellLayoutModel {
        guard let item = chatdatasource.messageWithIndexPath(indexPath),
            let _ = item.id,
            let cellClass = viewClass(forItem: item) as? ChatCellProtocol.Type else {
                return ChatCell.layoutModel()
        }
        var layoutModel = cellClass.layoutModel()
        layoutModel.avatarSize = .zero
        layoutModel.topLabelHeight = 0.0
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5.0
        layoutModel.maxWidthMarginSpace = 20.0
        if cellClass == ChatIncomingCell.self || cellClass == ChatAttachmentIncomingCell.self {
            if constants().APPDEL.dialog.type != .private {
                let topAttributedString = topLabelAttributedString(forItem: item)
                let size = TTTAttributedLabel.sizeThatFitsAttributedString(topAttributedString, withConstraints: CGSize(width: collectionView.frame.width - ChatViewControllerConstant.messagePadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:1)
                layoutModel.topLabelHeight = size.height
                layoutModel.avatarSize = CGSize(width: 35.0, height: 36.0)
            }
            layoutModel.spaceBetweenTopLabelAndTextView = 5
        }

        var bottomAttributedString = bottomLabelAttributedString(forItem: item)
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: collectionView.frame.width - ChatViewControllerConstant.messagePadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
        layoutModel.bottomLabelHeight = floor(size.height)
        return layoutModel
    }

    func collectionView(_ collectionView: ChatCollectionView, minWidthAt indexPath: IndexPath) -> CGFloat {
        guard let item = chatdatasource.messageWithIndexPath(indexPath),
            let _ = item.id else {
                return 0.0
        }
        let frameWidth = collectionView.frame.width
        let constraintsSize = CGSize(width:frameWidth - ChatViewControllerConstant.messagePadding, height: .greatestFiniteMagnitude)
        let attributedString = bottomLabelAttributedString(forItem: item)
        var size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: constraintsSize, limitedToNumberOfLines:0)
        if constants().APPDEL.dialog.type != .private {
            let attributedString = topLabelAttributedString(forItem: item)
            let topLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: constraintsSize, limitedToNumberOfLines:0)
            if topLabelSize.width > size.width {
                size = topLabelSize
            }
        }
        return size.width
    }

    func collectionView(_ collectionView: ChatCollectionView, dynamicSizeAt indexPath: IndexPath, maxWidth: CGFloat) -> CGSize {
        var size: CGSize = .zero
        guard let message = chatdatasource.messageWithIndexPath(indexPath) else {
            return size
        }
        let messageCellClass = viewClass(forItem: message)
        if messageCellClass === ChatAttachmentIncomingCell.self {
            size = CGSize(width: min(200, maxWidth), height: 200)
        } else if messageCellClass === ChatAttachmentOutgoingCell.self {
            let attributedString = bottomLabelAttributedString(forItem: message)
            let bottomLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: min(200, maxWidth), height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
            size = CGSize(width: min(200, maxWidth), height: 200 + ceil(bottomLabelSize.height))
        } else if messageCellClass === ChatNotificationCell.self {
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        } else {
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }
        return size
    }
}

//MARK:- UITextView Delegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.txtMessageField {
            constants().APPDEL.isPopup = true
            self.doViewUp()
            if self.txtMessageField.textColor == UIColor.lightGray {
                self.txtMessageField.text = ""
                self.txtMessageField.textColor = UIColor.black
            }
        }
        if textView != BottomToolbar.contentView.textView {
            return
        }
        if automaticallyScrollsToMostRecentMessage == true {
            scrollToBottomAnimated(true)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView == self.txtMessageField {
            return
        }
        if textView != BottomToolbar.contentView.textView {
            return
        }
        if isUploading == true || attachmentMessage != nil {
            BottomToolbar.setupBarButtonsEnabled(left: false, right: true)
        } else {
            BottomToolbar.setupBarButtonsEnabled(left: true, right: true)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == self.txtMessageField {
            if self.txtMessageField.text.isEmpty {
                self.txtMessageField.text = "Type your messages ..."
                self.txtMessageField.textColor = UIColor.lightGray
            }
            constants().APPDEL.isPopup = false
            return
        }
        if textView != BottomToolbar.contentView.textView {
            return
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == self.txtMessageField {
            if text == "\n" {
                textView.resignFirstResponder()
                self.doViewDown()
                if self.txtMessageField.text.isEmpty {
                    self.txtMessageField.text = "Type your messages ..."
                    self.txtMessageField.textColor = UIColor.lightGray
                }
                return false
            } else {
                let newSize = self.txtMessageField.sizeThatFits(CGSize(width: constants().SCREENSIZE.width - 120 , height: CGFloat.greatestFiniteMagnitude))
                var frame = self.txtMessageField.frame
                frame.size.width = constants().SCREENSIZE.width - 120
                frame.size.height = newSize.height
                self.txtMessageField.frame = frame

                frame = self.vwCustomTool.frame
                frame.size.width = constants().SCREENSIZE.width
                frame.size.height = textView.frame.size.height + 20
                frame.origin.y = constants().SCREENSIZE.height - frame.size.height
                self.vwCustomTool.frame = frame
                return true
            }
        }
        if range.length + range.location > textView.text.count {
            return false
        }
        return true
    }
}

//MARK:- ChatCell Delegate
extension ChatViewController: ChatCellDelegate {
    private func handleNotSentMessage(_ message: QBChatMessage, forCell cell: ChatCell) {
        let alertController = UIAlertController(title: "", message: NSLocalizedString("failedtosend", comment: ""), preferredStyle:.actionSheet)
        let resend = UIAlertAction(title: "Try again sending Message", style: .default) { (action) in
        }
        alertController.addAction(resend)
        let delete = UIAlertAction(title: "Delete Message", style: .destructive) { (action) in
            self.chatdatasource.deleteMessage(message)
        }
        alertController.addAction(delete)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        if alertController.popoverPresentationController != nil {
            view.endEditing(true)
            alertController.popoverPresentationController!.sourceView = cell.containerView
            alertController.popoverPresentationController!.sourceRect = cell.containerView.bounds
        }
        self.present(alertController, animated: true) {
        }
    }

    func chatCellDidTapAvatar(_ cell: ChatCell) {
    }

    private func openZoomVC(image: UIImage) {
        let zoomedVC = ZoomedAttachmentViewController()
        zoomedVC.zoomImageView.image = image
        zoomedVC.modalPresentationStyle = .overCurrentContext
        zoomedVC.modalTransitionStyle = .crossDissolve
        present(zoomedVC, animated: true, completion: nil)
    }

    func chatCellDidTapContainer(_ cell: ChatCell) {
        if let attachmentCell = cell as? ChatAttachmentCell, let attachmentImage = attachmentCell.attachmentImageView.image {
            self.openZoomVC(image: attachmentImage)
        }
    }

    func chatCell(_ cell: ChatCell, didTapAtPosition position: CGPoint) {}
    func chatCell(_ cell: ChatCell, didPerformAction action: Selector, withSender sender: Any) {}
    func chatCell(_ cell: ChatCell, didTapOn result: NSTextCheckingResult) {
        switch result.resultType {
        case NSTextCheckingResult.CheckingType.link:
            guard let strUrl = result.url?.absoluteString else {
                return
            }
            let hasPrefix = strUrl.lowercased().hasPrefix("https://") || strUrl.lowercased().hasPrefix("http://")
            if hasPrefix == true {
                guard let url = URL(string: strUrl) else {
                    return
                }
                let controller = SFSafariViewController(url: url)
                present(controller, animated: true, completion: nil)
            }
        case NSTextCheckingResult.CheckingType.phoneNumber:
            if canMakeACall() == false {
                SVProgressHUD.showInfo(withStatus: "Your Device can't make a phone call")
                break
            }
            view.endEditing(true)
            let alertController = UIAlertController(title: "", message: result.phoneNumber, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            let openAction = UIAlertAction(title: "Call", style: .destructive) { (action) in
                if let phoneNumber = result.phoneNumber,
                    let url = URL(string: "tel:" + phoneNumber) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            alertController.addAction(openAction)
            present(alertController, animated: true) {
            }
        default:
            break
        }
    }

    private func canMakeACall() -> Bool {
        var canMakeACall = false
        if let url = URL.init(string: "tel://"), UIApplication.shared.canOpenURL(url) == true {
            // Check if iOS Device supports phone calls
            let networkInfo = CTTelephonyNetworkInfo()
            guard let carrier = networkInfo.subscriberCellularProvider else {
                return false
            }
            let mobileNetworkCode = carrier.mobileNetworkCode
            if mobileNetworkCode?.isEmpty == true {
                // Device cannot place a call at this time.  SIM might be removed.
            } else {
                // iOS Device is capable for making calls
                canMakeACall = true
            }
        } else {
            // iOS Device is not capable for making calls
        }
        return canMakeACall
    }
}

//MARK:- QBChat Delegate
extension ChatViewController: QBChatDelegate {
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        if senderID == readerID || dialogID != constants().APPDEL.dialogID {
            return
        }
        guard let message = chatdatasource.messageWithID(messageID) else {
            return
        }
        message.readIDs?.append(NSNumber(value: readerID))
        chatdatasource.updateMessage(message)
    }

    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        if senderID == userID || dialogID != constants().APPDEL.dialogID {
            return
        }
        guard let message = chatdatasource.messageWithID(messageID) else {
            return
        }
        message.deliveredIDs?.append(NSNumber(value: userID))
        chatdatasource.updateMessage(message)
    }

    func chatDidReceive(_ message: QBChatMessage) {
        if message.dialogID == constants().APPDEL.dialogID {
            chatdatasource.addMessage(message)
        }
    }

    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        if dialogID == constants().APPDEL.dialogID {
            chatdatasource.addMessage(message)
        }
    }

    func chatDidConnect() {
        refreshAndReadMessages()
    }

    func chatDidReconnect() {
        refreshAndReadMessages()
    }

    //MARK:- Help
    private func refreshAndReadMessages() {
        loadMessages()
    }
}

//MARK:- AttachmentBar Delegate
extension ChatViewController: AttachmentBarDelegate {
    func attachmentBarFailedUpLoadImage(_ attachmentBar: AttachmentBar) {
        cancelUploadFile()
    }

    func attachmentBar(_ attachmentBar: AttachmentBar, didUpLoadAttachment attachment: QBChatAttachment) {
        attachmentMessage = createAttachmentMessage(with: attachment)
        isUploading = false
        BottomToolbar.setupBarButtonsEnabled(left: false, right: true)
        if let attacmentMessage = attachmentMessage, isUploading == false {
            send(withAttachmentMessage: attacmentMessage)
        }
    }

    func attachmentBar(_ attachmentBar: AttachmentBar, didTapCancelButton: UIButton) {
        attachmentMessage = nil
        BottomToolbar.setupBarButtonsEnabled(left: true, right: false)
        hideAttacnmentBar()
    }
}
