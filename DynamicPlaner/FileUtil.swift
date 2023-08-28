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

  static func checkFileExists(_ filename: String) -> Bool {
    let url = self.getDocumentsDirectory().appendingPathComponent(filename)
    return FileManager.default.fileExists(atPath: url.path)
  }

  // TODO: Handle read/write failures
  static func readFile(_ url : URL) -> String {
    try! String(contentsOf: url, encoding: .utf8)
  }
  
  static func writeFile(url: URL, viewModel: ViewModel) {
    try! viewModel.encode().write(to: url, atomically: true, encoding: .utf8)
  }
  
  static func createFile(_ filename: String) {
    let url = self.getDocumentsDirectory().appendingPathComponent(filename)
    FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    let emptyTemplate = ViewModel(state: UserDefaults().string(forKey: Constants.templateKey)!, file: url).encode()
    try! emptyTemplate.write(to: url, atomically: true, encoding: .utf8)
  }
  
  static func deleteFile(_ filename: String) {
    let url = self.getDocumentsDirectory().appendingPathComponent(filename)
    try! FileManager.default.removeItem(at: url)
  }
}

extension URL: Identifiable {
  public var id: URL { self }
}

