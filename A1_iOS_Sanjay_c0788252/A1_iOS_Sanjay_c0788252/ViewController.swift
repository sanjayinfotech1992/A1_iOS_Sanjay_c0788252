//
//  ViewController.swift
//  A1_iOS_Sanjay_c0788252
//
//  Created by Sanjay on 26/01/21.
//  Copyright © 2021 Sanjay. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var btnRoute: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var locArr = [CLLocationCoordinate2D]()
    var naming = ["A", "B", "C"]
    fileprivate var polygon: MKPolygon? = nil
    fileprivate var polyLine: MKPolyline? = nil
    var currentLoc : CLLocationCoordinate2D?
    var myLocString = "Your location"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnRoute.isEnabled = false
        askForLocation()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        
        let annotationW = MKPointAnnotation()
        annotationW.coordinate = CLLocationCoordinate2D(latitude: 42.3149, longitude: -83.0364)
        annotationW.title = "Windsor"
        mapView.addAnnotation(annotationW)
        
        
        let annotationO = MKPointAnnotation()
        annotationO.coordinate = CLLocationCoordinate2D(latitude: 45.4215, longitude: -75.6972)
        annotationO.title = "Ottawa"
        mapView.addAnnotation(annotationO)
        
        
        let annotationT = MKPointAnnotation()
        annotationT.coordinate = CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)
        annotationT.title = "Toronto"
        mapView.addAnnotation(annotationT)
        
        
    }
    
    @IBAction func routeClicked(_ sender: Any) {
        if locArr.count >= 3 {
            
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
            
            self.getRoutes()
        }
        
    }
    fileprivate func askForLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Location permission not allowed", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                
            case .authorizedAlways, .authorizedWhenInUse:
                return
            @unknown default:
                return
            }
        }
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
    
    func getRoutes() {
        
        let padding: CGFloat = 8
        let requestAB = MKDirections.Request()
        requestAB.source = MKMapItem(placemark: MKPlacemark(coordinate: locArr[0], addressDictionary: nil))
        requestAB.destination = MKMapItem(placemark: MKPlacemark(coordinate: locArr[1], addressDictionary: nil))
        requestAB.requestsAlternateRoutes = true
        requestAB.transportType = .automobile
        
        let directionsAB = MKDirections(request: requestAB)
        
        directionsAB.calculate { [unowned self] response, error in
            guard let route = response?.routes.first else { return }
            
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            self.mapView.setVisibleMapRect(
                self.mapView.visibleMapRect.union(
                    route.polyline.boundingMapRect
                ),
                edgePadding: UIEdgeInsets(
                    top: 0,
                    left: padding,
                    bottom: padding,
                    right: padding
                ),
                animated: true
            )
            
        }
        
        let requestBC = MKDirections.Request()
        requestBC.source = MKMapItem(placemark: MKPlacemark(coordinate: locArr[1], addressDictionary: nil))
        requestBC.destination = MKMapItem(placemark: MKPlacemark(coordinate: locArr[2], addressDictionary: nil))
        requestBC.requestsAlternateRoutes = true
        requestBC.transportType = .automobile
        
        let directionsBC = MKDirections(request: requestBC)
        
        directionsBC.calculate { [unowned self] response, error in
            guard let route = response?.routes.first else { return }
            
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            self.mapView.setVisibleMapRect(
                self.mapView.visibleMapRect.union(
                    route.polyline.boundingMapRect
                ),
                edgePadding: UIEdgeInsets(
                    top: 0,
                    left: padding,
                    bottom: padding,
                    right: padding
                ),
                animated: true
            )
        }
        
        
        let requestCA = MKDirections.Request()
        requestCA.source = MKMapItem(placemark: MKPlacemark(coordinate: locArr[2], addressDictionary: nil))
        requestCA.destination = MKMapItem(placemark: MKPlacemark(coordinate: locArr[0], addressDictionary: nil))
        requestCA.requestsAlternateRoutes = true
        requestCA.transportType = .automobile
        
        let directionsCA = MKDirections(request: requestCA)
        
        directionsCA.calculate { [unowned self] response, error in
            guard let route = response?.routes.first else { return }
            
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            self.mapView.setVisibleMapRect(
                self.mapView.visibleMapRect.union(
                    route.polyline.boundingMapRect
                ),
                edgePadding: UIEdgeInsets(
                    top: 0,
                    left: padding,
                    bottom: padding,
                    right: padding
                ),
                animated: true
            )
        }
        
        
    }
    
    fileprivate func manageMarker(_ newCoordinates: CLLocationCoordinate2D) {
        if locArr.count > 3 {
            locArr.removeAll()
            self.btnRoute.isEnabled = false
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
            
            let annos = self.mapView.annotations.filter {$0.title != myLocString}
            mapView.removeAnnotations(annos)
            
        }
        
        var placeInfo = "Not determined"
        if currentLoc != nil{
            
            let coordinate0 = CLLocation(latitude: (newCoordinates.latitude), longitude: (newCoordinates.longitude))
            let coordinate1 = CLLocation(latitude: currentLoc!.latitude, longitude: currentLoc!.longitude)
            let distanceInMeters = coordinate0.distance(from: coordinate1)
            let y = Double(round(100*distanceInMeters)/100)
            placeInfo = "\(y) Meters"
            
        }
        
        
        
        print(locArr.count)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        annotation.title = naming[locArr.count]
        annotation.subtitle = placeInfo
        
        
        locArr.append(newCoordinates)
        mapView.addAnnotation(annotation)
        self.mapView.setCenter(newCoordinates, animated: true)
        if locArr.count == 3 {
            locArr.append(locArr[0])
            self.makePolyline()
            self.btnRoute.isEnabled = true
        }
    }
    
    @objc func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            if !self.isCloseToAnyMarker(givenLoc: newCoordinates) {
                
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                           if error != nil {
                            print("Reverse geocoder failed with error" + (error?.localizedDescription ?? ""))
                               return
                           }

                    if placemarks?.count ?? 0 > 0 {
                        let pm = placemarks![0] as! CLPlacemark
                        if pm.administrativeArea != "ON"{
                            let alert = UIAlertController(title: "Selection outside Ontario is not allowed", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        else{
                            self.manageMarker(newCoordinates)
                        }
                       }
                       else {
                        let alert = UIAlertController(title: "Problem with getting data", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                       }
                   })
            }
            
            
        }
    }
    
    func makePolyline() {
        
        let polyLine = MKPolyline(coordinates: locArr, count: locArr.count)
        self.polyLine = polyLine
        
        let polygon = MKPolygon(coordinates: &locArr, count: locArr.count)
        self.polygon = polygon
        
        mapView.addOverlays([polyLine,polygon])
        
    }
    
    func isCloseToAnyMarker(givenLoc:CLLocationCoordinate2D) -> Bool {
        
        for locs in locArr{
            let coordinate0 = CLLocation(latitude: givenLoc.latitude, longitude: givenLoc.longitude)
            let coordinate1 = CLLocation(latitude: locs.latitude, longitude: locs.longitude)
            let distanceInMeters = coordinate0.distance(from: coordinate1)
            
            if distanceInMeters < 50{
                return true
            }
        }
        
        return false
    }
    
}

extension ViewController : CLLocationManagerDelegate,MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLoc = locValue
        
        mapView.mapType = MKMapType.standard
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        annotation.title = myLocString
        
        
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "City"
        
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            
        } else {
            
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self){
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.fillColor = UIColor.green
            polylineRenderer.strokeColor = UIColor.green
            polylineRenderer.lineWidth = 5
            
            return polylineRenderer
        }
        else if overlay.isKind(of: MKPolygon.self){
            let renderer = MKPolygonRenderer(polygon: polygon!)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}
