//
//  ShowMapViewController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/25/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

struct MyLocation{
    var name: String
    var lat: Double
    var lon: Double
}

class ShowMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var locationManager = CLLocationManager()
    var myplace: MyLocation?
    
    let myMarkerWidth: Int = 50
    let myMarkerHeight: Int = 50
    var data = [UserProfile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.view.backgroundColor = .white
        myMapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        setupViews()
        
        initGoogleMaps()
    }
    
    let myMapView: GMSMapView = {
        let m = GMSMapView()
        m.translatesAutoresizingMaskIntoConstraints=false
        return m
    }()
    
    var detailView: DetailView = {
        let v = DetailView()
        return v
    }()
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 28.7041, longitude: 77.1025, zoom: 17.0)
        self.myMapView.camera = camera
        self.myMapView.delegate = self
        self.myMapView.isMyLocationEnabled = true
    }
    
    func setupViews() {
        view.addSubview(myMapView)
        myMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myMapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myMapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        myMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60).isActive = true
        
        
        detailView = DetailView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 100))
        
    }
    
    // CLLOCATION Manager Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        let location = locations.last
        let lat = (location?.coordinate.latitude)!
        let lon = (location?.coordinate.longitude)!
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 17.0)
        
        self.myMapView.animate(to: camera)
        
        showAllMarkers(lat: lat, lon: lon)
    }
    
    func showAllMarkers(lat: Double, lon: Double) {
        myMapView.clear()
        for i in 0..<data.count {
            let randNum=Double(arc4random_uniform(50))/10000
            let marker = GMSMarker()
            let customMarker = MyMarkerView(frame: CGRect(x: 0, y: 0, width: myMarkerWidth, height: myMarkerHeight), image: data[i].photoImage!, borderColor: UIColor.darkGray, tag: i)
            marker.iconView=customMarker
            let randInt = arc4random_uniform(4)
            if randInt == 0 {
                marker.position = CLLocationCoordinate2D(latitude: lat+randNum, longitude: lon-randNum)
            } else if randInt == 1 {
                marker.position = CLLocationCoordinate2D(latitude: lat-randNum, longitude: lon+randNum)
            } else if randInt == 2 {
                marker.position = CLLocationCoordinate2D(latitude: lat-randNum, longitude: lon-randNum)
            } else {
                marker.position = CLLocationCoordinate2D(latitude: lat+randNum, longitude: lon+randNum)
            }
            marker.map = self.myMapView
        }
    }
    
    //Google Map Delegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let myMarkerView = marker.iconView as? MyMarkerView else { return false }
        let img = myMarkerView.img!
        let myMarker = MyMarkerView(frame: CGRect(x: 0, y: 0, width: myMarkerWidth, height: myMarkerHeight), image: img, borderColor: UIColor.white, tag: myMarkerView.tag)
        
        marker.iconView = myMarker
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let myMarkerView = marker.iconView as? MyMarkerView else { return nil }
        let data = self.data[myMarkerView.tag]
        detailView.setData(title: data.firstName, img: data.photoImage!)
        return detailView
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let myMarkerView = marker.iconView as? MyMarkerView else { return }
        let img = myMarkerView.img!
        let myMarker = MyMarkerView(frame: CGRect(x: 0, y: 0, width: myMarkerWidth, height: myMarkerHeight), image: img, borderColor: UIColor.darkGray, tag: myMarkerView.tag)
        marker.iconView = myMarker
    }

  

}
