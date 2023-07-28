//
//  DateUtil.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 28/07/2023.
//

import Foundation

struct DateUtil {
  static func timeToDate(baseDate: Date, time: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    guard let result = dateFormatter.date(from: time) else {
      dateFormatter.dateFormat = "HH"
      guard let result = dateFormatter.date(from: time) else {
        return nil
      }
      return add(baseDate: baseDate, to: result)
    }
    
    return add(baseDate: baseDate, to: result)
  }

  static func add(baseDate: Date, to: Date) -> Date? {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day, .month, .year], from: to, to: baseDate)
    return calendar.date(byAdding: components, to: to)
  }
  
  static func today() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: Date.now)
  }
  
  static func filenameToDate(_ filename: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: filename)!
  }
  
  static func dateToString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
  }
}
