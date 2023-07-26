import SwiftUI

struct ConfigView: View {
  @State var planningTemplate = ""
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
        TextEditor(text: $planningTemplate)
      }.padding(10)
        .onChange(of: planningTemplate) { newValue in
          UserDefaults().set(planningTemplate, forKey: Constants.templateKey)
        }
    }.onAppear {
      planningTemplate = UserDefaults().string(forKey: Constants.templateKey) ?? Constants.defaultTemplate
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

struct ConfigView_Preview: PreviewProvider {
  static var previews: some View {
    ConfigView()
  }
}

