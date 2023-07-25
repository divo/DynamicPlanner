//
//  CheckToggleStyle.swift
//  Daily Planner
//
//  Created by Steven Diviney on 07/07/2023.
//

import SwiftUI

struct CheckToggleStyle: ToggleStyle {
  let onSystemImage: String
  let offSystemImage: String

  init(onSystemImage: String = "checkmark.circle.fill", offSystemImage: String = "circle") {
    self.onSystemImage = onSystemImage
    self.offSystemImage = offSystemImage
  }
  
  
  func makeBody(configuration: Configuration) -> some View {
    Button {
      configuration.isOn.toggle()
    } label: {
      Label {
        configuration.label
      } icon: {
        Image(systemName: configuration.isOn ? onSystemImage : offSystemImage)
          .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
          .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
          .imageScale(.large)
      }
    }
    .buttonStyle(.plain)
  }
}
