//
//  Comment.swift
//  Continuum
//
//  Created by Maxwell Poffenbarger on 2/4/20.
//  Copyright © 2020 Max Poff. All rights reserved.
//

import Foundation
import CloudKit

//MARK: - String Constants
struct CommentConstants {
    
    static let recordType = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postReferenceKey = "post"
}//End of struct

//MARK: - Class Model
class Comment {
    
    let text: String
    let timestamp: Date
    let recordID: CKRecord.ID
    var postReference: CKRecord.Reference?
    
    init(text: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), postReference: CKRecord.Reference?) {
        self.text = text
        self.timestamp = timestamp
        self.recordID = recordID
        self.postReference = postReference
    }
}//End of class

//MARK: - Extensions
extension Comment {
    
    convenience init?(ckRecord: CKRecord) {
        guard let text = ckRecord[CommentConstants.textKey] as? String,
            let timestamp = ckRecord[CommentConstants.timestampKey] as? Date else { return nil }
        
        let postReference = ckRecord[CommentConstants.postReferenceKey] as? CKRecord.Reference
        
        self.init(text: text, timestamp: timestamp, recordID: ckRecord.recordID, postReference: postReference)
    }
}//End of extension

extension CKRecord {
    
    convenience init(comment: Comment) {
        
        self.init(recordType: CommentConstants.recordType, recordID: comment.recordID)
        
        self.setValuesForKeys([
            CommentConstants.textKey : comment.text,
            CommentConstants.timestampKey : comment.timestamp
        ])
        
        if let reference = comment.postReference {
            self.setValue(reference, forKey: CommentConstants.postReferenceKey)
        }
    }
}//End of extension
