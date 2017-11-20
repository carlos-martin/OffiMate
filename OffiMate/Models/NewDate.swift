//
//  NewDate.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 18/09/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation


internal func == (left: NewDate, rigth: NewDate) -> Bool {
    return left.id == rigth.id
}

internal func > (left: NewDate, rigth: NewDate) -> Bool {
    return left.id > rigth.id
}

internal func < (left: NewDate, rigth: NewDate) -> Bool {
    return left.id < rigth.id
}

internal func >= (left: NewDate, rigth: NewDate) -> Bool {
    return left.id >= rigth.id
}

internal func <= (left: NewDate, rigth: NewDate) -> Bool {
    return left.id <= rigth.id
}

class NewDate: CustomStringConvertible, Hashable {
    let date:       Date
    let year:       Int64
    let month:      Int64
    let day:        Int64
    let hour:       Int64
    let minutes:    Int64
    let seconds:    Int64
    let id:         Int64
    public var hashValue:  Int
    
    public var description: String {
        let toString: String
        let current = NewDate(date: Date())
        
        if current == self {
            toString = "Now"
        } else if (self.year == current.year && self.month == current.month && self.day == current.day) {
            let minToString = (self.minutes > 9 ? "\(self.minutes)" : "0\(self.minutes)")
            toString = "\(self.hour):\(minToString)"
        } else if (self.year == current.year && self.month == current.month && (current.day - self.day == 1)) {
            toString = "Yesterday"
        } else if (self.year == current.year && self.month == current.month && (current.day - self.day < 7)) {
            toString = self.getDayName()
        } else {
            toString = "\(day)/\(month)/\(String(String(year).suffix(2)))"
        }
        return toString
    }
    
    init(date: Date) {
        let calendar = Calendar.current
        self.date =     date
        self.year =     Int64(calendar.component(.year,   from: date))
        self.month =    Int64(calendar.component(.month,  from: date))
        self.day =      Int64(calendar.component(.day,    from: date))
        self.hour =     Int64(calendar.component(.hour,   from: date))
        self.minutes =  Int64(calendar.component(.minute, from: date))
        self.seconds =  Int64(calendar.component(.second, from: date))
        self.id =       (self.year * 10000000000) + (self.month * 100000000) + (self.day * 1000000) + (self.hour * 10000) + (self.minutes * 100) + self.seconds
        self.hashValue = Int((self.year * 10000) + (self.month * 100) + (self.day))
    }
    
    init(id: Int64) {
        self.id = id
        self.year =     Int64( self.id/10000000000)
        self.month =    Int64((self.id-year*10000000000)/100000000)
        self.day =      Int64((self.id-(year*10000000000)-(month*100000000))/1000000)
        self.hour =     Int64((self.id-(year*10000000000)-(month*100000000)-(day*1000000))/10000)
        self.minutes =  Int64((self.id-(year*10000000000)-(month*100000000)-(day*1000000)-(hour*10000))/100)
        self.seconds =  Int64( self.id-(year*10000000000)-(month*100000000)-(day*1000000)-(hour*10000)-(minutes*100))
        let syear =     "\(year)"
        let smonth =    (month > 9   ? "\(month)"   : "0\(month)")
        let sday =      (day > 9     ? "\(day)"     : "0\(day)")
        let shour =     (hour > 9    ? "\(hour)"    : "0\(hour)")
        let sminutes =  (minutes > 9 ? "\(minutes)" : "0\(minutes)")
        let sseconds =  (seconds > 9 ? "\(seconds)" : "0\(seconds)")
        let string = syear + "-" + smonth + "-" + sday + "T" + shour + ":" + sminutes + ":" + sseconds
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let _date = dateFormatter.date(from: string) {
            self.date = _date
        } else {
            self.date = Date()
        }
        self.hashValue = self.date.hashValue
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
    
    func getCompleteString () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy - HH:mm"
        return dateFormatter.string(from: self.date)
    }
    
    func getChannelFormat () -> String {
        let toString: String
        let current = NewDate(date: Date())
        
        if current == self {
            toString = "Now"
        } else if (self.year == current.year && self.month == current.month && self.day == current.day) {
            toString = "Today"
        } else if (self.year == current.year && self.month == current.month && (current.day - self.day == 1)) {
            toString = "Yesterday"
        } else if (self.year == current.year && self.month == current.month && (current.day - self.day < 7)) {
            toString = self.getDayName()
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            toString = dateFormatter.string(from: self.date)
        }
        return toString
    }
    
    /*
     result == 0 -> self == date
     result > 0 --> self > date
     result < 0 --> self < date
     */
    func compare (date: NewDate) -> Int64 {
        var total = self.year - date.year
        total += (total == 0 ? self.month - date.month : 0)
        total += (total == 0 ? self.day - date.day : 0)
        return total
    }
}
