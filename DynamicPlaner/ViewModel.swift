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
  
  /**
   Parse markdown document and update internal [ElementModel] state.
   - Supports a limited set of markdown with some custom extensions:
      - `- [ ] (Label)` : Checkbox, if label is omitted it becomes editable
      - `#(####) : Heading (5 levels)
   - Extensions to markdown
      - `\n` (Empty line) : Single line text Inpur field
      -  `\n\n`(Multiple empty lines) : Expandable text input area
      - `[label](time)` : Dates as Links sytnax. Can be used to create reminders.
      - `+`: Plus, a button that adds an empty checkbox one line above.
   
   - Invalid markdown will be render an Error element with the offedning line as the element content.
   */
  func update(state: String) {
    self.models = decode(state: state)
  }
  
  func addCheck(before: ElementModel) {
    let idx = self.models.firstIndex { model in model.elementID == before.elementID }
    guard let idx = idx else { return }
    models.insert(ElementModel(type: .check, text: "", done: false), at: idx)
  }
  
  internal func decode(state: String) -> [ElementModel] {
    var result: [ElementModel] = []
    let firstPass = firstPass(state: state)
    result = secondPass(elements: firstPass)
    
    return result
  }
  
  private func setDate() {
    if let file = self.file {
      self.date = DateUtil.filenameToDate(file.lastPathComponent)
    }
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
        if(string.first == "-") { // Checkbox
          return checkModel(string)
        } else if string.first == "#" { //Heading
          let text = String(string.drop(while: { c in c == "#" }).drop(while: { c in c == " " }))
          return ElementModel(type: .heading, text: text, weight: tokens.first?.count ?? 1)
        } else if string.first == "[" { // Date
          return linkModel(string)
        } else if (string.first == "+") { // Plus checkbox
          // TODO: Should this be a link or ?
          return ElementModel(type: .addCheck)
        } else if string == "" { // TextField
          return ElementModel(type: .field)
        } else { //if string.first?.isASCII != nil && string.first!.isASCII {
          return ElementModel(type: .field, text: String(string))
        }
      }()
      return model
    }
  }
  
  private func checkModel(_ string: String) -> ElementModel {
    // Validate the element is correct
    // Need to allow slightly ivalid strings, as we can have unlabeled checkboxes
    if string.count == 5 && (string == "- [ ]" || string == "- [x]") {
      let done = Array(string)[2] == "x"
      return ElementModel(type: .check, text: "", done: done)
    }
    
    if string.count < 6 {
      return empty(string)
    }
    
    let check = string[..<String.Index(utf16Offset: 6, in: string)]
    guard check == "- [ ] " || check == "- [x] " else {
      return empty(string)
    }
    
    let text = string.count > 6 ? String(string.dropFirst(6)) : ""
    let done = Array(string)[2] == "x"
    return ElementModel(type: .check, text: text, done: done)
  }
  
  /*
    Parse []() markdown links
    Only dates in the future are supported.
    Dates must written as HH:MM. The complete date is formed by adding
    the time component to the date the model entry represents
  */
  private func linkModel(_ string: String) -> ElementModel {
    // I'm sure this will never blow up
    let labelTime = string.dropFirst().split(separator: "]")
    let label = String(labelTime.first ?? "")

    let time = String((labelTime[1].split(separator: "(").first?.split(separator: ")"))?.first ?? "")
    let remaining = labelTime[1].split(separator: ")")
    var text = ""
    if remaining.count > 1 {
      text = String(remaining.last ?? "")
    }
    
    if let baseDate = self.date,
       let date = DateUtil.timeToDate(baseDate: baseDate, time: time) {
      return ElementModel(type: .notification, text: text, label: label, date: date)
    }
    return ElementModel(type: .heading) // TODO: Handle no date
  }
  
  /*
   Collate multiple consecutive TextFields into a single TextArea
   */
  private func secondPass(elements: [ElementModel]) -> [ElementModel] {
    var result: [ElementModel] = []
    // Merge adjacent elements of specific types
    for i in 0..<elements.count {
      let element = elements[i]
      if element.type == .field {
        if result.last?.type == .field || result.last?.type == .editor {
          let text = result.last!.text
          result = result.dropLast()
          let seperator = (i == elements.count - 1) ? "" : "\n"
          result.append(ElementModel(type: .editor, text: text + seperator + element.text))
        } else {
          result.append(element)
        }
      } else {
        result.append(element)
      }
    }
    
    return result
  }
  
  private func empty(_ string: String) -> ElementModel {
    return ElementModel(type: .empty, text: string)
  }
}
