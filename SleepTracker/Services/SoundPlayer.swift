import AVFoundation
import Foundation
import Observation

enum AmbientSound: String, CaseIterable, Identifiable {
    case rain, ocean, forest, fire, whiteNoise, pinkNoise, piano

    var id: String { rawValue }
    var title: String {
        switch self {
        case .rain: "Mưa"
        case .ocean: "Sóng biển"
        case .forest: "Rừng đêm"
        case .fire: "Lửa trại"
        case .whiteNoise: "White noise"
        case .pinkNoise: "Pink noise"
        case .piano: "Piano nhẹ"
        }
    }
    /// Đặt file tương ứng vào Resources/Sounds/<rawValue>.mp3
    var fileName: String { rawValue }
}

/// Phát âm thanh ru ngủ lặp lại, có hẹn giờ tắt và giảm âm lượng dần.
@Observable
final class SoundPlayer {
    private(set) var playing: AmbientSound?
    private(set) var remaining: TimeInterval?

    private var player: AVAudioPlayer?
    private var timer: Timer?

    func play(_ sound: AmbientSound) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else {
            print("Thiếu file âm thanh: \(sound.fileName).mp3")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.7
            player?.play()
            playing = sound
        } catch {
            print("Không phát được: \(error)")
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        player?.stop()
        player = nil
        playing = nil
        remaining = nil
    }

    /// Hẹn giờ tắt: giảm âm lượng dần ở 30 giây cuối.
    func setSleepTimer(minutes: Int) {
        timer?.invalidate()
        remaining = TimeInterval(minutes * 60)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self, var left = remaining else { return t.invalidate() }
            left -= 1
            remaining = left
            if left <= 30 { player?.volume = Float(max(left, 0) / 30) * 0.7 }
            if left <= 0 { stop() }
        }
    }
}
