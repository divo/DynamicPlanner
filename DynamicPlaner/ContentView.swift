//
//  ContentView.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 17/07/2023.
//

import SwiftUI

// This thing needs to have @Published arrays I can use to bind to view elements
// A subclass for each view type and a view builder that knows how to draw them.
// Probably cleaner to have a subclass for each View too, but all that logic
// could live in a big ViewBuilder function too.
// TODO: Abstract or something else? I need an abstract class that defines a text function, and leave
// everything else up to the subclasses. This is all very fucking annoying
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

struct TextView: View {
  var state: String
  var weight: Int = 1
  
  var body: some View {
    Text(state)
      .fontWeight(fontWeight)
  }
  
  func toString() -> String {
    "# \(state)"
  }
  
  var fontWeight: Font.Weight {
    switch self.weight {
    case 1:
      return .heavy
    case 2:
      return .bold
    default:
      return .regular
    }
  }
}

struct TextFieldView: View {
  @Binding var state: String
  
  var body: some View {
    TextField("", text: $state)
  }
}

struct CheckBoxView: View  {
  @Binding var text: String
  @Binding var done: Bool
  
  var body: some View {
    HStack {
      Toggle("", isOn: $done)
      Text(text)
    }
  }
}

class ViewModel: ObservableObject {
  @Published var models: [BaseModel] = []
}

struct ContentView : View {
  @State var stateString = "# This is some text\n \n# And some more text"
  @StateObject var vm = ViewModel()
  //  @StateObject var vm: [ViewModel] = []
  
  @ViewBuilder func render(vm: Binding<BaseModel>) -> some View {
    switch vm {
    case let textVm as TextViewModel:
      TextView(state: textVm.text, weight: textVm.weight)
      //      TextView(state: textVm.$text, weight: textVm.weight)
//    case let textFieldVm as TextFieldModel:
//      TextFieldView(state: textFieldVm.text)
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
          //          render(vm: $vm.models[element])
          if let textVm = vm.models[element] as? TextViewModel {
            TextView(state: textVm.text, weight: textVm.weight)
          } else if vm.models[element] is TextFieldModel {
            var fieldVm = vm.models[element] as! TextFieldModel
            let bd = Binding<TextFieldModel>(get: { fieldVm }, set: { fieldVm = $0 })
            TextFieldView(state: bd.text)
          }
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
    state.split(separator: "\n").map { string in
      let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
      if string.first == "#" {
        let text = String(string.drop(while: { c in c == "#" }))
//        result.append(ViewModel(text: text, type: .text, weight: tokens.first?.count ?? 1))
        result.append(TextViewModel(text: text, weight: tokens.first?.count ?? 1))
      } else if(string.first == " ") {
        result.append(TextFieldModel())
      } else if(string.first == "-" && string.count > 4) {
        // -[x]
        let text = String(string.dropFirst(5))
//        result.append(ViewModel(text: text, type: .checkBox, done: false))
      }
    }
    
    return result
  }
}

