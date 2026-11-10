import Foundation

/// Chuyển dữ liệu cảm biến thành giai đoạn ngủ và điểm số.
/// LƯU Ý: chỉ là heuristic để chạy được skeleton. Cần thay bằng thuật toán thật
/// và kiểm chứng với thiết bị đã được xác nhận (xem README, mục "Việc cần làm").
enum SleepAnalysis {

    // MARK: Giai đoạn ngủ

    static func estimateStages(from movements: [MovementSample],
                               interval: TimeInterval = 60) -> [StageSegment] {
        var segments: [StageSegment] = []
        for m in movements {
            let stage = stage(forIntensity: m.intensity)
            let end = m.time.addingTimeInterval(interval)
            if var last = segments.last, last.stage == stage {
                last.end = end
                segments[segments.count - 1] = last
            } else {
                segments.append(StageSegment(start: m.time, end: end, stage: stage))
            }
        }
        return segments
    }

    /// TODO: dùng cửa sổ trượt + chu kỳ ~90 phút + nhịp tim (nếu có) để tách REM.
    static func stage(forIntensity x: Double) -> SleepStage {
        switch x {
        case 0.5...: .awake
        case 0.15..<0.5: .light
        default: .deep
        }
    }

    // MARK: Điểm số 0...100

    static func score(for session: SleepSession, goalHours: Double) -> Int {
        guard session.timeInBed > 0 else { return 0 }
        let hours = session.timeAsleep / 3600

        // 50 điểm cho thời lượng so với mục tiêu
        let duration = min(hours / goalHours, 1) * 50
        // 30 điểm cho hiệu suất giấc ngủ (>= 90% là tối đa)
        let efficiency = min(session.efficiency / 0.9, 1) * 30
        // 20 điểm, trừ 4 điểm cho mỗi lần thức giấc
        let continuity = max(0, 20 - Double(session.awakenings) * 4)

        return Int((duration + efficiency + continuity).rounded())
    }
}
