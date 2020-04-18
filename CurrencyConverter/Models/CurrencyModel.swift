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

// MARK: - Rate
struct CurrencyRate
{
    var countryName : String?
    var countryCurrency : Double?
}

// MARK: - HistoricalRates
struct HistoricalRates: Codable
{
    let rates: [String: [String: Double]]?
    let startAt, base, endAt: String?

    enum CodingKeys: String, CodingKey {
        case rates
        case startAt = "start_at"
        case base
        case endAt = "end_at"
    }
}

// MARK: - ChartData
struct ChartData
{
    var date : String?
    var currency : Double?
}

