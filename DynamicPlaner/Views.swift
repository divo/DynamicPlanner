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
  @FocusState var focusedField: Int?
  var focusID: Int
  
  var body: some View {
    TextField("", text: $text)
      .focused($focusedField, equals: focusID)
      .onSubmit {
        focusedField = focusID + 1
      }
  }
}

struct CheckBoxView: View  {
  @Binding var text: String
  @Binding var done: Bool
  @FocusState var focusedField: Int?
  var focusID: Int
   
  var body: some View {
    HStack {
      Toggle("", isOn: $done)
        .toggleStyle(CheckToggleStyle())
      TextField("", text: $text)
        .focused($focusedField, equals: focusID)
        .onSubmit {
          focusedField = focusID + 1
        }//.onChange(of: text) { newValue in // This works but there is no tab key on iOS. TODO: Vary this by platform or something
//          if newValue.last == "\t" {
//            self.text = String(newValue.dropLast())
//            focusedField = focusID + 1
//          }
//        }
    }
  }
}

struct NotificationView: View {
  var label: String
  @Binding var text: String
  @Binding var notification: Bool
  @FocusState var focusedField: Int?
  var focusID: Int
  
  var body: some View {
    HStack {
      Toggle("", isOn: $notification)
        .toggleStyle(CheckToggleStyle(onSystemImage: "clock.badge.fill", offSystemImage: "clock"))
      Text(label)
      TextField("", text: $text)
        .focused($focusedField, equals: focusID)
        .onSubmit {
          focusedField = focusID + 1
        }
    }
  }
}

struct EditorView: View {
  @Binding var text: String
  @FocusState var focusedField: Int?
  var focusID: Int
   
  var body: some View {
    VStack {
      ScrollView {
        ZStack(alignment: .topLeading) {
          Text(text) // This is the hack to get the TextEditor to grow AND shrink as text is added .
            .padding()
            .opacity(1)
          TextEditor(text: $text)
            .frame(alignment: .leading)
            .multilineTextAlignment(.leading)
            .scrollDisabled(true)
        }
      }
    }
  }
}

struct AddCheckView: View {
  var addElementCallback: () -> ()
   
  var body: some View {
    Button(action: {
      addElementCallback()
    }, label: {
      Image(systemName: "plus.circle")
    })
  }
}

struct EmptyView: View {
  var text: String
  var body: some View {
    Text("Invalid element: \"\(text)\"")
      .foregroundColor(Style.errorColor)
  }
}
