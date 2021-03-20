//  ChatList.swift
//  LostAndFound
//  Created by Revamp on 23/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import Quickblox
import SVProgressHUD
class DialogCollectionCellModel: NSObject {
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?

    //MARK:- Life Cycle
    init(dialog: QBChatDialog) {
        super.init()
        if let dialogName = dialog.name {
            textLabelText = dialogName
        }

        // Unread messages counter label
        if dialog.unreadMessagesCount > 0 {
            var trimmedUnreadMessageCount = ""
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            unreadMessagesCounterHiden = false
        } else {
            unreadMessagesCounterLabelText = nil
            unreadMessagesCounterHiden = true
        }
        // Dialog icon
        dialogIcon = UIImage(named: "user")
        if dialog.recipientID == -1 {
            return
        }
        // Getting recipient from users.
        if let recipient = ChatManager.instance.storage.user(withID: UInt(dialog.recipientID)),
            let fullName = recipient.fullName {
            self.textLabelText = fullName
        } else {
            ChatManager.instance.loadUser(UInt(dialog.recipientID)) { [weak self] (user) in
                self?.textLabelText = user?.fullName ?? user?.login ?? ""
            }
        }
    }
}

class ChatList: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var vwTopView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var DialogsCollection : UICollectionView!
    @IBOutlet weak var vwBottomView : UIImageView!
    @IBOutlet weak var vwNoChats : UIView!

    @IBOutlet weak var BottomWhite : UIView!
    @IBOutlet weak var BottomCircle : UIView!

    var ArrChatDialogs: [QBChatDialog] = []
    private let chatManager = ChatManager.instance
    var ChatRefresher : UIRefreshControl!

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doSetFrames()
//        constants().APPDEL.MainQBuser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.vwNoChats.isHidden = true
        self.doConfigureRefreshControl()
        chatManager.delegate = self
        self.reloadContent()
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.reloadContent), userInfo: nil, repeats: false)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Configure Refresh Control
    func doConfigureRefreshControl() {
        self.ChatRefresher = UIRefreshControl()
        self.DialogsCollection!.alwaysBounceVertical = true
        self.ChatRefresher.tintColor = UIColor.white
        self.ChatRefresher.addTarget(self, action: #selector(self.reloadContent), for: .valueChanged)
        self.DialogsCollection.refreshControl = self.ChatRefresher
    }

    func stopRefresher() {
        self.DialogsCollection!.refreshControl?.endRefreshing()
    }

    //MARK:- Other Methods
    func doSetFrames() {
        self.lblTitle.text = NSLocalizedString("chat", comment: "")

        self.BottomCircle.layer.cornerRadius = 40.0
        self.BottomCircle.layer.masksToBounds = true

        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.vwTopView.frame
                frame.size.height = 80
                self.vwTopView.frame = frame

                frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.DialogsCollection.frame
                frame.origin.y = self.vwTopView.frame.origin.y + self.vwTopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.DialogsCollection.frame = frame

                frame = self.vwNoChats.frame
                frame.origin.y = self.vwTopView.frame.origin.y + self.vwTopView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.vwNoChats.frame = frame

                frame = self.BottomWhite.frame
                frame.size.height = 90
                frame.origin.y = constants().SCREENSIZE.height - frame.size.height
                self.BottomWhite.frame = frame

                frame = self.BottomCircle.frame
                frame.origin.y = constants().SCREENSIZE.height - frame.size.height - 40
                self.BottomCircle.frame = frame
            }
        }
    }

    //MARK:- Helpers
    @objc private func reloadContent() {
        self.ArrChatDialogs = chatManager.storage.dialogsSortByUpdatedAt()
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
        }
        DispatchQueue.main.async {
            self.DialogsCollection.reloadData()
            self.stopRefresher()
            if self.ArrChatDialogs.count == 0 {
                self.vwNoChats.isHidden = false
            } else {
                self.vwNoChats.isHidden = true
            }
        }
    }

    //MARK:- UICollectionView Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: constants().SCREENSIZE.width, height: 5)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrChatDialogs.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dialogcell", for: indexPath) as? DialogCollectionCell else {
            return UICollectionViewCell()
        }
        cell.isExclusiveTouch = true
        cell.backgroundColor = UIColor.white
        cell.contentView.isExclusiveTouch = true
        cell.tag = indexPath.row

        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true

        let chatDialog = self.ArrChatDialogs[indexPath.row]
        let cellModel = DialogCollectionCellModel(dialog: chatDialog)
        cell.dialogLastMessage.text = chatDialog.lastMessageText
        if chatDialog.lastMessageText == nil && chatDialog.lastMessageID != nil {
            cell.dialogLastMessage.text = "[Attachment]"
        }
        if chatDialog.lastMessageDate != nil {
            cell.dialogLastTime.text = constants().timeAgoSinceDate(chatDialog.lastMessageDate!, currentDate: Date(), numericDates: true)
        }
        cell.dialogName.text = cellModel.textLabelText
        cell.dialogTypeImage.image = cellModel.dialogIcon
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        cell.unreadMessageCounterHolder.isHidden = cellModel.unreadMessagesCounterHiden

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let nWidth = constants().SCREENSIZE.width - 40
        return CGSize(width: nWidth, height: 64)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let sDialog = self.ArrChatDialogs[indexPath.row]
        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "chatview") as! ChatViewController
        constants().APPDEL.dialogID = sDialog.id

        let newUser = QBUUser()
        newUser.fullName = sDialog.name
        newUser.id = UInt(sDialog.recipientID)
        constants().APPDEL.selectedQuser = newUser
        constants().APPDEL.window?.rootViewController = ivc
    }
}

//MARK:- QBChat Delegate
extension ChatList: QBChatDelegate {
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        chatManager.updateDialog(with: dialogID, with: message)
    }

    func chatDidReceive(_ message: QBChatMessage) {
        guard let dialogID = message.dialogID else {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }

    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        guard let dialogID = message.dialogID else {
            return
        }
        if let _ = chatManager.storage.dialog(withID: dialogID) {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }

    func chatServiceChatDidFail(withStreamError error: Error) {
    }

    func chatDidAccidentallyDisconnect() {
    }

    func chatDidNotConnectWithError(_ error: Error) {
    }

    func chatDidDisconnectWithError(_ error: Error) {
    }

    func chatDidConnect() {
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
        }
    }

    func chatDidReconnect() {
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
        }
    }
}

//MARK:- ChatManagerDelegate
extension ChatList: ChatManagerDelegate {
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog) {
        reloadContent()
        SVProgressHUD.dismiss()
    }

    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
    }

    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        reloadContent()
        SVProgressHUD.dismiss()
        QBChat.instance.addDelegate(self)
    }

    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
    }
}
