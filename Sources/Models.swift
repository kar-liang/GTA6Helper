import Foundation

// MARK: - Remote data model (gta6-guides.json)

struct GuideSection: Codable, Equatable {
    var heading: String
    var body: String
    var steps: [String]
}

struct GuideArticle: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var category: String
    var summary: String
    var sections: [GuideSection]
}

struct ChecklistItem: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var detail: String
}

struct ChecklistGroup: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var items: [ChecklistItem]
}

struct LocationPoint: Codable, Equatable, Identifiable {
    var id: String
    var name: String
    var area: String
    var detail: String
}

/// The whole library the app downloads from the online JSON. Adding a guide,
/// checklist item or location only requires editing that JSON — no new IPA.
struct GuideLibrary: Codable, Equatable {
    var version: Int
    var updatedAt: String
    var guides: [GuideArticle]
    var checklistGroups: [ChecklistGroup]
    var locations: [LocationPoint]

    var allChecklistItems: [ChecklistItem] {
        checklistGroups.flatMap { $0.items }
    }
}
