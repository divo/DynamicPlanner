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
  }
  
  let type: ViewType

  @Published var text: String
  @Published var done: Bool
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
    }
  }
}
