import Foundation
import HealthKit

@Observable
final class HealthKitManager {

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
    var isAuthorized: Bool = false

    private let healthStore = HKHealthStore()

    private let readTypes: Set<HKObjectType> = [
        HKQuantityType(.bloodGlucose),
        HKQuantityType(.heartRate),
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.bloodPressureSystolic),
        HKQuantityType(.bloodPressureDiastolic),
        HKQuantityType(.bodyMass),
        HKQuantityType(.bodyMassIndex),
        HKQuantityType(.height),
    ]

    private let writeTypes: Set<HKSampleType> = []

    func requestAuthorization() async throws -> Bool {
        guard isAvailable else { return false }
        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            isAuthorized = true
            return true
        } catch {
            isAuthorized = false
            return false
        }
    }
}
