//  MapLocationView.swift
//  LostAndFound
//  Created by Revamp on 30/11/19.
//  Copyright © 2019 Revamp. All rights reserved.

import UIKit
import MapKit
class MapLocationView: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var myMap : MKMapView!
    var myLocation = "California, USA"

    //MARK:- UIViewcontroller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        self.doSetFrames()
        self.doSetupMapLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK:- Other Methods
    func doSetFrames() {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
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

                frame = self.myMap.frame
                frame.origin.y = self.topView.frame.size.height
                frame.size.height = constants().SCREENSIZE.height - frame.origin.y
                self.myMap.frame = frame
            }
        }
    }

    func doSetupMapLocation() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(self.myLocation) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    return
            }

            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.myMap.setRegion(region, animated: true)

            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = self.myLocation
            annotation.subtitle = ""
            self.myMap.addAnnotation(annotation)
        }
    }

    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "map_pin")
        return annotationView
    }

    //MARK:- IBAction Methods
    @IBAction func doBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
