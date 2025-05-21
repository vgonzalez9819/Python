import SwiftUI

/// View for editing an existing entry.
struct EditEntryView: View {
    @Environment(\.presentationMode) private var presentation
    @State private var name: String
    @State private var assetTag: String
    let entry: Entry
    let viewModel: EntryViewModel

    init(entry: Entry, viewModel: EntryViewModel) {
        self.entry = entry
        self.viewModel = viewModel
        _name = State(initialValue: entry.name)
        _assetTag = State(initialValue: entry.assetTag)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Asset Tag", text: $assetTag)
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentation.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = entry
                        updated.name = name
                        updated.assetTag = assetTag
                        viewModel.updateEntry(updated)
                        presentation.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

