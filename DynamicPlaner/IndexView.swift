//
//  IndexView.swift
//  Daily Planner
//
//  Created by Steven Diviney on 04/07/2023.
//

import SwiftUI
import UserNotifications
import AlertToast

struct IndexView: View {
  @State var files = FileUtil.listDocuments()
  @State var showDetails = true
  @State var showingPopover = false
  @State var showConfig = false
  @State var selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
  @State private var showToast = false
  
  init() {
    let navBarAppearance = UINavigationBar.appearance()
    navBarAppearance.largeTitleTextAttributes = [.foregroundColor: Style.primaryUIColor]
    navBarAppearance.titleTextAttributes = [.foregroundColor: Style.primaryUIColor]
  }
  
  var body: some View {
    NavigationView {
      List(files.sorted(by: { l, r in
        l.lastPathComponent > r.lastPathComponent
      })) { file in
        NavigationLink {
          PlannerView(file: file)
        } label: {
          Text(file.lastPathComponent)
        }
      }.navigationTitle("Day Planner")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Image(systemName: "doc.badge.plus")
              .foregroundColor(.accentColor)
              .onTapGesture {
                createEntry()
              }
              .onLongPressGesture(minimumDuration: 0.1) {
                showingPopover = true
              }
          }
          ToolbarItem(placement: .navigationBarLeading) {
              Button {
                showConfig = true
              } label: {
                Image(systemName: "gear")
              }
            }
        }.popover(isPresented: $showingPopover) {
          List {
            VStack {
              DatePicker(selection: $selectedDate, in: Date.now..., displayedComponents: .date) {
                Text("Select a date for new entry")
              }
              Button("Done") {
                showingPopover = false
                createEntry(date: self.selectedDate)
              }
            }
          }.frame(width: 400, height: 200)
        }
        .popover(isPresented: $showConfig) {
          ConfigView().frame(idealWidth: 400, idealHeight: 600)
        }
    }
    .accentColor(Style.primaryColor)
    .onAppear {
      NotificationUtil.requestPermission()
      // iCloud failed, using local storage
      guard FileUtil.getDocumentsDirectory().absoluteString.contains("iCloud~DailyPlanner") else {
        showToast = true
        return
      }
      
      files = FileUtil.listDocuments()
    }.toast(isPresenting: $showToast){
      AlertToast(displayMode: .alert, type: .error(.orange), title: "iCloud not found, storing files localy")
    }
  }
  
  func createEntry(date: Date = Date.now) {
    let filename = FileUtil.dateToFilename(date)
    if !FileUtil.checkFileExists(filename) {
      FileUtil.createFile(filename)
      files = FileUtil.listDocuments()
    }
  }
}

struct IndexView_Preview: PreviewProvider {
  static var previews: some View {
    IndexView()
  }
}

