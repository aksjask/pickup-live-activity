import Foundation

struct PickupInfo: Identifiable, Hashable {
    var id: String { code + "|" + place }
    let code: String
    let place: String
    let carrier: String
    let rawText: String
}

enum PickupParser {
    private static let keywords = [
        "取件", "快递", "驿站", "包裹", "领取", "丰巢",
        "菜鸟", "快递柜", "代收", "取货", "提取码"
    ]

    static func parse(_ text: String) -> PickupInfo? {
        guard text.count <= 500 else { return nil }
        guard keywords.contains(where: { text.contains($0) }) else { return nil }
        // 明显的营销短信，没有取件码的一律跳过
        if text.contains("退订") && !text.contains("取件码") { return nil }
        guard let code = extractCode(from: text) else { return nil }
        return PickupInfo(
            code: code,
            place: extractPlace(from: text),
            carrier: extractCarrier(from: text),
            rawText: text
        )
    }

    private static func firstMatch(_ pattern: String, in text: String, group: Int = 1) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let ns = text as NSString
        guard let m = re.firstMatch(in: text, options: [], range: NSRange(location: 0, length: ns.length)),
              m.numberOfRanges > group else { return nil }
        let r = m.range(at: group)
        guard r.location != NSNotFound, let sw = Range(r, in: text) else { return nil }
        return String(text[sw]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractCode(from text: String) -> String? {
        let patterns = [
            #"(?:取件码|提取码|取货码|取件密码|凭码|密码)[为是:：\s]*([0-9A-Za-z]+(?:[-－][0-9A-Za-z]+){0,3})"#,
            #"凭\s*([0-9]+(?:[-－][0-9]+){1,3})\s*到"#,
            #"(?:取件|提取)\s*码?[^0-9A-Za-z]{0,4}([0-9]{4,8})(?![0-9])"#,
            #"([0-9]{1,2}[-－][0-9]{1,2}[-－][0-9]{3,6})"#
        ]
        for p in patterns {
            if let c = firstMatch(p, in: text), c.count >= 3 {
                return c.replacingOccurrences(of: "－", with: "-")
            }
        }
        return nil
    }

    private static func extractPlace(from text: String) -> String {
        let patterns = [
            #"到\s*(.{2,20}?)\s*(?:领取|取件|请凭|，|,|。)"#,
            #"到达\s*(.{2,20}?)(?:，|,|。|取件|领取)"#,
            #"(.{2,20}?(?:驿站|快递柜|丰巢柜|代收点|快递点|便利店|柜))"#
        ]
        for p in patterns {
            if let s = firstMatch(p, in: text) {
                let cleaned = s
                    .replacingOccurrences(of: "您", with: "")
                    .replacingOccurrences(of: "的包裹", with: "")
                    .replacingOccurrences(of: "包裹", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if cleaned.count >= 2 && cleaned.count <= 20 { return cleaned }
            }
        }
        return "取件点"
    }

    private static func extractCarrier(from text: String) -> String {
        if let c = firstMatch(#"【(.{2,12}?)】"#, in: text) { return c }
        let names = [
            "中通", "圆通", "韵达", "申通", "顺丰", "京东", "菜鸟",
            "丰巢", "极兔", "邮政", "EMS", "德邦", "百世"
        ]
        for n in names where text.contains(n) { return n }
        return "快递"
    }
}
