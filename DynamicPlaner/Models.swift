//
//  Models.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 25/07/2023.
//

import SwiftUI

class ElementModel: ObservableObject {
  enum ViewType {
    case text
    case field
    case check
    case editor
    case notification
    case empty // Handle parsing failures
  }
  
  let type: ViewType

  @Published var text: String {
    didSet {
      if self.type == .notification {
        if self.text != "" && done {
         let set = setReminder()
          if !set { self.done = false } // Unable to set reminder. This guard shouldn't be needed?
        } else {
          self.done = false
          removeReminder()
        }
      }
    }
  }
  @Published var done: Bool {
    didSet {
      if self.type == .notification {
        if self.done {
          let set = setReminder()
          if !set { self.done = false } // Unable to set reminder. This guard shouldn't be needed?
        } else {
          removeReminder()
        }
      }
    }
  }
  let weight: Int
  var label: String
  let date: Date
  
  init(type: ViewType, text: String = "", weight: Int = 5, done: Bool = false, label: String = "", date: Date = Date.now) {
    self.type = type
    self.text = text
    self.weight = weight
    self.done = done
    self.label = label
    self.date = date
    
    checkNotificationScheduled()
  }
  
  func checkNotificationScheduled() {
    if type == .notification {
      NotificationUtil.checkScheduled(id: DateUtil.dateToNotificationID(date)) { res in
        self.done = res
      }
    }
  }
  
  func toString() -> String {
    switch type {
    case .text:
      let prefix = weight < 5 ? String(repeating: "#", count: weight) : ""
      return "\(prefix) \(text)"
    case .field:
      return text
    case .check:
      return "-[\(done ? "x": " ")] \(text)"
    case .editor:
      return "\(text)\n"
    case .notification:
      return "[\(label)](\(DateUtil.dateToString(date))) \(text)"
    case .empty:
      return text
    }
  }
  
  func setReminder() -> Bool {
    let noteText = (self.text != "" ? self.text : self.label)
    return NotificationUtil.scheduleNotification(id: DateUtil.dateToNotificationID(date), message: noteText, date: date)
  }
  func removeReminder() {
    NotificationUtil.removeNotification(id: DateUtil.dateToNotificationID(date))
  }
}
