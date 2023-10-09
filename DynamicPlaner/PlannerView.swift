//
//  PlannerView.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 17/07/2023.
//

import SwiftUI

struct PlannerView : View {
  let file: URL?
  var initialState: String = "" //TODO: Wire this up so I can live-preview the template
  @StateObject var vm: ViewModel = ViewModel()
  @FocusState var focusedField: Int?
  
  init(file: URL) {
    self.file = file
  }
  
  init(state: String) {
    self.file = nil
    self.initialState = state
  }
  
  @ViewBuilder func render(vm: Binding<ElementModel>, focusID: Int?, index: Int) -> some View {
    switch vm.wrappedValue.type {
    case .heading:
      TextView(text: vm.wrappedValue.text, weight: vm.wrappedValue.weight)
    case .field:
      TextFieldView(text: vm.text, focusedField: _focusedField, focusID: focusID!)
    case .check:
      CheckBoxView(text: vm.text, done: vm.done, focusedField: _focusedField, focusID: focusID!)
    case .editor:
      EditorView(text: vm.text, focusedField: _focusedField, focusID: focusID!)
    case .link:
      NotificationView(label: vm.label.wrappedValue, text: vm.text, notification: vm.done, focusID: focusID!)
    case .addCheck:
      AddCheckView(addElementCallback: {
        self.vm.addCheck(before: vm.wrappedValue)
      })
    case .empty:
      EmptyView(text: vm.text.wrappedValue)
    }
  }

  var body: some View {
    VStack {
      List {
        ForEach(0..<$vm.models.count, id: \.self) { idx in
          render(vm: $vm.models[idx], focusID: vm.focusIDs[idx], index: idx)
        }
      }
      
    }.onAppear {
      if let file = self.file {
        if initialState == "" {
          vm.file = file
          guard let contents = FileUtil.readFile(file) else {
            // TODO: Show an error toast or pop back
            return
          }
          vm.update(state: contents)
        }
      }
    }
  }
}

struct PlannerView_Preview: PreviewProvider {
  static var previews: some View {
    PlannerView(state: "# Test\n\n")
  }
}
