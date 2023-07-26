//
//  FileUtil.swift
//  Daily Planner
//
//  Created by Steven Diviney on 04/07/2023.
//

import Foundation

struct FileUtil {
  static var baseURL: URL = driveURL()
  
  static func setDriveURL() {
    DispatchQueue.global().async {
      baseURL = driveURL()
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
 
  static func listDocuments() -> [URL] {
    try! FileManager.default.contentsOfDirectory(at: self.getDocumentsDirectory(), includingPropertiesForKeys: nil)
      .filter({ url in
        url.lastPathComponent.first != "."
      })
  }

  static func checkFileExists(_ filename: String) -> Bool {
    let url = self.getDocumentsDirectory().appendingPathComponent(filename)
    return FileManager.default.fileExists(atPath: url.path)
  }

//  static func readFile(_ url: URL) -> PlannerViewModel {
//    return try! JSONDecoder().decode(PlannerViewModel.self, from: Data(contentsOf: url))
//  }
//  
//  static func update(object: PlannerViewModel, with url: URL) {
//    let storedObj = try! JSONDecoder().decode(PlannerViewModel.self, from: Data(contentsOf: url))
//    object.update(other: storedObj)
//  }
//
//  static func writeFile(_ url: URL, viewModel: PlannerViewModel) {
//    let json = try! JSONEncoder().encode(viewModel)
//    try! json.write(to: url)
//  }
//
//  static func createFile(_ filename: String) {
//    let url = self.getDocumentsDirectory().appendingPathComponent(filename)
//    FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
//    let emptyJson = try! JSONEncoder().encode(PlannerViewModel())
//    try! emptyJson.write(to: url)
//  }
//
  static func readFile(_ url : URL) -> String {
    try! String(contentsOf: url, encoding: .utf8)
  }
  
  static func createFile(_ filename: String) {
    let url = self.getDocumentsDirectory().appendingPathComponent(filename)
    FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
    let emptyTemplate = ViewModel(state: UserDefaults().string(forKey: Constants.templateKey)!).encode()
    try! emptyTemplate.write(to: url, atomically: true, encoding: .utf8)
  }
  
  static func deleteFile(_ filename: String) {
    let url = self.getDocumentsDirectory().appendingPathComponent(filename)
    try! FileManager.default.removeItem(at: url)
  }
  
  static func dateToFilename(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
  }
  
  static func filenameToDate(_ filename: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: filename)!
  }
}

extension URL: Identifiable {
  public var id: URL { self }
}

