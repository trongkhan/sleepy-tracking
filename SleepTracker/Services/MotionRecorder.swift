import CoreMotion
import Foundation

/// Đo cử động qua gia tốc kế, gom thành mẫu mỗi `interval` giây.
final class MotionRecorder {
    private let manager = CMMotionManager()
    private var deltas: [Double] = []
    private var last: CMAcceleration?
    private var timer: Timer?

    var onSample: ((MovementSample) -> Void)?

    func start(interval: TimeInterval = 60) {
        guard manager.isAccelerometerAvailable else { return }
        manager.accelerometerUpdateInterval = 0.1   // 10 Hz là đủ, đỡ tốn pin

        manager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let a = data?.acceleration else { return }
            if let l = last {
                deltas.append(abs(a.x - l.x) + abs(a.y - l.y) + abs(a.z - l.z))
            }
            last = a
        }

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.flush(interval: interval)
        }
    }

    func stop() {
        manager.stopAccelerometerUpdates()
        timer?.invalidate()
        timer = nil
        deltas.removeAll()
        last = nil
    }

    private func flush(interval: TimeInterval) {
        let mean = deltas.isEmpty ? 0 : deltas.reduce(0, +) / Double(deltas.count)
        deltas.removeAll()
        // Chuẩn hoá về 0...1. TODO: hiệu chỉnh hệ số 10 theo dữ liệu thực tế.
        let intensity = min(mean * 10, 1)
        onSample?(MovementSample(time: .now.addingTimeInterval(-interval), intensity: intensity))
    }
}
