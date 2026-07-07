import Foundation

struct PickEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var month: String
    var discussionDate: String
    var groupRating: String
    var dateAdded: Date = Date()
}

struct AppSettings: Codable, Equatable {
    var categoryToggleOne: Bool = true
    var categoryToggleTwo: Bool = true
}
