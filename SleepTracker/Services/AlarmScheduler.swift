import Foundation
import UserNotifications

/// Báo thức dự phòng bằng local notification.
/// Đây là "lưới an toàn": nếu app bị hệ thống tắt giữa đêm thì vẫn có chuông vào giờ muộn nhất.
/// Chuông "thông minh" trong cửa sổ do SleepSessionManager kích hoạt khi app còn sống.
enum AlarmScheduler {
    private static let id = "alarm.latest"

    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func schedule(at date: Date, soundFile: String? = nil) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Dậy thôi!"
        content.body = "Đã đến giờ thức dậy."
        content.interruptionLevel = .timeSensitive
        // File phải <= 30 giây, nằm trong bundle (.caf/.aiff/.wav).
        content.sound = soundFile.map { UNNotificationSound(named: UNNotificationSoundName($0)) } ?? .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    // TODO: snooze (lên lịch lại +N phút), lặp theo weekdays, Critical Alerts (cần xin entitlement của Apple).
}
