//
//  Comment.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

struct CommentConstants {
    static let recordType = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postReferenceKey = "post"
}

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
} //End of class

extension Comment {
    convenience init?(ckRecord: CKRecord){
        guard let text = ckRecord[CommentConstants.textKey] as? String,
              let timestamp = ckRecord[CommentConstants.timestampKey] as? Date else { return nil }
        
        let postReference = ckRecord[CommentConstants.postReferenceKey] as? CKRecord.Reference

        self.init(text: text, timestamp: timestamp, recordID: ckRecord.recordID, postReference: postReference)
    }
} //End of extension

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
}
