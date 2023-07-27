//
//  ViewModel.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 26/07/2023.
//

import Foundation

class ViewModel: ObservableObject {
  @Published var models: [BaseModel]
  
  init() {
    self.models = []
  }
  
  init(state: String) {
    self.models = []
    self.models = decode(state: state)
  }
  
  func encode() -> String {
    models.map { vm in vm.toString() }.joined(separator: "\n")
  }
  
  func update(state: String) {
    self.models = decode(state: state)
  }
  
  private func decode(state: String) -> [BaseModel] {
    var result: [BaseModel] = []
    state.components(separatedBy: .newlines).forEach { string in
      let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
      if(string.first == "-") {
        let text = string.count > 4 ? String(string.dropFirst(5)) : ""
        let done = Array(string)[2] == "x"
        result.append(BaseModel(type: .check, text: text, done: done))
      } else if string.first == "#" {
        let text = String(string.drop(while: { c in c == "#" }).drop(while: { c in c == " " }))
        result.append(BaseModel(type: .text, text: text, weight: tokens.first?.count ?? 1))
      } else if string == ""{
        result.append(BaseModel(type: .text))
      } else if string == "" {
        result.append(BaseModel(type: .field))
      } else if string.first?.isASCII != nil && string.first!.isASCII {
        result.append(BaseModel(type: .field, text: String(string)))
      }
    }
    return result
  }
}
