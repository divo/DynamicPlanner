//
//  IndexViewModel.swift
//  Markdown Planner
//
//  Created by Steven Diviney on 21/09/2023.
//

import Foundation

class IndexViewModel: ObservableObject {
  @Published var files: [FileItem] = []
  
  private(set) var metadataProvider: MetadataProvider?
  
  init() {
    files = getFiles()
  }
  
  func setupMetadataProvider() {
    metadataProvider = MetadataProvider(containerIdentifier: "Markdown Planner", url: FileUtil.baseURL)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.metadataDidChange(_:)), name: .mdMetadataDidChange, object: nil)
  }
  
  func refresh() {
    files = getFiles()
  }
  
  @objc
  func metadataDidChange(_ notification: Notification) {
    guard notification.object is MetadataProvider,
          let userInfo = notification.userInfo as? MetadataProvider.MetadataDidChangeUserInfo,
          let metadataItems = userInfo[.queryResults] else { return }
    
    let newFiles = metadataItems.map({ FileItem(url: $0.url) })
    
    let filesToFetch = files.difference(from: newFiles).filter { file in
      DateUtil.filenameToDate(file.url.lastPathComponent) != nil
    }
    
    filesToFetch.forEach { file in
      // We may not have the file in time for the user to open but worry about solving that later
      try? FileManager.default.startDownloadingUbiquitousItem(at: file.url)
    }
    
    self.files.append(contentsOf: filesToFetch)
  }
    
  private func getFiles() -> [FileItem] {
    let files = FileUtil.listDocuments().sorted(by: { l, r in
      l.lastPathComponent > r.lastPathComponent
    })
    // Group the files by month, current month should be top level, all other months are nested
    var fileItems = files.map({ url in
      FileItem(url: url)
    })
    return fileItems
  }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
