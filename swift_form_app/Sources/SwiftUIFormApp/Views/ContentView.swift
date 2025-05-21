import SwiftUI

/// Landing page with submission form and list of existing entries.
struct ContentView: View {
    @State private var name: String = ""
    @State private var assetTag: String = ""
    @State private var showAdminLogin = false
    @ObservedObject var viewModel = EntryViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("New Submission")) {
                        TextField("Name", text: $name)
                        TextField("Asset Tag", text: $assetTag)
                        Button("Submit") {
                            guard !name.isEmpty, !assetTag.isEmpty else { return }
                            viewModel.addEntry(name: name, assetTag: assetTag)
                            name = ""
                            assetTag = ""
                        }
                    }
                }
                .frame(maxWidth: 600)

                List {
                    ForEach(viewModel.entries) { entry in
                        SubmissionRow(entry: entry)
                    }
                }
                .frame(maxWidth: .infinity)

                Button("Login as Admin") {
                    showAdminLogin.toggle()
                }
                .padding()
            }
            .navigationTitle("Asset Form")
            .sheet(isPresented: $showAdminLogin) {
                AdminLoginView(viewModel: viewModel)
            }
        }
    }
}

struct SubmissionRow: View {
    let entry: Entry
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.name).font(.headline)
            Text(entry.assetTag).font(.subheadline)
        }
    }
}
