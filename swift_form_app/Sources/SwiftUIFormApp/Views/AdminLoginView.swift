import SwiftUI

/// Login screen for admin users.
struct AdminLoginView: View {
    @Environment(\.presentationMode) private var presentation
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showError = false

    var viewModel: EntryViewModel
    @StateObject private var admin = AdminViewModel()

    var body: some View {
        NavigationView {
            Form {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                Button("Login") {
                    if !admin.login(username: username, password: password) {
                        showError = true
                    }
                }
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Invalid credentials"))
            }
            .navigationTitle("Admin Login")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { presentation.wrappedValue.dismiss() }
                }
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $admin.loggedIn) {
            AdminDashboardView(viewModel: viewModel, adminViewModel: admin)
        }
        #else
        .sheet(isPresented: $admin.loggedIn) {
            AdminDashboardView(viewModel: viewModel, adminViewModel: admin)
        }
        #endif
    }
}
