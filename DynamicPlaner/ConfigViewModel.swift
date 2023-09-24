//
//  ConfigViewModel.swift
//  Markdown Planner
//
//  Created by Steven Diviney on 24/09/2023.
//

import Foundation

class ConfigViewModel: ObservableObject {
  @Published var planningTemplate: String
  private let templateUrl: URL

  init() {
    templateUrl = FileUtil.url(for: FileUtil.default_journal.addExtension(), directory: FileUtil.default_journal)
    if let templateFile = FileUtil.readFile(templateUrl) {
      planningTemplate = templateFile
    } else {
      // Migrate anything left in UserDefaults, then remove it
      planningTemplate = UserDefaults().string(forKey: Constants.templateKey) ?? Constants.defaultTemplate
      writeTemplate()
    }
  }

  func writeTemplate() {
    FileUtil.writeFile(url: templateUrl, content: planningTemplate)
  }
}
