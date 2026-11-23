import ActivityKit
import Foundation

struct PickupAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var code: String
        var place: String
        var note: String
    }
    var title: String
}
