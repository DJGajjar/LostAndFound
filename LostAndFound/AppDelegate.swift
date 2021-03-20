//  AppDelegate.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.
//Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import UserNotifications
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
import PushKit
import CallKit
import Alamofire
import AuthenticationServices
import CoreLocation
import Braintree

struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 60.0
    static let dialingTimeInterval: TimeInterval = 5.0
}

struct AppDelegateConstant {
    static let enableStatsReports: UInt = 1
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var selectedQuser = QBUUser()
    var mainQBuser = QBUUser()

    var window: UIWindow?
    var isCalling = false {
        didSet {
            if UIApplication.shared.applicationState == .background, isCalling == false {
            }
        }
    }

    var qbrtcSession: QBRTCSession?

    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()

    private var callUUID: UUID?
    lazy private var voipRegistry: PKPushRegistry = {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        return voipRegistry
    }()

    var dialogID: String! {
        didSet {
            self.dialog = ChatManager.instance.storage.dialog(withID: dialogID)
        }
    }
    var dialog: QBChatDialog!
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()

    var global_LOC_Manager: CLLocationManager?
    var StrLattitude = ""
    var StrLongitude = ""

    var isMapMode = false

    var dictSignupDetails = NSMutableDictionary()
    var CategoryList = NSMutableArray()
    var dictUserProfile = NSDictionary()
    var ColorList = NSMutableArray()

    var ArrSearchHistory = NSMutableArray()
    var strOptionSearch = ""
    var strSearchText = ""
    var LocationitemName = ""
    var LocationItemAddress = ""

    var strFilterName = ""
    var strFilterCatID = ""
    var strFilterBrandString = ""
    var strFilterColorID = ""
    var strFilterFromDate = ""
    var strFilterToDate = ""
    var strFilterLocation = ""

    var ArrFavLocations = NSMutableArray()

    var isCodeScanDone = false
    var ScanError = ""

    var isMyItem = 0
    var isLostOrFound = 1
    var myItemSelectedSegment = 1

    var psTitle = ""
    var psLocation = ""
    var psEmail = ""
    var psData : Data? = nil
    var psDataExtention = ""

    var LostCollectionContentOffSet = CGPoint(x: 0.0, y: 0.0)
    var FoundCollectionContentOffSet = CGPoint(x: 0.0, y: 0.0)

    var ArrAutosuggestionsList = NSMutableArray()
    var isAdJustClosed = false
    var isPopup = false
    var NativeAdPosition = 100
    var selectedCode = "en"

    //MARK:- UIApplication Delegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window?.backgroundColor = UIColor(red: 232.0/255.0, green: 234.0/255.0, blue: 242.0/255.0, alpha: 1.0)

        // Configure QuickBlOX
        self.doConfigureQuickBlox()

        // Tab Bar Custom Appearance
        let tabBar = UITabBar.appearance()
        tabBar.unselectedItemTintColor = UIColor.black
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()

        // Facebook Sign in
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Firebase library to configure APIs.
        FirebaseApp.configure()

        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        // Google SignIn
        GIDSignIn.sharedInstance().clientID = constants().Google_ClientID

        // Braintree
        BTAppSwitch.setReturnURLScheme(constants().BRAINTREE_URL_SCHEME)

        LocaleManager.setup()

        if constants().doGetLoginStatus() == "true" {
           
           /*
            // Active Location Manager
            self.global_LOC_Manager = CLLocationManager()
            self.global_LOC_Manager?.delegate = self
            self.global_LOC_Manager?.requestAlwaysAuthorization()
            self.global_LOC_Manager?.desiredAccuracy = kCLLocationAccuracyBest
            self.global_LOC_Manager?.allowsBackgroundLocationUpdates = true
            self.global_LOC_Manager?.startUpdatingLocation()
            self.global_LOC_Manager?.startMonitoringSignificantLocationChanges()
             
            self.global_LOC_Manager?.allowsBackgroundLocationUpdates = true
            self.global_LOC_Manager?.pausesLocationUpdatesAutomatically = false
            self.global_LOC_Manager?.distanceFilter = kCLDistanceFilterNone
           */
            
             
                       
            /// Random Rate Timer
            constants().RateAlert()

            // Fetch Position for Native Ad
            constants().FetchNativeAdPosition()

            constants().FetchFavoriteLocations()

            self.QuickBloxSilentLogin()
        }

        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true

        QBRTCClient.instance().add(self)

        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
        self.doPushPermission()
        return true
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {")
        application.registerForRemoteNotifications()
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        print("public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {")
        if application.applicationState == .active {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "chatview") as! ChatViewController
            if constants().APPDEL.window?.rootViewController != ivc {
                if ((userInfo["aps"] as! Dictionary<String, Any>)["alert"] as! String).contains("calling") {
                    QBRequest.user(withID: UInt(userInfo["callerid"] as! String)!, successBlock: { (response, quser) in
                        constants().APPDEL.selectedQuser = quser
                        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "chatview") as! ChatViewController
                        self.dialogID = (userInfo["dialogid"] as! String)
                        constants().APPDEL.window?.rootViewController = ivc
                    }) { (response) in
                        print(" Error ")
                    }
                }
            }
        } else {
            if application.applicationState == .inactive {
                self.isCalling = true
                if ((userInfo["aps"] as! Dictionary<String, Any>)["alert"] as! String).contains("calling") {
                    QBRequest.user(withID: UInt(userInfo["callerid"] as! String)!, successBlock: { (response, quser) in
                        constants().APPDEL.selectedQuser = quser
                    }) { (response) in
                        print(" Error ")
                    }
                }
            }
            if application.applicationState == .background {
                if ((userInfo["aps"] as! Dictionary<String, Any>)["alert"] as! String).contains("calling") {
                    QBRequest.user(withID: UInt(userInfo["callerid"] as! String)!, successBlock: { (response, quser) in
                        constants().APPDEL.selectedQuser = quser
                        let ivc = constants().storyboard.instantiateViewController(withIdentifier: "chatview") as! ChatViewController
                        self.dialogID = (userInfo["dialogid"] as! String)
                        self.window?.rootViewController = ivc
                    }) { (response) in
                        print(" Error ")
                    }
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        debugPrint("App Terminated")
        
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {")
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let deviceIdentifier = identifierForVendor.uuidString
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey:"devicetoken")
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
        }, errorBlock: { response in
            debugPrint("[UsersViewController] Create Subscription request - Error")
        })
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if url.scheme == constants().facebook_SCHEME {
            return ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        if url.scheme == constants().google_SCHEME {
            return GIDSignIn.sharedInstance().handle(url)
        }
        return false
    }

    private func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("private func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {")
    }

    //On Action click
    private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        /*application.applicationIconBadgeNumber = 0
        self.global_LOC_Manager?.stopUpdatingLocation()
        */
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        /*registerForRemoteNotifications()
        ChatManager.instance.connect { (error) in
            if let _ = error {
                return
            }
        }*/
    }

    private func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
            if let error = error {
                debugPrint("[AppDelegate] requestAuthorization error: \(error.localizedDescription)")
                return
            }
            center.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    return
                }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            })
        })
    }

    //MARK:- Push Notification Permission Prompt
    func doPushPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    //MARK:- Location Manager
   /* func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.StrLattitude = String(format: "%.4f", locValue.latitude)
        self.StrLongitude = String(format: "%.4f", locValue.longitude)
        if !self.StrLattitude.isEmpty && !self.StrLongitude.isEmpty {
            constants().SendUserLog_Location(strLat: self.StrLattitude, strLong: StrLongitude)
//            if constants().doEqualCoordinate(cLat: self.StrLattitude, cLong: self.StrLongitude) == true {
//            } else {
//                constants().doSaveLastCoordinate(sLat: self.StrLattitude, sLong: self.StrLongitude)
//                constants().SendUserLog_Location(strLat: self.StrLattitude, strLong: StrLongitude)
//            }
        }
    }
*/
    
    //MARK:- Internet Chkecker
    func isInternetOn(currentController: UIViewController) -> Bool {
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            let ivc = constants().storyboard.instantiateViewController(withIdentifier: "noconnections") as! NoConnections
            ivc.modalPresentationStyle = .fullScreen
            currentController.present(ivc, animated: false, completion: nil)
            return false
        }
        return true
    }

    func MainQBuser() {
        QBRequest.user(withLogin: constants().doGetUserId(), successBlock: { (response, quser) in
            constants().APPDEL.mainQBuser = quser
        }) { (response) in
        }
    }

    //MARK:- QuickBlox
    func doConfigureQuickBlox() {
        QBSettings.applicationID = constants().QUICKBLOX_APPID
        QBSettings.authKey = constants().QUICKBLOX_AUTHKEY
        QBSettings.authSecret = constants().QUICKBLOX_AUTHSECRET
        QBSettings.accountKey = constants().QUICKBLOX_ACCOUNTKEY
        QBSettings.carbonsEnabled = true
        QBSettings.logLevel = .debug
        QBSettings.enableXMPPLogging()
        QBSettings.disableFileLogging()
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        QBRTCConfig.setLogLevel(QBRTCLogLevel.verbose)

        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        QBRTCClient.initializeRTC()
    }

    private func disconnectUser() {
        QBChat.instance.disconnect(completionBlock: { error in
            QBRequest.logOut(successBlock: { [weak self] response in
                Profile.clearProfile()
                ChatManager.instance.storage.clear()
            }) { response in
            }
        })
    }

    func doQuickBloxLogout() {
        if QBChat.instance.isConnected == false {
            return
        }
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let uuidString = identifierForVendor.uuidString
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in
            let subscriptionsUIUD = subscriptions?.first?.deviceUDID
            if subscriptionsUIUD == uuidString {
                QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: uuidString, successBlock: { response in
                    self.disconnectUser()
                }, errorBlock: { error in
                    if let error = error.error {
                        return
                    }
                    SVProgressHUD.dismiss()
                })
            } else {
                self.disconnectUser()
            }
        }) { response in
            if response.status.rawValue == 404 {
                self.disconnectUser()
            }
        }
    }

    //MARK:- Spinner Methods
    func doStartSpinner() {
        DispatchQueue.main.async {
            self.spinner.style = UIActivityIndicatorView.Style.whiteLarge
            self.spinner.frame = CGRect(x:0, y:0, width: constants().SCREENSIZE.width, height: constants().SCREENSIZE.height + 25)
            self.spinner.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.4)
            self.window?.addSubview(self.spinner)
            self.spinner.startAnimating()
        }
    }

    func doStartLanguageSpinner() {
        DispatchQueue.main.async {
            self.spinner.style = UIActivityIndicatorView.Style.whiteLarge
            self.spinner.frame = CGRect(x:0, y:0, width: constants().SCREENSIZE.width, height: constants().SCREENSIZE.height + 25)
            self.spinner.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            self.window?.addSubview(self.spinner)
            self.spinner.startAnimating()
        }
    }

    func doStopSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
        }
    }

    //MARK:- QuickBlox Login
    func QuickBloxSilentLogin() {
        let qlogin = constants().doGetUserId()
        let qfullname = constants().doGetUserFirstName()

        let newUser = QBUUser()
        newUser.login = qlogin
        newUser.fullName = qfullname
        newUser.password = constants().defaultPassword
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            guard let self = self else {
                return
            }
            self.login(fullName: qfullname, login: qlogin)
            }, errorBlock: { [weak self] response in
                if response.status == QBResponseStatusCode.validationFailed {
                    self?.login(fullName: qfullname, login: qlogin)
                    return
                }
        })
    }

    private func login(fullName: String, login: String, password: String = constants().defaultPassword) {
        QBRequest.logIn(withUserLogin: login, password: password, successBlock: { [weak self] response, user in
            guard let self = self else {
                return
            }
            user.password = password
            Profile.synchronize(user)
            self.mainQBuser = user
            self.connectToChat()
            }, errorBlock: { [weak self] response in
                if response.status == QBResponseStatusCode.unAuthorized {
                }
        })
    }

    //MARK:- Create New Dialog
    func doGetQuickBloxUser(nLogin: String) {
        QBRequest.user(withLogin: nLogin, successBlock: { (response, quser) in
            self.selectedQuser = quser
            self.doCreateDialog(sUser: quser)
        }) { (response) in
            print(" Error ")
        }
    }

    func doCreateDialog(sUser: QBUUser) {
        let completion = { [weak self] (response: QBResponse?, dialog: QBChatDialog?) -> Void in
            guard let dialog = dialog else {
                if let error = response?.error {
                }
                return
            }
            self?.openNewDialog(dialog)
        }

        self.createChat(sUser: sUser, completion: completion)
    }

    private func createChat(name: String? = nil, sUser:QBUUser, completion: @escaping ((_ response: QBResponse?, _ createdDialog: QBChatDialog?) -> Void)) {
        ChatManager.instance.createPrivateDialog(withOpponent: sUser, completion: { (response, dialog) in
            guard let dialog = dialog else {
                completion(nil, nil)
                return
            }
            completion(response, dialog)
        })
    }

    private func openNewDialog(_ newDialog: QBChatDialog) {
        let chatController = constants().storyboard.instantiateViewController(withIdentifier: "chatview") as? ChatViewController
        self.dialogID = newDialog.id
        self.window?.rootViewController = chatController
    }

    func call(with conferenceType: QBRTCConferenceType) {
        if self.qbrtcSession != nil {
            return
        }
        if hasConnectivity() {
            CallPermissions.check(with: conferenceType) { granted in
                if granted {
                    let opponentsIDs = [self.selectedQuser.id]
                    //Create new session
                    let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs as [NSNumber], with: conferenceType)
                    if session.id.isEmpty == false {
                        constants().APPDEL.qbrtcSession = session
                        let uuid = UUID()
                        self.callUUID = uuid
                        CallKitManager.instance.startCall(withUserIDs: opponentsIDs as [NSNumber], session: session, uuid: uuid)
                        let storyboard: UIStoryboard = UIStoryboard(name: "Call", bundle: nil)
                        if let callVC = storyboard.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController {
                            callVC.session = constants().APPDEL.qbrtcSession
                            callVC.CallToQuser = self.selectedQuser
                            callVC.callUUID = uuid
                            callVC.modalPresentationStyle = .fullScreen
                            self.window?.rootViewController!.present(callVC , animated: false)
                        }
                        let profile = Profile()
                        guard profile.isFull == true else {
                            return
                        }
                        let opponentName = profile.fullName.isEmpty == false ? profile.fullName : "Unknown user"
                        let payload = ["message": "\(opponentName) is calling you.", "ios_voip": "1", "VOIPCall": "1", "callerid":"\(self.mainQBuser.id)", "dialogid":self.dialogID]
                        let data = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        let arrayUserIDs = opponentsIDs.map({"\($0)"})
                        event.usersIDs = arrayUserIDs.joined(separator: ",")
                        event.type = QBMEventType.oneShot
                        event.message = message
                        QBRequest.createEvent(event, successBlock: { response, events in
                            debugPrint("[UsersViewController] Send voip push - Success")
                        }, errorBlock: { response in
                            debugPrint("[UsersViewController] Send voip push - Error")
                        })
                    } else {
                    }
                }
            }
        }
    }

    //MARK:- Internal Methods
    func hasConnectivity() -> Bool {
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            showAlertView(message: "Please check your Internet connection")
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall")
                }
            }
            return false
        }
        return true
    }

    func showAlertView(message: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
        self.window?.rootViewController!.present(alertController, animated: true)
    }
}

//MARK:- QBRTCClientDelegate
extension AppDelegate: QBRTCClientDelegate {
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if CallKitManager.instance.isCallStarted() == false && constants().APPDEL.qbrtcSession?.id == session.id && constants().APPDEL.qbrtcSession?.initiatorID == userID {
            CallKitManager.instance.endCall(with: callUUID) {
                debugPrint("[UsersViewController] endCall")
            }
            prepareCloseCall()
        }
    }

    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.qbrtcSession != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        constants().APPDEL.qbrtcSession = session
        let uuid = UUID()
        callUUID = uuid
        var opponentIDs = [session.initiatorID]
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        for userID in session.opponentsIDs {
            if userID.uintValue != profile.ID {
                opponentIDs.append(userID)
            }
        }
        
        var callerName = ""
        var opponentNames = [String]()
        let newUsers = [NSNumber]()
        opponentNames.append(self.selectedQuser.fullName!)

        if newUsers.isEmpty == false {
        } else {
            callerName = opponentNames.joined(separator: ", ")
            self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: uuid)
        }
    }

    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs, outCallerName: outCallerName, session: session, uuid: uuid, onAcceptAction: { [weak self] in
                guard let self = self else {
                    return
                }

                QBRequest.user(withID: UInt(truncating: userIDs[0]), successBlock: { (response, quser) in
                    let storyboard: UIStoryboard = UIStoryboard(name: "Call", bundle: nil)
                    if let callVC = storyboard.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController {
                        callVC.session = session
                        callVC.callUUID = self.callUUID
                        callVC.CallToQuser = quser
                        callVC.modalPresentationStyle = .fullScreen
                        self.window?.rootViewController!.present(callVC , animated: false)
                    }
                }) { (response) in
//                    let storyboard: UIStoryboard = UIStoryboard(name: "Call", bundle: nil)
//                    if let callVC = storyboard.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController {
//                        callVC.session = session
//                        callVC.callUUID = self.callUUID
//                        callVC.modalPresentationStyle = .fullScreen
//                        self.window?.rootViewController!.present(callVC , animated: false)
//                    }
                }

//                let storyboard: UIStoryboard = UIStoryboard(name: "Call", bundle: nil)
//                if let callVC = storyboard.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController {
//                    callVC.session = session
//                    callVC.callUUID = self.callUUID
//                    callVC.modalPresentationStyle = .fullScreen
//                    self.window?.rootViewController!.present(callVC , animated: false)
//                }
            }, completion: { (end) in
                    debugPrint("[UsersViewController] endCall")
            })
        } else {
        }
    }

    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = constants().APPDEL.qbrtcSession?.id, sessionID == session.id {
            CallKitManager.instance.endCall(with: self.callUUID) {
                debugPrint("[UsersViewController] endCall")
            }
            prepareCloseCall()
        }
    }

    private func prepareCloseCall() {
        self.callUUID = nil
        constants().APPDEL.qbrtcSession = nil
        if QBChat.instance.isConnected == false {
            self.connectToChat()
        }
    }

    private func connectToChat() {
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        QBChat.instance.connect(withUserID: profile.ID, password: LoginConstant.defaultPassword, completion: { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                } else {
                    debugPrint("[UsersViewController] login error response:\n \(error.localizedDescription)")
                }
            } else {
                SVProgressHUD.dismiss()
            }
        })
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    //MARK:- PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        if payload.dictionaryPayload["VOIPCall"] != nil {
            let application = UIApplication.shared
            if application.applicationState == .background && backgroundTask == .invalid {
                backgroundTask = application.beginBackgroundTask(expirationHandler: {
                    application.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = UIBackgroundTaskIdentifier.invalid
                })
            }
            if QBChat.instance.isConnected == false {
                connectToChat()
            }
        }
    }
}


/// Change in existing code
//Info.plist

//GoogleAds
//OLD SET BY VETHICS.  //GADApplicationIdentifier ca-app-pub-1502776645309201~4059596871
//NEW FROM AMIRBHAI ACCOUNT //GADApplicationIdentifier ca-app-pub-1462000771437197/5105118029

//Facebook
//OLD SET BY VETHICS.  //FacebookAppID  1220257348160280
//NEW FROM lostandfound0786@gmail.com ACCOUNT 586209618621651

//URLSCHEMAS
//ITEM0
//OLD SET BY VETHICS.  //FacebookAppID  fb1220257348160280
//NEW FROM lostandfound0786@gmail.com ACCOUNT fb586209618621651

//UL SCHEMAS
//ITEM1
//OLD SET BY VETHICS. com.googleusercontent.apps.495781592318-6tj72bb96rdfg0gkhptqouk8d4ejh0l4
//NEW FROM lostandfound0786@gmail.com ACCOUNT com.googleusercontent.apps.1013172577936-48b18dib253u3v4m1vqap8qqkh2khtcg

//SMTP Set from lostandfoundreply@gmail.com // Direct in database.

//BrainTree Client Token Generated on server end.
