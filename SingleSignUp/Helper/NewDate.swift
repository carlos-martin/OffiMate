//
//  NewDate.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 18/09/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation

class NewDate {
    let date:   Date
    let year:   Int
    let month:  Int
    let day:    Int
    let id:     Int
    
    init(date: Date) {
        let calendar = Calendar.current
        self.date =  date
        self.year =  calendar.component(.year,  from: date)
        self.month = calendar.component(.month, from: date)
        self.day =   calendar.component(.day,   from: date)
        self.id =    (self.year * 10000) + (self.month * 100) + self.day
    }
    
    func getWeekNum() -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekOfYear, from: self.date)
    }
    
    func getWeekDay() -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self.date)
    }
    
    func getDayName(weekDayNum: Int?=nil) -> String {
        let _weekDay: Int
        
        if let _ = weekDayNum {
            _weekDay = weekDayNum!
        } else {
            _weekDay = self.getWeekDay()
        }
        
        switch _weekDay {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thrusday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return ""
        }
    }
}
