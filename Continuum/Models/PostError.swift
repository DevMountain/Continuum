//
//  PostError.swift
//  Continuum
//
//  Created by Marcus Armstrong on 3/25/20.
//  Copyright © 2020 Max Poff. All rights reserved.
//

import Foundation

enum PostError: LocalizedError {
    
    case ckError(Error)
    case noRecord
    case noPost
    
    var localizedDescription: String {
        switch self {
        case .ckError(let error):
            return "There was an error returned from cloudkit. Error: \(error)"
        case .noRecord:
            return "No record was returned from cloudkit"
        case .noPost:
            return "The post was not found"
        }
    }
}
