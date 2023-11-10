//
//  RawFileEditorView.swift
//  Markdown Planner
//
//  Created by Steven Diviney on 10/11/2023.
//

import SwiftUI

struct RawFileEditorView: View {
  let file: URL
  @State var text: String
  
  init(file: URL) {
    self.file = file
    _text = State(wrappedValue: FileUtil.readFile(file)!)
  }
  
  var body: some View {
    VStack {
      TextEditor(text: $text)
        .frame(alignment: .leading)
        .multilineTextAlignment(.leading)
    }.navigationTitle("Editing: " + (file.lastPathComponent.toDate()?.toFilename().dropExtension() ?? ""))
    .padding(10)
      .onChange(of: text) { newValue in
        FileUtil.writeFile(url: file, content: text)
      }
  }
}
