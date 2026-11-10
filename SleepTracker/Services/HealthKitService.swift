import Foundation
import HealthKit

/// Đọc/ghi dữ liệu giấc ngủ với Apple Health.
/// Giai đoạn ngủ chính xác (REM/sâu) chỉ có khi người dùng có Apple Watch hoặc thiết bị khác ghi vào Health.
final class HealthKitService {
    private let store = HKHealthStore()
    private let sleepType = HKCategoryType(.sleepAnalysis)
    private let heartRate = HKQuantityType(.heartRate)

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async throws {
        guard isAvailable else { return }
        try await store.requestAuthorization(toShare: [sleepType], read: [sleepType, heartRate])
    }

    /// Lưu một phiên ngủ vào Health.
    func save(_ session: SleepSession) async throws {
        guard let wake = session.wakeTime else { return }
        let samples = session.stages.map { seg -> HKCategorySample in
            let value: HKCategoryValueSleepAnalysis = switch seg.stage {
            case .awake: .awake
            case .light: .asleepCore
            case .deep: .asleepDeep
            case .rem: .asleepREM
            }
            return HKCategorySample(type: sleepType, value: value.rawValue,
                                    start: seg.start, end: seg.end)
        }
        let inBed = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue,
                                     start: session.bedtime, end: wake)
        try await store.save([inBed] + samples)
    }

    // TODO: fetchSleep(from:to:) đọc từ Watch, fetchHeartRate(...) để cải thiện ước lượng giai đoạn.
}
