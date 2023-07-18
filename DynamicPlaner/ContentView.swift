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

struct ContentView : View {
  @State var stateString = "# This is some text\n \n# And some more text"
  @State var elements: [AnyView] = [AnyView(Text("Compile time view"))]
  
  // 2
  var body: some View {
    VStack {
      TextEditor(text: $stateString)
      
      Button("Serialize") {
        print(elements.map({ e in (e as? any MDElement)?.toString() }))
      }
      
      
      List {
        ForEach(0..<$elements.count, id: \.self) { element in
          elements[element] // Why can't I have an array of views? What am I missing?
        }
      }
      
    }.onAppear {
      stateString.split(separator: "\n").map { string  in
        let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
        if string.first == "#" {
          elements.append(AnyView(TextElement(id: 1, data: String(string.drop(while: { c in c == "#" })), weight: tokens.first?.count ?? 1)))
        } else if(string.first == " ") {
          elements.append(AnyView(TextFieldElement(id: 2)))
        }
      }
    }
  }
}

