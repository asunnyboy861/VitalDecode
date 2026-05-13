import Foundation

@Observable
final class AIConsentManager {

    var hasConsented: Bool {
        get { UserDefaults.standard.bool(forKey: "aiDataConsentGranted") }
        set { UserDefaults.standard.set(newValue, forKey: "aiDataConsentGranted") }
    }

    var consentTimestamp: Date? {
        get { UserDefaults.standard.object(forKey: "aiDataConsentTimestamp") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "aiDataConsentTimestamp") }
    }

    func recordConsent() {
        hasConsented = true
        consentTimestamp = Date()
    }

    func revokeConsent() {
        hasConsented = false
        consentTimestamp = nil
    }
}
