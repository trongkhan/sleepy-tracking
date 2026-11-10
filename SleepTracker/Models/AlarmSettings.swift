import Foundation
import Observation

struct AlarmSettings: Codable, Equatable {
    var isEnabled = true
    /// Giờ muộn nhất phải dậy (phút kể từ 0h)
    var latestWakeMinutes = 7 * 60
    /// Cho phép dậy sớm hơn tối đa bao nhiêu phút, nếu gặp lúc ngủ nhẹ
    var smartWindowMinutes = 30
    var weekdays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]   // Calendar weekday
    var soundName = "default"
    var snoozeMinutes = 9
    var goalSleepHours = 8.0
}

/// Lưu cài đặt báo thức vào UserDefaults.
@Observable
final class AlarmStore {
    var settings: AlarmSettings {
        didSet { save() }
    }
    private let key = "alarm.settings"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let s = try? JSONDecoder().decode(AlarmSettings.self, from: data) {
            settings = s
        } else {
            settings = AlarmSettings()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// Lần thức dậy muộn nhất kế tiếp, tính từ `date`.
    func nextLatestWake(after date: Date = .now) -> Date? {
        var comps = DateComponents()
        comps.hour = settings.latestWakeMinutes / 60
        comps.minute = settings.latestWakeMinutes % 60
        return Calendar.current.nextDate(after: date, matching: comps, matchingPolicy: .nextTime)
    }
}
