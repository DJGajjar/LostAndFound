//
//  String+Localized.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

class StringUtils {
    func addRedStar(msg: String) -> NSAttributedString {
        let redStar = NSAttributedString(string: " *", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        let attributedMsg = NSMutableAttributedString(string: msg)
        attributedMsg.append(redStar)
        return attributedMsg
    }
}
