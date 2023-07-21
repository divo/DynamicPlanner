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
class ViewModel {
  @Published var text: String
  @Published var done: Bool
  let weight: Int
  let type: ViewType //TODO: Push this information into subclasses(?)
  
  enum ViewType {
    case text
    case textField
    case checkBox
  }
  
  init(text: String = "View Model", type: ViewType, weight: Int = 1, done: Bool = false) {
    self.text = text
    self.type = type
    self.weight = weight
    self.done = done
  }
  
  func toString() -> String {
    text
  }
}

struct TextView: View {
  @Binding var state: String
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

struct ContentView : View {
  @State var stateString = "# This is some text\n \n# And some more text"
  @State var vm: [ViewModel] = []
  
  @ViewBuilder func render(vm: Binding<ViewModel>) -> some View {
    switch vm.wrappedValue.type {
    case .text:
      TextView(state: vm.text, weight: vm.wrappedValue.weight)
    case .textField:
      TextFieldView(state: vm.text)
    case .checkBox:
      CheckBoxView(text: vm.text, done: vm.done)
    }
  }
  
  // 2
  var body: some View {
    VStack {
      TextEditor(text: $stateString)
      
      Button("Serialize") {
        print(vm.map({ vm in
          vm.toString()
        }))
      }
      
      List {
        ForEach(0..<$vm.count, id: \.self) { element in
          render(vm: $vm[element])
        }
      }
      
    }.onAppear {
      vm = deserialize(state: stateString)
    }
    .onChange(of: stateString, perform: { newValue in
      vm = deserialize(state: stateString)
    })
  }
  
  func deserialize(state: String) -> [ViewModel] {
    var result: [ViewModel] = []
    state.split(separator: "\n").map { string in
      let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
      if string.first == "#" {
        let text = String(string.drop(while: { c in c == "#" }))
        result.append(ViewModel(text: text, type: .text, weight: tokens.first?.count ?? 1))
      } else if(string.first == " ") {
        result.append(ViewModel(text: "", type: .textField))
      } else if(string.first == "-" && string.count > 4) {
        // -[x]
        let text = String(string.dropFirst(5))
        result.append(ViewModel(text: text, type: .checkBox, done: false))
      }
    }
    
    return result
  }
}

