//
//  EditLocalPhotoViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 03.06.2022.
//

import UIKit
import MapKit
import Photos

final class EditLocalPhotoViewController: UIViewController {

    @IBOutlet private weak var photoItemImageView: UIImageView!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var questionTextField: UITextField!
    @IBOutlet private weak var answerTextField: UITextField!
    
    @IBOutlet private  weak var mapView: MKMapView!
    
    var photoItem: LocalPhoto?
    
    var takeNewPhotoFromCamera = true
    
    private let locationManager = CLLocationManager()
    private var itemCoordinate: CLLocationCoordinate2D?
    private var currentCoordinate: CLLocationCoordinate2D?
    
    let delegate: canUpdatePhotoItemInArray
    let indexPhotoItemInArray: Int?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(photoItem: LocalPhoto?,
         indexPhotoItemInArray: Int?,
         delegate: canUpdatePhotoItemInArray) {
        self.photoItem = photoItem
        self.indexPhotoItemInArray = indexPhotoItemInArray
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if photoItem == nil {
            takeImage(fromCamera: takeNewPhotoFromCamera)
        }
    }
    
}

// MARK: -  Functions
extension EditLocalPhotoViewController {
    
    private func dismissAndGoBack() {
        _ = navigationController?.popViewController(animated: true)
    }
}


// MARK: -  CLLocationManagerDelegate, Map & Location
extension EditLocalPhotoViewController: CLLocationManagerDelegate {
    
    private func setMapViewCenterByPhotoCoordinate() {
        var centerCoordinates = CLLocationCoordinate2D()
        
        if let itemCoordinates = itemCoordinate {
            centerCoordinates = itemCoordinates
        } else if let currentCoordinate = currentCoordinate {
            centerCoordinates = currentCoordinate
        }
        
        let mapRegion = MKCoordinateRegion(center: centerCoordinates,
                                           latitudinalMeters: 100,
                                           longitudinalMeters: 100)
        mapView.setRegion(mapRegion, animated: false)
    }
    
}


// MARK: -  UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension EditLocalPhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private func takeImage(fromCamera: Bool) {
        if !fromCamera {
            let status = PHPhotoLibrary.authorizationStatus()
            
            if status == .notDetermined  {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .notDetermined {return}
                })
            }
        }
        
        let vc = UIImagePickerController()
        vc.sourceType = fromCamera ? .camera : .photoLibrary
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        photoItemImageView.image = image
        
        //try to detect coordinate
        itemCoordinate = nil
        
        if let asset = info[.phAsset] as? PHAsset {
            itemCoordinate = asset.location?.coordinate
        } else {
            if takeNewPhotoFromCamera {
                itemCoordinate = currentCoordinate
            }
        }
        
        setMapViewCenterByPhotoCoordinate()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissAndGoBack()
    }
}
