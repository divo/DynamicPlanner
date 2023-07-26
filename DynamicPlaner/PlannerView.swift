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
  
  @ViewBuilder func render(vm: BaseModel) -> some View {
    switch vm {
    case let textVm as TextViewModel:
      TextView(text: textVm.text, weight: textVm.weight)
    case var fieldVm as TextFieldModel:
      let bd = Binding<TextFieldModel>(get: { fieldVm }, set: { fieldVm = $0 })
      TextFieldView(text: bd.text)
    case var checkVm as CheckBoxModel:
      let bd = Binding<CheckBoxModel>(get: { checkVm }, set: { checkVm = $0 })
      CheckBoxView(text: bd.text, done: bd.done)
    default:
      Spacer()
    }
  }
  
  var body: some View {
    VStack {
      Button("Serialize") {
        print(vm.encode())
        if let file = self.file {
          FileUtil.writeFile(url: file, viewModel: vm)
        }
      }
      
      List {
        ForEach(0..<$vm.models.count, id: \.self) { element in
          render(vm: vm.models[element])
        }
      }
      
    }.onAppear {
      if let file = self.file {
        if initialState == "" {
          vm.update(state: FileUtil.readFile(file))
        }
      }
    }
  }
}
