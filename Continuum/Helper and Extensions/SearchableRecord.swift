//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Maxwell Poffenbarger on 2/4/20.
//  Copyright © 2020 Max Poff. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
