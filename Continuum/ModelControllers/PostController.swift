//
//  PostController.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
  
  //MARK: - SharedInstance
  static let shared = PostController()
  private init() {}
  
  //MARK: - Source of Truth
  var posts: [Post] = []
  
  //MARK: - CRUD Methods
  //MARK: - Create Methods
  func addComment(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
    let comment = Comment(text: text, post: post)
    post.comments.append(comment)
    let record = CKRecord(comment: comment)
    CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
      if let error = error{
        print("\(error.localizedDescription) \(error) in function: \(#function)")
        completion(nil)
        return
      }
      //This process of unwrapping the record and initalizing a comment is designed to make sure saving worked properly, and will give anyone using the function later a way to execute code after the save completes.
      guard let record = record else { completion(nil) ; return }
      let comment = Comment(ckRecord: record, post: post)
      self.incrementCommentCount(for: post, completion: nil)
      completion(comment)
    }
  }
  
  func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
    let post = Post(photo: photo, caption: caption)
    self.posts.append(post)
    let record = CKRecord(post: post)
    CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
      if let error = error{
        print("\(error.localizedDescription) \(error) in function: \(#function)")
        completion(nil)
        return
      }
        //This process of unwrapping the record and initalizing a post is designed to make sure saving worked properly, and will give anyone using the function later a way to execute code after the save completes.
        guard let record = record,
          let post = Post(ckRecord: record)  else { completion(nil) ; return }
        completion(post)
    }
  }
  
  //MARK: - Read Methods
  func fetchPosts(completion: @escaping ([Post]?) -> Void){
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
    CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
      if let error = error{
        print("\(error.localizedDescription) \(error) in function: \(#function)")
        completion(nil)
        return
      }
      guard let records = records else { completion(nil) ; return }
      let posts = records.compactMap{ Post(ckRecord: $0) }
      self.posts = posts
      completion(posts)
    }
  }
  
  func fetchComments(for post: Post, completion: @escaping ([Comment]?) -> Void){
    let postRefence = post.recordID
    //This is a predicate (filter) for all of the comments in CloudKit which have this postReference
    let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postRefence)
    let commentIDs = post.comments.compactMap({$0.recordID})
    //This is a predicate (filter) which excludes all of the comments we already have storeds within the local post.  This allows us to not refetch comments we already have pulled down.
    let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
    let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
    CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
      if let error = error {
        print("Error fetching comments from cloudKit \(#function) \(error) \(error.localizedDescription)")
        completion(nil)
        return
      }
      guard let records = records else { completion(nil); return }
      let comments = records.compactMap{ Comment(ckRecord: $0, post: post) }
      post.comments.append(contentsOf: comments)
      completion(comments)
    }
  }
  
  //MARK: - Update Methods
  func incrementCommentCount(for post: Post, completion: ((Bool)-> Void)?){
    //Increment the comment count locally
    post.commentCount += 1
    //Initialize the class that will modify a post's CKRecord in CloudKit
    let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
    //Only updates the properties that have changed on the post
    modifyOperation.savePolicy = .changedKeys
    //This is the completion block that will be called after the modify operation finishes
    modifyOperation.modifyRecordsCompletionBlock = { (records, _, error) in
      if let error = error{
        print("\(error.localizedDescription) \(error) in function: \(#function)")
        completion?(false)
        return
      }else {
        completion?(true)
      }
    }
    //Add the operation to the public database
    CKContainer.default().publicCloudDatabase.add(modifyOperation)
  }
}
