//  DialogCollectionCell.swift
//  LostAndFound
//  Created by Revamp on 20/02/20.
//  Copyright © 2020 Revamp. All rights reserved.

import UIKit

class DialogCollectionCell: UICollectionViewCell {
    @IBOutlet weak var dialogLastMessage: UILabel!
    @IBOutlet weak var dialogName: UILabel!
    @IBOutlet weak var dialogTypeImage: UIImageView!
    @IBOutlet weak var unreadMessageCounterLabel: UILabel!
    @IBOutlet weak var unreadMessageCounterHolder: UIView!
    @IBOutlet weak var dialogLastTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.unreadMessageCounterHolder.layer.cornerRadius = 12.0
    }
}
