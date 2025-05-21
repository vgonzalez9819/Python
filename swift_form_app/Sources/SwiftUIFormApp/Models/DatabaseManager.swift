import Foundation
import SQLite3
import CryptoKit

/// Handles all SQLite database operations.
final class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTables()
        insertDefaultAdmin()
    }

    private func openDatabase() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dbURL = urls[0].appendingPathComponent("form.sqlite")
        let result = sqlite3_open(dbURL.path, &db)
        check(result, message: "Unable to open database")
    }

    /// Log SQLite errors if the return code indicates a failure.
    private func check(_ code: Int32, message: String) {
        guard code != SQLITE_OK && code != SQLITE_DONE && code != SQLITE_ROW else { return }
        if let err = sqlite3_errmsg(db) {
            print("\(message): \(String(cString: err))")
        } else {
            print("\(message): Unknown SQLite error")
        }
    }

    private func createTables() {
        let createEntries = "CREATE TABLE IF NOT EXISTS entries(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, asset_tag TEXT NOT NULL, timestamp REAL NOT NULL);"
        let createAdmins = "CREATE TABLE IF NOT EXISTS admins(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT);"
        check(sqlite3_exec(db, createEntries, nil, nil, nil), message: "Create entries table failed")
        check(sqlite3_exec(db, createAdmins, nil, nil, nil), message: "Create admins table failed")
    }

    func insertEntry(name: String, assetTag: String) {
        var stmt: OpaquePointer?
        let sql = "INSERT INTO entries(name, asset_tag, timestamp) VALUES(?,?,?);"
        let prep = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        if prep == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (assetTag as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 3, Date().timeIntervalSince1970)
            check(sqlite3_step(stmt), message: "Insert entry failed")
        } else {
            check(prep, message: "Insert entry prepare failed")
        }
        sqlite3_finalize(stmt)
    }

    func fetchEntries() -> [Entry] {
        var stmt: OpaquePointer?
        let sql = "SELECT id, name, asset_tag, timestamp FROM entries ORDER BY timestamp DESC;"
        var result: [Entry] = []
        let prep = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        if prep == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int64(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let assetTag = String(cString: sqlite3_column_text(stmt, 2))
                let time = sqlite3_column_double(stmt, 3)
                result.append(Entry(id: id, name: name, assetTag: assetTag, timestamp: Date(timeIntervalSince1970: time)))
            }
        } else {
            check(prep, message: "Fetch entries prepare failed")
        }
        sqlite3_finalize(stmt)
        return result
    }

    func deleteEntry(id: Int64) {
        var stmt: OpaquePointer?
        let sql = "DELETE FROM entries WHERE id=?;"
        let prepDel = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        if prepDel == SQLITE_OK {
            sqlite3_bind_int64(stmt, 1, id)
            check(sqlite3_step(stmt), message: "Delete entry failed")
        } else {
            check(prepDel, message: "Delete entry prepare failed")
        }
        sqlite3_finalize(stmt)
    }

    func updateEntry(_ entry: Entry) {
        var stmt: OpaquePointer?
        let sql = "UPDATE entries SET name=?, asset_tag=? WHERE id=?;"
        let prepUpd = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        if prepUpd == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (entry.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (entry.assetTag as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(stmt, 3, entry.id)
            check(sqlite3_step(stmt), message: "Update entry failed")
        } else {
            check(prepUpd, message: "Update entry prepare failed")
        }
        sqlite3_finalize(stmt)
    }

    func authenticateAdmin(username: String, password: String) -> Bool {
        var stmt: OpaquePointer?
        let sql = "SELECT COUNT(*) FROM admins WHERE username=? AND password=?;"
        var success = false
        let prep = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        if prep == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (hash(password) as NSString).utf8String, -1, nil)
            if sqlite3_step(stmt) == SQLITE_ROW {
                success = sqlite3_column_int(stmt, 0) > 0
            }
        } else {
            check(prep, message: "Authenticate admin prepare failed")
        }
        sqlite3_finalize(stmt)
        return success
    }

    private func insertDefaultAdmin() {
        var stmt: OpaquePointer?
        let check = "SELECT COUNT(*) FROM admins WHERE username='admin';"
        var exists = false
        if sqlite3_prepare_v2(db, check, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                exists = sqlite3_column_int(stmt, 0) > 0
            }
        }
        sqlite3_finalize(stmt)
        if !exists {
            let insert = "INSERT INTO admins(username, password) VALUES(?, ?);"
            var insertStmt: OpaquePointer?
            if sqlite3_prepare_v2(db, insert, -1, &insertStmt, nil) == SQLITE_OK {
                sqlite3_bind_text(insertStmt, 1, ("admin" as NSString).utf8String, -1, nil)
                let hashed = hash("$uper@dmin")
                sqlite3_bind_text(insertStmt, 2, (hashed as NSString).utf8String, -1, nil)
                check(sqlite3_step(insertStmt), message: "Insert default admin failed")
            }
            sqlite3_finalize(insertStmt)
        }
    }

    /// Compute a SHA-256 hash from the given string.
    private func hash(_ string: String) -> String {
        let digest = SHA256.hash(data: Data(string.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
