import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [PickEntry] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isPro: Bool = false

    /// Free tier allows up to this many entries. Deliberately set well above
    /// the seed data count so a fresh install never trips the paywall.
    static let freeLimit = 14

    private let entriesFileName = "entries.json"
    private let settingsFileName = "settings.json"

    init() {
        load()
        if entries.isEmpty {
            seed()
            save()
        }
    }

    private var supportDirectory: URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Bookclub Log", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func seed() {
        entries = [
            PickEntry(name: "Circe", month: "May 2026", discussionDate: "2026-05-28", groupRating: "4.5"),
            PickEntry(name: "Educated", month: "June 2026", discussionDate: "2026-06-25", groupRating: "4.2")
        ]
    }

    func load() {
        let entriesURL = supportDirectory.appendingPathComponent(entriesFileName)
        if let data = try? Data(contentsOf: entriesURL),
           let decoded = try? JSONDecoder().decode([PickEntry].self, from: data) {
            entries = decoded
        }
        let settingsURL = supportDirectory.appendingPathComponent(settingsFileName)
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    func save() {
        let entriesURL = supportDirectory.appendingPathComponent(entriesFileName)
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: entriesURL)
        }
        let settingsURL = supportDirectory.appendingPathComponent(settingsFileName)
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL)
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(name: String, f1: String, f2: String, f3: String) -> Bool {
        guard canAddMore else { return false }
        let entry = PickEntry(name: name, month: f1, discussionDate: f2, groupRating: f3)
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: PickEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: PickEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
}
