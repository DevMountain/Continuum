//
//  Post.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

struct PostConstants {
    static let typeKey = "Post"
    static let captionKey = "caption"
    static let timestampKey = "timestamp"
    static let commentsKey = "comments"
    static let photoKey = "photo"
    static let commentCountKey = "commentCount"
}

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
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(recordID.recordName).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error writing to temporary URL \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    //MARK: - Initializers
    init(photo: UIImage?, caption: String, timestamp: Date = Date(), comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentCount: Int = 0) {
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.recordID = recordID
        self.commentCount = commentCount
        self.photo = photo
    }
} //End of class

extension Post {
    
    convenience init?(ckRecord: CKRecord) {
        guard let caption = ckRecord[PostConstants.captionKey] as? String,
              let timestamp = ckRecord[PostConstants.timestampKey] as? Date,
              let commentCount = ckRecord[PostConstants.commentCountKey] as? Int
        else { return nil }
        
        var postPhoto: UIImage?
        
        if let photoAsset = ckRecord[PostConstants.photoKey] as? CKAsset {
            do {
                guard let url = photoAsset.fileURL else {return nil}
                let data = try Data(contentsOf: url)
                postPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asset to data.")
            }
        }
        self.init(photo: postPhoto, caption: caption, timestamp: timestamp, comments: [], recordID: ckRecord.recordID, commentCount: commentCount)
    }
} //End of extension

extension CKRecord {
    convenience init(post: Post) {
        
        self.init(recordType: PostConstants.typeKey, recordID: post.recordID)
        
        self.setValuesForKeys([
            PostConstants.captionKey : post.caption,
            PostConstants.timestampKey : post.timestamp,
            PostConstants.commentCountKey : post.commentCount
        ])
        
        if let postPhoto = post.imageAsset {
            self.setValue(postPhoto, forKey: PostConstants.photoKey)
        }
    }
} //End of extension

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            return false
        }
    }
}//End of extension
