//
//  DatabseMethods.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 17/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import RealmSwift

class CurrencyRealm: Object {
    
    @objc dynamic var countryName = ""
    @objc dynamic var countryCurrency : Double = 0.0
}

class DatabseMethods
{
    static let shared = DatabseMethods()
    let realm = try! Realm()
    
    func saveCurrencyData(obj: CurrencyRate)
    {
        let currency_Realm = CurrencyRealm()
        currency_Realm.countryCurrency = obj.countryCurrency ?? 0.0
        currency_Realm.countryName = obj.countryName ?? ""
        // Persist your data easily
        try! realm.write {
            realm.add(currency_Realm)
        }
    }
    
    func getData() -> [CurrencyRate]
    {
        return realm.objects(CurrencyRealm.self).compactMap { Elements  in
            return CurrencyRate(countryName: Elements.countryName, countryCurrency: Elements.countryCurrency)
        }
    }
    
    func clearData()  {
        try! realm.write {
          realm.deleteAll()
        }
    }
    
    func saveCurrencyDataArray(arrData: [CurrencyRate])
    {
        clearData()
        for items in arrData
        {
            saveCurrencyData(obj: items)
        }
    }
}
