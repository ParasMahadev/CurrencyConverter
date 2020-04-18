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
    case getRatesBWDates(baseCountry : String, otherCountry: String, stratDate: String, endDate:String)
    
    //https://api.exchangeratesapi.io/history?start_at=2019-03-01&end_at=2019-03-31&base=USD&symbols=USD,INR
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
       
        case .getRatesBWDates:
            return "/history"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getExchangeRates,.getExchangeRatesByBaseCountry,.getExchangeRatesBWCountry,.getRatesBWDates:
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

        case .getExchangeRatesBWCountry(let baseCountry,let otherCountry):
            let authParams = ["base":"\(baseCountry)","symbols":"\(baseCountry),\(otherCountry)"]
            return .requestParameters(parameters: authParams, encoding: URLEncoding.default)
      
        case .getRatesBWDates(let baseCountry, let otherCountry, let stratDate, let endDate):
            let authParams = ["start_at":stratDate,"end_at":endDate, "base":"\(baseCountry)","symbols":"\(baseCountry),\(otherCountry)"]
            return .requestParameters(parameters: authParams, encoding: URLEncoding.default)

        }
    }
}




