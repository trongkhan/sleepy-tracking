# Sleepy: BRD và mô tả kỹ thuật

| | |
|---|---|
| Phiên bản tài liệu | 0.1 (bản nháp) |
| Ngày | 2026-11-10 |
| Nền tảng | iOS native (Swift, SwiftUI), iOS 17+ |
| Trạng thái | Đã có skeleton mã nguồn, chưa chạy thử trên máy thật |

> Các mục đánh dấu **[Giả định]** hoặc **[Cần xác nhận]** là đề xuất ban đầu, chưa có số liệu hay quyết định chính thức.

---

# PHẦN A: BRD (Business Requirements Document)

## 1. Tổng quan

### 1.1 Mục tiêu sản phẩm
Xây dựng ứng dụng iOS giúp người dùng **theo dõi giấc ngủ, đánh giá chất lượng giấc ngủ, thức dậy đúng lúc và dễ đi vào giấc ngủ hơn**, chỉ cần điện thoại, không bắt buộc có thiết bị đeo.

### 1.2 Vấn đề cần giải quyết
- Nhiều người ngủ không đủ giấc hoặc không sâu giấc nhưng không biết nguyên nhân.
- Báo thức thông thường đánh thức sai thời điểm (lúc đang ngủ sâu) nên người dùng thức dậy mệt.
- Khó đi vào giấc ngủ, cần âm thanh thư giãn có hẹn giờ.
- Người dùng muốn thấy kết quả dễ hiểu (điểm số, biểu đồ, xu hướng) thay vì dữ liệu thô.

### 1.3 Đối tượng người dùng [Giả định]
- Người đi làm văn phòng, sinh viên, ngủ muộn hoặc ngủ không đều.
- Người hay ngáy hoặc muốn biết mình có ngáy không.
- Người đã dùng Apple Watch và muốn xem dữ liệu giấc ngủ gọn hơn.

### 1.4 Tham chiếu cạnh tranh
Sleep Cycle (đã xem qua trên App Store), SleepScore, Pillow, Calm, Rise, Apple Sleep. Nên dùng thử từng app để ghi lại điểm mạnh, điểm yếu và mô hình giá trước khi chốt phạm vi.

### 1.5 Mục tiêu kinh doanh [Cần xác nhận]
- Ra mắt MVP trên App Store.
- Có người dùng quay lại hằng ngày (retention) nhờ thói quen buổi tối và buổi sáng.
- Chuyển đổi một phần người dùng sang gói trả phí.

Chưa có chỉ tiêu số cụ thể. Cần chốt KPI (xem mục 8).

## 2. Phạm vi

### 2.1 Trong phạm vi MVP
1. Theo dõi giấc ngủ bằng cảm biến điện thoại (chuyển động, micro).
2. Báo thức, gồm cửa sổ thức dậy thông minh.
3. Âm thanh ru ngủ với hẹn giờ tắt.
4. Báo cáo kết quả giấc ngủ (điểm, chỉ số, biểu đồ, lịch sử).
5. Kết nối Apple Health (ghi dữ liệu giấc ngủ).

### 2.2 Ngoài phạm vi MVP
- Android.
- App Apple Watch riêng.
- Chẩn đoán hoặc tư vấn y khoa (ví dụ ngưng thở khi ngủ).
- Mạng xã hội, bảng xếp hạng.
- Nội dung thiền, truyện ru ngủ (để các phiên bản sau).

## 3. Yêu cầu nghiệp vụ (chức năng)

Mức ưu tiên: **P0** bắt buộc cho MVP, **P1** nên có, **P2** để sau.

### 3.1 Đo chất lượng giấc ngủ

| ID | Yêu cầu | Ưu tiên |
|---|---|---|
| SL-01 | Người dùng bắt đầu và kết thúc một phiên ngủ bằng một nút bấm. | P0 |
| SL-02 | Hệ thống ghi mức cử động bằng gia tốc kế theo từng phút. | P0 |
| SL-03 | Hệ thống phát hiện sự kiện âm thanh (ngáy, ho, tiếng ồn) bằng micro, chỉ lưu mức dB và thời điểm, không lưu âm thanh thô. | P0 |
| SL-04 | Hệ thống ước lượng các giai đoạn: thức, ngủ nhẹ, ngủ sâu (REM khi có dữ liệu từ thiết bị đeo). | P0 |
| SL-05 | Hệ thống tính các chỉ số: thời gian ngủ thực, hiệu suất giấc ngủ, số lần thức giấc, số lần ngáy. | P0 |
| SL-06 | Hệ thống tính điểm giấc ngủ 0–100 (công thức ở mục 6.4). | P0 |
| SL-07 | Người dùng chấm tâm trạng buổi sáng và gắn tag (cà phê, rượu, stress, tập thể dục). | P1 |
| SL-08 | Nghe lại các đoạn ngáy (clip ngắn) khi người dùng đồng ý. | P2 |
| SL-09 | Đọc dữ liệu nhịp tim, giai đoạn ngủ từ Apple Watch để tăng độ chính xác. | P1 |

### 3.2 Báo thức

| ID | Yêu cầu | Ưu tiên |
|---|---|---|
| AL-01 | Đặt giờ thức dậy muộn nhất, bật/tắt báo thức. | P0 |
| AL-02 | Cửa sổ thức dậy thông minh (0/15/30/45 phút): chuông kêu sớm nhất trong cửa sổ khi người dùng đang ngủ nhẹ, hoặc kêu đúng giờ muộn nhất. | P0 |
| AL-03 | Thông báo cục bộ dự phòng vào giờ muộn nhất, phòng trường hợp app bị hệ thống tắt. | P0 |
| AL-04 | Chuông tăng âm lượng dần, rung, màn hình Snooze/Tắt. | P0 |
| AL-05 | Chọn nhạc chuông, thời gian báo lại (5/9/10/15 phút). | P1 |
| AL-06 | Lặp theo ngày trong tuần. | P1 |
| AL-07 | Cách tắt báo thức nâng cao (giải toán, lắc máy). | P2 |

### 3.3 Âm nhạc và âm thanh ru ngủ

| ID | Yêu cầu | Ưu tiên |
|---|---|---|
| SN-01 | Danh sách âm thanh: mưa, sóng biển, rừng đêm, lửa trại, white noise, pink noise, piano nhẹ. | P0 |
| SN-02 | Phát lặp, vẫn phát khi tắt màn hình. | P0 |
| SN-03 | Hẹn giờ tắt (15/30/45/60/90 phút) với giảm âm lượng dần. | P0 |
| SN-04 | Trộn nhiều âm thanh cùng lúc, yêu thích, tải offline. | P1 |
| SN-05 | Thiền hướng dẫn, truyện ru ngủ. | P2 |

### 3.4 Kết quả giấc ngủ

| ID | Yêu cầu | Ưu tiên |
|---|---|---|
| RS-01 | Màn hình kết quả sau mỗi đêm: điểm, thời gian ngủ, hiệu suất, số lần thức, số lần ngáy. | P0 |
| RS-02 | Biểu đồ các giai đoạn theo thời gian (hypnogram) và biểu đồ sự kiện âm thanh. | P0 |
| RS-03 | Lịch sử các đêm và biểu đồ xu hướng 7 đêm. | P0 |
| RS-04 | Xu hướng tuần/tháng, sleep debt, độ đều đặn giờ giấc. | P1 |
| RS-05 | Insight cá nhân hóa, ví dụ ảnh hưởng của cà phê đến thời gian ngủ. | P1 |
| RS-06 | Xuất báo cáo PDF để gửi bác sĩ. | P2 |

### 3.5 Chức năng chung

| ID | Yêu cầu | Ưu tiên |
|---|---|---|
| GN-01 | Onboarding hướng dẫn đặt điện thoại, cắm sạc, xin quyền. | P0 |
| GN-02 | Cài đặt: mục tiêu giờ ngủ, kết nối Apple Health, quyền riêng tư. | P0 |
| GN-03 | Xóa và xuất toàn bộ dữ liệu của người dùng. | P0 |
| GN-04 | Đồng bộ iCloud, đăng nhập. | P1 |
| GN-05 | Gói trả phí (StoreKit 2). | P1 |
| GN-06 | Nhắc giờ đi ngủ. | P1 |

## 4. Yêu cầu phi chức năng

| Nhóm | Yêu cầu |
|---|---|
| Độ tin cậy | Báo thức phải kêu đúng giờ trong mọi trường hợp có thể kiểm soát. Đây là tiêu chí chất lượng quan trọng nhất của app. |
| Pin | Theo dõi cả đêm khi cắm sạc không được làm máy nóng hoặc ngắt giữa chừng. Cần hướng dẫn cắm sạc. |
| Quyền riêng tư | Âm thanh xử lý trên máy, không upload. Dữ liệu sức khỏe lưu cục bộ (SwiftData), chỉ đồng bộ khi người dùng bật. |
| Hiệu năng | Mở màn hình kết quả dưới 1 giây với lịch sử vài trăm đêm. |
| Khả dụng | Giao diện tối, ít sáng, nút lớn dùng được khi vừa thức dậy. |
| Ngôn ngữ | Tiếng Việt trước, chuẩn bị đa ngôn ngữ [Cần xác nhận]. |
| Tương thích | iOS 17+; theo dõi cảm biến cần máy thật. |

## 5. Quyền riêng tư và pháp lý

- Dữ liệu giấc ngủ và âm thanh là dữ liệu nhạy cảm. Cần xin đồng ý rõ ràng trước khi thu thập (micro, chuyển động, Health).
- Không lưu bản ghi âm cả đêm. Nếu có tính năng nghe lại đoạn ngáy, chỉ lưu clip ngắn và phải được người dùng cho phép.
- Không đưa ra tuyên bố y tế. Hiển thị cảnh báo "không thay thế chẩn đoán y khoa". Các giai đoạn ngủ là **ước lượng**.
- Cần chính sách quyền riêng tư công khai và khai báo đúng trong App Store Privacy Labels.
- Tuân thủ luật bảo vệ dữ liệu cá nhân của thị trường mục tiêu (ví dụ Nghị định 13/2023 tại Việt Nam, GDPR nếu có người dùng châu Âu). **[Cần xác nhận với bộ phận pháp lý]**
- Nhạc và âm thanh phải có bản quyền hợp lệ (tự thu, mua giấy phép hoặc royalty-free).

## 6. Mô hình kinh doanh [Giả định, cần xác nhận]

Freemium:
- **Miễn phí:** theo dõi cơ bản, báo thức, một số âm thanh, kết quả đêm gần nhất.
- **Trả phí:** lịch sử và xu hướng đầy đủ, báo thức thông minh, toàn bộ thư viện âm thanh, insight, xuất báo cáo.

Giá và cách tính gói (tháng/năm) chưa được quyết định.

## 7. Rủi ro và giả định

| Rủi ro | Mức | Giảm thiểu |
|---|---|---|
| iOS hạn chế chạy nền, app bị tắt giữa đêm, báo thức không kêu | Cao | Dùng chế độ nền audio, thông báo cục bộ dự phòng, thử nghiệm trên nhiều máy và kịch bản; cân nhắc xin Critical Alerts. |
| Độ chính xác giai đoạn ngủ thấp khi chỉ dùng điện thoại | Cao | Ghi rõ là ước lượng; tích hợp dữ liệu Watch; kiểm chứng với thiết bị đối chiếu. |
| Hao pin, máy nóng | Trung bình | Lấy mẫu 10 Hz, gom theo phút, hướng dẫn cắm sạc. |
| Người dùng ngại micro vì riêng tư | Trung bình | Xử lý trên máy, giải thích minh bạch, cho phép tắt micro. |
| Bị xem là thiết bị y tế | Trung bình | Không tuyên bố y tế, cảnh báo rõ trong app và trên store. |
| Bản quyền âm thanh | Trung bình | Chỉ dùng nội dung có giấy phép. |
| Cạnh tranh với Sleep Cycle và các app đã có | Trung bình | Chọn điểm khác biệt trong phân khúc (cần quyết định). |

**Giả định:** người dùng đặt điện thoại trên nệm và cắm sạc; có tài khoản Apple Developer để dùng HealthKit và phát hành.

## 8. Chỉ số thành công [Đề xuất, chưa có mục tiêu số]

- Tỷ lệ hoàn thành onboarding.
- Số đêm theo dõi trung bình mỗi người dùng mỗi tuần.
- Retention ngày 1, ngày 7, ngày 30.
- Tỷ lệ báo thức kêu đúng giờ (đo qua thử nghiệm và phản hồi người dùng).
- Tỷ lệ chuyển đổi sang gói trả phí.
- Đánh giá trên App Store.

## 9. Lộ trình đề xuất

| Giai đoạn | Nội dung |
|---|---|
| 0. Skeleton | Khung mã nguồn, chạy được luồng cơ bản (đã xong). |
| 1. MVP nội bộ | Hoàn thiện báo thức (chuông, Snooze), nhạc thật, onboarding, thử trên máy thật. |
| 2. Beta | TestFlight, thu thập dữ liệu, chỉnh ngưỡng thuật toán, đối chiếu độ chính xác. |
| 3. Phát hành | Quyền riêng tư, App Store, gói trả phí. |
| 4. Mở rộng | Insight, Apple Watch, phân loại âm thanh bằng Core ML, đồng bộ iCloud. |

## 10. Câu hỏi còn mở

1. Đối tượng chính là ai và điểm khác biệt so với Sleep Cycle là gì?
2. Tên app, thương hiệu, bundle ID.
3. Giá và danh sách tính năng thuộc gói trả phí.
4. Có phát hành ngoài Việt Nam không (ảnh hưởng ngôn ngữ và pháp lý)?
5. Có xin Critical Alerts cho báo thức không?
6. Nguồn âm thanh: tự thu, mua hay royalty-free?

---

# PHẦN B: Mô tả kỹ thuật (skeleton hiện tại)

## 1. Công nghệ

| Hạng mục | Lựa chọn |
|---|---|
| Ngôn ngữ / UI | Swift 5.9, SwiftUI |
| Lưu trữ | SwiftData |
| Biểu đồ | Swift Charts |
| Cảm biến | CoreMotion (gia tốc kế), AVAudioEngine (micro) |
| Âm thanh | AVFoundation (AVAudioPlayer) |
| Thông báo | UserNotifications |
| Sức khỏe | HealthKit |
| Trạng thái | Observation (`@Observable`) |
| Tạo project | XcodeGen (`project.yml`) |

## 2. Cấu trúc thư mục

```
SleepTracker/
├── project.yml                  # cấu hình XcodeGen (quyền, background mode, HealthKit)
├── README.md
├── docs/
│   └── BRD-and-Technical-Overview.md
└── SleepTracker/
    ├── App/
    │   └── SleepTrackerApp.swift        # entry point + RootView (TabView)
    ├── Models/
    │   ├── SleepModels.swift            # SleepSession, SleepStage, MovementSample, SoundEvent
    │   └── AlarmSettings.swift          # AlarmSettings + AlarmStore (UserDefaults)
    ├── Services/
    │   ├── MotionRecorder.swift         # gia tốc kế -> mức cử động mỗi phút
    │   ├── AudioEventDetector.swift     # micro -> sự kiện âm thanh (chỉ dB)
    │   ├── SleepAnalysis.swift          # cử động -> giai đoạn ngủ, điểm số
    │   ├── SleepSessionManager.swift    # điều phối 1 đêm + báo thức thông minh
    │   ├── AlarmScheduler.swift         # local notification dự phòng
    │   ├── SoundPlayer.swift            # âm thanh ru ngủ, hẹn giờ, fade out
    │   └── HealthKitService.swift       # đọc/ghi Apple Health
    ├── Features/
    │   ├── Tonight/TonightView.swift    # bắt đầu/kết thúc ngủ
    │   ├── Alarm/AlarmView.swift        # cài đặt báo thức
    │   ├── Sounds/SoundsView.swift      # chọn âm thanh + hẹn giờ
    │   ├── Results/ResultsView.swift    # lịch sử + chi tiết một đêm
    │   └── Settings/SettingsView.swift  # Health, quyền riêng tư
    └── Resources/Sounds/                # đặt file .mp3 ở đây (hiện trống)
```

## 3. Kiến trúc

Các service được tạo một lần ở `SleepTrackerApp` và truyền xuống View qua `.environment`. View chỉ hiển thị và gọi hành động; logic nằm trong service.

```
SwiftUI Views
  TonightView  AlarmView  SoundsView  HistoryView/ResultsView  SettingsView
      │            │          │              │                       │
      ▼            ▼          ▼              ▼ (@Query)              ▼
SleepSessionManager  AlarmStore  SoundPlayer  SwiftData(SleepSession)  HealthKitService
      │   │
      │   └── AudioEventDetector (AVAudioEngine)
      └────── MotionRecorder (CoreMotion)
```

## 4. Luồng chính

### 4.1 Một đêm ngủ
1. Người dùng bấm **Bắt đầu ngủ** ở `TonightView`.
2. Nếu báo thức bật: xin quyền thông báo, lên lịch thông báo dự phòng vào giờ muộn nhất (`AlarmScheduler`).
3. `SleepSessionManager.start` bật audio session (`playAndRecord`, `mixWithOthers`), khởi động `MotionRecorder` và `AudioEventDetector`, đặt timer 30 giây kiểm tra báo thức.
4. Mỗi phút, `MotionRecorder` phát một `MovementSample` (cường độ 0...1). Mỗi sự kiện âm thanh vượt ngưỡng được ghi thành `SoundEvent`.
5. Người dùng bấm **Thức dậy** (hoặc báo thức kêu): `stop` dừng cảm biến, gọi `SleepAnalysis.estimateStages`, tính điểm, lưu `SleepSession` vào SwiftData và hiển thị `ResultsView`.

### 4.2 Báo thức thông minh
Mỗi 30 giây `checkSmartWake` thực hiện:
- Nếu đã đến giờ muộn nhất: kích hoạt báo thức.
- Nếu đang trong cửa sổ (giờ muộn nhất trừ `smartWindowMinutes`) và giai đoạn hiện tại là thức hoặc ngủ nhẹ (trung bình 3 mẫu gần nhất): kích hoạt báo thức.

Thông báo cục bộ ở bước 4.1.2 là lưới an toàn khi app bị hệ thống tắt.

### 4.3 Âm thanh ru ngủ
`SoundPlayer.play` phát file `<tên>.mp3` lặp vô hạn. `setSleepTimer` đếm ngược mỗi giây và giảm âm lượng tuyến tính trong 30 giây cuối rồi dừng.

## 5. Mô hình dữ liệu

**`SleepSession`** (`@Model`)

| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| id | UUID | |
| bedtime / wakeTime | Date / Date? | Bắt đầu và kết thúc phiên |
| movements | [MovementSample] | Cường độ cử động theo phút |
| soundEvents | [SoundEvent] | Sự kiện âm thanh (loại, thời điểm, dB đỉnh, thời lượng) |
| stages | [StageSegment] | Các đoạn giai đoạn ngủ |
| score | Int | Điểm 0–100 |
| moodRating | Int? | 1–5, chấm buổi sáng |
| tags | [String] | Yếu tố ảnh hưởng |

Thuộc tính tính toán: `timeInBed`, `timeAsleep`, `efficiency`, `awakenings`, `snoreCount`.

**`AlarmSettings`** (Codable, lưu UserDefaults qua `AlarmStore`): bật/tắt, giờ muộn nhất (phút từ 0h), cửa sổ thông minh, ngày lặp, tên chuông, thời gian báo lại, mục tiêu giờ ngủ.

## 6. Thuật toán hiện tại (heuristic tạm)

### 6.1 Cử động
Gia tốc kế 10 Hz. Mỗi phút lấy trung bình độ lệch tuyệt đối giữa hai mẫu liên tiếp (|Δx|+|Δy|+|Δz|), nhân 10 và giới hạn về tối đa 1.

### 6.2 Phát hiện âm thanh
Tính RMS mỗi buffer rồi quy ra dBFS. Vượt ngưỡng **-35 dB** thì bắt đầu sự kiện, hạ xuống dưới ngưỡng thì kết thúc. Sự kiện dài hơn 0,3 giây được ghi lại. Dài hơn 1 giây tạm coi là "ngáy", còn lại là "tiếng ồn".

### 6.3 Giai đoạn ngủ

| Cường độ cử động | Giai đoạn |
|---|---|
| ≥ 0,5 | Thức |
| 0,15 đến dưới 0,5 | Ngủ nhẹ |
| < 0,15 | Ngủ sâu |

Chưa phân biệt được REM.

### 6.4 Điểm giấc ngủ (tổng 100)

| Thành phần | Điểm tối đa | Cách tính |
|---|---|---|
| Thời lượng | 50 | `min(giờ ngủ / mục tiêu, 1) × 50` |
| Hiệu suất | 30 | `min(hiệu suất / 0,9, 1) × 30` |
| Liên tục | 20 | `max(0, 20 − 4 × số lần thức giấc)` |

Các ngưỡng và trọng số trên là **giá trị tạm**, cần hiệu chỉnh bằng dữ liệu thật.

## 7. Quyền và cấu hình

| Hạng mục | Giá trị |
|---|---|
| Micro | `NSMicrophoneUsageDescription` |
| Chuyển động | `NSMotionUsageDescription` |
| Health | `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription` |
| Chế độ nền | `UIBackgroundModes = audio` |
| Entitlement | `com.apple.developer.healthkit` |
| Thông báo | xin runtime qua `UNUserNotificationCenter` |

## 8. Hiện trạng và việc cần làm

**Đã có:** luồng theo dõi đầu-cuối, lưu SwiftData, màn hình 5 tab, biểu đồ, hẹn giờ âm thanh, ghi Health. Mã đã qua typecheck với iOS 17 SDK.

**Chưa kiểm chứng:** chưa chạy trên máy thật, chưa đo pin, chưa đối chiếu độ chính xác.

**Việc cần làm theo ưu tiên:**
1. Thêm file âm thanh thật vào `Resources/Sounds/`.
2. Hoàn thiện báo thức: chuông tăng dần, rung, Snooze/Tắt, lặp theo ngày, chọn nhạc chuông (hiện `handleAlarm` chỉ in log).
3. Thử độ tin cậy báo thức: app bị kill, hết pin, Không làm phiền, nhiều dòng máy.
4. Onboarding và xin quyền có giải thích.
5. Thuật toán giai đoạn ngủ thật (REM, nhịp tim từ Watch) và kiểm chứng độ chính xác.
6. Phân loại ngáy/ho/nói mớ bằng SoundAnalysis hoặc Core ML.
7. Insight cá nhân hóa, tag, tâm trạng buổi sáng.
8. Xóa/xuất dữ liệu, iCloud, StoreKit 2.

## 9. Cách chạy

```
brew install xcodegen
cd SleepTracker
xcodegen
open Sleepy.xcodeproj
```

Đổi `bundleIdPrefix` trong `project.yml`, bật signing bằng team của bạn và chạy trên **máy thật** (simulator không có cảm biến chuyển động).
