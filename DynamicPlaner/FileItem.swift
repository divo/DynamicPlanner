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
  var url: URL
  var children: [FileItem]? = nil
  var description: String {
    switch children {
    case nil:
      return " \(name)"
    case .some(let children):
      return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
    }
  }
  
  init(url: URL) {
    self.name = url.lastPathComponent.dropExtension()
    self.url = url
  }
}
