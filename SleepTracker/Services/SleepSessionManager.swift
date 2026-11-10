import AVFoundation
import Foundation
import Observation
import SwiftData

/// Điều phối một đêm ngủ: bật cảm biến, gom dữ liệu, tính kết quả, kích hoạt báo thức.
@Observable
@MainActor
final class SleepSessionManager {
    private(set) var isTracking = false
    private(set) var current: SleepSession?

    private let motion = MotionRecorder()
    private let audio = AudioEventDetector()
    private var wakeCheckTimer: Timer?

    private var alarm: AlarmSettings?
    private var latestWake: Date?
    var onAlarmFired: (() -> Void)?

    // MARK: Bắt đầu / kết thúc

    func start(alarm: AlarmSettings, latestWake: Date?) throws {
        guard !isTracking else { return }

        // Audio session giữ app sống ở nền (cần UIBackgroundModes = audio).
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default,
                                options: [.mixWithOthers, .defaultToSpeaker])
        try session.setActive(true)

        current = SleepSession(bedtime: .now)
        self.alarm = alarm
        self.latestWake = latestWake

        motion.onSample = { [weak self] sample in
            Task { @MainActor in self?.current?.movements.append(sample) }
        }
        audio.onEvent = { [weak self] event in
            Task { @MainActor in self?.current?.soundEvents.append(event) }
        }
        motion.start()
        try audio.start()

        // Mỗi 30 giây kiểm tra có nên đánh thức không.
        wakeCheckTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.checkSmartWake() }
        }
        isTracking = true
    }

    /// Dừng theo dõi, tính kết quả, lưu vào SwiftData.
    @discardableResult
    func stop(goalHours: Double, context: ModelContext) -> SleepSession? {
        guard isTracking, let session = current else { return nil }
        motion.stop()
        audio.stop()
        wakeCheckTimer?.invalidate()
        wakeCheckTimer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        session.wakeTime = .now
        session.stages = SleepAnalysis.estimateStages(from: session.movements)
        session.score = SleepAnalysis.score(for: session, goalHours: goalHours)
        context.insert(session)
        try? context.save()

        isTracking = false
        current = nil
        return session
    }

    // MARK: Báo thức thông minh

    private func checkSmartWake() {
        guard let alarm, alarm.isEnabled, let latestWake else { return }
        let now = Date.now
        let windowStart = latestWake.addingTimeInterval(-Double(alarm.smartWindowMinutes) * 60)

        let inWindow = now >= windowStart
        let mustWake = now >= latestWake
        let isLightSleep = currentStage() == .light || currentStage() == .awake

        if mustWake || (inWindow && isLightSleep) {
            onAlarmFired?()
            wakeCheckTimer?.invalidate()
        }
    }

    private func currentStage() -> SleepStage {
        guard let last = current?.movements.suffix(3), !last.isEmpty else { return .light }
        let avg = last.map(\.intensity).reduce(0, +) / Double(last.count)
        return SleepAnalysis.stage(forIntensity: avg)
    }
}
