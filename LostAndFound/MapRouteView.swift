// MapRouteView.swift
// AnimatesRoute

import UIKit
import MapKit
class MapRouteView : UIViewController, MKMapViewDelegate {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnDone : UIButton!
    @IBOutlet weak var mapView : MKMapView!
    private var drawingTimer : Timer?
    private var polyline : MKPolyline?
    let newPin = MKPointAnnotation()
    var ArrLogRoute = NSMutableArray()
    var LastRouteLogArray = NSMutableArray()

    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.doSetFrames()
        self.AddGesture()
        self.doFetchLastRoute()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        if (constants().userinterface == .pad) {
        } else {
            if (constants().SCREENSIZE.height == 812 || constants().SCREENSIZE.height == 896) {
                var frame = self.topView.frame
                frame.size.height = 80
                self.topView.frame = frame

                frame = self.lblTitle.frame
                frame.origin.y = 35
                self.lblTitle.frame = frame

                frame = self.btnBack.frame
                frame.origin.y = 40
                self.btnBack.frame = frame

                frame = self.btnDone.frame
                frame.origin.y = 40
                self.btnDone.frame = frame

                frame = self.mapView.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.mapView.frame = frame
            }
        }
    }

    func doFetchLastRoute() {
        constants().APPDEL.doStartSpinner()
        apiClass().doNormalAPI(param: ["user_id":constants().doGetUserId()], APIName: apiClass().GetUserLogsAPI, method: "POST") { (success, errMessage, mDict) in
            DispatchQueue.main.async {
                if success == true {
                    self.LastRouteLogArray = (mDict.value(forKey: "user_log") as! NSArray).mutableCopy() as! NSMutableArray
                    self.ArrLogRoute.removeAllObjects()
                    for i in 0..<(self.LastRouteLogArray.count) {
                        let mDict = self.LastRouteLogArray.object(at: i) as! NSDictionary
                        let coord = CLLocationCoordinate2D(latitude: Double((mDict.value(forKey: "latitude") as! String))!, longitude: Double((mDict.value(forKey: "longitude") as! String))!)
                        self.ArrLogRoute.add(coord)
                        if (i == 0) || (i == (self.LastRouteLogArray.count-1)) {
                            self.AddMapAnnotation(coord: coord)
                        }
                    }
                    if self.ArrLogRoute.count > 0 {
                        self.doApplyRoute()
                    }
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("alert", comment: ""), message: errMessage, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func doApplyRoute() {
        let route = self.ArrLogRoute
        self.center(onRoute: route as! [CLLocationCoordinate2D], fromDistance: 15)
        self.animate(route: route as! [CLLocationCoordinate2D], duration: 1.5) {
        }
    }

    func AddMapAnnotation(coord:CLLocationCoordinate2D) {
        let EndPin = MKPointAnnotation()
        EndPin.coordinate = coord
        EndPin.title = ""
        self.mapView.addAnnotation(EndPin)
    }

    //MARK:- Gesture Methods
    func AddGesture() {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapRouteView.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressRecogniser)
    }

    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        self.mapView.removeAnnotation(self.newPin)
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let touchMapCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        self.newPin.coordinate = touchMapCoordinate
        self.newPin.title = "title"
        self.mapView.addAnnotation(self.newPin)

        let userLocation :CLLocation = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(userLocation) { [weak self] (placemarks, error) in
            guard let self = self else {return }
            if let _ = error {
                return
            }
            guard let placemark = placemarks?.first  else {
                return
            }

            var pinAddress = ""
            let City = placemark.locality ?? ""
            let State = placemark.administrativeArea ?? ""
            let Country = placemark.country ?? ""
            DispatchQueue.main.async {
                if !City.isEmpty {
                    pinAddress = City
                }
                if !State.isEmpty {
                    if !pinAddress.isEmpty {
                        pinAddress += ", "
                    }
                    pinAddress += State
                }
                if !Country.isEmpty {
                    if !pinAddress.isEmpty {
                        pinAddress += ", "
                    }
                    pinAddress += Country
                }
                self.newPin.title = pinAddress
                constants().APPDEL.LocationItemAddress = pinAddress
                constants().APPDEL.LocationitemName = ""
            }
        }
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doDone() {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK:- Map Route Methods
    func center(onRoute route: [CLLocationCoordinate2D], fromDistance km: Double) {
        let center = MKPolyline(coordinates: route, count: route.count).coordinate
        mapView.setCamera(MKMapCamera(lookingAtCenter: center, fromDistance: km * 1000, pitch: 0, heading: 0), animated: false)
    }

    func animate(route: [CLLocationCoordinate2D], duration: TimeInterval, completion: (() -> Void)?) {
        guard route.count > 0 else { return }
        var currentStep = 1
        let totalSteps = route.count
        let stepDrawDuration = duration/TimeInterval(totalSteps)
        var previousSegment: MKPolyline?

        drawingTimer = Timer.scheduledTimer(withTimeInterval: stepDrawDuration, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                completion?()
                return
            }

            if let previous = previousSegment {
                self.mapView.removeOverlay(previous)
                previousSegment = nil
            }

            guard currentStep < totalSteps else {
                let finalPolyline = MKPolyline(coordinates: route, count: route.count)
                self.mapView.addOverlay(finalPolyline)
                self.polyline = finalPolyline
                timer.invalidate()
                completion?()
                return
            }

            let subCoordinates = Array(route.prefix(upTo: currentStep))
            let currentSegment = MKPolyline(coordinates: subCoordinates, count: subCoordinates.count)
            self.mapView.addOverlay(currentSegment)
            previousSegment = currentSegment
            currentStep += 1
        }
    }

    //MARK:- MKMapView Delegate Methods
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        let polylineRenderer = MKPolylineRenderer(overlay: polyline)
        polylineRenderer.strokeColor = UIColor(red: 89.0/255.0, green: 69.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
}
