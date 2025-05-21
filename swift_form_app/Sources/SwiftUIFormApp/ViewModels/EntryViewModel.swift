import Foundation
import Combine

/// View model handling CRUD operations for form entries.
final class EntryViewModel: ObservableObject {
    @Published private(set) var entries: [Entry] = []

    init() {
        loadEntries()
    }

    func loadEntries() {
        entries = DatabaseManager.shared.fetchEntries()
    }

    func addEntry(name: String, assetTag: String) {
        guard !name.isEmpty, !assetTag.isEmpty else { return }
        DatabaseManager.shared.insertEntry(name: name, assetTag: assetTag)
        loadEntries()
    }

    func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entry = entries[index]
            DatabaseManager.shared.deleteEntry(id: entry.id)
        }
        loadEntries()
    }

    func updateEntry(_ entry: Entry) {
        DatabaseManager.shared.updateEntry(entry)
        loadEntries()
    }
}
