//
//  EditItemViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 27.04.2022.
//

import UIKit
import MapKit
import Photos

final class EditItemViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerMapLabel: UILabel!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var isVisitedStackView: UIStackView!
    
    @IBOutlet weak var likedImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var visitedImageView: UIImageView!
    
    var photoItem: PhotoItem?
    var takeNewPhotoFromCamera = true
    private let locationManager = CLLocationManager()
    private var itemCoordinate: CLLocationCoordinate2D?
    private var currentCoordinate: CLLocationCoordinate2D?
    private var distanceFromHereMeters: Double?
    
    let delegate: canUpdatePhotoItemInArray
    let indexPhotoItemInArray: Int?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(photoItem: PhotoItem?,
         indexPhotoItemInArray: Int?,
         delegate: canUpdatePhotoItemInArray) {
        self.photoItem = photoItem
        self.indexPhotoItemInArray = indexPhotoItemInArray
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Опубликовать", style: .plain, target: self, action: #selector(postItem))
        //addKeyboardNotifications()
        configure()
        redrawFastActionsViews() 
        configurePostButton()
        configureMapView()
        configureLocationServices()
        
        descriptionTextField.delegate = self
        
        if photoItem == nil {
            distanceLabel.isHidden = true
            isVisitedStackView.isHidden = true
            takeImage(fromCamera: takeNewPhotoFromCamera)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}

// MARK: -  UITextFieldDelegate
extension EditItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

// MARK: -  MKMapViewDelegate
extension EditItemViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        itemCoordinate = mapView.centerCoordinate
    }
}

// MARK: -  CLLocationManagerDelegate, Map & Location
extension EditItemViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        if itemCoordinate == nil {
            let zoomRegion = MKCoordinateRegion(center: latestLocation.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(zoomRegion, animated: false)
        }
    
        currentCoordinate = latestLocation.coordinate
        
        distanceFromHereMeters = CLLocation(latitude: currentCoordinate!.latitude, longitude: currentCoordinate!.longitude).distance(from: CLLocation(latitude: itemCoordinate!.latitude, longitude: itemCoordinate!.longitude))
        
        distanceLabel.text = "отсюда " + localeDistanceString(distanceMeters: distanceFromHereMeters!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
    
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
}

// MARK: -  UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension EditItemViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        photoImageView.image = image
        
        configurePostButton()
        
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

// MARK: -  fast actions
extension EditItemViewController {
    private func addGesturesToFastActionsViews() {
        let likedTapGesture = UITapGestureRecognizer(target: self, action: #selector(likedTapped))
        likedTapGesture.numberOfTapsRequired = 1
        likedImageView.addGestureRecognizer(likedTapGesture)
        
        let visitedTapGesture = UITapGestureRecognizer(target: self, action: #selector(visitedTapped))
        visitedTapGesture.numberOfTapsRequired = 1
        visitedImageView.addGestureRecognizer(visitedTapGesture)
    }
    
    private func redrawFastActionsViews() {
        guard let photoItem = photoItem else {
            return
        }
        
        likedImageView.image = UIImage(systemName: photoItem.isLikedByCurrentUser ? "heart.fill" : "heart")
        visitedImageView.image = UIImage(systemName: photoItem.isVisitedByCurrentUser ? "eye.fill" : "eye")
    }
    
    @objc private func likedTapped()
    {
        guard var photoItem = photoItem else {return}
        photoItem.setLikedByCurrentUser(!photoItem.isLikedByCurrentUser)
        self.photoItem = photoItem
        redrawFastActionsViews()
    }
    
    @objc private func visitedTapped()
    {
        guard var photoItem = photoItem else {return}
        guard let distanceFromHereMeters = distanceFromHereMeters else {return}
        
        if !photoItem.isVisitedByCurrentUser && distanceFromHereMeters > 10 {
            let alertController = UIAlertController(title: "Далековато отсюда \(localeDistanceString(distanceMeters: distanceFromHereMeters))", message: "Для отметки посещения необходимо быть не дальше 10 метров от точки съемки. Такие правила. Движение - жизнь.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Понятно", style: .cancel)
            alertController.addAction(action)
            present(alertController, animated: true)
            return
        }
        
        photoItem.setVisitedByCurrentUser(!photoItem.isVisitedByCurrentUser)
        self.photoItem = photoItem
        redrawFastActionsViews()
    }
}

// MARK: -  functions
extension EditItemViewController {
    private func configure() {
        if let photoItem = photoItem {
            navigationItem.title = photoItem.description
            imageLoadingIndicator.startAnimating()
            ImagesService.fetchImageForPhotoItem(photoItem: photoItem,
                                          completion: setImage)
            if photoItem.latitude != 0 {
                itemCoordinate = CLLocationCoordinate2D(latitude: photoItem.latitude,
                                                        longitude: photoItem.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = itemCoordinate!
                mapView.addAnnotation(annotation)
                centerMapLabel.isHidden = true
                
                setMapViewCenterByPhotoCoordinate()
            }
            descriptionTextField.isHidden = true
            
            addGesturesToFastActionsViews()
        }
    }
    
    func setImage(uiImage: UIImage?) {
        if let uiImage = uiImage{
            photoImageView.image = uiImage
            imageLoadingIndicator.stopAnimating()
        }
    }
    
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
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    private func configurePostButton() {
        navigationItem.rightBarButtonItem?.isEnabled = photoImageView.image != nil && !(descriptionTextField.text?.isEmpty ?? false)
    }
    
    @objc private func textFieldDidChange() {
        configurePostButton()
    }
    
    private func dismissAndGoBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc private func postItem() {
        guard let uiImage = photoImageView.image,
        let description = descriptionTextField.text else {
            return
        }
        
        FireBaseService.postItem(image: uiImage,
                                 description: description,
                                 latitude: itemCoordinate?.latitude,
                                 longitude: itemCoordinate?.longitude)
        dismissAndGoBack()
    }
}

// MARK: - Keyboard support
extension EditItemViewController {
    private func addKeyboardNotifications() {
        // call the 'keyboardWillShow' function when the view controller receive notification that keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }
}
