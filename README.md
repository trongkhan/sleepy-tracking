# Sleepy (iOS skeleton)

SwiftUI + SwiftData + Swift Charts, iOS 17+.

## Chạy

Cách 1: XcodeGen
```
brew install xcodegen
cd SleepTracker && xcodegen && open Sleepy.xcodeproj
```
Cách 2: Xcode → New Project (iOS App, SwiftUI, SwiftData) → kéo thư mục `SleepTracker/SleepTracker` vào project, rồi:
- Signing & Capabilities: thêm **HealthKit** và **Background Modes → Audio**
- Info: thêm `NSMicrophoneUsageDescription`, `NSMotionUsageDescription`, `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`

Tính năng theo dõi giấc ngủ cần **chạy trên máy thật** (simulator không có cảm biến chuyển động).

## Cấu trúc

| Thư mục | Vai trò |
|---|---|
| `Models/` | `SleepSession` (SwiftData), `AlarmSettings` |
| `Services/MotionRecorder` | gia tốc kế → mức cử động mỗi phút |
| `Services/AudioEventDetector` | micro → sự kiện ngáy/ho (chỉ lưu dB, không lưu âm thanh) |
| `Services/SleepAnalysis` | cử động → giai đoạn ngủ, điểm số |
| `Services/SleepSessionManager` | điều phối 1 đêm, báo thức thông minh |
| `Services/AlarmScheduler` | local notification dự phòng |
| `Services/SoundPlayer` | âm thanh ru ngủ, hẹn giờ + fade out |
| `Services/HealthKitService` | đọc/ghi Apple Health |
| `Features/*` | màn hình: Đêm nay, Báo thức, Âm thanh, Kết quả, Cài đặt |

## Việc cần làm (theo độ ưu tiên)

1. Thêm file âm thanh `Resources/Sounds/<rain|ocean|forest|fire|whiteNoise|pinkNoise|piano>.mp3` (nhớ bản quyền).
2. Báo thức: phát chuông tăng dần + màn hình Snooze/Tắt, lặp theo ngày, nhạc chuông chọn được. Thử kỹ trường hợp app bị kill, hết pin, bật Không làm phiền.
3. Thuật toán giai đoạn ngủ thật (REM, nhịp tim từ Watch) và kiểm chứng độ chính xác.
4. Phân loại ngáy/ho/nói mớ bằng SoundAnalysis hoặc Core ML.
5. Insight cá nhân hoá (tag cafe/rượu → điểm ngủ), chấm tâm trạng buổi sáng.
6. Đồng bộ iCloud, StoreKit 2 (freemium), onboarding, xoá/xuất dữ liệu.
