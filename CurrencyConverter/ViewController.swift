//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 16/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import UIKit
import Moya

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    let provider = MoyaProvider<WebService>()

    var rate = [CurrencyRate](){
         didSet{
           tableview.reloadData()
        }
    }
    
    @IBOutlet var tableview: UITableView!{
         didSet{
            tableview.register(UINib(nibName:"CurrencyCell", bundle: nil), forCellReuseIdentifier: "CurrencyCell")
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

//        provider.request(.getExchangeRates) { Result in
//            
//            switch Result{
//            case.success(let response):
//                do {
//                    let json = try JSONDecoder().decode(Currency.self, from: response.data)
//                    self.rate = (json.rates?.compactMap({ (key,val)  in
//                        return CurrencyRate(countryName: key, countryCurrency: val)
//                    }))!
//                        
//                } catch  {
//                    print(error)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
        
        provider.request(.getExchangeRatesByBaseCountry(baseCountry: "MYR")) { Result in
            
            print(Result)
            switch Result{
                
            case.success(let response):
                do {
                    let json = try JSONDecoder().decode(Currency.self, from: response.data)
                    self.rate = (json.rates?.compactMap({ (key,val)  in
                        return CurrencyRate(countryName: key, countryCurrency: val)
                    }))!
                        
                } catch  {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rate.count
    }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        cell.lblCountry.text = rate[indexPath.row].countryName
        cell.lblRate.text = "\(rate[indexPath.row].countryCurrency ?? 0)"
        return cell
       }

}

