//
//  ViewUtil.swift
//  Daily Planner
//
//  Created by Steven Diviney on 04/07/2023.
//

import SwiftUI

struct ViewUtil {
  static func dividerLine() -> some View {
    Divider()
      .frame(height: 1)
      .padding(.horizontal, 30)
      .background(Color.primary)
  }
  
  static func textLabel(_ text: String) -> some View {
    Text(text)
      .font(.title2)
      .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
  }
  
  static func titleLabel(_ text: String) -> some View {
   Text(text)
      .font(.title)
      .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
  }
  
  static func smallLabel(_ text: String) -> some View {
    Text(text)
      .font(.subheadline)
      .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
  }
  
  static func divider() -> some View {
    Rectangle()
      .frame(height: 1)
      .foregroundColor(.primary.opacity(0.2))
  }
}
