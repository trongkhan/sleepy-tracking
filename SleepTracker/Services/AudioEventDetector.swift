import AVFoundation
import Foundation

/// Nghe micro, phát hiện sự kiện âm thanh (ngáy, ho, nói mớ...).
/// Quyền riêng tư: chỉ tính mức âm lượng trên máy, KHÔNG lưu âm thanh thô.
/// Nếu sau này cho nghe lại đoạn ngáy, chỉ lưu các clip ngắn quanh sự kiện và phải xin phép người dùng.
final class AudioEventDetector {
    private let engine = AVAudioEngine()
    private var eventStart: Date?
    private var peak: Float = -160

    /// Ngưỡng dBFS coi là "có tiếng". TODO: tự hiệu chỉnh theo tiếng ồn nền phòng.
    var thresholdDB: Float = -35
    var onEvent: ((SoundEvent) -> Void)?

    func start() throws {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            self?.process(buffer)
        }
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        eventStart = nil
    }

    private func process(_ buffer: AVAudioPCMBuffer) {
        guard let data = buffer.floatChannelData?[0] else { return }
        let n = Int(buffer.frameLength)
        guard n > 0 else { return }

        var sum: Float = 0
        for i in 0..<n { sum += data[i] * data[i] }
        let db = 20 * log10(max(sqrt(sum / Float(n)), 0.000_001))

        let now = Date()
        if db > thresholdDB {
            if eventStart == nil { eventStart = now; peak = db }
            peak = max(peak, db)
        } else if let start = eventStart {
            let duration = now.timeIntervalSince(start)
            eventStart = nil
            if duration > 0.3 {
                onEvent?(SoundEvent(time: start,
                                    kind: classify(duration: duration, peak: peak),
                                    peakDecibel: Double(peak),
                                    duration: duration))
            }
        }
    }

    /// TODO: thay bằng Core ML / SoundAnalysis (SNClassifySoundRequest) để phân loại ngáy/ho/nói mớ.
    private func classify(duration: TimeInterval, peak: Float) -> SoundEvent.Kind {
        duration > 1.0 ? .snore : .noise
    }
}
