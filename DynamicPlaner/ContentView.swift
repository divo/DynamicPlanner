//
//  ContentView.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 17/07/2023.
//

import SwiftUI

class ViewModel: ObservableObject {
  @Published var models: [BaseModel] = []
}

struct ContentView : View {
  @State var stateString = "# This is some text\n\n# And some more text\n-[ ] Checkbox"
  @StateObject var vm = ViewModel()
  
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
      TextEditor(text: $stateString)
      
      Button("Serialize") {
        print(vm.models.map({ vm in
          vm.toString()
        }))
      }
      
      List {
        ForEach(0..<$vm.models.count, id: \.self) { element in
          render(vm: vm.models[element])
        }
      }
      
    }.onAppear {
      vm.models = deserialize(state: stateString)
    }
    .onChange(of: stateString, perform: { newValue in
      vm.models = deserialize(state: stateString)
    })
  }
  
  func deserialize(state: String) -> [BaseModel] {
    var result: [BaseModel] = []
    state.components(separatedBy: .newlines).map { string in
      let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
      if(string == "") {
        result.append(TextFieldModel())
      } else if(string.first == "-" && string.count > 4) {
        let text = String(string.dropFirst(5))
        let done = Array(string)[2] == "x"
        result.append(CheckBoxModel(text: text, done: done))
      } else if string.first == "#" {
        let text = String(string.drop(while: { c in c == "#" }).drop(while: { c in c == " " }))
        result.append(TextViewModel(text: text, weight: tokens.first?.count ?? 1))
      } else if string.first?.isASCII != nil && string.first!.isASCII {
        result.append(TextViewModel(text: String(string)))
      }
    }
    
    return result
  }
}
