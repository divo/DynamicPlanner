//
//  IndexViewModel.swift
//  Markdown Planner
//
//  Created by Steven Diviney on 21/09/2023.
//

import Foundation

class IndexViewModel: ObservableObject {
  @Published var files: [URL] = FileUtil.listDocuments()
  private(set) var metadataProvider: MetadataProvider?
  
  func setupMetadataProvider() {
    metadataProvider = MetadataProvider(containerIdentifier: "Markdown Planner", url: FileUtil.baseURL)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.metadataDidChange(_:)), name: .mdMetadataDidChange, object: nil)
  }
  
  @objc
  func metadataDidChange(_ notification: Notification) {
    guard notification.object is MetadataProvider,
          let userInfo = notification.userInfo as? MetadataProvider.MetadataDidChangeUserInfo,
          let metadataItems = userInfo[.queryResults] else { return }
    
    let newFiles = metadataItems.map({ $0.url })
    
    let filesToFetch = files.difference(from: newFiles).filter { url in
      DateUtil.filenameToDate(url.lastPathComponent) != nil
    }
    
    filesToFetch.forEach { url in
      // We may not have the file in time for the user to open but worry about solving that later
      try? FileManager.default.startDownloadingUbiquitousItem(at: url)
    }
    
    self.files.append(contentsOf: filesToFetch)
  }
  
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
