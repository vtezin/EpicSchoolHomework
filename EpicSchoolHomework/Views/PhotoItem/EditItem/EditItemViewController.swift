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
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var fastActionsStackView: UIStackView!
    
    @IBOutlet private weak var likedImageView: UIImageView!
    @IBOutlet private weak var visitedImageView: UIImageView!
    @IBOutlet private weak var commentsImageView: UIImageView!
    @IBOutlet private weak var questionImageView: UIImageView!
    
    var photoItem: PhotoItem

    private let locationManager = CLLocationManager()
    private var itemCoordinate: CLLocationCoordinate2D?
    private var currentCoordinate: CLLocationCoordinate2D?
    private var distanceFromHereMeters: Double?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(photoItem: PhotoItem) {
        self.photoItem = photoItem
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addKeyboardNotifications()
        configure()
        configureFastActionsViews()
        configureMapView()
        configureLocationServices()
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
        mapView.showsScale = false
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.delegate = self
        
        itemCoordinate = CLLocationCoordinate2D(latitude: photoItem.latitude,
                                                longitude: photoItem.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = itemCoordinate!
        mapView.addAnnotation(annotation)
        
        setMapViewCenterByPhotoCoordinate()
    }
}

// MARK: -  Fast actions
extension EditItemViewController {
    private func addGesturesToFastActionsViews() {
        let likedTapGesture = UITapGestureRecognizer(target: self, action: #selector(likedTapped))
        likedTapGesture.numberOfTapsRequired = 1
        likedImageView.addGestureRecognizer(likedTapGesture)
        
        let visitedTapGesture = UITapGestureRecognizer(target: self, action: #selector(visitedTapped))
        visitedTapGesture.numberOfTapsRequired = 1
        visitedImageView.addGestureRecognizer(visitedTapGesture)
        
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(commentsTapped))
        commentsTapGesture.numberOfTapsRequired = 1
        commentsImageView.addGestureRecognizer(commentsTapGesture)
        
        let questionTapGesture = UITapGestureRecognizer(target: self, action: #selector(questionTapped))
        questionTapGesture.numberOfTapsRequired = 1
        questionImageView.addGestureRecognizer(questionTapGesture)
    }
    
    private func configureFastActionsViews() {
        likedImageView.image = photoItem.likedImage
        visitedImageView.image = photoItem.visitedImage
        questionImageView.image = photoItem.answeredImage
        questionImageView.isHidden = !photoItem.hasQuestion
    }
    
    @objc private func questionTapped()
    {
        let vc = QuestionViewController(photoItem: photoItem)
        present(vc, animated: true)
    }
    
    @objc private func commentsTapped()
    {
        let vc = CommentsListViewController(photoItem: photoItem)
        present(vc, animated: true)
    }
    
    @objc private func likedTapped()
    {
        photoItem.setLikedByCurrentUser(!photoItem.isLikedByCurrentUser)
        configureFastActionsViews()
    }
    
    @objc private func visitedTapped()
    {
        guard let distanceFromHereMeters = distanceFromHereMeters else {return}
        
        if distanceFromHereMeters > 11 {
            let alertTitle = "Далековато отсюда \(localeDistanceString(distanceMeters: distanceFromHereMeters))"
            
            if photoItem.isVisitedByCurrentUser {
                let alertController = UIAlertController(title: alertTitle , message: "Для новой отметки посещения необходимо будет снова посетить место съемки.", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Ненене!", style: .cancel) { _ in
                    return
                }
                alertController.addAction(action1)
                let action2 = UIAlertAction(title: "Схожу не развалюсь", style: .default) {_ in
                    self.toggleVisited()
                }
                alertController.addAction(action2)
                present(alertController, animated: true)
            } else {
                let alertController = UIAlertController(title: alertTitle, message: "Для отметки посещения необходимо быть не дальше 10 метров от точки съемки. Такие правила. Движение - жизнь.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Понятно", style: .cancel)
                alertController.addAction(action)
                present(alertController, animated: true)
                return
            }
        } else {
            toggleVisited()
        }
    }
    
    private func toggleVisited() {
        photoItem.setVisitedByCurrentUser(!photoItem.isVisitedByCurrentUser)
        configureFastActionsViews()
    }
}

// MARK: -  Functions
extension EditItemViewController {
    private func configure() {
        navigationItem.title = photoItem.description
        photoImageView.image = photoItem.image
        
        descriptionTextField.isHidden = true
        
        addGesturesToFastActionsViews()
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
