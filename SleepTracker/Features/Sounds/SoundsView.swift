import SwiftUI

struct SoundsView: View {
    @Environment(SoundPlayer.self) private var player
    @State private var timerMinutes = 30

    var body: some View {
        NavigationStack {
            List {
                Section("Hẹn giờ tắt") {
                    Picker("Tắt sau", selection: $timerMinutes) {
                        ForEach([15, 30, 45, 60, 90], id: \.self) { Text("\($0) phút").tag($0) }
                    }
                    if let left = player.remaining {
                        Text("Còn \(Int(left) / 60):\(String(format: "%02d", Int(left) % 60))")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Âm thanh") {
                    ForEach(AmbientSound.allCases) { sound in
                        Button {
                            if player.playing == sound {
                                player.stop()
                            } else {
                                player.play(sound)
                                player.setSleepTimer(minutes: timerMinutes)
                            }
                        } label: {
                            HStack {
                                Text(sound.title)
                                Spacer()
                                if player.playing == sound {
                                    Image(systemName: "speaker.wave.2.fill").foregroundStyle(.indigo)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
                // TODO: mixer nhiều âm thanh cùng lúc, yêu thích, tải offline, truyện/thiền ru ngủ
            }
            .navigationTitle("Âm thanh")
        }
    }
}
