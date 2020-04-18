//
//  CurrencyConvertVC.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 17/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import UIKit
import Moya
import RealmSwift

class CurrencyConvertVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var btnBaseCountry: UIButton!
    @IBOutlet var btnOtherCountry: UIButton!
    
    @IBOutlet var txtBaseCountry: UITextField!
    @IBOutlet var txtOtherCountry: UITextField!
    
    @IBOutlet var viewPicker: UIView!
    @IBOutlet var pickerVw: UIPickerView!
    @IBOutlet var lblLastUpdate: UILabel!
    
    var isBaseCountry = true
    
    let provider = MoyaProvider<WebService>()
    var rate = [CurrencyRate](){
        didSet{
            pickerVw.reloadAllComponents()
        }
    }
    
    var strBaseCountry = "MYR"
    var otherCountry = "INR"
    var baseValue = 0.0
    var otherValue = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBaseCountry.layer.cornerRadius = 5
        btnBaseCountry.layer.borderColor = UIColor.link.cgColor
        btnBaseCountry.layer.borderWidth = 1.0
        
        btnOtherCountry.layer.cornerRadius = 5
        btnOtherCountry.layer.borderColor = UIColor.link.cgColor
        btnOtherCountry.layer.borderWidth = 1.0
        
        btnBaseCountry.setTitle("\(strBaseCountry)", for: .normal)
        btnOtherCountry.setTitle("\(otherCountry)", for: .normal)
        
        txtBaseCountry.text = "1.0"
        
        self.rate = DatabseMethods.shared.getData()
        refreshData(baseCountry: strBaseCountry, otherCountry: otherCountry)
        
        txtBaseCountry.addTarget(self, action: #selector(txtBaseCountryEditing), for: UIControl.Event.editingChanged)
        txtOtherCountry.addTarget(self, action: #selector(txtOtherCountryEditing), for: UIControl.Event.editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard () {
        txtBaseCountry.resignFirstResponder()
        txtOtherCountry.resignFirstResponder()
    }
    
    @objc func txtBaseCountryEditing(textField: UITextField)
    {
        let newBaseValue = Double(txtBaseCountry.text!) ?? 0.0
        txtOtherCountry.text = "\(newBaseValue * otherValue)"
        
        
    }
    @objc func txtOtherCountryEditing(textField: UITextField)
    {
        let newOtherValue = Double(txtOtherCountry.text!) ?? 0.0
        txtBaseCountry.text = "\(newOtherValue/otherValue)"
    }
    
    
    // MARK: - Refresh Data API call
    /*
     @Developer     - Paras Navadiya
     @Description   - This method will used to refresh data or get latetst data of currency.
     @Parameter     - No Parameters
     @Return        - Void
     */
    func refreshData(baseCountry : String, otherCountry: String)
    {
        print(baseCountry, otherCountry)
        if Connectivity.sharedInstance.isReachable
        {
            provider.request(.getExchangeRatesBWCountry(baseCountry: baseCountry, otherCountry: otherCountry)) { Result in
                switch Result{
                case.success(let response):
                    do {
                        let json = try JSONDecoder().decode(Currency.self, from: response.data)
                        
                        let currencyArray = (json.rates?.compactMap({ (key,val)  in
                            return CurrencyRate(countryName: key, countryCurrency: val)
                        }))!
                        
                        if json.base == self.strBaseCountry && json.base == currencyArray[0].countryName ?? ""
                        {
                            self.baseValue = currencyArray[0].countryCurrency ?? 0.0
                            self.otherValue = currencyArray[1].countryCurrency ?? 0.0
                            self.txtBaseCountry.text = "\(currencyArray[0].countryCurrency ?? 0)"
                            guard let baseVal = Double(self.txtBaseCountry.text!) else {return}
                            guard let countryCurrency = currencyArray[1].countryCurrency else {return}
                            
                            self.txtOtherCountry.text = "\(baseVal * countryCurrency)"
                        }
                        else
                        {
                            self.baseValue = currencyArray[1].countryCurrency ?? 0.0
                            self.otherValue = currencyArray[0].countryCurrency ?? 0.0
                            self.txtBaseCountry.text = "\(currencyArray[1].countryCurrency ?? 0)"
                            guard let baseVal = Double(self.txtBaseCountry.text!) else {return}
                            guard let countryCurrency = currencyArray[0].countryCurrency else {return}
                            
                            self.txtOtherCountry.text = "\(baseVal * countryCurrency)"
                        }
                        self.lblLastUpdate.text = "Last updated: " + (json.date ?? "")
                        
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
            showAlert(message: "The Internet connection appears to be offline", viewController: self)
        }
    }
    // MARK: - Button Action Methods
    @IBAction func btnBaseCountry(_ sender: Any)
    {
        if Connectivity.sharedInstance.isReachable
        {
            dismissKeyboard()
            isBaseCountry = true
            viewPicker.isHidden = false
            self.view.bringSubviewToFront(viewPicker)
        }
        else
        {
            showAlert(message: "The Internet connection appears to be offline", viewController: self)
        }
    }
    @IBAction func btnOtherCountry(_ sender: Any)
    {
        if Connectivity.sharedInstance.isReachable
        {
            dismissKeyboard()
            isBaseCountry = false
            viewPicker.isHidden = false
            self.view.bringSubviewToFront(viewPicker)
        }
        else
        {
            showAlert(message: "The Internet connection appears to be offline", viewController: self)
        }
    }
    
    @IBAction func btnCancelPicker(_ sender: Any)
    {
        viewPicker.isHidden = true
        self.view.sendSubviewToBack(viewPicker)
    }
    
    @IBAction func btnDonePicker(_ sender: Any)
    {
        if isBaseCountry
        {
            btnBaseCountry.setTitle("\(strBaseCountry)", for: .normal)
            refreshData(baseCountry: strBaseCountry, otherCountry: otherCountry)
        }
        else
        {
            btnOtherCountry.setTitle("\(strBaseCountry)", for: .normal)
            refreshData(baseCountry: strBaseCountry, otherCountry: otherCountry)
        }
        
        viewPicker.isHidden = true
        self.view.sendSubviewToBack(viewPicker)
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
        strBaseCountry = self.rate[row].countryName ?? ""
        
        if isBaseCountry
        {
            otherCountry = btnOtherCountry.titleLabel?.text ?? ""
        }
        else
        {
            otherCountry = btnOtherCountry.titleLabel?.text ?? ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.rate[row].countryName
    }
}
