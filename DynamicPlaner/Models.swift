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
  }
  
  let type: ViewType

  @Published var text: String
  @Published var done: Bool
  let weight: Int
  
  init(type: ViewType, text: String = "", weight: Int = 5, done: Bool = false) {
    self.type = type
    self.text = text
    self.weight = weight
    self.done = done
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
    }
  }
}
