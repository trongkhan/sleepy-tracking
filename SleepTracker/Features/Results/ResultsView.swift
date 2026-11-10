import SwiftUI
import SwiftData
import Charts

// MARK: - Danh sách lịch sử + xu hướng

struct HistoryView: View {
    @Query(sort: \SleepSession.bedtime, order: .reverse) private var sessions: [SleepSession]

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView("Chưa có dữ liệu", systemImage: "moon.zzz",
                                           description: Text("Hãy bắt đầu theo dõi giấc ngủ đêm nay."))
                } else {
                    List {
                        Section("7 đêm gần nhất") { trendChart }
                        Section("Các đêm") {
                            ForEach(sessions) { s in
                                NavigationLink(value: s) { row(s) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kết quả")
            .navigationDestination(for: SleepSession.self) { ResultsView(session: $0) }
        }
    }

    private var trendChart: some View {
        Chart(sessions.prefix(7).reversed()) { s in
            BarMark(x: .value("Ngày", s.bedtime, unit: .day),
                    y: .value("Giờ ngủ", s.timeAsleep / 3600))
                .foregroundStyle(.indigo)
        }
        .frame(height: 160)
    }

    private func row(_ s: SleepSession) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(s.bedtime.formatted(date: .abbreviated, time: .omitted)).font(.headline)
                Text(duration(s.timeAsleep)).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(s.score)").font(.title2.bold())
        }
    }
}

// MARK: - Chi tiết một đêm

struct ResultsView: View {
    let session: SleepSession

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                scoreHeader
                metrics
                hypnogram
                soundEvents
                // TODO: insight cá nhân hoá, gợi ý cải thiện, chấm tâm trạng, gắn tag (cafe, rượu...), xuất PDF
            }
            .padding()
        }
        .navigationTitle("Kết quả đêm ngủ")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var scoreHeader: some View {
        VStack {
            Text("\(session.score)").font(.system(size: 64, weight: .bold))
            Text("Điểm giấc ngủ").foregroundStyle(.secondary)
        }
    }

    private var metrics: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                metric("Thời gian ngủ", duration(session.timeAsleep))
                metric("Hiệu suất", "\(Int(session.efficiency * 100))%")
            }
            GridRow {
                metric("Lần thức giấc", "\(session.awakenings)")
                metric("Tiếng ngáy", "\(session.snoreCount) lần")
            }
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack {
            Text(value).font(.title3.bold())
            Text(title).font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }

    private var hypnogram: some View {
        VStack(alignment: .leading) {
            Text("Các giai đoạn").font(.headline)
            Chart(session.stages, id: \.self) { seg in
                RectangleMark(xStart: .value("Từ", seg.start),
                              xEnd: .value("Đến", seg.end),
                              y: .value("Giai đoạn", seg.stage.title))
                    .foregroundStyle(by: .value("Giai đoạn", seg.stage.title))
            }
            .chartYScale(domain: SleepStage.allCases.map(\.title))
            .frame(height: 180)
            Text("Ước lượng từ cử động, chưa phải đo y khoa.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var soundEvents: some View {
        if !session.soundEvents.isEmpty {
            VStack(alignment: .leading) {
                Text("Sự kiện âm thanh").font(.headline)
                Chart(session.soundEvents, id: \.self) { e in
                    PointMark(x: .value("Giờ", e.time), y: .value("dB", e.peakDecibel))
                }
                .frame(height: 120)
            }
        }
    }
}

func duration(_ t: TimeInterval) -> String {
    let m = Int(t / 60)
    return "\(m / 60) giờ \(m % 60) phút"
}
