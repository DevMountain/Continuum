//
//  PhotoSelectorViewControllerDelegate.swift
//  Continuum
//
//  Created by Maxwell Poffenbarger on 2/8/20.
//  Copyright © 2020 Max Poff. All rights reserved.
//

import UIKit

protocol PhotoSelectorViewControllerDelegate: class {
    func photoSelectorViewControllerSelected(image: UIImage)
}
