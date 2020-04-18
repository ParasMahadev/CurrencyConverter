//
//  Webservices.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 16/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import Foundation
import Moya
import Alamofire
enum WebService{
    case getExchangeRates
    case getExchangeRatesByBaseCountry(baseCountry : String)
    case getExchangeRatesBWCountry(baseCountry : String, otherCountry: String)
}
extension WebService : TargetType{
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL {
        return URL(string: "https://api.exchangeratesapi.io")!
    }
    var path: String {
        switch self {
        case .getExchangeRates,.getExchangeRatesByBaseCountry,.getExchangeRatesBWCountry:
            return "/latest"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getExchangeRates,.getExchangeRatesByBaseCountry,.getExchangeRatesBWCountry:
            return .get
        }
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        switch self
        {
        case .getExchangeRates:
            return .requestPlain
            
        case .getExchangeRatesByBaseCountry(let baseCountry):
            let authParams = ["base":"\(baseCountry)"]
            return .requestParameters(parameters: authParams, encoding: URLEncoding.default)

        case .getExchangeRatesBWCountry(let base_country,let other_country):
            let authParams = ["base":"\(base_country)","symbols":"\(base_country),\(other_country)"]
            return .requestParameters(parameters: authParams, encoding: URLEncoding.default)
        }
    }
}




