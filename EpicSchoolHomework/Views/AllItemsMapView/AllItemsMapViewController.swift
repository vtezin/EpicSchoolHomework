//
//  AllItemsMapViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 24.05.2022.
//

import UIKit
import MapKit
import Firebase

class AllItemsMapViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var photoItems = [PhotoItem]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Карта"
        configureMapView()
        configureLocationServices()
        
        let itemsRef = Database.database().reference().child("photos")
        itemsRef.observe(DataEventType.value, with: { snapshot in
            DataService.fetchPhotoItems(handler: self.photoItemsFetched)
        })
    }
}

// MARK: -  Functions
extension AllItemsMapViewController {
    func photoItemsFetched(photoItems: [PhotoItem]) {
        self.photoItems = photoItems
        DispatchQueue.main.async {
            self.addItemsAnnotationsToMap()
        }
    }
    
    func addItemsAnnotationsToMap() {
        for photoItem in photoItems {
            let annotation = PhotoItemAnnotation(photoItem: photoItem)
            mapView.addAnnotation(annotation)
        }
    }
    
}

// MARK: -  Functions Locations
extension AllItemsMapViewController {
    private func configureLocationServices() {
        locationManager.delegate = self
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
           beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func configureMapView() {
        mapView.mapType = .standard
        mapView.userTrackingMode = .none
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.delegate = self
    }
  
    private func setMapCenterToCurrentLocation() {
        guard let currentCoordinate = currentCoordinate else {
            return
        }
        
        let mapRegion = MKCoordinateRegion(center: currentCoordinate, span: mapView.region.span)
        mapView.setRegion(mapRegion, animated: true)
    }
}

// MARK: -  CLLocationManagerDelegate
extension AllItemsMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        if currentCoordinate == nil {
            let zoomRegion = MKCoordinateRegion(center: latestLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(zoomRegion, animated: true)
        }
    
        currentCoordinate = latestLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
}

// MARK: -  MKMapViewDelegate
extension AllItemsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {
            return MKUserLocationView()
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? PhotoItemAnnotation{
            annotationView = annotation.setAnnotationView(on: mapView)
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let placemark = view.annotation as? PhotoItemAnnotation {
            let vc = EditItemViewController(photoItem: placemark.photoItem,
                                            indexPhotoItemInArray: 0,
                                            delegate: self)
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}
    

// MARK: -  canUpdatePhotoItemInArray
extension AllItemsMapViewController: canUpdatePhotoItemInArray {
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int) {
        //TODO
    }
}
