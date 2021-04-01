//  constants.swift
//  LostAndFound
//  Created by Revamp on 14/09/19.
//  Copyright © 2019 Revamp. All rights reserved.

import Foundation
import CoreGraphics
import UIKit
import AVFoundation
import StoreKit

class constants {
    // For check if device is iPad or iPhone
    let userinterface = UIDevice.current.userInterfaceIdiom

    // App delegate instance
    let APPDEL = UIApplication.shared.delegate as! AppDelegate

    // Storyboard instance
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

    // Screen bounds
    let SCREENSIZE = UIScreen.main.bounds.size

    let animDuration = 0.4

    let USERTYPE_INDIVIDUAL = "Individual"
    let USERTYPE_ORGANIZATION = "organization"

    let MEMBER_INVITATION_STATUS_ACCEPTED = "accepted"
    let MEMBER_INVITATION_STATUS_PENDING = "pending"

    // Font Types
    let FONT_BOLD      = "HKGrotesk-Bold"
    let FONT_SEMIBOLD  = "HKGrotesk-SemiBold"
    let FONT_REGULAR   = "HKGrotesk-Regular"
    let FONT_Medium    = "HKGrotesk-Medium"
    let FONT_LIGHT     = "HKGrotesk-Light"

    // Application color set
    let COLOR_DARKGRAY = UIColor(red: 25.0/255.0, green: 27.0/255.0, blue: 32.0/255.0, alpha: 1.0)
    let COLOR_GRAY = UIColor(red: 104.0/255.0, green: 105.0/255.0, blue: 111.0/255.0, alpha: 1.0)
    let COLOR_LIGHTGRAY = UIColor(red: 145.0/255.0, green: 145.0/255.0, blue: 150.0/255.0, alpha: 1.0)
    let COLOR_UltraLIGHTGRAY = UIColor(red: 184.0/255.0, green: 184.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    let COLOR_WhiteGRAY = UIColor(red: 232.0/255.0, green: 234.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    let COLOR_TEXTGRAY = UIColor(red: 64.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    let COLOR_PURPLE = UIColor(red: 109.0/255.0, green: 98.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    let COLOR_LightBlue = UIColor(red: 89.0/255.0, green: 69.0/255.0, blue: 242.0/255.0, alpha: 1.0)

    //OLD - let facebook_SCHEME = "fb1220257348160280"
    let facebook_SCHEME = "fb586209618621651"    //NEW - [ from lostandfound0786@gmail.com account ]
    
    //OLD let google_SCHEME = "com.googleusercontent.apps.495781592318-6tj72bb96rdfg0gkhptqouk8d4ejh0l4"
    //OLD let Google_ClientID = "495781592318-6tj72bb96rdfg0gkhptqouk8d4ejh0l4.apps.googleusercontent.com"

//    let google_SCHEME = "com.googleusercontent.apps.495781592318-6tj72bb96rdfg0gkhptqouk8d4ejh0l4"
//    let Google_ClientID = "572135090475-43v32lo0oc24n64qeduijq8ts6d2croc.apps.googleusercontent.com"

    let google_SCHEME = "com.googleusercontent.apps.1013172577936-48b18dib253u3v4m1vqap8qqkh2khtcg" //NEW - [ from lostandfound0786@gmail.com account ] // Lost & Found Live
    let Google_ClientID = "1013172577936-48b18dib253u3v4m1vqap8qqkh2khtcg.apps.googleusercontent.com" //NEW - [ from lostandfound0786@gmail.com account ] // Lost & Found Live

    
    // Braintree URL Scheme
    let BRAINTREE_URL_SCHEME = "com.amir.lostandfound.payments"
  
    // In App Pro Bundle
    let PREMIUM_PRODUCT_ID = "LostAndFound_Pro_Subscription"

    let AD_APP_ID = "ca-app-pub-1462000771437197~3544624340"
    let AD_BANNER_ID = "ca-app-pub-1462000771437197/9003444203"
    let AD_BANNER_TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    let AD_FULL_ID = "ca-app-pub-1462000771437197/3186003139"
    let AD_FULL_TEST_ID = "ca-app-pub-3940256099942544/4411468910"
    let AD_NATIVE_ID = "ca-app-pub-1502776645309201/6739060091"
    let AD_NATIVE_TEST_ID = "ca-app-pub-3940256099942544/3986624511"

    //QUICK BLOX
    /* Set by Vethics.
    let QUICKBLOX_APPID: UInt = 78960
    let QUICKBLOX_AUTHKEY = "p3guKrWH-ttxLUX"
    let QUICKBLOX_AUTHSECRET = "q3nQkZvs2GMMMJx"
    let QUICKBLOX_ACCOUNTKEY = "byLaDZhvCGgaDRLV5sZe"
    let defaultPassword = "12345678"
    */
    
    let QUICKBLOX_APPID: UInt = 79757
    let QUICKBLOX_AUTHKEY = "sz2FsgbKP4Xm3d2"
    let QUICKBLOX_AUTHSECRET = "DKg2Qpne7DggbHF"
    let QUICKBLOX_ACCOUNTKEY = "-MuePxqYyQYg-y4v43xy"
    let defaultPassword = "12345678"
    
    //DATE FORMATTER
    let DISPLAY_DATEFORMAT = "dd MMM, yyyy"
    let DISPLAY_DATETIMEFORMAT = "dd MMM, yyyy HH:mm"
    let SUBMIT_DATEFORMAT = "yyyy-MM-dd"
    let SUBMIT_DATETIMEFORMAT = "yyyy-MM-dd HH:mm"

    //MARK:- Notification Icon
    func NotificationTypeIcon(nType:String) -> UIImage {
        var nName = "notif_other"
        switch nType {
        case "new_user":
            nName = "notif_other"
        case "winner":
            nName = "notif_troffy"
        case "monthly_update":
            nName = "notif_croud"
        case "add_found_item":
            nName = "notif_other"
        case "add_lost_item":
            nName = "notif_other"
        default:
            nName = "notif_other"
            break
        }
        return UIImage(named: nName)!
    }

    //MARK:- Notification Color
    func NotificationTypeColor(nType: String) -> UIColor {
        var nColor = self.COLOR_LightBlue
        switch nType {
        case "new_user":
            nColor = self.COLOR_LightBlue
        case "winner":
            nColor = UIColor(red: 235.0/255.0, green: 181.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        case "monthly_update":
            nColor = UIColor(red: 226.0/255.0, green: 58.0/255.0, blue: 39.0/255.0, alpha: 1.0)
        case "add_found_item":
            nColor = self.COLOR_LightBlue
        case "add_lost_item":
            nColor = UIColor(red: 71.0/255.0, green: 160.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        default:
            nColor = self.COLOR_LightBlue
            break
        }
        return nColor
    }

    // Tribute Cell Colors
    func tributeBackgroundColor(indexRow: Int) -> UIColor {
        var CELL_COLOR = UIColor(red: 195.0/255.0, green: 155.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        switch indexRow {
        case 0:
            CELL_COLOR = UIColor(red: 195.0/255.0, green: 155.0/255.0, blue: 37.0/255.0, alpha: 1.0)
            break
        case 1:
            CELL_COLOR = UIColor(red: 83.0/255.0, green: 48.0/255.0, blue: 229.0/255.0, alpha: 1.0)
            break
        case 2:
            CELL_COLOR = UIColor(red: 56.0/255.0, green: 128.0/255.0, blue: 232.0/255.0, alpha: 1.0)
            break
        case 3:
            CELL_COLOR = UIColor(red: 57.0/255.0, green: 157.0/255.0, blue: 227.0/255.0, alpha: 1.0)
            break
        case 4:
            CELL_COLOR = UIColor(red: 71.0/255.0, green: 161.0/255.0, blue: 106.0/255.0, alpha: 1.0)
            break
        case 5:
            CELL_COLOR = UIColor(red: 134.0/255.0, green: 42.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            break
        case 6:
            CELL_COLOR = UIColor(red: 26.0/255.0, green: 52.0/255.0, blue: 192.0/255.0, alpha: 1.0)
            break
        case 7:
            CELL_COLOR = UIColor(red: 73.0/255.0, green: 184.0/255.0, blue: 222.0/255.0, alpha: 1.0)
            break
        case 8:
            CELL_COLOR = UIColor(red: 213.0/255.0, green: 43.0/255.0, blue: 120.0/255.0, alpha: 1.0)
            break
        case 9:
            CELL_COLOR = UIColor(red: 214.0/255.0, green: 158.0/255.0, blue: 40.0/255.0, alpha: 1.0)
            break
        case 10:
            CELL_COLOR = UIColor(red: 226.0/255.0, green: 119.0/255.0, blue: 38.0/255.0, alpha: 1.0)
            break
        case 11:
            CELL_COLOR = UIColor(red: 100.0/255.0, green: 49.0/255.0, blue: 197.0/255.0, alpha: 1.0)
            break
        case 12:
            CELL_COLOR = UIColor(red: 199.0/255.0, green: 169.0/255.0, blue: 32.0/255.0, alpha: 1.0)
            break
        default:
            CELL_COLOR = UIColor(red: 195.0/255.0, green: 155.0/255.0, blue: 37.0/255.0, alpha: 1.0)
            break
        }
        return CELL_COLOR
    }

    // Tribute Cell Colors
    func tributeBackgroundImage(indexRow: Int) -> UIImage {
        var CELL_Image = "tribute_12"
        switch indexRow {
        case 0:
            CELL_Image = "tribute_1"
            break
        case 1:
            CELL_Image = "tribute_2"
            break
        case 2:
            CELL_Image = "tribute_3"
            break
        case 3:
            CELL_Image = "tribute_4"
            break
        case 4:
            CELL_Image = "tribute_5"
            break
        case 5:
            CELL_Image = "tribute_6"
            break
        case 6:
            CELL_Image = "tribute_7"
            break
        case 7:
            CELL_Image = "tribute_8"
            break
        case 8:
            CELL_Image = "tribute_9"
            break
        case 9:
            CELL_Image = "tribute_10"
            break
        case 10:
            CELL_Image = "tribute_11"
            break
        case 11:
            CELL_Image = "tribute_12"
            break
        case 12:
            CELL_Image = "tribute_12"
            break
        case 13:
            CELL_Image = "tribute_13"
            break
        default:
            CELL_Image = "tribute_12"
            break
        }
        return UIImage(named: CELL_Image)!
    }

    //MARK:- Supported Language Array
    let arrLanguages = [["name" : "English",  "image": "flag_english", "code"  : "en"],
                        ["name" : "عربى",     "image": "flag_arbic",   "code"  : "ar"],
                        ["name" : "中文",     "image": "flag_chinese",  "code"  : "zh-Hans"],
                        ["name" : "Français", "image": "flag_france",  "code"  : "fr"],
                        ["name" : "हिंदी",      "image": "flag_India",   "code"  : "hi"],
                        ["name" : "اردو",     "image": "flag_urdu",    "code"  : "ur"]]

    func ValidateLanguageCode() {
        APPDEL.selectedCode = Locale.userPreferred.languageCode!
        if APPDEL.selectedCode != arrLanguages[0]["code"] &&
            APPDEL.selectedCode != arrLanguages[1]["code"] &&
            APPDEL.selectedCode != arrLanguages[2]["code"] &&
            APPDEL.selectedCode != arrLanguages[3]["code"] &&
            APPDEL.selectedCode != arrLanguages[4]["code"] &&
            APPDEL.selectedCode != arrLanguages[5]["code"] {
            APPDEL.selectedCode = "en"
        }
    }

    //MARK:- Get Cuntry Phone Code
    func doPhoneCode() -> String {
        let finalCode = "+"
        let countryDictionary  = ["AF":"93", "AL":"355", "DZ":"213", "AS":"1", "AD":"376", "AO":"244", "AI":"1", "AG":"1", "AR":"54", "AM":"374", "AW":"297", "AU":"61", "AT":"43", "AZ":"994", "BS":"1", "BH":"973", "BD":"880", "BB":"1", "BY":"375", "BE":"32", "BZ":"501", "BJ":"229", "BM":"1", "BT":"975", "BA":"387", "BW":"267", "BR":"55", "IO":"246", "BG":"359", "BF":"226", "BI":"257", "KH":"855", "CM":"237", "CA":"1", "CV":"238", "KY":"345", "CF":"236", "TD":"235", "CL":"56", "CN":"86", "CX":"61", "CO":"57", "KM":"269", "CG":"242", "CK":"682", "CR":"506", "HR":"385", "CU":"53", "CY":"537", "CZ":"420", "DK":"45", "DJ":"253", "DM":"1", "DO":"1", "EC":"593", "EG":"20", "SV":"503", "GQ":"240", "ER":"291", "EE":"372", "ET":"251", "FO":"298", "FJ":"679", "FI":"358", "FR":"33", "GF":"594", "PF":"689", "GA":"241", "GM":"220", "GE":"995", "DE":"49", "GH":"233", "GI":"350", "GR":"30", "GL":"299", "GD":"1", "GP":"590", "GU":"1", "GT":"502", "GN":"224", "GW":"245", "GY":"595", "HT":"509", "HN":"504", "HU":"36", "IS":"354", "IN":"91", "ID":"62", "IQ":"964", "IE":"353", "IL":"972", "IT":"39", "JM":"1", "JP":"81", "JO":"962", "KZ":"77", "KE":"254", "KI":"686", "KW":"965", "KG":"996", "LV":"371", "LB":"961", "LS":"266", "LR":"231", "LI":"423", "LT":"370", "LU":"352", "MG":"261", "MW":"265", "MY":"60", "MV":"960", "ML":"223", "MT":"356", "MH":"692", "MQ":"596", "MR":"222", "MU":"230", "YT":"262", "MX":"52", "MC":"377", "MN":"976", "ME":"382", "MS":"1", "MA":"212", "MM":"95", "NA":"264", "NR":"674", "NP":"977", "NL":"31", "AN":"599", "NC":"687", "NZ":"64", "NI":"505", "NE":"227", "NG":"234", "NU":"683", "NF":"672", "MP":"1", "NO":"47", "OM":"968", "PK":"92", "PW":"680", "PA":"507", "PG":"675", "PY":"595", "PE":"51", "PH":"63", "PL":"48", "PT":"351", "PR":"1", "QA":"974", "RO":"40", "RW":"250", "WS":"685", "SM":"378", "SA":"966", "SN":"221", "RS":"381", "SC":"248", "SL":"232", "SG":"65", "SK":"421", "SI":"386", "SB":"677", "ZA":"27", "GS":"500", "ES":"34", "LK":"94", "SD":"249", "SR":"597", "SZ":"268", "SE":"46", "CH":"41", "TJ":"992", "TH":"66", "TG":"228", "TK":"690", "TO":"676", "TT":"1", "TN":"216", "TR":"90", "TM":"993", "TC":"1", "TV":"688", "UG":"256", "UA":"380", "AE":"971", "GB":"44", "US":"1", "UY":"598", "UZ":"998", "VU":"678", "WF":"681", "YE":"967", "ZM":"260", "ZW":"263", "BO":"591", "BN":"673", "CC":"61", "CD":"243", "CI":"225", "FK":"500", "GG":"44", "VA":"379", "HK":"852","IR":"98","IM":"44","JE":"44","KP":"850", "KR":"82", "LA":"856", "LY":"218", "MO":"853", "MK":"389", "FM":"691", "MD":"373", "MZ":"258", "PS":"970", "PN":"872", "RE":"262", "RU":"7", "BL":"590", "SH":"290", "KN":"1", "LC":"1", "MF":"590", "PM":"508", "VC":"1", "ST":"239", "SO":"252", "SJ":"47", "SY":"963", "TW":"886", "TZ":"255", "TL":"670", "VE":"58", "VN":"84", "VG":"284", "VI":"340"]
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            return "+\(countryDictionary[countryCode]!) "
        }
        return finalCode
    }

    //MARK:- Native Ad Position
    func FetchNativeAdPosition() {
        apiClass().doNormalAPI(param: [:], APIName: apiClass().GetNativeAdPositionAPI, method: "GET") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    let adPositionString = (mDict.value(forKey: "advertisment_value") as! NSDictionary).value(forKey: "value") as! String
                    constants().APPDEL.NativeAdPosition = Int(adPositionString)!
                }
            }
        }
    }

    //MARK:- Favorite Locations
    func FetchFavoriteLocations() {
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetMyFavLocationsAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    constants().APPDEL.ArrFavLocations = (mDict.value(forKey: "location") as! NSArray).mutableCopy() as! NSMutableArray
                    constants().doCreateLocationFilterJoint()
                }
            }
        }
    }

    //MARK:- Transition Animation
    func pushFromBottomTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        return transition
    }

    func pushWithFlipTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType(rawValue: "flip")
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        return transition
    }

    func popTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        return transition
    }

    //MARK:- Hex to UIColor
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }

    //MARK:- Language Done
    func LanguageDone() {
        UserDefaults.standard.set(true, forKey: "languageDONE")
    }
    func isLanguageDone() -> Bool {
        if UserDefaults.standard.string(forKey: "languageDONE") != nil {
            return true
        }
        return false
    }

    //MARK:- Send Device Token
    func doSendDEviceToken() {
        if  let tokenString = UserDefaults.standard.string(forKey: "devicetoken") {
            print("token")
            print(tokenString)
            apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "device_token":tokenString, "device_id":tokenString, "device_type":"ios"], APIName: apiClass().UpdateTokenAPI, method: "POST") { (success, errMessage, mDict) in
                print("")
                print(mDict)
                print("")
            }
        }
    }

    //MARK:- Validate Mobile
    func isValidPhone(phone: String) -> Bool {
        let fString = phone.replacingOccurrences(of: " ", with: "")
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: fString)
    }

    //MARK:- Validate Password
    func isStrongPassword(sPassword: String) -> Bool {
        var passRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[_])(?=.*[!@#$&*]).{6,24}$"
        passRegex = "^(?=.*[A-Z,a-z])(?=.*[0-9])(?=.*[_]).{6,24}$"
        let passTest = NSPredicate(format: "SELF MATCHES %@", passRegex)
        return passTest.evaluate(with: sPassword)
    }

    //MARK:- Validate email
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    //MARK:- Move view Up & Down
    func doMoveViewToUp(mView: UIView, mValue: CGFloat) {
        let newValue = mValue + mView.frame.origin.y
        UIView.animateKeyframes(withDuration: 0.25, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
            mView.frame.origin.y-=newValue
        },completion: nil)
    }
    func doMoveViewToDown(mView: UIView) {
        UIView.animateKeyframes(withDuration: 0.25, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
            mView.frame.origin.y = 0
        },completion: nil)
    }

    //MARK:- Dynamic Label Height
    func labelWidth(mString: String) -> CGFloat {
        let mlabel = UITextView()
        mlabel.frame = CGRect(x: 0, y: 0, width: 10, height: 30)
        mlabel.font = UIFont(name: constants().FONT_REGULAR, size: 18)
        mlabel.textAlignment = .center
        mlabel.text = mString
        let newSize = mlabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30))
        return newSize.width
    }

    //MARK:- HtML From String
    func setHTMLFromString(text: String) -> NSAttributedString {
        let modifiedFont = NSString(format:"<span style=\"font-family: \(self.FONT_LIGHT); font-size: 18\">%@</span>" as NSString, text) as String
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: modifiedFont.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: options, documentAttributes: nil)
        return attributedString
    }

    func setTermsHTMLFromString(text: String) -> NSAttributedString {
        let modifiedFont = NSString(format:"<span style=\"font-family: \(self.FONT_LIGHT); font-size: 18\">%@</span>" as NSString, text) as String
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: modifiedFont.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: options, documentAttributes: nil)
        return attributedString
    }

    //MARK:- Social
    func doGetSocial() -> String {
        if let dStatus = UserDefaults.standard.string(forKey: "social") {
            return dStatus
        }
        return ""
    }

    func doSaveSocial(sStr: String) {
        UserDefaults.standard.set(sStr, forKey:"social")
    }

    //MARK:- Login Status
    func doGetLoginStatus() -> String {
        if let dStatus = UserDefaults.standard.string(forKey: "login") {
            return dStatus
        }
        return ""
    }

    func doSaveLoginStatus(sStatus: String) {
        UserDefaults.standard.set(sStatus, forKey:"login")
        APPDEL.QuickBloxSilentLogin()
    }

    //MARK:- remember me username
    func doGetUsername() -> String {
        if let dStatus = UserDefaults.standard.string(forKey: "username") {
            return dStatus
        }
        return ""
    }

    func doSaveUsername(sUsername: String) {
        UserDefaults.standard.set(sUsername, forKey:"username")
//        APPDEL.QuickBloxSilentLogin()
    }

    //MARK:- remember me password
    func doGetPassword() -> String {
        if let dStatus = UserDefaults.standard.string(forKey: "password") {
            return dStatus
        }
        return ""
    }

    func doSavePassword(sPassword: String) {
        UserDefaults.standard.set(sPassword, forKey:"password")
//        APPDEL.QuickBloxSilentLogin()
    }

    //MARK:- User Type
    func doGetUserType() -> String {
        if let uType = UserDefaults.standard.string(forKey: "usertype") {
            return uType
        }
        return ""
    }

    func doSaveUserType(uType: String) {
        UserDefaults.standard.set(uType, forKey:"usertype")
    }

    //MARK:- Active Organisation
    func doGetActiveOrganisation() -> String {
        if let uActive = UserDefaults.standard.string(forKey: "orgactive") {
            return uActive
        }
        return ""
    }

    func doSaveActiveOrganisation(uActive: String) {
        UserDefaults.standard.set(uActive, forKey:"orgactive")
    }

    //MARK:- Get User ID
    func doGetUserId() -> String {
        let data = UserDefaults.standard.object(forKey: "userdata") as? NSData
        let object = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! NSDictionary
        let userID = object.value(forKey: "user_id") as! String
        return userID
    }

    //MARK:- Get User First Name
    func doGetUserFirstName() -> String {
        let data = UserDefaults.standard.object(forKey: "userdata") as? NSData
        let object = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! NSDictionary
        let fname = object.value(forKey: "first_name") as! String
        return fname
    }

    //MARK:- Biometric Status
    func doGetBiometricStatus() -> String {
        if let bStatus = UserDefaults.standard.string(forKey: "biometricstatus") {
            return bStatus
        }
        return ""
    }
    
    func doGetBiometricStatusOnOff() -> String {
        if let bStatus = UserDefaults.standard.string(forKey: "biometric_on_off") {
            return bStatus
        }
        return ""
    }

    func doSaveBiometricStatusOnOff(bStatus: String) {
        UserDefaults.standard.set(bStatus, forKey:"biometric_on_off")
    }
    
    func doSaveBiometricStatus(bStatus: String) {
        UserDefaults.standard.set(bStatus, forKey:"biometricstatus")
    }

    //MARK:- Search History List
    func doGetSearchHistory() {
        if let searchhistoryList = UserDefaults.standard.object(forKey: "searchhistory") {
            self.APPDEL.ArrSearchHistory = (searchhistoryList as! NSArray).mutableCopy() as! NSMutableArray
        }
    }

    func doSaveSearchHistory() {
        UserDefaults.standard.set(self.APPDEL.ArrSearchHistory, forKey:"searchhistory")
    }

    //MARK:- Call Function
    func doCallNumber(phoneNumber:String) {
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }

    //MARK:- Login First Alert
    func doLoginFirst(mControl: UIViewController) {
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: "Login First", preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
        }
        alertController.addAction(okAction)
        mControl.present(alertController, animated: true, completion: nil)
    }

    func doDateToString(mDate: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let now = df.string(from:mDate)
        return now
    }

    //MARK:- Reset Filters
    func ResetFilters() {
        APPDEL.strFilterName = ""
        APPDEL.strFilterCatID = ""
        APPDEL.strFilterBrandString = ""
        APPDEL.strFilterColorID = ""
        APPDEL.strFilterFromDate = ""
        APPDEL.strFilterToDate = ""
        APPDEL.strFilterLocation = ""
    }

    //MARK:- Reset Filters
    func getVideoThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }

    //MARK:- Start Of Month Date
    func FirstDateOfCurrentMonth() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = constants().SUBMIT_DATEFORMAT
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: components)!
        return startOfMonth
    }

    //MARK:- Start Of Month Date
    func doCreateLocationFilterJoint() {
        let arrFavLoc = NSMutableArray()
        for index in 0..<APPDEL.ArrFavLocations.count {
            let mDict = APPDEL.ArrFavLocations.object(at: index) as! NSDictionary
            if mDict.value(forKey: "is_filter") as! String == "TRUE" {
                arrFavLoc.add(mDict.value(forKey: "location") as! String)
            }
        }
        APPDEL.strFilterLocation = arrFavLoc.componentsJoined(by: ",")
    }

    //MARK:- Last Seen from Date
    func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())

        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1) {
            if (numericDates) {
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1) {
            if (numericDates) {
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1) {
            if (numericDates) {
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates) {
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }
    }

    //MARK:- Send User Log Location API (Silent)
    func SendUserLog_Location(strLat:String, strLong:String) {
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId(), "latitude":strLat, "longitude":strLong], APIName: apiClass().AddUserLogAPI, method: "POST") { (success, errMessage, mDict) in
        }
    }

    //MARK:- Generate Random No for Ad
    func isAdRandomNo() -> Int {
        if constants().APPDEL.isAdJustClosed == true {
            return 1
        }
        let dice1 = arc4random_uniform(8) + 1
        if constants().APPDEL.isPopup == true {
            return 1
        }
        return Int(dice1)
    }

    //MARK:- Random Alert
    func RateAlert() {
        let rNo = arc4random_uniform(120) + 30
        Timer.scheduledTimer(timeInterval: TimeInterval(rNo), target: self, selector: #selector(self.doFireRateAlert), userInfo: nil, repeats: false)
    }
    @objc func doFireRateAlert() {
        if constants().APPDEL.isPopup == false {
            let dice1 = arc4random_uniform(8) + 1
            if dice1 == 5 {
                SKStoreReviewController.requestReview()
            }
        }
    }

    //MARK:- Clean Up User
    func doCleanUpUserData() {
        APPDEL.doQuickBloxLogout()
        self.doSaveBiometricStatus(bStatus: "")
        self.doSaveSocial(sStr: "false")
        self.doSaveLoginStatus(sStatus: "false")
        self.doSaveUserType(uType: "")
        self.doSaveActiveOrganisation(uActive: "")
    }

    //MARK:- Manage User Coordinate
    func doEqualCoordinate(cLat:String, cLong:String) -> Bool {
        let mDict = (["lat":cLat, "long":cLong]) as Dictionary
        if UserDefaults.standard.string(forKey: "lastCoord") != nil {
            if (UserDefaults.standard.dictionary(forKey: "lastCoord") as! Dictionary) != mDict {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    func doSaveLastCoordinate(sLat: String, sLong: String) {
        let mDict = (["lat":sLat, "long":sLong])
        UserDefaults.standard.set(mDict, forKey: "lastCoord")
    }

    func swipeCloseArea() -> CGFloat {
        if self.userinterface == .pad {
            return 350
        }
        return 220
    }

    func allowednumberset(str:String) -> Bool {
        let allowedCharacters = "1234567890"
        let allowedCharcterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharcterSet = CharacterSet(charactersIn: str)
        return allowedCharcterSet.isSuperset(of: typedCharcterSet)
    }
}
