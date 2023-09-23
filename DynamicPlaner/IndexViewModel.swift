//
//  IndexViewModel.swift
//  Markdown Planner
//
//  Created by Steven Diviney on 21/09/2023.
//

import Foundation

class IndexViewModel: ObservableObject {
  @Published var files: [FileItem] = []
  private var urls: [URL] {
    FileUtil.listDocuments().sorted(by: { l, r in
      l.lastPathComponent > r.lastPathComponent
    })
  }
  
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
    
    let newFiles = metadataItems.map({ $0.url })
    
    let filesToFetch = urls.difference(from: newFiles).filter { fileURL in
      DateUtil.filenameToDate(fileURL.lastPathComponent) != nil
    }
    
    filesToFetch.forEach { fileURL in
      // We may not have the file in time for the user to open but worry about solving that later
      try? FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
    }
    
    // This is a little bit hacky, we are downloading the files so can't just
    // list the disk contents. Instead we append the downloading files
    // to the list and sort them. Trust the file is downloaded by the time the user
    // tries to open it
    // TODO: Add a check for file downloaded when opening
    var allUrls = urls
    allUrls.append(contentsOf: filesToFetch)
    self.files = sortFiles(allUrls)
  }
  
  private func getFiles() -> [FileItem] {
    return sortFiles(urls)
  }
  
  // Group the files by month, current month should be top level, all other months are nested
  private func sortFiles(_ files: [URL]) -> [FileItem] {
    let fileItems = urls.map({ url in
      FileItem(url: url)
    })
    
    //Pick out the months
    let groups = Dictionary(grouping: fileItems) { item in
      let components = Calendar.current.dateComponents([.month, .year], from: item.date)
      return "\(components.year!)-\(String(format: "%02d", components.month!))"
    }
    
    // Little bit messy
    let sortedKeys = groups.keys.sorted().reversed()
    guard let first = sortedKeys.first else { return [] }
    var result = groups[first]!
    
    for (key) in sortedKeys.dropFirst() {
      var month = FileItem(name: key)
      month.children = groups[key]
      result.append(month)
    }
    
    return result
  }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
