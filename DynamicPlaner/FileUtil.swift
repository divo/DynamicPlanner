//
//  FileUtil.swift
//  Daily Planner
//
//  Created by Steven Diviney on 04/07/2023.
//

import Foundation

struct FileUtil {
  static var default_journal = "day_planner"
  static var baseURL: URL = driveURL()
  
  static func setDriveURL() {
    DispatchQueue.global().async {
      baseURL = driveURL()
      var isdirectory : ObjCBool = true
      let exists = FileManager.default.fileExists(atPath: baseURL.absoluteString, isDirectory: &isdirectory)
      if !isdirectory.boolValue || !exists {
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: baseURL.appending(path: default_journal), withIntermediateDirectories: true)
      }
      migrateFiles(to: default_journal)
    }
  }
  
  static func migrateFiles(to: String) {
    // List all the files in the top level directory
    do {
      let urls = try FileManager.default.contentsOfDirectory(at: self.getDocumentsDirectory(), includingPropertiesForKeys: [URLResourceKey.isRegularFileKey])
        .filter({ url in
          !url.hasDirectoryPath
        })
      
      try urls.forEach { url in
        guard url.lastPathComponent.caseInsensitiveCompare(".DS_Store") != .orderedSame &&
          url.lastPathComponent.contains("icloud") != true else { return }
        let contents = readFile(url)!
        let filename = url.lastPathComponent.addExtension()
        let newUrl = self.getDocumentsDirectory().appending(path: to).appending(path: filename)
        try contents.write(to: newUrl, atomically: true, encoding: .utf8)
        deleteFile(url)
      }
    } catch {
      print("Failed to run migration")
    }
  }
  
  static func driveURL() -> URL {
    guard let iCloudURL = (FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")) else {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
    }
    return iCloudURL
  }
  
  static func getDocumentsDirectory() -> URL {
    return baseURL
  }
 
  static func listDocuments(directory: String = default_journal) -> [URL] {
    // Let it crash and hope I get a report.
    try! FileManager.default.contentsOfDirectory(at: self.getDocumentsDirectory().appending(path: directory), includingPropertiesForKeys: nil)
      .filter({ url in
        url.lastPathComponent.first != "."
      })
  }
  
  static func url(for filename: String, directory: String = default_journal) -> URL {
    return self.getDocumentsDirectory().appending(path: directory).appendingPathComponent(filename)
  }

  static func checkFileExists(_ url: URL) -> Bool {
//    let url = self.getDocumentsDirectory().appending(path: directory).appendingPathComponent(filename)
    return FileManager.default.fileExists(atPath: url.path)
  }

  // TODO: Handle read/write failures
  static func readFile(_ url : URL) -> String? {
    try? String(contentsOf: url, encoding: .utf8)
  }
  
  static func writeFile(url: URL, viewModel: PlannerViewModel) {
    try! viewModel.encode().write(to: url, atomically: true, encoding: .utf8)
  }

  static func writeFile(url: URL, content: String) {
    try! content.write(to: url, atomically: true, encoding: .utf8)
  }
 
  static func createFile(url: URL, template: String) {
    FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    // Why encode the viewModel instead of just writing the string directly....
    // The _should_ be the same
    let emptyTemplate = PlannerViewModel(state: template, file: url).encode()
    try! emptyTemplate.write(to: url, atomically: true, encoding: .utf8)
  }
  
  static func deleteFile(_ url: URL) {
    try! FileManager.default.removeItem(at: url)
  }
}

extension URL: Identifiable {
  public var id: URL { self }
}

