import SwiftUI

struct SettingsView: View {
    private let health = HealthKitService()
    @State private var healthStatus = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Apple Health") {
                    Button("Kết nối Apple Health") {
                        Task {
                            do {
                                try await health.requestAuthorization()
                                healthStatus = "Đã kết nối"
                            } catch {
                                healthStatus = error.localizedDescription
                            }
                        }
                    }
                    if !healthStatus.isEmpty { Text(healthStatus).font(.footnote) }
                }

                Section("Quyền riêng tư") {
                    Text("Âm thanh được xử lý trên máy. Ứng dụng không lưu bản ghi âm cả đêm.")
                        .font(.footnote)
                    // TODO: xoá toàn bộ dữ liệu, xuất dữ liệu, chính sách quyền riêng tư
                }

                Section("Khác") {
                    // TODO: đăng nhập + đồng bộ iCloud, gói Premium (StoreKit 2), nhắc giờ đi ngủ
                    Text("Phiên bản 0.1 (skeleton)").foregroundStyle(.secondary)
                    Text("Ứng dụng không thay thế chẩn đoán y khoa.").font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}
