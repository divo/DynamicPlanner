//
//  MetadataProvider.swift
//  Markdown Planner
//
//  Created by Steven Diviney on 24/08/2023.
//

// After implementing (copying) all of this I realised I can just list the files and
// call `startDownloadingUbiquitousItem` for anything with an iCloud extension
// I'm going to keep the MetadataProvider solution though because 1) Files are pushed
// to the UI using notifications, no need to pull to refresh and 2) If I want to add more
// advanced iCould features later this seems like the better place to start from

import Foundation
import Combine

extension Notification.Name {
  static let mdMetadataDidChange = Notification.Name("mdMetadataDidChange")
}

class MetadataProvider {
  enum MetadataDidChangeUserInfoKey: String {
    case queryResults
  }
  typealias MetadataDidChangeUserInfo = [MetadataDidChangeUserInfoKey: [MetadataItem]]
  
  private(set) var containerRootURL: URL?
  private let metadataQuery = NSMetadataQuery()
  private var querySubscriber: AnyCancellable?
  
  // Fails if not logged into iCloud
  // Expects the iCloud file location URL to be passed to it. FileUtil is responsible for that already
  init?(containerIdentifier: String?, url: URL) {
    guard FileManager.default.ubiquityIdentityToken != nil else {
      print("iCloud not enabled")
      return nil
    }
    
    self.containerRootURL = url
    
    let names: [NSNotification.Name] = [.NSMetadataQueryDidFinishGathering, .NSMetadataQueryDidUpdate]
    let publishers = names.map { NotificationCenter.default.publisher(for: $0) }
    querySubscriber = Publishers.MergeMany(publishers).receive(on: DispatchQueue.main).sink { notification in
      guard notification.object as? NSMetadataQuery === self.metadataQuery else { return }
      var userInfo = MetadataDidChangeUserInfo()
      userInfo[.queryResults] = self.metadataItemList()
      NotificationCenter.default.post(name: .mdMetadataDidChange, object: self, userInfo: userInfo)
    }
    
    metadataQuery.notificationBatchingInterval = 1
    metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope] //NSMetadataQueryUbiquitousDataScope, ]
    metadataQuery.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, "*.md")
    metadataQuery.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemFSNameKey, ascending: true)]
    metadataQuery.start()
  }
  
  deinit {
    guard metadataQuery.isStarted else { return }
    metadataQuery.stop()
  }
}

// MARK: Providing metadata items
//
extension MetadataProvider {
  
  func metadataItemList() -> [MetadataItem] {
    var result = [MetadataItem]()
    metadataQuery.disableUpdates()
    if let metadataItems = metadataQuery.results as? [NSMetadataItem] {
      result = metadataItemList(from: metadataItems)
    }
    metadataQuery.enableUpdates()
    return result
  }
  
  // Convert from Objc to Swift
  // Filter out items that don't have a valid URL
  private func metadataItemList(from nsMetadataItems: [NSMetadataItem]) -> [MetadataItem] {
    let validItems = nsMetadataItems.filter { item in
      guard let fileURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL,
            item.value(forAttribute: NSMetadataItemFSNameKey) != nil else { return false }
      
      //TODO: Going to allow directories, do I need to explictily check for packages?
      return true
    }
    
    // Valid items have a valid URL and file system name so unwrap all the optionals
    return validItems.sorted {
      let name0 = $0.value(forAttribute: NSMetadataItemFSNameKey) as? String
      let name1 = $1.value(forAttribute: NSMetadataItemFSNameKey) as? String
      return name0! < name1!
    }.map {
      let itemURL = $0.value(forAttribute: NSMetadataItemURLKey) as? URL
      return MetadataItem(nsMetadataItem: $0, url: itemURL!)
    }
  }
}
