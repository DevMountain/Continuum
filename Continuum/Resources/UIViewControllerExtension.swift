//
//  UIViewControllerExtension.swift
//  Continuum
//
//  Created by DevMountain on 2/25/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

extension UIViewController {
  func presentSimpleAlertWith(title: String, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
    alertController.addAction(okayAction)
    present(alertController, animated: true)
  }
}
