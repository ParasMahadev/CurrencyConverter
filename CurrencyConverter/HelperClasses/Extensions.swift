//
//  Extensions.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 18/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import Foundation

extension Date
{
    func interval() -> Int
    {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year], from: Date())
        
        let startDay = calendar.date(from: components) ?? Date()
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: startDay) else { return 0 }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: self) else { return 0 }
        
        return end - (start-1)
    }
    func getString() -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter.string(from: self)
    }
    func getNewDate(daycount : Int) -> Date
    {
        let cal = Calendar.current
        return cal.date(byAdding: .day, value: daycount, to: self)!
    }
}

extension String
{
    func getDate() -> Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter.date(from: self) ?? Date()
    }
}
