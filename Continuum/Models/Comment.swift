//
//  Comment.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import Foundation

class Comment {
  let text: String
  let timestamp: Date
  weak var post: Post?
  
  init(text: String, post: Post, timestamp: Date = Date()) {
    self.text = text
    self.post = post
    self.timestamp = timestamp
  }
}
