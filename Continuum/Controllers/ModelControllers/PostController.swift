//
//  PostController.swift
//  Continuum
//
//  Created by Maxwell Poffenbarger on 2/4/20.
//  Copyright © 2020 Max Poff. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    //MARK: - Properties
    static let sharedInstance = PostController()
    var posts: [Post] = []
    let publicDB = CKContainer.default().publicCloudDatabase
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
    //MARK: - CK Methods (Create)
    func addComment(text: String, post: Post, completion: @escaping (Result<Comment?, PostError>) -> Void) {
        
        let postReference = CKRecord.Reference(recordID: post.recordID, action: .none)
        
        let comment = Comment(text: text, postReference: postReference)
        
        post.comments.append(comment)
        
        let record = CKRecord(comment: comment)
        
        publicDB.save(record) { (record, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record else { return completion(.failure(.noRecord)) }
            
            let comment = Comment(ckRecord: record)
            
            self.incrementCommentCount(for: post, completion: nil)
            
            completion(.success(comment))
        }
    }
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Result<Post?, PostError>) -> Void) {
        
        let post = Post(photo: photo, caption: caption)
        
        self.posts.append(post)
        
        let record = CKRecord(post: post)
        
        publicDB.save(record) { (record, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let post = Post(ckRecord: record)  else { return completion(.failure(.noPost)) }
            
            completion(.success(post))
        }
    }
    
    //MARK: - CK Methods (Read)
    func fetchPosts(completion: @escaping (Result<[Post]?, PostError>) -> Void){
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            guard let records = records else { return completion(.failure(.noRecord)) }
            
            let posts = records.compactMap{ Post(ckRecord: $0) }
            
            self.posts = posts
            
            completion(.success(posts))
        }
    }
    
    func fetchComments(for post: Post, completion: @escaping (Result<[Comment]?, PostError>) -> Void){
        
        let postRefence = post.recordID
        
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postRefence)
        
        let commentIDs = post.comments.compactMap({$0.recordID})
        
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            guard let records = records else { return completion(.failure(.noRecord)) }
            
            let comments = records.compactMap{ Comment(ckRecord: $0) }
            
            post.comments.append(contentsOf: comments)
            
            completion(.success(comments))
        }
    }
    
    //MARK: - CK Methods (Update)
    func incrementCommentCount(for post: Post, completion: ((Bool)-> Void)?){
        
        post.commentCount += 1
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
        
        modifyOperation.savePolicy = .changedKeys
        
        modifyOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            
            if let error = error{
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)" )
                completion?(false)
                return
            } else {
                completion?(true)
            }
        }
        publicDB.add(modifyOperation)
    }
    
    //MARK: - CK Methods (Subscriptions)
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?){
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: "Post", predicate: predicate, subscriptionID: "AllPosts", options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        let notifcationInfo = CKSubscription.NotificationInfo()
        notifcationInfo.alertBody = "New post added to Continuum"
        
        notifcationInfo.shouldBadge = true
        notifcationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notifcationInfo
        
        publicDB.save(subscription) { (subscription, error) in
            
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                completion?(false, error)
                return
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func addSubscritptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?){
        
        let postRecordID = post.recordID
        
        let predicate = NSPredicate(format: "%K = %@", CommentConstants.postReferenceKey, postRecordID)
        
        let subscription = CKQuerySubscription(recordType: "Comment", predicate: predicate, subscriptionID: post.recordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "A new comment was added to a post that you follow"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = nil
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                completion?(false, error)
                return
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool) -> ())?) {
        
        let subscriptionID = post.recordID.recordName
        
        publicDB.delete(withSubscriptionID: subscriptionID) { (_, error) in
            
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                completion?(false)
                return
            } else {
                print("Subscription deleted")
                completion?(true)
            }
        }
    }
    
    func checkForSubscription(to post: Post, completion: ((Bool) -> ())?) {
        
        let subscriptionID = post.recordID.recordName
        
        publicDB.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            if subscription != nil {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> ())?){
        
        checkForSubscription(to: post) { (isSubscribed) in
            
            if isSubscribed{
                self.removeSubscriptionTo(commentsForPost: post, completion: { (success) in
                    if success {
                        print("Successfully removed the subscription to the post with caption: \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("There was an error removing the subscription to the post with caption: \(post.caption)")
                        completion?(false, nil)
                    }
                })
            } else {
                self.addSubscritptionTo(commentsForPost: post, completion: { (success, error) in
                    if let error = error {
                        print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                        completion?(false, error)
                        return
                    }
                    if success {
                        print("Successfully subscribed to the post with caption: \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("There was an error subscribing to the post with caption: \(post.caption)")
                        completion?(false, nil)
                    }
                })
            }
        }
    }
}
