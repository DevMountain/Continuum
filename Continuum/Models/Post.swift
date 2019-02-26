//
//  Post.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class Post {
  var photoData: Data?
  var timestamp: Date
  var caption: String
  var commentCount: Int
  var comments: [Comment]
  let recordID: CKRecord.ID
  var photo: UIImage? {
    get {
      guard let photoData = photoData else { return nil }
      return UIImage(data: photoData)
    }
    set {
      photoData = newValue?.jpegData(compressionQuality: 0.5)
    }
  }
  
  var imageAsset: CKAsset? {
    get {
      let tempDirectory = NSTemporaryDirectory()
      let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
      let fileURL = tempDirecotryURL.appendingPathComponent(recordID.recordName).appendingPathExtension("jpg")
      do {
        try photoData?.write(to: fileURL)
      } catch let error {
        print("Error writing to temp url \(error) \(error.localizedDescription)")
      }
      return CKAsset(fileURL: fileURL)
    }
  }
  
  //MARK: - Initializers
  init(photo: UIImage, caption: String, timestamp: Date = Date(), comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentCount: Int = 0) {
    self.caption = caption
    self.timestamp = timestamp
    self.comments = comments
    self.recordID = recordID
    self.commentCount = commentCount
    self.photo = photo
  }
  
  init?(ckRecord: CKRecord) {
    do{
    guard let caption = ckRecord[PostConstants.captionKey] as? String,
      let timestamp = ckRecord[PostConstants.timestampKey] as? Date,
      let photoAsset = ckRecord[PostConstants.photoKey] as? CKAsset,
      let commentCount = ckRecord[PostConstants.commentCountKey] as? Int
      else { return nil}
      
      let photoData = try Data(contentsOf: photoAsset.fileURL)
      self.caption = caption
      self.timestamp = timestamp
      self.photoData = photoData
      self.recordID = ckRecord.recordID
      self.commentCount = commentCount
      self.comments = []
    }catch {
      print("There was as error in \(#function) :  \(error) \(error.localizedDescription)")
      return nil
    }
  }
}

extension Post: SearchableRecord {
  func matches(searchTerm: String) -> Bool {
    if caption.contains(searchTerm) {
      return true
    }else {
      for comment in comments {
        if comment.matches(searchTerm: searchTerm) {
          return true
        }
      }
    }
    return false
  }
}

struct PostConstants {
  static let typeKey = "Post"
  static let captionKey = "caption"
  static let timestampKey = "timestamp"
  static let commentsKey = "comments"
  static let photoKey = "photo"
  static let commentCountKey = "commentCount"
}
