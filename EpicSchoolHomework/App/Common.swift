//
//  Common.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 16.06.2022.
//

import UIKit

func printDebug(_ string: String) {
    print("debug | " + string)
}

func simpleAlert(title: String, message: String, closeButtonTitle: String = "OK") -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: closeButtonTitle, style: .cancel)
    alertController.addAction(action)
    return alertController
}
