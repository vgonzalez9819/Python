import SwiftUI

/// Dashboard showing all submissions with options to edit or delete.
struct AdminDashboardView: View {
    @Environment(\.presentationMode) private var presentation
    @ObservedObject var viewModel: EntryViewModel
    @ObservedObject var adminViewModel: AdminViewModel
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.entries) { entry in
                    Button(action: { editingEntry = entry }) {
                        VStack(alignment: .leading) {
                            Text(entry.name).font(.headline)
                            Text(entry.assetTag).font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteEntries)
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarItems(trailing: Button("Close") {
                adminViewModel.loggedIn = false
                presentation.wrappedValue.dismiss()
            })
            .sheet(item: $editingEntry) { entry in
                EditEntryView(entry: entry, viewModel: viewModel)
            }
        }
    }
}
