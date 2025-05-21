import Foundation
import SQLite3

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
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
        }
    }

    private func createTables() {
        let createEntries = "CREATE TABLE IF NOT EXISTS entries(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, asset_tag TEXT NOT NULL, timestamp REAL NOT NULL);"
        let createAdmins = "CREATE TABLE IF NOT EXISTS admins(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT);"
        sqlite3_exec(db, createEntries, nil, nil, nil)
        sqlite3_exec(db, createAdmins, nil, nil, nil)
    }

    func insertEntry(name: String, assetTag: String) {
        var stmt: OpaquePointer?
        let sql = "INSERT INTO entries(name, asset_tag, timestamp) VALUES(?,?,?);"
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (assetTag as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 3, Date().timeIntervalSince1970)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func fetchEntries() -> [Entry] {
        var stmt: OpaquePointer?
        let sql = "SELECT id, name, asset_tag, timestamp FROM entries ORDER BY timestamp DESC;"
        var result: [Entry] = []
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int64(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let assetTag = String(cString: sqlite3_column_text(stmt, 2))
                let time = sqlite3_column_double(stmt, 3)
                result.append(Entry(id: id, name: name, assetTag: assetTag, timestamp: Date(timeIntervalSince1970: time)))
            }
        }
        sqlite3_finalize(stmt)
        return result
    }

    func deleteEntry(id: Int64) {
        var stmt: OpaquePointer?
        let sql = "DELETE FROM entries WHERE id=?;"
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int64(stmt, 1, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func updateEntry(_ entry: Entry) {
        var stmt: OpaquePointer?
        let sql = "UPDATE entries SET name=?, asset_tag=? WHERE id=?;"
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (entry.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (entry.assetTag as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(stmt, 3, entry.id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func authenticateAdmin(username: String, password: String) -> Bool {
        var stmt: OpaquePointer?
        let sql = "SELECT COUNT(*) FROM admins WHERE username=? AND password=?;"
        var success = false
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (password as NSString).utf8String, -1, nil)
            if sqlite3_step(stmt) == SQLITE_ROW {
                success = sqlite3_column_int(stmt, 0) > 0
            }
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
            let insert = "INSERT INTO admins(username, password) VALUES('admin', '$uper@dmin');"
            sqlite3_exec(db, insert, nil, nil, nil)
        }
    }
}
