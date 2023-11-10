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
  @StateObject var viewModel = IndexViewModel()
  @StateObject var configViewModel = ConfigViewModel()
  @State var showDetails = true
  @State var showingPopover = false
  @State var selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
  @State private var showToast = false
  
  init() {
    let navBarAppearance = UINavigationBar.appearance()
    navBarAppearance.largeTitleTextAttributes = [.foregroundColor: Style.primaryUIColor]
    navBarAppearance.titleTextAttributes = [.foregroundColor: Style.primaryUIColor]
  }
  
  var body: some View {
    NavigationView {
      List($viewModel.files, children: \.children) { $file in
        if file.isLeaf { // Correct way to do this is two subtypes but types are for nerds. I'm still asking the same question
          NavigationLink {
            PlannerView(file: file.url!)
          } label: {
            Text(file.description)
          }
        } else {
          Text(file.description)
        }
      }
      .navigationTitle("Day Planner")
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
            NavigationLink {
              ConfigView(viewModel: configViewModel)
              //                .frame(idealWidth: 400, idealHeight: 600)
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
    }
    .accentColor(Style.primaryColor)
    .onAppear {
      NotificationUtil.requestPermission()
      // iCloud failed, using local storage
      guard FileUtil.getDocumentsDirectory().absoluteString.contains("iCloud~DailyPlanner") else {
        showToast = true
        return
      }
      
      viewModel.refresh()
      viewModel.setupMetadataProvider()
    }.toast(isPresenting: $showToast){
      AlertToast(displayMode: .alert, type: .error(.orange), title: "iCloud not found, storing files localy")
    }
  }
  
  func createEntry(date: Date = Date.now) {
    let url = FileUtil.url(for: date.toFilename())
    if !FileUtil.checkFileExists(url) {
      FileUtil.createFile(url: url, template: configViewModel.planningTemplate)
      viewModel.refresh()
    }
  }
}

struct IndexView_Preview: PreviewProvider {
  static var previews: some View {
    IndexView()
  }
}

