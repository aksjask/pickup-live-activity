import WidgetKit
import SwiftUI
import ActivityKit

struct PickupWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PickupAttributes.self) { ctx in
            VStack(alignment: .leading, spacing: 6) {
                Text("取件码 · \(ctx.state.place)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(ctx.state.code)
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(ctx.state.note)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.75))
        } dynamicIsland: { ctx in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("取件")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(ctx.state.code)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .minimumScaleFactor(0.5)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(ctx.state.place).font(.caption)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(ctx.state.note)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text("码").font(.caption2)
            } compactTrailing: {
                Text(ctx.state.code)
                    .font(.caption.monospacedDigit())
            } minimal: {
                Text("·")
            }
        }
    }
}

@main
struct PickupWidgetBundle: WidgetBundle {
    var body: some Widget {
        PickupWidget()
    }
}
