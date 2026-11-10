import SwiftUI
import SwiftData

struct TonightView: View {
    @Environment(SleepSessionManager.self) private var manager
    @Environment(SoundPlayer.self) private var sounds
    @Environment(AlarmStore.self) private var alarmStore
    @Environment(\.modelContext) private var context

    @State private var errorMessage: String?
    @State private var lastResult: SleepSession?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                if manager.isTracking {
                    Text("Đang theo dõi giấc ngủ…")
                        .font(.title2)
                    if let s = manager.current {
                        Text("Bắt đầu lúc \(s.bedtime.formatted(date: .omitted, time: .shortened))")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.indigo)
                    alarmSummary
                }

                Button(action: toggle) {
                    Text(manager.isTracking ? "Thức dậy" : "Bắt đầu ngủ")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(manager.isTracking ? .orange : .indigo)
                .padding(.horizontal)

                if !manager.isTracking {
                    Text("Đặt điện thoại trên nệm gần đầu giường và cắm sạc.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .navigationTitle("Đêm nay")
            .alert("Lỗi", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
            .sheet(item: $lastResult) { ResultsView(session: $0) }
        }
        .onAppear {
            manager.onAlarmFired = { handleAlarm() }
        }
    }

    private var alarmSummary: some View {
        let s = alarmStore.settings
        let h = s.latestWakeMinutes / 60, m = s.latestWakeMinutes % 60
        return VStack {
            Text(s.isEnabled ? String(format: "Báo thức %02d:%02d", h, m) : "Báo thức đang tắt")
                .font(.headline)
            if s.isEnabled {
                Text("Dậy sớm nhất \(s.smartWindowMinutes) phút trước giờ nếu bạn ngủ nhẹ")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Actions

    private func toggle() {
        if manager.isTracking {
            lastResult = manager.stop(goalHours: alarmStore.settings.goalSleepHours, context: context)
            AlarmScheduler.cancel()
            sounds.stop()
        } else {
            Task { await begin() }
        }
    }

    private func begin() async {
        let s = alarmStore.settings
        let latest = s.isEnabled ? alarmStore.nextLatestWake() : nil
        do {
            if let latest {
                _ = await AlarmScheduler.requestAuthorization()
                await AlarmScheduler.schedule(at: latest)   // lưới an toàn
            }
            try manager.start(alarm: s, latestWake: latest)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleAlarm() {
        // TODO: phát âm báo thức tăng dần âm lượng + rung, hiện màn hình Snooze / Tắt.
        sounds.stop()
        print("⏰ Báo thức!")
    }
}
