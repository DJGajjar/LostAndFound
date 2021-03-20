import UIKit
import Alamofire
import SVProgressHUD

class WebService: NSObject {
    class func request(method: String, webServiceName: String, param: [String: Any]?, showLoader: Bool, completion: @escaping (_ result: Bool, _ response: [String:Any]? )->()) {
        let header = [String:String]()
        Alamofire.request(webServiceName, method: HTTPMethod(rawValue: method)!, parameters: param, headers: header).responseJSON(completionHandler: { (dataResponse) in
            SVProgressHUD.dismiss()
            switch dataResponse.result {
            case .success(let JSON):
                if let data = try? JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted),
                    let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                let response: [String: Any] = JSON as! [String : Any]// as! NSDictionary
                print("JSON: \(response)")
                if let status = response ["status"] as? Int {
                    if (status == 200) {
                        completion(true, response)
                    } else if (status == 402){
                        completion(true, response)
                    } else if (status == 500){
                        completion(true, response)
                    } else if (status == 400){
                        completion(true, response)
                    } else {
                        if let message = response["message"] as? String {
                        }
                        completion(false, [:] as? [String : Any])
                    }
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(false, nil)
            }
        })
    }
}
