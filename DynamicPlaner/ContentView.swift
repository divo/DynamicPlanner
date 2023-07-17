//
//  ContentView.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 17/07/2023.
//

import SwiftUI

struct Element: Identifiable {
  let id = UUID()
  let data: String
  let type: String
  
  func buildView() -> AnyView {
    switch type {
    case "Button": return AnyView( Button(data, action: {
      print("Press")
    }))
    case "Text": return AnyView( Text(data) )
    default: return AnyView(EmptyView())
    }
  }
}

struct ContentView : View {
  @State var elements = [
    Element(data: "John", type: "Text"),
    Element(data: "Alice", type: "Button"),
    Element(data: "Bob", type: "Text")
  ]
  
  // 2
  var body: some View {
    List {
      ForEach(0..<$elements.count, id: \.self) { index in
        elements[index].buildView()
      }
    }
    
    HStack {
      Button {
        elements.append(Element(data: "Hi", type: "Text"))
      } label: {
        Text("Append text")
      }
      
      Button {
        elements.append(Element(data: "Test", type: "Button"))
      } label: {
        Text("Append button")
      }

      
    }
    
  }
  
}

