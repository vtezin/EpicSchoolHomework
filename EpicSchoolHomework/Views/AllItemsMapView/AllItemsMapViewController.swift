//
//  AllItemsMapViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 24.05.2022.
//

import UIKit
import MapKit
import Firebase
import Combine

class AllItemsMapViewController: UIViewController {
    @IBOutlet weak var mapModeControl: UISegmentedControl!
    @IBOutlet weak var moveToCurLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    private var currentCoordinate: CLLocationCoordinate2D?
    private var photoItems = [PhotoItem]()
    
    private var subscriptions = Set<AnyCancellable>()
    
    @IBAction func mapModeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = mapModeControl.selectedSegmentIndex == 0 ? .standard : .hybrid
    }
    
    @IBAction func moveToCurLocationButtonTapped(_ sender: UIButton) {
        setMapCenterToCurrentLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Карта"
        
        configureMapView()
        configureLocationServices()
        
        photoItems = appState.photoItems
        appState.$photoItems.sink(receiveValue: {[weak self] photoItems in
            self?.photoItems = photoItems
            self?.addItemsAnnotationsToMap()
        })
        .store(in: &subscriptions)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appState.locationService.startUpdating()
        moveToCurLocationButtonSetVisible()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appState.locationService.stopUpdating()
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
    
    private func addItemsAnnotationsToMap() {
        guard mapView != nil else {return}
        
        //remove all anotations
        for annotation in mapView.annotations {
            if annotation is PhotoItemAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        
        //add annotations
        for photoItem in photoItems {
            let annotation = PhotoItemAnnotation(photoItem: photoItem)
            mapView.addAnnotation(annotation)
        }
    }
    
    private func moveToCurLocationButtonSetVisible() {
        UIView.transition(with: moveToCurLocationButton, duration: 0.5,
          options: [.curveEaseOut],
          animations: {
            self.moveToCurLocationButton.alpha = self.mapView.isUserLocationVisible ? 0 : 1
          },
          completion: { _ in
            self.moveToCurLocationButton.isHidden = self.mapView.isUserLocationVisible
          }
        )
    }
}

// MARK: -  Functions Locations
extension AllItemsMapViewController {
    private func configureLocationServices() {
        appState.locationService.$lastLocation.sink(receiveValue: { [weak self]  newLocation in
            guard let newLocation = newLocation else {return}
            self?.receivedNewLocation(newLocation)
        })
        .store(in: &subscriptions)
        appState.locationService.startUpdating()
    }
    
    private func receivedNewLocation(_ newLocation: CLLocation) {
        if currentCoordinate == nil {
            let zoomRegion = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(zoomRegion, animated: true)
        }
        currentCoordinate = newLocation.coordinate
    }
    
    private func configureMapView() {
        mapView.showsUserLocation = true
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
            mapView.deselectAnnotation(placemark, animated: false)
            let vc = EditItemViewController(photoItem: placemark.photoItem)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        moveToCurLocationButtonSetVisible()
    }
    
}
