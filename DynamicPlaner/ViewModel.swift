//
//  ViewModel.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 26/07/2023.
//

import Foundation

class ViewModel: ObservableObject {
  @Published var models: [ElementModel] {
    didSet {
      if let file = file {
        FileUtil.writeFile(url: file, viewModel: self)
      }
    }
  }
  
  var file: URL?
  
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
  
  private func decode(state: String) -> [ElementModel] {
    var result: [ElementModel] = []
    let firstPass = firstPass(state: state)
    
    return result
  }
  
  private func firstPass(state: String) -> [ElementModel] {
    state.components(separatedBy: .newlines).map { (string) -> ElementModel in
      let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
      let model: ElementModel = {
        if(string.first == "-") {
          let text = string.count > 4 ? String(string.dropFirst(5)) : ""
          let done = Array(string)[2] == "x"
          return ElementModel(type: .check, text: text, done: done)
        } else if string.first == "#" {
          let text = String(string.drop(while: { c in c == "#" }).drop(while: { c in c == " " }))
          return ElementModel(type: .text, text: text, weight: tokens.first?.count ?? 1)
        } else if string == "" {
          return ElementModel(type: .field)
        } else { //if string.first?.isASCII != nil && string.first!.isASCII {
          return ElementModel(type: .field, text: String(string))
        }
      }()
      return model
    }
  }
}
