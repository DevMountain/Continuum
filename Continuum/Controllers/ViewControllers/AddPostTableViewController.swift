//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Maxwell Poffenbarger on 2/4/20.
//  Copyright © 2020 Max Poff. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var captionTextField: UITextField!
    
    //MARK: - Properties
    var selectedImage: UIImage?
    
    //MARK: - Lifecycle
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
        
        guard let photo = selectedImage, let caption = captionTextField.text else { return }
        
        PostController.sharedInstance.createPostWith(photo: photo, caption: caption) { (post) in }
        
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
}//End of class

//MARK: - Extensions
extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    }
}//End of extension
