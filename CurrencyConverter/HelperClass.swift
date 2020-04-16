//
//  HelperClass.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 17/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import Foundation
import Alamofire

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}

func showAlert(message: String, viewController:UIViewController)
{
    let alert = UIAlertController(title: "CurrencyExchange", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    viewController.present(alert, animated: true, completion: nil)
}

