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
    
    @IBOutlet private weak var photoStackView: UIStackView!
    @IBOutlet private weak var centerMapImageView: UIImageView!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var mapModeControl: UISegmentedControl!
    
    @IBOutlet weak var viewMode: UISegmentedControl!
    @IBAction func viewModeChanged(_ sender: Any) {
        setMapPhotoVisible()
    }
    @IBAction func mapModeChanged(_ sender: Any) {
        mapView.mapType = mapModeControl.selectedSegmentIndex == 0 ? .standard : .hybrid
    }
    
    var photoItem: LocalPhoto?
    
    var takeNewPhotoFromCamera = true
    
    private var photoCoordinate: CLLocationCoordinate2D?
    
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
        setMapPhotoVisible()
        
        addKeyboardNotifications()
        descriptionTextField.delegate = self
        questionTextField.delegate = self
        answerTextField.delegate = self
        
        let saveMenu = UIMenu(title: "", children: [
            UIAction(title: "В Фотки", image: UIImage(systemName: "photo.on.rectangle.angled")){
                action in
                self.save()
            },
            UIAction(title: "Опубликовать", image: UIImage(systemName: "cloud")){
                action in
                self.share()
            }
        ])
        
        let saveMenuItem = UIBarButtonItem(title: "Сохранить", menu: saveMenu)
        
        if photoItem == nil {
            let _ = appState.locationService.$lastLocation.sink(receiveValue: { [weak self]  newLocation in
                guard let newLocation = newLocation else {return}
                self?.locationDidChanged(newLocation: newLocation)
            })
            appState.locationService.startUpdating()
            takeImage(fromCamera: takeNewPhotoFromCamera)
            navigationItem.rightBarButtonItem = saveMenuItem
        } else {
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: Selector(("delete")))
            navigationItem.rightBarButtonItems = [deleteButton, saveMenuItem]
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appState.locationService.stopUpdating()
    }
}

// MARK: -  Functions
extension EditLocalPhotoViewController {
    private func dismissAndGoBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func setMapPhotoVisible() {
        mapView.isHidden = viewMode.selectedSegmentIndex == 0
        centerMapImageView.isHidden = mapView.isHidden
        mapModeControl.isHidden = mapView.isHidden
        photoStackView.isHidden = !mapView.isHidden
    }
    
    private func save() {
        let localPhotoForSave = LocalPhoto(id: photoItem == nil ? UUID().uuidString : photoItem!.id,
                                           image: photoItemImageView.image!,
                                           addingDate: photoItem == nil ? Date() : photoItem!.addingDate,
                                           latitude: photoCoordinate!.latitude,
                                           longitude: photoCoordinate!.longitude,
                                           description: descriptionTextField.text ?? "",
                                           mapType: mapView.mapType,
                                           mapSpan: mapView.region.span)
        LocalPhotoRealm.savePhotoToRealm(photo: localPhotoForSave)
        dismissAndGoBack()
    }
    
    private func share() {
        dismissAndGoBack()
    }
}


// MARK: - Map & Location
extension EditLocalPhotoViewController: MKMapViewDelegate {
    private func locationDidChanged(newLocation: CLLocation) {

    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        photoCoordinate = mapView.centerCoordinate
    }
        
    private func setMapViewCenterByPhotoCoordinate() {
        guard let photoCoordinate = photoCoordinate else {return}
        
        let mapRegion = MKCoordinateRegion(center: photoCoordinate,
                                           latitudinalMeters: 100,
                                           longitudinalMeters: 100)
        mapView.setRegion(mapRegion, animated: false)
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
        
        photoCoordinate = appState.locationService.lastLocation?.coordinate
        
        if let asset = info[.phAsset] as? PHAsset {
            photoCoordinate = asset.location?.coordinate
        }
        
        setMapViewCenterByPhotoCoordinate()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissAndGoBack()
    }
}

// MARK: -  UITextFieldDelegate
extension EditLocalPhotoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

// MARK: - Keyboard support
extension EditLocalPhotoViewController {
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
