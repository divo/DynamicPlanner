import SwiftUI

struct LegendItem: View {
  let name: String
  let text: String
  
  var body: some View {
    HStack {
      Text(text)
      Spacer()
      Text(name)
    }
  }
}

struct ConfigView: View {
  @ObservedObject var viewModel: ConfigViewModel
  @State var dayStart = UserDefaults().object(forKey: "dayStart") as? Date ?? Date.now
  @State var planningTime = UserDefaults().object(forKey: "planningTime") as? Date ?? Date.now
  @State var startNotification = false
  @State var planningNotification = false

  var body: some View {
    List {
      HStack {
        Toggle("", isOn: $startNotification)
          .toggleStyle(CheckToggleStyle(onSystemImage: "clock.badge", offSystemImage: "clock"))
          .frame(width: 16)
        DatePicker("Day start", selection: $dayStart, displayedComponents: [.hourAndMinute])
          .datePickerStyle(CompactDatePickerStyle())
      }.onAppear {
        setTime(7, for: "dayStart", date: $dayStart)
      }.padding(10)
        .onChange(of: startNotification) { value in
          if value {
            NotificationUtil.scheduleRepeatingNotification(id: "dayStart", message: "Time to get to work!", date: dayStart)
          } else {
            NotificationUtil.removeNotification(id: "dayStart")
          }
        }.onChange(of: dayStart) { newValue in
          startNotification = false
        }
      
      HStack {
        Toggle("", isOn: $planningNotification)
          .toggleStyle(CheckToggleStyle(onSystemImage: "clock.badge", offSystemImage: "clock"))
          .frame(width: 16)
        DatePicker("Planning", selection: $planningTime, displayedComponents: [.hourAndMinute])
          .datePickerStyle(CompactDatePickerStyle())
      }.onAppear {
        setTime(21, for: "planningTime", date: $planningTime)
      }.padding(10)
        .onChange(of: planningNotification) { value in
          if value {
            NotificationUtil.scheduleRepeatingNotification(id: "planningTime", message: "Time to plan!", date: planningTime)
          } else {
            NotificationUtil.removeNotification(id: "planningTime")
          }
        }.onChange(of: planningTime) { newValue in
          planningNotification = false
        }
      
      VStack {
        VStack {
          Text("Legend")
          LegendItem(name: "Heading", text: "#")
          LegendItem(name: "Checkbox", text: "- [ ] ")
          LegendItem(name: "Text field", text: "\\n")
          LegendItem(name: "Multi line text field", text: "\\n\\n")
          LegendItem(name: "Reminder", text: "[label](time)")
          LegendItem(name: "Create empty checkbox", text: "+")
        }.background(Color(uiColor: UIColor.systemGray6))
            

        TextView(text: "Template:").padding([.top], 10)
        ScrollView {
          ZStackLayout(alignment: .topLeading) {
            Text(viewModel.planningTemplate) // This is the hack to get the TextEditor to grow AND shrink as text is added .
              .padding()
              .opacity(1)
            TextEditor(text: $viewModel.planningTemplate)
              .frame(alignment: .leading)
              .multilineTextAlignment(.leading)
              .scrollDisabled(true)
          }
        }
      }.padding(10)
        .onChange(of: viewModel.planningTemplate) { newValue in
          viewModel.writeTemplate()
        }
    }.onAppear {
      DispatchQueue.main.async {
        NotificationUtil.checkScheduled(id: "planningTime") { res in self.planningNotification = res }
        NotificationUtil.checkScheduled(id: "dayStart") { res in self.startNotification = res }
      }
    }
  }
  
  func setTime(_ time: Int, for key: String, date: Binding<Date>) {
    let calendar = Calendar.current
    if UserDefaults().object(forKey: key) == nil {
      let defaultDate = calendar.date(bySettingHour: time, minute: 0, second: 0, of: Date()) ?? Date()
      date.wrappedValue = defaultDate
    }
  }
}

