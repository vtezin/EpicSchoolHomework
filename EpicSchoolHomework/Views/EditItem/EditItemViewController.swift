//
//  EditItemViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 27.04.2022.
//

import UIKit

final class EditItemViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var postItemButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addKeyboardNotifications()
        configurePostButton()
    }
    
    @IBAction func takeImageFromCameraTapped(_ sender: Any) {
        takeImage(fromCamera: true)
    }

    @IBAction func takeImageFromLibraryTapped(_ sender: Any) {
        takeImage(fromCamera: false)
    }

    @IBAction func postItemButtonTapped(_ sender: Any) {
        postItem()        
    }
}

// MARK: -  UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension EditItemViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        photoImageView.image = image
        configurePostButton()
    }
}

// MARK: -  functions
extension EditItemViewController {
    private func takeImage(fromCamera: Bool) {
        let vc = UIImagePickerController()
        vc.sourceType = fromCamera ? .camera : .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func postItem() {
        guard let uiImage = photoImageView.image,
        let description = descriptionTextField.text else {
            return
        }
        
        FireBaseController.postItem(image: uiImage, description: description)
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func configurePostButton() {
        postItemButton.isEnabled = photoImageView.image != nil && !(descriptionTextField.text?.isEmpty ?? false)
        
        if postItemButton.isEnabled {
            postItemButton.setTitle("Опубликовать", for: .normal)
        } else {
            postItemButton.setTitle("Выберите фото и введите описание", for: .normal)
        }
        
    }
    
    @objc private func textFieldDidChange() {
        configurePostButton()
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
