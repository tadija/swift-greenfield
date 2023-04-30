#if canImport(SQLite3)

import Foundation
import SQLite3

/// Simple wrapper around SQLite3.
///
/// Example of a possible implementation:
///
///     let path = Bundle.main.path(forResource: "db", ofType: "sqlite")
///     let db = SQLite(path: path)
///     let sql = "SELECT t.id, t.name FROM aTable t"
///
///     db.selectQuery(sql: sql) { row in
///         print(String(describing: row?.int32(at: 0)))
///         print(String(describing: row?.string(at: 1)))
///     }
///
public final class SQLite {

    private var db: OpaquePointer?
    private var statement: OpaquePointer?

    public init(path: String) {
        openDatabase(atPath: path)
    }

    deinit {
        closeDatabase()
    }

    // MARK: API

    public func selectQuery(sql: String, rowHandler: (OpaquePointer?) -> Void) {
        prepareStatement(sql: sql)
        while sqlite3_step(statement) == SQLITE_ROW {
            rowHandler(statement)
        }
        finalizeStatement()
    }

    // MARK: Helpers

    private func openDatabase(atPath path: String) {
        guard sqlite3_open(path, &db) == SQLITE_OK else {
            print("Failed to open connection to database at: \(path)")
            return
        }
        print("Opened connection to database at: \(path)")
    }

    private func closeDatabase() {
        guard sqlite3_close(db) == SQLITE_OK else {
            print("Failed to close connection to database")
            return
        }
        db = nil
        print("Closed connection to database.")
    }

    private func prepareStatement(sql: String) {
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Failed to prepare statement: \(errorMessage)")
            return
        }
    }

    private func finalizeStatement() {
        guard sqlite3_finalize(statement) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Failed to finalize statement: \(errorMessage)")
            return
        }
        statement = nil
    }

}

public extension OpaquePointer {

    func bool(at columnIndex: Int32) -> Bool? {
        guard hasValue(at: columnIndex) else {
            return nil
        }
        return Bool(truncating: Int32(sqlite3_column_int(self, columnIndex)) as NSNumber)
    }

    func int16(at columnIndex: Int32) -> Int16? {
        guard hasValue(at: columnIndex) else {
            return nil
        }
        return Int16(sqlite3_column_int(self, columnIndex))
    }

    func int32(at columnIndex: Int32) -> Int32? {
        guard hasValue(at: columnIndex) else {
            return nil
        }
        return Int32(sqlite3_column_int(self, columnIndex))
    }

    func int64(at columnIndex: Int32) -> Int64? {
        guard hasValue(at: columnIndex) else {
            return nil
        }
        return Int64(sqlite3_column_int64(self, columnIndex))
    }

    func string(at columnIndex: Int32) -> String? {
        guard hasValue(at: columnIndex) else {
            return nil
        }
        guard let cString = sqlite3_column_text(self, columnIndex) else {
            return nil
        }
        return String(cString: cString)
    }

    func data(at columnIndex: Int32) -> Data? {
        guard hasValue(at: columnIndex) else {
            return nil
        }
        let data = sqlite3_column_blob(self, columnIndex)
        let size = sqlite3_column_bytes(self, columnIndex)
        let value = NSData(bytes: data, length: Int(size)) as Data
        return value
    }

    private func hasValue(at columnIndex: Int32) -> Bool {
        sqlite3_column_type(self, columnIndex) != SQLITE_NULL
    }

}

#endif
