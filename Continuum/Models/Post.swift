//
//  Post.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class Post {
  var photoData: Data?
  var timestamp: Date
  var caption: String
  var comments: [Comment]
  var photo: UIImage? {
    get {
      guard let photoData = photoData else { return nil }
      return UIImage(data: photoData)
    }
    set {
      photoData = newValue?.jpegData(compressionQuality: 0.5)
    }
  }
  
  init(photo: UIImage, caption: String, timestamp: Date = Date(), comments: [Comment] = []) {
    self.caption = caption
    self.timestamp = timestamp
    self.comments = comments
    self.photo = photo
  }
} //End of class

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            return false
        }
    }
}//End of extension
