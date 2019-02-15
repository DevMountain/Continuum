//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
  
  //MARK: - IBOutlets
  @IBOutlet weak var captionTextField: UITextField!
  
  //MARK: - Properties
  var selectedImage: UIImage?
  
  //MARK: - View Lifecycle Methods
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    captionTextField.text = nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPhotoSelectorVC" {
      let photoSelector = segue.destination as? PhotoSelectorViewController
      photoSelector?.delegate = self
    }
  }
  
  //MARK: - Actions
  @IBAction func addPostButtonTapped(_ sender: UIButton) {
    guard let photo = selectedImage,
      let caption = captionTextField.text else { return }
    PostController.shared.createPostWith(photo: photo, caption: caption) { (post) in
      
    }
    self.tabBarController?.selectedIndex = 0
  }
  
  @IBAction func cancelButtonTapped(_ sender: Any) {
    self.tabBarController?.selectedIndex = 0
  }
}

extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
  func photoSelectorViewControllerSelected(image: UIImage) {
    selectedImage = image
  }
}
