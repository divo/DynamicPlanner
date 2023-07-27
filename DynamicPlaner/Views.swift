//
//  Views.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 25/07/2023.
//

import SwiftUI

struct TextView: View {
  var text: String
  var weight: Int = 5
  
  var body: some View {
    Text(text)
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

struct TextFieldView: View {
  @Binding var text: String
  
  var body: some View {
    TextField("", text: $text)
  }
}

struct CheckBoxView: View  {
  @Binding var text: String
  @Binding var done: Bool
  
  var body: some View {
    HStack {
      Toggle("", isOn: $done)
      TextField("", text: $text)
    }
  }
}
