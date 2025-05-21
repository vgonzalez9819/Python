import Foundation
import Combine

/// View model managing admin authentication state.
final class AdminViewModel: ObservableObject {
    @Published var loggedIn = false

    func login(username: String, password: String) -> Bool {
        let success = DatabaseManager.shared.authenticateAdmin(username: username, password: password)
        loggedIn = success
        return success
    }
}
