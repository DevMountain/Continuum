//
//  PhotoSelectorViewController.swift
//  Continuum
//
//  Created by DevMountain on 2/15/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PhotoSelectorViewController: UIViewController {
  
  //MARK: - IBOUTlets
  @IBOutlet weak var selectPhotoButton: UIButton!
  @IBOutlet weak var photoImageView: UIImageView!
  
  //MARK: - Properties
  weak var delegate: PhotoSelectorViewControllerDelegate?
  
  //MARK: - View Lifecycle Methods
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    photoImageView.image = nil
    selectPhotoButton.setTitle("Select Photo", for: .normal)
  }
  
  @IBAction func selectPhotoButtonTapped(_ sender: Any) {
    presentImagePickerActionSheet()
  }
}

//MARK: - UIImagePickerDelegate
extension PhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      selectPhotoButton.setTitle("", for: .normal)
      photoImageView.image = photo
      delegate?.photoSelectorViewControllerSelected(image: photo)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func presentImagePickerActionSheet() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    let actionSheet = UIAlertController(title: "Select a Photo", message: nil, preferredStyle: .actionSheet)
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
      actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
      }))
    }
    if UIImagePickerController.isSourceTypeAvailable(.camera){
      actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
        imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        self.present(imagePickerController, animated: true, completion: nil)
      }))
    }
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(actionSheet, animated: true)
  }
}

protocol PhotoSelectorViewControllerDelegate: class {
  func photoSelectorViewControllerSelected(image: UIImage)
}
