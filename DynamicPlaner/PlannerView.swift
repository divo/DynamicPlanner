//
//  PlannerView.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 17/07/2023.
//

import SwiftUI

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
    state.components(separatedBy: .newlines).map { string in
      let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
      if(string.first == "-") {
        let text = string.count > 4 ? String(string.dropFirst(5)) : ""
        let done = Array(string)[2] == "x"
        result.append(CheckBoxModel(text: text, done: done))
      } else if string.first == "#" {
        let text = String(string.drop(while: { c in c == "#" }).drop(while: { c in c == " " }))
        result.append(TextViewModel(text: text, weight: tokens.first?.count ?? 1))
      } else if string == ""{
        result.append(TextFieldModel())
      } else if string.first?.isASCII != nil && string.first!.isASCII {
        result.append(TextFieldModel(text: String(string)))
      }
    }
    return result
  }
}

struct PlannerView : View {
  @State var stateString: String
  @StateObject var vm: ViewModel = ViewModel()
  
  init(file: URL) {
    self.stateString = FileUtil.readFile(file)
  }
  
  init(state: String) {
    self.stateString = state
  }
  
  @ViewBuilder func render(vm: BaseModel) -> some View {
    switch vm {
    case let textVm as TextViewModel:
      TextView(text: textVm.text, weight: textVm.weight)
    case var fieldVm as TextFieldModel:
      let bd = Binding<TextFieldModel>(get: { fieldVm }, set: { fieldVm = $0 })
      TextFieldView(text: bd.text)
    case var checkVm as CheckBoxModel:
      let bd = Binding<CheckBoxModel>(get: { checkVm }, set: { checkVm = $0 })
      CheckBoxView(text: bd.text, done: bd.done)
    default:
      Spacer()
    }
  }
  
  var body: some View {
    VStack {
      Button("Serialize") {
        print(vm.encode())
      }
      
      List {
        ForEach(0..<$vm.models.count, id: \.self) { element in
          render(vm: vm.models[element])
        }
      }
      
    }.onAppear {
      vm.update(state: stateString)
    }
  }
}
