import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var latestGlucose: Double = 0.0 // в ммоль/л
    
    func requestAuthorization() {
        guard let glucoseType = HKObjectType.quantityType(forIdentifier: .bloodGlucose) else { return }
        
        healthStore.requestAuthorization(toShare: nil, read: [glucoseType]) { success, error in
            if success {
                self.fetchLatestGlucose()
            }
        }
    }
    
    func fetchLatestGlucose() {
        guard let glucoseType = HKObjectType.quantityType(forIdentifier: .bloodGlucose) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: glucoseType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else { return }
            
            // Конвертируем в ммоль/л
            let unit = HKUnit(from: "mmol/L")
            let value = sample.quantity.doubleValue(for: unit)
            
            DispatchQueue.main.async {
                self.latestGlucose = value
            }
        }
        healthStore.execute(query)
    }
}
