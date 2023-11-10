//
//  FileItem.swift
//  Markdown Planner
//
//  Created by Steven Diviney on 22/09/2023.
//

import Foundation

struct FileItem: Hashable, Identifiable, CustomStringConvertible {
  var id: Self { self }
  var name: String
  var url: URL?
  var children: [FileItem]? = nil
  var isLeaf: Bool = true
  
  var description: String {
    // Each month after the current should have children, the month itself is no interactable
    guard isLeaf else { return name }
    
    switch children {
    case nil:
      return name
    case .some(let children):
      return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
    }
  }
  
  var date: Date {
    DateUtil.filenameToDate(name.dropExtension())!
  }
  
  init(url: URL) {
    self.name = url.lastPathComponent.dropExtension()
    self.url = url
  }
  
  init(name: String) {
    self.name = name
    self.isLeaf = false
  }
}
