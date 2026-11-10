import SwiftUI

struct AlarmView: View {
    @Environment(AlarmStore.self) private var store

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            Form {
                Section {
                    Toggle("Bật báo thức", isOn: $store.settings.isEnabled)
                    DatePicker("Giờ dậy muộn nhất", selection: wakeBinding(store),
                               displayedComponents: .hourAndMinute)
                }

                Section("Báo thức thông minh") {
                    Picker("Cửa sổ thức dậy", selection: $store.settings.smartWindowMinutes) {
                        Text("Tắt").tag(0)
                        ForEach([15, 30, 45], id: \.self) { Text("\($0) phút").tag($0) }
                    }
                    Text("Chuông sẽ kêu sớm nhất \(store.settings.smartWindowMinutes) phút trước giờ đã đặt, khi bạn đang ngủ nhẹ.")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                Section("Chuông") {
                    // TODO: chọn nhạc chuông, âm lượng tăng dần, rung
                    Picker("Báo lại sau", selection: $store.settings.snoozeMinutes) {
                        ForEach([5, 9, 10, 15], id: \.self) { Text("\($0) phút").tag($0) }
                    }
                }

                Section("Mục tiêu") {
                    Stepper(value: $store.settings.goalSleepHours, in: 5...11, step: 0.5) {
                        Text("Ngủ \(store.settings.goalSleepHours, specifier: "%.1f") giờ mỗi đêm")
                    }
                }
            }
            .navigationTitle("Báo thức")
        }
    }

    private func wakeBinding(_ store: AlarmStore) -> Binding<Date> {
        Binding(
            get: {
                let m = store.settings.latestWakeMinutes
                return Calendar.current.date(bySettingHour: m / 60, minute: m % 60, second: 0, of: .now) ?? .now
            },
            set: {
                let c = Calendar.current.dateComponents([.hour, .minute], from: $0)
                store.settings.latestWakeMinutes = (c.hour ?? 7) * 60 + (c.minute ?? 0)
            }
        )
    }
}
