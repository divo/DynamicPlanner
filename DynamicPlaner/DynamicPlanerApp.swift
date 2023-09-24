//
//  DynamicPlanerApp.swift
//  DynamicPlaner
//
//  Created by Steven Diviney on 17/07/2023.
//

import SwiftUI

@main
struct DynamicPlanerApp: App {
  init() {
   FileUtil.setDriveURL()
  }
  
  var body: some Scene {
    WindowGroup {
      IndexView()
    }
  }
}
