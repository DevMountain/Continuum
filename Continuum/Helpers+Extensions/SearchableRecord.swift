//
//  SearchableRecord.swift
//  Continuum
//
//  Created by DevMountain on 2/15/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import Foundation

protocol SearchableRecord {
  func matches(searchTerm: String) -> Bool
}
