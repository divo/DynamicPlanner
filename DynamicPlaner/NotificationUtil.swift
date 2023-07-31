//
//  NotificationUtil.swift
//  Daily Planner
//
//  Created by Steven Diviney on 07/07/2023.
//

import UserNotifications

struct NotificationUtil {
  static func requestPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
      if success {
        print("All set!")
      } else if let error = error {
        print(error.localizedDescription)
      }
    }
  }
  
  static func checkScheduled(id: String, completion: @escaping (Bool) -> ()) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
      completion({
       requests.contains { request in
          request.identifier == id
        }
      }())
    }
  }
  
  static func scheduleRepeatingNotification(id: String, message: String, date: Date) -> Bool {
    removeNotification(id: id)
    
    let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
    let content = UNMutableNotificationContent()
    content.title = message
    content.sound = .default

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
    return true
  }
  
  static func scheduleNotification(id: String, message: String, date: Date) -> Bool {
    removeNotification(id: id) // I'm probably updating the message
    
    let due = date.timeIntervalSince(Date.now)
    if due <= 0 {
      print("Cannot set reminder in the past!")
      return false
    }
    
    let content = UNMutableNotificationContent()
    content.title = message
    content.sound = UNNotificationSound.default
    
    // TODO: Check if notification already exists
    // Calculating a timeinterval instead of using Calender dates, what could go wrong.
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: due, repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
    return true
  }
  
  static func removeNotification(id: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
  }
}

