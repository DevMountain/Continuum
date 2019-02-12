//
//  PostController.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostController {
  //MARK: - SharedInstance
  static let shared = PostController()
  private init() {}
  
  //MARK: - Source of Truth
  var posts: [Post] = []
  
  //MARK: - CRUD Methods
  //MARK: - Create Methods
  func addComment(text: String, post: Post, completion: (Comment) -> Void) {
    let comment = Comment(text: text, post: post)
    post.comments.append(comment)
  }
  
  func createPostWith(photo: UIImage, caption: String, completion: (Post?) -> Void) {
    let post = Post(photo: photo, caption: caption)
    posts.append(post)
  }
}
