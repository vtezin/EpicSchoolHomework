//
//  EditLocalPhotoViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 03.06.2022.
//

import UIKit
import MapKit
import Photos
import Combine

final class EditLocalPhotoViewController: UIViewController {
    @IBOutlet private weak var photoItemImageView: UIImageView!
    
    @IBOutlet private weak var descriptionStackView: UIStackView!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var questionTextView: UITextView!
    
    @IBOutlet private weak var answerTextField: UITextField!
    @IBOutlet private weak var answerDescriptionTextView: UITextView!
    
    @IBOutlet private weak var centerMapImageView: UIImageView!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var mapModeControl: UISegmentedControl!
    
    @IBOutlet weak var viewMode: UISegmentedControl!
    @IBAction func viewModeChanged(_ sender: Any) {
        setVisibleLayer()
    }
    @IBAction func mapModeChanged(_ sender: Any) {
        mapView.mapType = mapModeControl.selectedSegmentIndex == 0 ? .standard : .hybrid
    }
    
    var localPhoto: LocalPhoto?
    
    var takeNewPhotoFromCamera = true
    
    private var photoCoordinate: CLLocationCoordinate2D?
    private var subscriptions = Set<AnyCancellable>()
    
    //TODO: remove delegate
    let delegate: LocalPhotoCollectionViewer
    let indexPhotoItemInArray: Int?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(photoItem: LocalPhoto?,
         indexPhotoItemInArray: Int?,
         delegate: LocalPhotoCollectionViewer) {
        self.localPhoto = photoItem
        self.indexPhotoItemInArray = indexPhotoItemInArray
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setVisibleLayer()
        
        answerDescriptionTextView.layer.borderWidth = 1
        answerDescriptionTextView.layer.borderColor = UIColor.systemBackground.cgColor
        answerDescriptionTextView.layer.cornerRadius = 8
        
        configureMapView()
        
        if let localPhoto = localPhoto {
            configureByPhoto(localPhoto)
        }
        
        configureBarMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appState.locationService.stopUpdating()
    }
}

// MARK: -  Data actions
extension EditLocalPhotoViewController {
    private func getLocalPhotoForSave() -> LocalPhoto {
        return LocalPhoto(id: localPhoto == nil ? UUID().uuidString : localPhoto!.id,
                          image: photoItemImageView.image!,
                          addingDate: localPhoto == nil ? Date() : localPhoto!.addingDate,
                          description: descriptionTextField.text,
                          question: questionTextView.text,
                          answer: answerTextField.text,
                          answerDescription: answerDescriptionTextView.text,
                          latitude: photoCoordinate?.latitude ?? 0,
                          longitude: photoCoordinate?.longitude ?? 0,
                          mapType: mapView.mapType,
                          mapSpan: mapView.region.span)
    }
    
    @objc private func save() {
        let localPhotoForSave = getLocalPhotoForSave()
        LocalPhotoRealm.savePhotoToRealm(photo: localPhotoForSave)
        
        if let _ = localPhoto, let indexPhotoItemInArray = indexPhotoItemInArray {
            delegate.photoChanged(localPhoto: localPhotoForSave, index: indexPhotoItemInArray)
        } else {
            delegate.photoAdded(localPhoto: localPhotoForSave)
        }
        
        dismissAndGoBack()
    }
    
    @objc private func publish() {
        if !appState.firebaseIsConnected {
            let alertController = simpleAlert(title: "Нет связи ((", message: "Отсутствует соединение с сервером. Публикация невозможна. Можно забраться куда то повыше или спросить пароль от вайфая. Должны дать по идее.")
            present(alertController, animated: true)
            return
        }
        
        let alertController = UIAlertController(title: "Опубликовать фото?" , message: "После публикации фото нельзя редактировать. Оно принадлежит Вселенной.", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Отмена, еще подумаю", style: .cancel) { _ in
            return
        }
        alertController.addAction(action1)
        let action2 = UIAlertAction(title: "Опубликовать", style: .default) {_ in
            if let _ = self.localPhoto,
                let indexPhotoItemInArray = self.indexPhotoItemInArray {
                let localPhotoForPublish = self.getLocalPhotoForSave()
                LocalPhoto.publishPhoto(localPhotoForPublish)
            }
            self.dismissAndGoBack()
        }
        alertController.addAction(action2)
        present(alertController, animated: true)
    }
    
    @objc private func deletePhoto() {
        let alertController = UIAlertController(title: "Удалить фото?" , message: "это навсегда, совсем", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Не-не-не! Отмена", style: .cancel) { _ in
            return
        }
        alertController.addAction(action1)
        let action2 = UIAlertAction(title: "Удалить", style: .destructive) {_ in
            if let localPhoto = self.localPhoto, let indexPhotoItemInArray = self.indexPhotoItemInArray {
                LocalPhotoRealm.deletePhoto(photo: localPhoto)
                self.delegate.photoDeleted(index: indexPhotoItemInArray)
            }
            self.dismissAndGoBack()
        }
        alertController.addAction(action2)
        present(alertController, animated: true)
    }
}

// MARK: -  Configure view
extension EditLocalPhotoViewController {
    private func dismissAndGoBack() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func setVisibleLayer() {
        switch viewMode.selectedSegmentIndex {
        case 0:
            photoItemImageView.isHidden = false
            mapView.isHidden = true
            descriptionStackView.isHidden = true
        case 1:
            photoItemImageView.isHidden = true
            mapView.isHidden = false
            descriptionStackView.isHidden = true
        case 2:
            photoItemImageView.isHidden = true
            mapView.isHidden = true
            descriptionStackView.isHidden = false
        default:
            return
        }
        centerMapImageView.isHidden = mapView.isHidden
        mapModeControl.isHidden = mapView.isHidden
    }
    
    private func configureBarMenu() {
        let saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(save))
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(publish))
        
        if localPhoto == nil {
            appState.locationService.$lastLocation.sink(receiveValue: { [weak self]  newLocation in
                guard let newLocation = newLocation else {return}
                self?.locationDidChanged(newLocation: newLocation)
            })
            .store(in: &subscriptions)
            appState.locationService.startUpdating()
            takeImage(fromCamera: takeNewPhotoFromCamera)
            navigationItem.rightBarButtonItems = [saveButton, shareButton]
        } else {
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePhoto))
            navigationItem.rightBarButtonItems = [saveButton, shareButton, deleteButton]
        }
    }
    
    func configureByPhoto(_ localPhoto: LocalPhoto) {
        photoItemImageView.image = localPhoto.image
        descriptionTextField.text = localPhoto.description
        questionTextView.text = localPhoto.question
        answerTextField.text = localPhoto.answer
        answerDescriptionTextView.text = localPhoto.answerDescription
        
        photoCoordinate = localPhoto.coordinate
        mapView.mapType = localPhoto.mapType
        mapModeControl.selectedSegmentIndex = mapView.mapType == .standard ? 0 : 1
        let mapRegion = MKCoordinateRegion(center: localPhoto.coordinate, span: localPhoto.mapSpan)
        mapView.setRegion(mapRegion, animated: false)
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
        mapView.showsScale = false
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
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

