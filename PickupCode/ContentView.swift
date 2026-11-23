import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var code = ""
    @State private var place = ""
    @State private var message = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("取件信息") {
                    TextField("取件码", text: $code)
                        .textInputAutocapitalization(.never)
                    TextField("驿站 / 地点", text: $place)
                }
                Section {
                    Button("钉到锁屏和灵动岛") {
                        start()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty)

                    Button("结束显示") {
                        endAll()
                    }
                }
                if !message.isEmpty {
                    Section {
                        Text(message).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("取件码")
        }
    }

    private func start() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            message = "系统未开启实时活动，请先到 设置 里允许"
            return
        }
        let attributes = PickupAttributes(title: "取件码")
        let state = PickupAttributes.ContentState(
            code: code.trimmingCharacters(in: .whitespaces),
            place: place.isEmpty ? "取件点" : place,
            note: "亮屏即见"
        )
        do {
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil)
            )
            message = "已钉上锁屏，点亮屏幕查看"
        } catch {
            message = "失败：\(error.localizedDescription)"
        }
    }

    private func endAll() {
        for activity in Activity<PickupAttributes>.activities {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        message = "已结束显示"
    }
}
