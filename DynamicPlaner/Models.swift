//
//  Models.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 25/07/2023.
//

import SwiftUI

class BaseModel: ObservableObject {
  func toString() -> String { "" }
}

class TextViewModel: BaseModel {
  @Published var text: String
  let weight: Int
  
  init(text: String = "View Model", weight: Int = 1) {
    self.text = text
    self.weight = weight
  }
  
  override func toString() -> String {
    text
  }
}

class TextFieldModel: BaseModel {
  @Published var text: String
  
  init(text: String = "") {
    self.text = text
  }
  
  override func toString() -> String {
    text
  }
}

class CheckBoxModel: BaseModel {
  @Published var text: String
  @Published var done: Bool

  init(text: String = "", done: Bool = false) {
    self.text = text
    self.done = done
  }
  
  override func toString() -> String {
    text
  }
}
