//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 16/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import UIKit
import Moya
import RealmSwift

class CurrencyExchange: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let provider = MoyaProvider<WebService>()
    @IBOutlet var viewPicker: UIView!
    @IBOutlet var pickerVw: UIPickerView!
    @IBOutlet var btnTitle: UIButton!
    
    var rate = [CurrencyRate](){
        didSet{
            tableview.reloadData()
            pickerVw.reloadAllComponents()
        }
    }
    
    @IBOutlet var tableview: UITableView!{
        didSet{
            tableview.register(UINib(nibName:"CurrencyCell", bundle: nil), forCellReuseIdentifier: "CurrencyCell")
        }
    }
    
    var selectedCountry = "MYR"{
        didSet
        {
            btnTitle.setTitle("Currency Exchange(\(selectedCountry))", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
    }
    
    // MARK: - Refresh Data API call
    /*
    @Developer     - Paras Navadiya
    @Description   - This method will used to refresh data or get latetst data of currency.
    @Parameter     - No Parameters
    @Return        - Void
    */
    func refreshData()
    {
        if Connectivity.sharedInstance.isReachable
        {
            provider.request(.getExchangeRatesByBaseCountry(baseCountry: selectedCountry)) { Result in
                switch Result{
                case.success(let response):
                    do {
                        let json = try JSONDecoder().decode(Currency.self, from: response.data)
                        let currencyArray = (json.rates?.compactMap({ (key,val)  in
                            return CurrencyRate(countryName: key, countryCurrency: val)
                        }))!
                        
                        DatabseMethods.shared.saveCurrencyDataArray(arrData: currencyArray)
                        self.rate = DatabseMethods.shared.getData()
                        
                    } catch  {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        else
        {
            self.rate = DatabseMethods.shared.getData()
            if self.rate.count == 0
            {
                showAlert(message: "No Internet connectivity", viewController: self)
            }
        }
    }
    
    // MARK: - Button Action Methods
    @IBAction func btnChangeCountry(_ sender: Any)
    {
        viewPicker.isHidden = false
        self.view.bringSubviewToFront(viewPicker)
    }
    @IBAction func btnCancelPicker(_ sender: Any)
    {
        viewPicker.isHidden = true
        self.view.sendSubviewToBack(viewPicker)
    }
        
    @IBAction func btnDonePicker(_ sender: Any)
    {
        viewPicker.isHidden = true
        self.view.sendSubviewToBack(viewPicker)
        refreshData()
    }
    @IBAction func btnRefresh(_ sender: Any)
    {
        refreshData()
    }
    
    // MARK: - UITableView Delegate and DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyCell
        cell.lblCountry.text = rate[indexPath.row].countryName
        cell.lblRate.text = "\(rate[indexPath.row].countryCurrency ?? 0)"
        
        if  rate[indexPath.row].countryName == selectedCountry
        {
            cell.backgroundColor = .lightGray
        }
        else
        {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    // MARK: - UIPickerView Delegate and DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return self.rate.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedCountry = self.rate[row].countryName ?? ""
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.rate[row].countryName
    }
}
