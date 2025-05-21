import SwiftUI

/// Dashboard showing all submissions with options to edit or delete.
struct AdminDashboardView: View {
    @Environment(\.presentationMode) private var presentation
    @ObservedObject var viewModel: EntryViewModel
    @ObservedObject var adminViewModel: AdminViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.entries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.name).font(.headline)
                        Text(entry.assetTag).font(.subheadline)
                    }
                }
                .onDelete(perform: viewModel.deleteEntries)
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarItems(trailing: Button("Close") {
                adminViewModel.loggedIn = false
                presentation.wrappedValue.dismiss()
            })
        }
    }
}
