import SwiftUI
import SwiftData

struct ManualEntryView: View {
    let userProfile: UserProfile
    let storeManager: StoreManager

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: Biomarker.BiomarkerCategory = .completeBloodCount
    @State private var entries: [ManualEntry] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Biomarker.BiomarkerCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .onChange(of: selectedCategory) { _, _ in
                        loadEntries()
                    }
                }

                Section("Biomarkers") {
                    ForEach($entries) { $entry in
                        HStack {
                            Text(entry.name)
                                .frame(width: 100, alignment: .leading)
                                .font(.subheadline)
                            TextField("Value", value: $entry.value, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Text(entry.unit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 50)
                        }
                    }
                }

                Section {
                    Button("Save Report") {
                        saveReport()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(entries.filter { $0.value != nil }.isEmpty)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { loadEntries() }
        }
    }

    private func loadEntries() {
        let definitions = BiomarkerDefinitions.all.filter { $0.category == selectedCategory }
        entries = definitions.map { ManualEntry(name: $0.canonicalName, unit: $0.unit, definition: $0) }
    }

    private func saveReport() {
        let report = BloodTestReport(sourceType: .manual)

        for entry in entries {
            guard let value = entry.value, let definition = entry.definition else { continue }
            let status = BiomarkerDefinitions.calculateStatus(
                value: value,
                refLow: definition.referenceLow,
                refHigh: definition.referenceHigh,
                optLow: definition.optimalLow,
                optHigh: definition.optimalHigh
            )
            let biomarker = Biomarker(
                name: entry.name,
                canonicalName: definition.canonicalName,
                value: value,
                unit: definition.unit,
                referenceLow: definition.referenceLow,
                referenceHigh: definition.referenceHigh,
                optimalLow: definition.optimalLow,
                optimalHigh: definition.optimalHigh,
                status: status,
                category: definition.category
            )
            biomarker.report = report
            report.biomarkers.append(biomarker)
        }

        modelContext.insert(report)
        if !storeManager.isPro {
            userProfile.incrementFreeScan()
        }
        dismiss()
    }
}

private struct ManualEntry: Identifiable {
    let id = UUID()
    let name: String
    let unit: String
    var value: Double?
    let definition: BiomarkerDefinition?
}
