//
//  ImageView+Extention.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setRoundedView(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
    }

    func loadProfileImage(url: String) {
//        self.sd_setIndicatorStyle(.gray)
//        self.sd_setShowActivityIndicatorView(true)
        self.sd_setImage(with: URL(string: url), completed: { image, error, cacheType, imageURL in
            if ((error) != nil) {
                 self.image = UIImage(named: "ic_user_default")
            }
        })
    }

}

extension UIButton {
    
    func loadProfileImage(url: String) {
//        self.sd_setIndicatorStyle(.gray)
//        self.sd_setShowActivityIndicatorView(true)
        self.sd_setImage(with: URL(string: url), for: .normal, completed: { image, error, cacheType, imageURL in
            if ((error) != nil) {
                self.imageView!.image = UIImage(named: "ic_user_default")
            }
        })
    }

}

extension UIView {
    func setRoundBorderEdgeView(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        clipsToBounds = true
    }
}
