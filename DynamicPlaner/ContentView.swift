//
//  ContentView.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 17/07/2023.
//

import SwiftUI

protocol MDElement: View, Identifiable {
  var id: Int { get }
  func toString() -> String
}

struct TextElement: MDElement {
  var id: Int
  let data: String
  var weight: Int = 1
  
  var body: some View {
    Text(data)
      .fontWeight(fontWeight)
  }
  
  func toString() -> String {
    "# \(data)"
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

struct TextFieldElement: MDElement {
  var id: Int
  @State var data: String = ""
  
  var body: some View {
    TextField("", text: $data)
  }
  
  func toString() -> String {
    " \(data)"
  }
}

// This thing needs to have @Published arrays I can use to bind to view elements
class ViewModel {
  @Published var text: String
  
  init(text: String = "View Model") {
    self.text = text
  }
}

struct TextView2: View {
  @Binding var state: String
  
  var body: some View {
    TextField("", text: $state)
  }
}

struct ContentView : View {
  @State var stateString = "# This is some text\n \n# And some more text"
  @State var vm: [ViewModel] = [ViewModel()]
  
  @ViewBuilder func render(vm: Binding<ViewModel>) -> some View {
    TextView2(state: vm.text)
  }
  
  // 2
  var body: some View {
    VStack {
      TextEditor(text: $stateString)
      
      Button("Serialize") {
        print(vm.map({ vm in
          vm.text
        }))
      }
      
      
      List {
        ForEach(0..<$vm.count, id: \.self) { element in
          render(vm: $vm[element])
        }
      }
      
    }.onAppear {
      stateString.split(separator: "\n").map { string  in
        let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
        if string.first == "#" {
          //          elements.append(TextElement(id: 1, data: String(string.drop(while: { c in c == "#" })), weight: tokens.first?.count ?? 1))
        } else if(string.first == " ") {
          vm.append(ViewModel(text: "Appended"))
        }
      }
    }
  }
}

