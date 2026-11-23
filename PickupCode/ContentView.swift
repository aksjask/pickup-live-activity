import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var code = ""
    @State private var place = ""
    @State private var message = ""
    @State private var candidates: [PickupInfo] = []
    @State private var scanning = false

    var body: some View {
        NavigationStack {
            Form {
                Section("短信识别") {
                    Button {
                        scanSMS()
                    } label: {
                        if scanning {
                            ProgressView()
                        } else {
                            Label("从短信识别取件码", systemImage: "message.badge.filled.fill")
                        }
                    }
                    .disabled(scanning)

                    if !candidates.isEmpty {
                        Text("识别到 \(candidates.count) 条，点一条填入：")
                            .font(.caption).foregroundStyle(.secondary)
                        ForEach(candidates) { item in
                            Button {
                                code = item.code
                                place = item.place
                                message = "已填入 \(item.code)，点下方按钮钉到锁屏"
                            } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(item.carrier)
                                            .font(.caption.weight(.semibold))
                                        Text(item.place)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(item.code)
                                        .font(.system(.body, design: .monospaced))
                                    Text(item.rawText)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

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

    private func scanSMS() {
        scanning = true
        switch SMSReader.readRecent() {
        case .failure(let err):
            message = "读短信失败：\(err)"
        case .success(let records):
            var seen = Set<String>()
            var found: [PickupInfo] = []
            for record in records {
                guard let info = PickupParser.parse(record.text) else { continue }
                guard !seen.contains(info.code) else { continue }
                seen.insert(info.code)
                found.append(info)
                if found.count >= 12 { break }
            }
            candidates = found
            if let first = found.first {
                code = first.code
                place = first.place
                message = "识别到 \(found.count) 条，已自动填入最新一条"
            } else {
                message = "最近 \(records.count) 条短信里没找到取件码"
            }
        }
        scanning = false
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
