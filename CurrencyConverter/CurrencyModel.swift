//
//  CurrencyModel.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 16/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import Foundation

// MARK: - Currency
struct Currency: Codable {
    let rates: [String: Double]?
    let base, date: String?
}

// MARK: - Currency
struct CurrencyRate
{
    var countryName : String?
    var countryCurrency : Double?
}




