//
//  ContentView.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 17/07/2023.
//

import SwiftUI

protocol MDElement: View, Identifiable {
  var id: Int { get }
}

struct TextElement: MDElement {
  var id: Int
  let data: String
  var weight: Int = 1

  var body: some View {
    Text(data)
      .fontWeight(fontWeight)
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
}

struct ContentView : View {
  @State var stateString = "# This is some text\n \n# And some more text"
  @State var elements = [
    TextElement(id: 1, data: "Test")
  ]
  
  // 2
  var body: some View {
    TextEditor(text: $stateString)
    
    List {
      ForEach(stateString.split(separator: "\n"), id: \.self) { string in
        let tokens = String(string).split(separator: " ") // Has to be better way than this nonsense
        if string.first == "#" {
          TextElement(id: 1, data: String(string.drop(while: { c in c == "#" })), weight: tokens.first?.count ?? 1)
        } else if(string.first == " ") {
          TextFieldElement(id: 2)
        }
      }
    }
  }
}

