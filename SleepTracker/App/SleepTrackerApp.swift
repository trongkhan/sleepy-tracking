import SwiftUI
import SwiftData

@main
struct SleepTrackerApp: App {
    @State private var sessionManager = SleepSessionManager()
    @State private var soundPlayer = SoundPlayer()
    @State private var alarmStore = AlarmStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sessionManager)
                .environment(soundPlayer)
                .environment(alarmStore)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: SleepSession.self)
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            TonightView()
                .tabItem { Label("Đêm nay", systemImage: "moon.stars.fill") }
            AlarmView()
                .tabItem { Label("Báo thức", systemImage: "alarm.fill") }
            SoundsView()
                .tabItem { Label("Âm thanh", systemImage: "music.note") }
            HistoryView()
                .tabItem { Label("Kết quả", systemImage: "chart.bar.fill") }
            SettingsView()
                .tabItem { Label("Cài đặt", systemImage: "gearshape.fill") }
        }
    }
}
