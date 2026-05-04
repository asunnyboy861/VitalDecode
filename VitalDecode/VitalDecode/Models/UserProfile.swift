import Foundation

@Observable
final class UserProfile {
    var name: String = UserDefaults.standard.string(forKey: "userName") ?? "" {
        didSet { UserDefaults.standard.set(name, forKey: "userName") }
    }
    var age: Int = UserDefaults.standard.integer(forKey: "userAge") {
        didSet { UserDefaults.standard.set(age, forKey: "userAge") }
    }
    var gender: Gender = Gender(rawValue: UserDefaults.standard.string(forKey: "userGender") ?? "") ?? .notSpecified {
        didSet { UserDefaults.standard.set(gender.rawValue, forKey: "userGender") }
    }
    var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    var freeScansUsed: Int = UserDefaults.standard.integer(forKey: "freeScansUsed") {
        didSet { UserDefaults.standard.set(freeScansUsed, forKey: "freeScansUsed") }
    }
    var lastScanResetDate: Date = UserDefaults.standard.object(forKey: "lastScanResetDate") as? Date ?? .distantPast {
        didSet { UserDefaults.standard.set(lastScanResetDate, forKey: "lastScanResetDate") }
    }

    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case notSpecified = "Not Specified"
    }

    var canScanFree: Bool {
        if freeScansUsed < 1 { return true }
        let calendar = Calendar.current
        let now = Date()
        if let resetDate = calendar.date(byAdding: .month, value: 1, to: lastScanResetDate) {
            return now >= resetDate
        }
        return false
    }

    func incrementFreeScan() {
        if freeScansUsed == 0 {
            lastScanResetDate = Date()
        }
        freeScansUsed += 1
    }

    func resetMonthlyScansIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        if let resetDate = calendar.date(byAdding: .month, value: 1, to: lastScanResetDate), now >= resetDate {
            freeScansUsed = 0
            lastScanResetDate = now
        }
    }
}
