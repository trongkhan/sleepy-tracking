import Foundation
import SwiftData

enum SleepStage: String, Codable, CaseIterable {
    case awake, light, deep, rem

    var title: String {
        switch self {
        case .awake: "Thức"
        case .light: "Ngủ nhẹ"
        case .deep: "Ngủ sâu"
        case .rem: "REM"
        }
    }
}

struct StageSegment: Codable, Hashable {
    var start: Date
    var end: Date
    var stage: SleepStage
}

/// Mức cử động trung bình trong 1 khoảng (mặc định 1 phút), 0...1
struct MovementSample: Codable, Hashable {
    var time: Date
    var intensity: Double
}

struct SoundEvent: Codable, Hashable {
    enum Kind: String, Codable { case snore, cough, talking, noise }
    var time: Date
    var kind: Kind
    var peakDecibel: Double
    var duration: TimeInterval
}

@Model
final class SleepSession {
    var id: UUID
    var bedtime: Date
    var wakeTime: Date?
    var movements: [MovementSample]
    var soundEvents: [SoundEvent]
    var stages: [StageSegment]
    var score: Int
    var moodRating: Int?        // 1...5, người dùng chấm buổi sáng
    var tags: [String]          // "cafe", "rượu", "stress", "tập thể dục"...

    init(bedtime: Date = .now) {
        self.id = UUID()
        self.bedtime = bedtime
        self.wakeTime = nil
        self.movements = []
        self.soundEvents = []
        self.stages = []
        self.score = 0
        self.moodRating = nil
        self.tags = []
    }

    // MARK: Chỉ số suy ra

    var timeInBed: TimeInterval {
        (wakeTime ?? .now).timeIntervalSince(bedtime)
    }

    var timeAsleep: TimeInterval {
        stages.filter { $0.stage != .awake }
            .reduce(0) { $0 + $1.end.timeIntervalSince($1.start) }
    }

    var efficiency: Double {
        timeInBed > 0 ? timeAsleep / timeInBed : 0
    }

    /// Số lần chuyển từ ngủ sang thức
    var awakenings: Int {
        zip(stages, stages.dropFirst()).filter { $0.stage != .awake && $1.stage == .awake }.count
    }

    var snoreCount: Int { soundEvents.filter { $0.kind == .snore }.count }
}
