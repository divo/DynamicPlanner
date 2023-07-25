import SwiftUI

struct ConfigView: View {
  @State var habbitsText = UserDefaults().string(forKey: "habbits") ?? ""
  @State var dayStart = UserDefaults().object(forKey: "dayStart") as? Date ?? Date.now
  @State var planningTime = UserDefaults().object(forKey: "planningTime") as? Date ?? Date.now
  @State var startNotification = false
  @State var planningNotification = false
  
  var body: some View {
    List {
      VStack {
        ViewUtil.textLabel("habbits").tint(.primary)
        ViewUtil.smallLabel("comma seperated").tint(Style.primaryColor)
        TextEditor(text: $habbitsText)
          .frame(idealHeight: 20)
          .overlay(ViewUtil.divider(), alignment: .bottom)
      }.padding(10)
        .onChange(of: habbitsText) { newValue in
          UserDefaults().set(habbitsText, forKey: "habbits")
        }
      
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

