//
//  PhotoItemAnnotation.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 24.05.2022.
//

import MapKit

class PhotoItemAnnotation: NSObject, MKAnnotation {
    
    let photoItem: PhotoItem
    
    var coordinate = CLLocationCoordinate2D()
    var title: String? = ""
    var subtitle: String? = ""
    
    init(photoItem: PhotoItem) {
        self.photoItem = photoItem
        self.coordinate = photoItem.coordinate
        self.title = photoItem.description
        self.subtitle = photoItem.author
    }
    
    func setAnnotationView(on mapView: MKMapView) -> MKAnnotationView {
        
        let identifier = "PhotoItem"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: self, reuseIdentifier: identifier)
            annotationView!.canShowCallout = false
        } else {
            annotationView!.annotation = self
        }
        
        let pointColor = UIColor.orange
        
        annotationView!.markerTintColor = pointColor
        annotationView!.glyphImage = UIImage(systemName: "photo.circle.fill")
        
        // allow this to show pop up information
        annotationView?.canShowCallout = false

        annotationView!.displayPriority = .required
        annotationView!.titleVisibility = .adaptive
        
        // attach an information button to the view
        //annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView!
        
    }
    
}
