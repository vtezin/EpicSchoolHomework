//
//  SimpleItemMapViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 07.06.2022.
//

import UIKit
import MapKit

final class SimpleItemMapViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }
}

// MARK: -  MapView, MKMapViewDelegate
extension SimpleItemMapViewController: MKMapViewDelegate {
    private func configureMapView() {
        mapView.mapType = .standard
        mapView.userTrackingMode = .none
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.delegate = self
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    }
}

// MARK: -  Functions
extension SimpleItemMapViewController {
    
    
}
