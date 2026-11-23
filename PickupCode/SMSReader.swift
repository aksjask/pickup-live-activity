import Foundation
import SQLite3

struct SMSRecord {
    let text: String
    let date: Int64
}

enum SMSReader {
    static let dbPath = "/private/var/mobile/Library/SMS/sms.db"

    static func readRecent(limit: Int32 = 200) -> Result<[SMSRecord], String> {
        var raw: OpaquePointer?
        let uri = "file:\(dbPath)?mode=ro"
        let status = sqlite3_open_v2(
            uri,
            &raw,
            SQLITE_OPEN_READONLY | SQLITE_OPEN_URI,
            nil
        )
        guard status == SQLITE_OK, let db = raw else {
            let msg = raw.map { String(cString: sqlite3_errmsg($0)) } ?? "无法打开短信数据库"
            if let r = raw { sqlite3_close(r) }
            return .failure(msg)
        }
        defer { sqlite3_close(db) }

        var stmt: OpaquePointer?
        let sql = """
        SELECT text, date FROM message
        WHERE is_from_me = 0 AND text IS NOT NULL
        ORDER BY date DESC LIMIT ?
        """
        let prep = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        guard prep == SQLITE_OK, let s = stmt else {
            return .failure(String(cString: sqlite3_errmsg(db)))
        }
        defer { sqlite3_finalize(s) }
        sqlite3_bind_int(s, 1, limit)

        var rows: [SMSRecord] = []
        while sqlite3_step(s) == SQLITE_ROW {
            guard let ptr = sqlite3_column_text(s, 0) else { continue }
            rows.append(SMSRecord(
                text: String(cString: ptr),
                date: sqlite3_column_int64(s, 1)
            ))
        }
        return .success(rows)
    }
}
