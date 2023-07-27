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
  
  init(file: URL) {
    self.file = file
  }
  
  init(state: String) {
    self.file = nil
    self.initialState = state
  }
  
  @ViewBuilder func render(vm: Binding<BaseModel>) -> some View {
    switch vm.wrappedValue.type {
    case .text:
      TextView(text: vm.wrappedValue.text, weight: vm.wrappedValue.weight)
    case .field:
      TextFieldView(text: vm.text)
    case .check:
      CheckBoxView(text: vm.text, done: vm.done)
    }
  }
  
  var body: some View {
    VStack {
      List {
        ForEach(0..<$vm.models.count, id: \.self) { element in
          render(vm: $vm.models[element])
        }
      }
      
    }.onAppear {
      if let file = self.file {
        if initialState == "" {
          vm.file = file
          vm.update(state: FileUtil.readFile(file))
        }
      }
    }
  }
}
