//  ReplaceSegue.swift
//  sample-chat-swift
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.

import Foundation
import UIKit
class ReplaceSegue : UIStoryboardSegue {
	override func perform() {
		let sourceViewController = self.source
		let destinationViewController = self.destination
		let navigationController = sourceViewController.navigationController
		navigationController?.pushViewController(destinationViewController, animated: false)

		guard var mutableVC = navigationController?.viewControllers else {
			return
		}

        guard let sourceViewControllerIndex = mutableVC.firstIndex(of: sourceViewController) else {
			return
		}
		mutableVC.remove(at: sourceViewControllerIndex)
		navigationController?.setViewControllers(mutableVC, animated: true)
	}
}
