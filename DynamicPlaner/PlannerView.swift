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
  
  @State var bool = false
  
  init(file: URL) {
    self.file = file
  }
  
  init(state: String) {
    self.file = nil
    self.initialState = state
  }
  
  @ViewBuilder func render<T: BaseModel>(vm: T) -> some View {
    switch vm {
    case let textVm as TextViewModel:
      TextView(text: textVm.text, weight: textVm.weight)
    case var fieldVm as TextFieldModel:
      let bd = Binding<TextFieldModel>(get: { fieldVm }, set: { fieldVm = $0 })
      TextFieldView(text: bd.text)
    case var checkVm as CheckBoxModel:
      let bd = Binding<CheckBoxModel>(get: { checkVm }, set: {
        checkVm = $0
      })
//      var bd = createBinding(model: &checkVm)
//      CheckBoxView(text: bd.text, done: bd.done)
      CheckBoxView(model: bd)
    default:
      Spacer()
    }
  }
  
  func createBinding<T: BaseModel>(model: inout T) -> Binding<T> {
//    let bd = Binding<T>(get: { model }, set: { $0 })
    let bd = Binding { [model] in
      model
    } set: { [model] in
      var m = model
      m = $0
    }
    
//    let bd = Binding<TextFieldModel>(get: { model }, set: { model = $0 })
    return bd
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
