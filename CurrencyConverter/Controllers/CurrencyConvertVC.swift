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
import Charts

class CurrencyConvertVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    
    @IBOutlet var btnBaseCountry: UIButton!
    @IBOutlet var btnOtherCountry: UIButton!
    @IBOutlet var txtBaseCountry: UITextField!
    @IBOutlet var txtOtherCountry: UITextField!
    @IBOutlet var viewPicker: UIView!
    @IBOutlet var pickerVw: UIPickerView!
    @IBOutlet var lblLastUpdate: UILabel!
    @IBOutlet var chartView: BarChartView!
    
    var isBaseCountry = true // To differentiate picker view
    let provider = MoyaProvider<WebService>() // Api calling
    
    var arrCountryList = [CurrencyRate]() // Rate Array to display country in picker view
        {
        didSet{
            pickerVw.reloadAllComponents()
        }
    }
    
    var arrChartData = [ChartData]() // For display data in chart
        {
        didSet
        {
            setChartData(arrData: arrChartData)
        }
    }
    
    // Below variable are default variable to use in currency convertion
    var strBaseCountry = "MYR"
    var otherCountry = "INR"
    var baseValue = 0.0
    var otherValue = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arrCountryList = DatabseMethods.shared.getData()
        
        setup(barLineChartView: chartView) // Setup chart view
        
        // Border and cornor redius of buttons
        btnBaseCountry.layer.cornerRadius = 5
        btnBaseCountry.layer.borderColor = UIColor.link.cgColor
        btnBaseCountry.layer.borderWidth = 1.0
        
        btnOtherCountry.layer.cornerRadius = 5
        btnOtherCountry.layer.borderColor = UIColor.link.cgColor
        btnOtherCountry.layer.borderWidth = 1.0
        
        btnBaseCountry.setTitle("\(strBaseCountry)", for: .normal)
        btnOtherCountry.setTitle("\(otherCountry)", for: .normal)
        
        txtBaseCountry.text = "1.0" // Setting default value in base country currency.
        
        // Adding editing event for calculation of currency
        txtBaseCountry.addTarget(self, action: #selector(txtBaseCountryEditing), for: UIControl.Event.editingChanged)
        txtOtherCountry.addTarget(self, action: #selector(txtOtherCountryEditing), for: UIControl.Event.editingChanged)
        
        // Adding Tap gesture for removing keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //Making first api call to get data form the default values Here is : MYR and INR
        convertCurrency(baseCountry: strBaseCountry, otherCountry: otherCountry) {
            self.getRateBWdates(baseCountry: self.strBaseCountry, otherCountry: self.otherCountry)
        }
    }
    
    func setup(barLineChartView chartView: BarLineChartViewBase) {
        
        chartView.delegate = self
        chartView.rightAxis.enabled = false
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.valueFormatter = DayAxisValueFormatter(chart: chartView)
    }
    
    func setChartData(arrData: [ChartData])
    {
        var entries  = [BarChartDataEntry]()
        
        for item in arrData
        {
            let entry = BarChartDataEntry(x: Double((item.date?.getDate().interval())!), y: item.currency ?? 0)
            entries.append(entry)
        }
        
        let dataSet = BarChartDataSet(entries: entries, label: "Last 7 Days Results")
        let data = BarChartData(dataSets: [dataSet])
        
        chartView.data = data
        chartView.notifyDataSetChanged()
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
    
    
    // MARK: - Currency Conversation API call
    /*
     @Developer     - Paras Navadiya
     @Description   - This method will used to refresh data or get latetst data of currency.
     @Parameter     - No Parameters
     @Return        - Void
     */
    func convertCurrency(baseCountry : String, otherCountry: String, completion:@escaping ()->())
    {
        print(baseCountry, otherCountry)
        if Connectivity.sharedInstance.isReachable
        {
            provider.request(.getExchangeRatesBWCountry(baseCountry: baseCountry, otherCountry: otherCountry)) { Result in
                switch Result{
                case.success(let response):
                    do {
                        let json = try JSONDecoder().decode(Currency.self, from: response.data)
                        
                        if json.rates?.count ?? 0 > 0
                        {
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
                        }
                        completion()
                    } catch  {
                        showAlert(message: error.localizedDescription, viewController: self)
                    }
                case .failure(let error):
                    showAlert(message: error.localizedDescription, viewController: self)
                }
            }
        }
        else
        {
            showAlert(message: "The Internet connection appears to be offline", viewController: self)
        }
    }
    
    // MARK: - Get Historical Rate Data API call
    /*
     @Developer     - Paras Navadiya
     @Description   - This method will used to get Get historical rates for a time period.
     @Parameter     - Base country and OtherCountry
     @Return        - Void
     */
    
    func getRateBWdates(baseCountry : String, otherCountry: String)
    {
        print(baseCountry, otherCountry)
        if Connectivity.sharedInstance.isReachable
        {
            provider.request(.getRatesBWDates(baseCountry: baseCountry, otherCountry: otherCountry, stratDate:Date().getNewDate(daycount: -7).getString() , endDate:Date().getString() )) { Result in
                
                switch Result
                {
                case .success(let response):
                    do
                    {
                        let json = try JSONDecoder().decode(HistoricalRates.self, from: response.data)
                        if json.rates?.count ?? 0 > 0
                        {
                            self.arrChartData.removeAll()
                            for item in json.rates!
                            {
                                var data  = ChartData()
                                data.date = item.key
                                
                                let dic = item.value
                                data.currency = dic[otherCountry]
                                
                                self.arrChartData.append(data)
                            }
                        }
                        else
                        {
                            showAlert(message: "Please try again", viewController: self)
                        }
                    }
                    catch
                    {
                        showAlert(message: error.localizedDescription, viewController: self)
                    }
                case .failure(let error):
                    showAlert(message: error.localizedDescription, viewController: self)
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
        if strBaseCountry == otherCountry
        {
            showAlert(message: "Both countries are same \nPlease change to other country", viewController: self)
            return
        }
        
        if isBaseCountry
        {
            btnBaseCountry.setTitle("\(strBaseCountry)", for: .normal)
        }
        else
        {
            btnOtherCountry.setTitle("\(otherCountry)", for: .normal)
        }
        
        convertCurrency(baseCountry: strBaseCountry, otherCountry: otherCountry) {                      self.getRateBWdates(baseCountry: self.strBaseCountry, otherCountry: self.otherCountry)
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
        return self.arrCountryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if isBaseCountry
        {
            strBaseCountry = self.arrCountryList[row].countryName ?? ""
        }
        else
        {
            otherCountry = self.arrCountryList[row].countryName ?? ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.arrCountryList[row].countryName
    }
}
