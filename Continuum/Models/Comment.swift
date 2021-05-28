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
  
  init(text: String, timestamp: Date = Date()) {
    self.text = text
    self.timestamp = timestamp
  }
}
