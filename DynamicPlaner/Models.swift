//
//  Models.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 25/07/2023.
//

import SwiftUI

class ElementModel: ObservableObject {
  enum ViewType {
    case heading
    case field
    case check
    case editor
    case link
    case addCheck // Could expand this to be generic in future, for now only adding checkboxes seems to make sense.
    case empty // Handle parsing failures
  }
  
  let type: ViewType
  let elementID: String = UUID().uuidString // Just for finding elements, not for SwiftUI

  @Published var text: String {
    didSet {
      if self.type == .link {
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
      if self.type == .link {
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
    if type == .link {
      NotificationUtil.checkScheduled(id: date.toNotificationID()) { res in
        self.done = res
      }
    }
  }
  
  func toString() -> String {
    switch type {
    case .heading:
      let prefix = weight < 5 ? String(repeating: "#", count: weight) : ""
      return "\(prefix) \(text)"
    case .field:
      return text
    case .check:
      return "- [\(done ? "x": " ")] \(text)"
    case .editor:
      return "\(text)"
    case .link:
      return "[\(label)](\(date.toTime()))\(text)"
    case .addCheck:
      return "+"
    case .empty:
      return text
    }
  }
  
  func setReminder() -> Bool {
    let noteText = (self.text != "" ? self.text : self.label)
    return NotificationUtil.scheduleNotification(id: date.toNotificationID(), message: noteText, date: date)
  }
  func removeReminder() {
    NotificationUtil.removeNotification(id: date.toNotificationID())
  }
}
