//  apiClass.swift
//  MuskClinic

import UIKit
import Foundation
import AVFoundation
import Alamofire

class apiClass {
    //let mainAPIURL                      =  "https://vethicsinternational.com/lostandfound/webservice/v1/api/"
    //let mainAPIURL                      =   "http://localhost/API-Code/webservice/v1/api/"
    let mainAPIURL                      =     "http://18.224.171.88/lostandfoundapi/webservice/v1/api/";
    let CategoryListAPI                 =  "get_category"
    let GetAppVersion                   =  "get_app_version"
    let AboutUsAPI                      =  "get_about_us"
    let TermsAPI                        =  "get_terms_condition"
    let SignUpAPI                       =  "user_signup"
    let OTPVerificationAPI              =  "otp_verification"
    let LoginAPI                        =  "login_user"
    let LostItemListAPI                 =  "get_lost_item"
    let LostItemFilterAPI               =  "get_lost_item_filter"
    let AddLocationAPI                  =  "add_favorite_location"
    let DeleteLocationAPI               =  "delete_favorite_location"
    let ChangePasswordAPI               =  "change_user_password"
    let GetProfileAPI                   =  "get_user_profile_by_id"
    let UpdateProfileAPI                =  "update_user_profile"
    let ColorListAPI                    =  "get_color_list"
    let TributeAPI                      =  "get_tribute_to"
    let GetRulesAPI                     =  "get_rules"
    let GetPlaceListAPI                 =  "get_place_list"
    let AddLostItemAPI                  =  "add_lost_item"
    let ChangeNotificationStatusAPI     =  "change_user_notification_status"
    let AddFoundItemAPI                 =  "add_found_item"
    let GetFoundItemListAPI             =  "get_found_item"
    let AddUserLogAPI                   =  "add_user_log"
    let GetUserLostItemsListAPI         =  "get_user_lost_item"
    let DeleteAccountAPI                =  "delete_user_account"
    let ChangeTextChatStatusAPI         =  "change_user_text_chat_status"
    let ChangeVoiceChatStatusAPI        =  "change_user_voice_chat_status"
    let ChangeVideoChatStatusAPI        =  "change_user_video_chat_status"
    let ChangeDisplayMobileStatusAPI    =  "change_display_mobile_status"
    let ChangeDisplayPhotoStatusAPI     =  "change_display_photo_status"
    let GetAllFoundItemAPI              =  "get_all_found_item"
    let GetAllMarketPlaceItemAPI        =  "get_all_marketplace_item"
    let AddFavoriteItemAPI              =  "add_favorite_item"
    let GetMyFavoriteItemAPI            =  "get_my_favorite_item"
    let GetMyLeaderboardAPI             =  "get_my_leaderboard"
    let GetAllFindersAPI                =  "get_all_finders"
    let GetMyMarketplaceAPI             =  "get_my_marketplace_item"
    let SearchLostItemAPI               =  "search_lost_item"
    let GetUserNotificationAPI          =  "get_user_notification"
    let LostViewCountAPI                =  "lost_numb_of_view_add"
    let FoundViewCountAPI               =  "fount_numb_of_view_add"
    let RelatedProductAPI               =  "get_related_product"
    let SearchFoundItemAPI              =  "search_found_item"
    let ChangeDisplayAddressStatusAPI   =  "change_display_address_status"
    let SearchMarketPlaceItemAPI        =  "search_marketplace_item"
    let ForgetPasswordAPI               =  "forgot_user_password"
    let GetUserSubscriptionAPI          =  "get_user_subscription"
    let UpdateUserSubscriptionAPI       =  "update_user_subscription"
    let HandoverOTPRequestAPI           =  "handover_otp_request"
    let VerifyHandoverOTPAPI            =  "verify_handover_otp"
    let ContactSupportAPI               =  "add_contact_support"
    let SocialLoginAPI                  =  "social_media_login"
    let WinnerListAPI                   =  "get_winner_list"
    let UpdateTokenAPI                  =  "update_user_token"
    let SupportReasonsAPI               =  "get_support_list"
    let SupportSettingAPI               =  "get_support_setting"
    let ResendOtpAPI                    =  "resend_otp"
    let GetMyFavLocationsAPI            =  "get_my_favorite_location"
    let UpdateFavLocationAPI            =  "update_favourite_location_status"
    let ClearLocationAPI                =  "clear_favourite_location_status"
    let ResetNotificationAPI            =  "read_notification_status"
    let SubmitUserRatingAPI             =  "add_user_rating"
    let EditFoundItemAPI                =  "edit_found_item"
    let EditLostItemAPI                 =  "edit_lost_item"
    let UpdateUserVideoCountAPI         =  "update_user_video_count"
    let LostItemDetailAPI               =  "get_lost_item_detail"
    let FoundItemDetailAPI              =  "get_found_item_detail"
    let ClientTokenAPI                  =  "get_client_token"
    let BraintreeCreateOrderAPI         =  "braintree_create_order"
    let GetUserLogsAPI                  =  "get_user_log_detail"
    let GetNativeAdPositionAPI          =  "get_advertisment_value"
    let GetPoliceStationListAPI         =  "get_police_station_list"
    let CreateRewardOrderAPI            =  "create_reward_order"
    let PayOrganisationFeeAPI           =  "pay_organization_fee"
    let UpdateOrganisationAPI           =  "update_organization"
    let GetOrganisationDetailAPI        =  "get_organization_detail"
    let SendOrganisationInvitationAPI   =  "send_organization_invitation"
    let CancelOrganisationInvitationAPI =  "cancel_organization_invitation"
    let GetOrganisationInvitationAPI    =  "get_organization_invitation"
    let ResendOrganisationInvitationAPI =  "resend_organization_invitation"
    let DeleteOrganisationMemberAPI     =  "delete_organization_member"
    let GetOrganisationMemberDetailAPI  =  "get_organization_member_detail"

    let timeoutTime: Double = 180.0
    typealias CompletionResponse = (_ success:Bool, _ errorMessage: String) -> Void
    typealias CompHandler = (_ success:Bool, _ errorMessage: String, _ mDict: NSDictionary) -> Void

    //MARK:- Normal API Call
    func doNormalAPI(param:[String:Any], APIName:String, method:String, compHandler: @escaping CompHandler) {
        let header = [String:String]()
        print("Parameters===>");
        debugPrint(param);
        
        debugPrint("APIURL==>");
        debugPrint(mainAPIURL+APIName);
        
        
        Alamofire.request(mainAPIURL+APIName, method: HTTPMethod(rawValue: method)!, parameters: param, headers: header).responseJSON(completionHandler: { (dataResponse) in
            switch dataResponse.result {
                
                
                
            case .success(let JSON):
                
                debugPrint("DataResponse===>");
                debugPrint(dataResponse);
                
                let response: [String: Any] = JSON as! [String : Any]
                print("RESPONSE String===>");
                debugPrint(response);
                constants().APPDEL.doStopSpinner()
                let mDict = (response["response"] as! NSArray).object(at: 0) as! NSDictionary
                print("RESPONSE===>");
                debugPrint(mDict);

                if (mDict.value(forKey: "status") as! String) == "true" {
                    compHandler(true, "", mDict)
                } else {
                    compHandler(false, mDict.value(forKey: "response_msg") as! String, NSDictionary())
                }
            case .failure(let error):
                
                debugPrint("DataResponse===>");
                debugPrint(dataResponse);
                
                constants().APPDEL.doStopSpinner()
                print("Request failed with error: \(error)")
                compHandler(false, error.localizedDescription, NSDictionary())
            }
        })
    }

    //MARK:- Upload API Call
    func doUploadAPI(param:[String:Any], APIName:String, method:String, compHandler: @escaping CompHandler) {
        let header = [String:String]()
        constants().APPDEL.doStartSpinner()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                if (value is [UIImage]) {
                    for image in value as! [UIImage] {
                        if let imageData = image.jpegData(compressionQuality: 0.9) {
                            multipartFormData.append(imageData, withName: "image[]", fileName: "file.jpg", mimeType: "image/jpg")
                        }
                    }
                } else if (value is UIImage) {
                    if let imageData = (value as! UIImage).jpegData(compressionQuality: 0.9) {
                        multipartFormData.append(imageData, withName: key, fileName: "file.jpg", mimeType: "image/jpg")
                    }
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!, withName: key)
                }
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: mainAPIURL+APIName, method: HTTPMethod(rawValue: method)!, headers: header) { (dataResponse) in
            switch dataResponse {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let res = response.result.value as? [String: Any] {
                            constants().APPDEL.doStopSpinner()
                            let mDict = (res["response"] as! NSArray).object(at: 0) as! NSDictionary
                            if (mDict.value(forKey: "status") as! String) == "true" {
                                compHandler(true, "", mDict)
                            } else {
                                compHandler(false, mDict.value(forKey: "response_msg") as! String, NSDictionary())
                            }
                        } else {
                            constants().APPDEL.doStopSpinner()
                            compHandler(false, response.result.error!.localizedDescription, NSDictionary())
                        }
                    }
                case .failure(let error):
                    constants().APPDEL.doStopSpinner()
                    print("Request failed with error: \(error)")
                    compHandler(false, error.localizedDescription, NSDictionary())
            }
        }
    }

    //MARK:- add_lost_item
    func doAddLostItemAPICall(lostDate: String, itemName: String, colorID: String, desc: String, mBrandName: String, mCatID: String, imgArray: NSMutableArray, mReward: String, addr1: String, addr2: String, addr3:String, addr4: String, strPlaceID: String, strPlaceName: String, mLocation: String, completionhandler: @escaping CompletionResponse) {
        var param: [String: Any] = ["user_id":constants().doGetUserId(), "lost_date":lostDate, "item_name":itemName, "color":colorID, "description":desc, "brand_name":mBrandName, "reward":mReward, "location":mLocation]
        if !mCatID.isEmpty {
            param["category_id"] = mCatID
        }
        if !strPlaceID.isEmpty {
            param["place"] = "{\"place_id\":\"\(strPlaceID)\",\"name\":\"\(strPlaceName)\",\"field_1\":\"\(addr1)\",\"field_2\":\"\(addr2)\",\"field_3\":\"\(addr3)\",\"field_4\":\"\(addr4)\"}"
        }
        constants().APPDEL.doStartSpinner()

        let header = [String:String]()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                if (value is UIImage) {
                    if let imageData = (value as! UIImage).jpegData(compressionQuality: 0.9) {
                        multipartFormData.append(imageData, withName: key, fileName: "file.jpg", mimeType: "image/jpg")
                    }
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!, withName: key)
                }
            }
            for image in imgArray as! [UIImage] {
                if let imageData = image.jpegData(compressionQuality: 0.9) {
                    multipartFormData.append(imageData, withName: "image[]", fileName: "file.jpg", mimeType: "image/jpg")
                }
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: mainAPIURL+AddLostItemAPI, method: HTTPMethod(rawValue: "POST")!, headers: header) { (dataResponse) in
            switch dataResponse {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let res = response.result.value as? [String: Any] {
                            constants().APPDEL.doStopSpinner()
                            let mDict = (res["response"] as! NSArray).object(at: 0) as! NSDictionary
                            if (mDict.value(forKey: "status") as! String) == "true" {
                                completionhandler(true, "")
                            } else {
                                completionhandler(false, mDict.value(forKey: "response_msg") as! String)
                            }
                            print("JSON: \(res)")
                        } else {
                            constants().APPDEL.doStopSpinner()
                            completionhandler(false, response.result.error!.localizedDescription)
                        }
                    }
                case .failure(let error):
                    constants().APPDEL.doStopSpinner()
                    print("Request failed with error: \(error)")
                    completionhandler(false, error.localizedDescription)
            }
        }
    }

    //MARK:- add_found_item
    func doAddFoundItemAPICall(itemName: String, foundDate: String, colorID: String, lTag: String, mReward: String, mLocation: String, imgArray: NSMutableArray, mFoundWith: String, mCatID: String, mBrandName: String, completionhandler: @escaping CompletionResponse) {
        var param: [String: Any] = ["user_id":constants().doGetUserId(), "item_name":itemName, "category_id":mCatID, "found_date":foundDate, "color":colorID, "tag":lTag, "expected_reward":mReward, "location":mLocation, "found_with":mFoundWith, "brand_name":mBrandName]
        if !constants().APPDEL.psTitle.isEmpty {
            param["ps_location"] = constants().APPDEL.psLocation
            param["ps_title"] = constants().APPDEL.psTitle
            param["ps_email"] = constants().APPDEL.psEmail
            param["police_certificate"] = constants().APPDEL.psData
        }
        constants().APPDEL.doStartSpinner()

        let header = [String:String]()
        
        
        /*Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                if key == "police_certificate" {
                    if constants().APPDEL.psDataExtention == "pdf" {
                        multipartFormData.append(value as! Data, withName: key, fileName: "file.pdf", mimeType: "Application/PDF")
                    } else {
                        multipartFormData.append(value as! Data, withName: key, fileName: "file.jpg", mimeType: "image/jpg")
                    }
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!, withName: key)
                }
            }
            for image in imgArray as! [UIImage] {
                if let imageData = image.jpegData(compressionQuality: 0.9) {
                    multipartFormData.append(imageData, withName: "image[]", fileName: "file.jpg", mimeType: "image/jpg")
                }
            }
          */
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in param {
                    if (value is UIImage) {
                        if let imageData = (value as! UIImage).jpegData(compressionQuality: 0.9) {
                            multipartFormData.append(imageData, withName: key, fileName: "file.jpg", mimeType: "image/jpg")
                        }
                    } else {
                        multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!, withName: key)
                    }
                }
                for image in imgArray as! [UIImage] {
                    if let imageData = image.jpegData(compressionQuality: 0.9) {
                        multipartFormData.append(imageData, withName: "image[]", fileName: "file.jpg", mimeType: "image/jpg")
                    }
                }
    
            debugPrint(param);
            debugPrint(multipartFormData);
            
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: mainAPIURL+AddFoundItemAPI, method: HTTPMethod(rawValue: "POST")!, headers: header) { (dataResponse) in
           
            switch dataResponse {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        debugPrint(response);
                        
                        if let res = response.result.value as? [String: Any] {
                            constants().APPDEL.doStopSpinner()
                            let mDict = (res["response"] as! NSArray).object(at: 0) as! NSDictionary
                            if (mDict.value(forKey: "status") as! String) == "true" {
                                completionhandler(true, "")
                            } else {
                                completionhandler(false, mDict.value(forKey: "response_msg") as! String)
                            }
                        } else {
                            constants().APPDEL.doStopSpinner()
                            completionhandler(false, response.result.error!.localizedDescription)
                        }
                    }
                case .failure(let error):
                    constants().APPDEL.doStopSpinner()
                    print("Request failed with error: \(error)")
                    completionhandler(false, error.localizedDescription)
            }
        }
    }

    //MARK:- AutoSuggestAPI
    func doAutoSuggestAPI(strKeyword:String, completionhandler: @escaping CompletionResponse) {
        let searchAPIString = "http://suggestqueries.google.com/complete/search?client=firefox&q=\(strKeyword)"
        let param: [String: Any] = [:]
        let header = [String:String]()
        Alamofire.request(searchAPIString, method: HTTPMethod(rawValue: "GET")!, parameters: param, headers: header).responseJSON(completionHandler: { (dataResponse) in
            switch dataResponse.result {
            case .success(let JSON):
                if JSON is Array<Any> {
                    let ArrList = JSON as! NSArray
                    if ArrList.count >= 2 {
                        if ArrList.object(at: 1) is Array<Any> {
                            constants().APPDEL.ArrAutosuggestionsList = (ArrList.object(at: 1) as! NSArray).mutableCopy() as! NSMutableArray
                            completionhandler(true, "success")
                        } else {
                            completionhandler(false, "Failed")
                        }
                    } else {
                        completionhandler(false, "Failed")
                    }
                } else {
                    completionhandler(false, "Failed")
                }
                constants().APPDEL.doStopSpinner()
            case .failure(let error):
                constants().APPDEL.doStopSpinner()
                print("Request failed with error: \(error)")
                completionhandler(false, error.localizedDescription)
            }
        })
    }

    //MARK:- edit_found_item
    func doEditFoundItemAPICall(foundID:String, itemName: String, foundDate: String, colorID: String, lTag: String, mReward: String, mLocation: String, imgArray: NSMutableArray, mFoundWith: String, mCatID: String, mBrandName: String, delImage:String, completionhandler: @escaping CompletionResponse) {
        var param: [String: Any] = ["user_id":constants().doGetUserId(), "found_id":foundID, "item_name":itemName, "category_id":mCatID, "found_date":foundDate, "color":colorID, "tag":lTag, "expected_reward":mReward, "location":mLocation, "found_with":mFoundWith, "brand_name":mBrandName, "delete_image":delImage]
        if !constants().APPDEL.psTitle.isEmpty {
            param["ps_location"] = constants().APPDEL.psLocation
            param["ps_title"] = constants().APPDEL.psTitle
            param["ps_email"] = constants().APPDEL.psEmail
            param["police_certificate"] = constants().APPDEL.psData
        }
        
        //Update: 15 Dec 2020
        print("Parameters===>");
        debugPrint(param);
        
        
        
        constants().APPDEL.doStartSpinner()

        let header = [String:String]()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                if key == "police_certificate" {
                    if constants().APPDEL.psDataExtention == "pdf" {
                        multipartFormData.append(value as! Data, withName: key, fileName: "file.pdf", mimeType: "Application/PDF")
                    } else {
                        multipartFormData.append(value as! Data, withName: key, fileName: "file.jpg", mimeType: "image/jpg")
                    }
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!, withName: key)
                }
            }
            for image in imgArray as! [UIImage] {
                if let imageData = image.jpegData(compressionQuality: 0.9) {
                    multipartFormData.append(imageData, withName: "image[]", fileName: "file.jpg", mimeType: "image/jpg")
                }
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: mainAPIURL+EditFoundItemAPI, method: HTTPMethod(rawValue: "POST")!, headers: header) { (dataResponse) in
            
            //Update: 15 Dec 2020
            debugPrint("DataResponse===>");
            debugPrint(dataResponse);
            
            
            
            switch dataResponse {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let res = response.result.value as? [String: Any] {
                            constants().APPDEL.doStopSpinner()
                            let mDict = (res["response"] as! NSArray).object(at: 0) as! NSDictionary
                            if (mDict.value(forKey: "status") as! String) == "true" {
                                completionhandler(true, "")
                            } else {
                                completionhandler(false, mDict.value(forKey: "response_msg") as! String)
                            }
                        } else {
                            constants().APPDEL.doStopSpinner()
                            completionhandler(false, response.result.error!.localizedDescription)
                        }
                    }
                case .failure(let error):
                    constants().APPDEL.doStopSpinner()
                    print("Request failed with error: \(error)")
                    completionhandler(false, error.localizedDescription)
            }
        }
    }

    //MARK:- edit_lost_item
    func doEditLostItemAPICall(lostID:String, lostDate: String, itemName: String, colorID: String, desc: String, mBrandName: String, mCatID: String, imgArray: NSMutableArray, mReward: String, addr1: String, addr2: String, addr3:String, addr4: String, strPlaceID: String, strPlaceName: String, mLocation: String, delImage:String, completionhandler: @escaping CompletionResponse) {
        var param: [String: Any] = ["user_id":constants().doGetUserId(), "lost_id":lostID, "lost_date":lostDate, "item_name":itemName, "color":colorID, "description":desc, "brand_name":mBrandName, "reward":mReward, "location":mLocation, "delete_image":delImage]
        if !mCatID.isEmpty {
            param["category_id"] = mCatID
        }
        if !strPlaceID.isEmpty {
            param["place"] = "{\"place_id\":\"\(strPlaceID)\",\"name\":\"\(strPlaceName)\",\"field_1\":\"\(addr1)\",\"field_2\":\"\(addr2)\",\"field_3\":\"\(addr3)\",\"field_4\":\"\(addr4)\"}"
        }
        constants().APPDEL.doStartSpinner()

        let header = [String:String]()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                if (value is UIImage) {
                    if let imageData = (value as! UIImage).jpegData(compressionQuality: 0.9) {
                        multipartFormData.append(imageData, withName: key, fileName: "file.jpg", mimeType: "image/jpg")
                    }
                } else {
                    multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!, withName: key)
                }
            }
            for image in imgArray as! [UIImage] {
                if let imageData = image.jpegData(compressionQuality: 0.9) {
                    multipartFormData.append(imageData, withName: "image[]", fileName: "file.jpg", mimeType: "image/jpg")
                }
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: mainAPIURL+EditLostItemAPI, method: HTTPMethod(rawValue: "POST")!, headers: header) { (dataResponse) in
            switch dataResponse {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let res = response.result.value as? [String: Any] {
                            constants().APPDEL.doStopSpinner()
                            let mDict = (res["response"] as! NSArray).object(at: 0) as! NSDictionary
                            if (mDict.value(forKey: "status") as! String) == "true" {
                                completionhandler(true, "")
                            } else {
                                completionhandler(false, mDict.value(forKey: "response_msg") as! String)
                            }
                        } else {
                            constants().APPDEL.doStopSpinner()
                            completionhandler(false, response.result.error!.localizedDescription)
                        }
                    }
                case .failure(let error):
                    constants().APPDEL.doStopSpinner()
                    print("Request failed with error: \(error)")
                    completionhandler(false, error.localizedDescription)
            }
        }
    }

    /*    //MARK:- get_category
    func doGetCategoryListAPI() {
    let param: [String: Any] = ["mobile": self.strMobile, "otp": otpCode]
    constants().APPDEL.doStartSpinner()
    apiClass().doNormalAPI(param: param, APIName: apiClass().OTPVerificationAPI, method: "POST") { (success, errMessage, mDict) in
        DispatchQueue.main.async {
            if success == true {
            } else {
            }
        }
    }
    }*/
}
