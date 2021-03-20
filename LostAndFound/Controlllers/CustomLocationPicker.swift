import UIKit
class CustomLocationPicker: LocationPicker {
    override func viewDidLoad() {
        super.addBarButtons()
        super.viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc override func locationDidSelect(locationItem: LocationItem) {
        print("Select overrided method: " + locationItem.name)
    }

    @objc override func locationDidPick(locationItem: LocationItem) {
        constants().APPDEL.LocationitemName = locationItem.name
        constants().APPDEL.LocationItemAddress = locationItem.formattedAddressString!
    }
}
