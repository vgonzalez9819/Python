import Foundation

/// Simple model representing a form submission.
struct Entry: Identifiable {
    var id: Int64
    var name: String
    var assetTag: String
    var timestamp: Date
}
