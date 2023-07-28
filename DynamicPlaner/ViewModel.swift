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
  
  var focusIDs: [Int?] {
    get {
      var idx = 0
      return models.map { element in
        if element.type == .check || element.type == .field || element.type == .editor || element.type == .notification {
          idx += 1 //Bit unintuaive but it's only the order that matters
          return idx
        } else {
          return nil
        }
      }
    }
  }
  
  var file: URL? {
    didSet {
      setDate()
    }
  }
  var date: Date?
  
  // Used by PlannerView to create an inital state. I don't want to read the file
  // right away so need a way to init to a useless state. This init leaves the VM invalid.....
  init() {
    self.models = []
  }
  
  init(state: String, file: URL) {
    self.models = []
    self.file = file
    self.setDate()
    self.models = decode(state: state)
  }
  
  func encode() -> String {
    models.map { vm in vm.toString() }.joined(separator: "\n")
  }
  
  func update(state: String) {
    self.models = decode(state: state)
  }
  
  private func setDate() {
    if let file = self.file {
      self.date = DateUtil.filenameToDate(file.lastPathComponent)
    }
  }
  
  private func decode(state: String) -> [ElementModel] {
    var result: [ElementModel] = []
    let firstPass = firstPass(state: state)
    result = secondPass(elements: firstPass)
    
    return result
  }
  
  // Split on newlines, while keeping an element for succesive empty lines
  private func splitLines(_ string: String) -> [String] {
    var result: [String] = []
    var acc: [Character] = []
    for char in string {
      if char == "\n" {
        result.append(String(acc))
        acc = []
      } else {
        acc.append(char)
      }
    }
    result.append("")
    return result
  }
  
  private func firstPass(state: String) -> [ElementModel] {
   return splitLines(state).map { (string) -> ElementModel in
      let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
      let model: ElementModel = {
        if(string.first == "-") {
          guard string.count > 5 else { return ElementModel(type: .empty, text: String(string)) }
          
          let text = string.count > 4 ? String(string.dropFirst(5)) : ""
          let done = Array(string)[2] == "x"
          return ElementModel(type: .check, text: text, done: done)
        } else if string.first == "#" {
          let text = String(string.drop(while: { c in c == "#" }).drop(while: { c in c == " " }))
          return ElementModel(type: .text, text: text, weight: tokens.first?.count ?? 1)
        } else if string.first == "[" {
          // I'm sure this will never blow up
          let labelTime = string.dropFirst().split(separator: "]")
          let label = String(labelTime.first ?? "")
          let time = String((labelTime[1].split(separator: "(").first?.split(separator: ")"))?.first ?? "")
          let remaining = labelTime[1].split(separator: " ")
          var text = ""
          if remaining.count > 1 {
            text = String(remaining.last ?? "")
          }
          if let baseDate = self.date,
             let date = DateUtil.timeToDate(baseDate: baseDate, time: time) {
            return ElementModel(type: .notification, text: text, label: label, date: date)
          }
          return ElementModel(type: .text) // TODO: Handle no date
        } else if string == "" {
          return ElementModel(type: .field)
        } else { //if string.first?.isASCII != nil && string.first!.isASCII {
          return ElementModel(type: .field, text: String(string))
        }
      }()
      return model
    }
  }
  
  private func secondPass(elements: [ElementModel]) -> [ElementModel] {
    var result: [ElementModel] = []
    // Merge adjacent elements of specific types
    elements.forEach { element in
      if element.type == .field {
        if result.last?.type == .field || result.last?.type == .editor {
          let text = result.last!.text
          result = result.dropLast()
          result.append(ElementModel(type: .editor, text: text))
        } else {
          result.append(element)
        }
      } else {
        result.append(element)
      }
    }
    
    return result
  }
}
