import Foundation

actor AIAnalysisService {

    struct AIAnalysis: Codable {
        let summary: String
        let keyFindings: [String]
        let correlations: [String]
        let topicsToDiscuss: [String]
        let suggestedNextSteps: [String]
        let isAIGenerated: Bool

        init(summary: String, keyFindings: [String], correlations: [String], topicsToDiscuss: [String], suggestedNextSteps: [String], isAIGenerated: Bool = false) {
            self.summary = summary
            self.keyFindings = keyFindings
            self.correlations = correlations
            self.topicsToDiscuss = topicsToDiscuss
            self.suggestedNextSteps = suggestedNextSteps
            self.isAIGenerated = isAIGenerated
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            summary = try container.decode(String.self, forKey: .summary)
            keyFindings = try container.decode([String].self, forKey: .keyFindings)
            correlations = try container.decode([String].self, forKey: .correlations)
            topicsToDiscuss = try container.decodeIfPresent([String].self, forKey: .topicsToDiscuss) ?? []
            suggestedNextSteps = try container.decodeIfPresent([String].self, forKey: .suggestedNextSteps) ?? []
            isAIGenerated = try container.decodeIfPresent(Bool.self, forKey: .isAIGenerated) ?? false
        }
    }

    enum AIError: Error, LocalizedError {
        case invalidAPIKey
        case requestFailed(String)
        case decodingFailed
        case noData

        var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "An OpenAI API key is required for AI-powered data comparison. Please enter your key in Settings, or use the built-in comparison instead."
            case .requestFailed(let detail):
                return "Analysis request failed: \(detail). Please check your API key and try again."
            case .decodingFailed:
                return "Failed to parse AI response. Please try again."
            case .noData:
                return "No biomarker data available for analysis."
            }
        }
    }

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }

    var hasAPIKey: Bool {
        !apiKey.isEmpty
    }

    func analyze(biomarkers: [Biomarker], userProfile: UserProfile) async throws -> AIAnalysis {
        guard !apiKey.isEmpty else {
            throw AIError.invalidAPIKey
        }

        let biomarkerSummary = biomarkers.map { marker in
            "\(marker.canonicalName): \(marker.value) \(marker.unit) (Status: \(marker.status.rawValue), Ref: \(marker.referenceLow)-\(marker.referenceHigh), Optimal: \(marker.optimalLow)-\(marker.optimalHigh))"
        }.joined(separator: "\n")

        let prompt = """
        You are a data reference assistant that helps users understand their blood test report data by comparing values to published reference ranges. You do NOT provide medical diagnosis, treatment advice, or health assessments. You only compare data points to reference ranges and note which values fall inside or outside those ranges.

        User Profile: Age \(userProfile.age), Gender \(userProfile.gender.rawValue)

        Blood Test Results:
        \(biomarkerSummary)

        Provide your analysis as JSON with these fields:
        - summary: A 2-3 sentence overview of which values are within or outside reference ranges (pure data comparison, no health assessment)
        - keyFindings: Array of 3-5 data observations (e.g., "Vitamin D at 28 ng/mL is below the reference range of 30-100 ng/mL")
        - correlations: Array of 2-3 observations about related markers (e.g., "Ferritin and Iron values show a pattern — discuss with your healthcare provider")
        - topicsToDiscuss: Array of 3-5 general wellness topics the user might want to bring up with their healthcare provider (always phrase as "Discuss [topic] with your healthcare provider")
        - suggestedNextSteps: Array of 2-3 non-medical next steps (e.g., "Share these results with your healthcare provider for professional interpretation")

        IMPORTANT RULES:
        - NEVER use words like "diagnosis", "treatment", "condition", "disease", "symptom"
        - NEVER suggest specific medications, supplements, or dosages
        - ALWAYS recommend consulting a healthcare professional for interpretation
        - Focus on comparing numbers to reference ranges, not interpreting health implications
        - All suggestions must be framed as topics to discuss with a doctor

        Return ONLY valid JSON, no markdown.
        """

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a data reference assistant that compares blood test values to published reference ranges. You NEVER provide medical diagnosis, treatment advice, or health assessments. You ONLY compare data points to reference ranges. Always recommend consulting a healthcare professional. All suggestions must be framed as topics to discuss with a doctor."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 1500
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw AIError.requestFailed("HTTP \(statusCode)")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String ?? ""

        let cleanedContent = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let contentData = cleanedContent.data(using: .utf8) else {
            throw AIError.decodingFailed
        }

        do {
            var analysis = try JSONDecoder().decode(AIAnalysis.self, from: contentData)
            analysis = AIAnalysis(
                summary: analysis.summary,
                keyFindings: analysis.keyFindings,
                correlations: analysis.correlations,
                topicsToDiscuss: analysis.topicsToDiscuss,
                suggestedNextSteps: analysis.suggestedNextSteps,
                isAIGenerated: true
            )
            return analysis
        } catch {
            throw AIError.decodingFailed
        }
    }

    func fallbackAnalysis(biomarkers: [Biomarker], userProfile: UserProfile) -> AIAnalysis {
        let critical = biomarkers.filter { $0.status == .criticalLow || $0.status == .criticalHigh }
        let slightlyOff = biomarkers.filter { $0.status == .low || $0.status == .high }
        let normal = biomarkers.filter { $0.status == .normal }
        let optimal = biomarkers.filter { $0.status == .optimal }

        let summary: String
        if critical.isEmpty && slightlyOff.isEmpty {
            if !optimal.isEmpty {
                summary = "All \(biomarkers.count) biomarkers are within standard ranges, with \(optimal.count) within optimal ranges."
            } else {
                summary = "All \(biomarkers.count) biomarkers measured fall within standard reference ranges."
            }
        } else if !critical.isEmpty {
            summary = "Your blood test shows \(critical.count) biomarker(s) outside standard ranges and \(slightlyOff.count) slightly outside standard ranges. Please consult your healthcare provider to discuss these results."
        } else {
            summary = "Your blood test shows \(slightlyOff.count) biomarker(s) slightly outside standard ranges. All \(normal.count + optimal.count) other markers are within standard ranges."
        }

        var keyFindings: [String] = []

        for marker in critical {
            let direction = marker.status == .criticalHigh ? "significantly above reference range" : "significantly below reference range"
            keyFindings.append("\(marker.canonicalName) is \(direction) at \(marker.value) \(marker.unit) (reference: \(marker.referenceLow)-\(marker.referenceHigh))")
        }

        for marker in slightlyOff {
            let direction = marker.status == .high ? "slightly above optimal range" : "slightly below optimal range"
            keyFindings.append("\(marker.canonicalName) is \(direction) at \(marker.value) \(marker.unit) (optimal: \(marker.optimalLow)-\(marker.optimalHigh))")
        }

        if !optimal.isEmpty {
            keyFindings.append("\(optimal.count) biomarker(s) are within optimal range, including \(optimal.prefix(3).map(\.canonicalName).joined(separator: ", "))")
        }

        if keyFindings.isEmpty {
            keyFindings.append("All \(biomarkers.count) biomarkers are within standard reference ranges")
        }

        var correlations: [String] = []
        let ironRelated = biomarkers.filter { ["Ferritin", "Iron", "TIBC", "Transferrin Saturation"].contains($0.canonicalName) }
        if ironRelated.count >= 2 {
            let outOfRange = ironRelated.filter { $0.status != .normal && $0.status != .optimal }
            if !outOfRange.isEmpty {
                correlations.append("Iron-related markers (\(outOfRange.map(\.canonicalName).joined(separator: ", "))) are outside reference range — discuss with your healthcare provider")
            }
        }

        let inflammatory = biomarkers.filter { ["CRP", "ESR", "Homocysteine"].contains($0.canonicalName) && ($0.status == .high || $0.status == .criticalHigh) }
        if !inflammatory.isEmpty {
            correlations.append("Markers (\(inflammatory.map(\.canonicalName).joined(separator: ", "))) are outside standard ranges — discuss with your healthcare provider")
        }

        let metabolic = biomarkers.filter { ["Glucose", "HbA1c", "Insulin"].contains($0.canonicalName) && ($0.status != .normal && $0.status != .optimal) }
        if metabolic.count >= 2 {
            correlations.append("Multiple metabolic markers (\(metabolic.map(\.canonicalName).joined(separator: ", "))) are outside standard ranges — discuss with your healthcare provider")
        }

        if correlations.isEmpty {
            correlations.append("No obvious data patterns detected between out-of-range biomarkers based on standard reference ranges")
        }

        var topicsToDiscuss: [String] = []

        let vitaminD = biomarkers.first { $0.canonicalName == "Vitamin D" }
        if let vd = vitaminD, vd.status == .low || vd.status == .criticalLow {
            topicsToDiscuss.append("Discuss your Vitamin D results with your healthcare provider")
        }

        let b12 = biomarkers.first { $0.canonicalName == "Vitamin B12" }
        if let b = b12, b.status == .low || b.status == .criticalLow {
            topicsToDiscuss.append("Discuss your Vitamin B12 results with your healthcare provider")
        }

        if !ironRelated.filter({ $0.status == .low || $0.status == .criticalLow }).isEmpty {
            topicsToDiscuss.append("Discuss your iron-related results with your healthcare provider")
        }

        if !inflammatory.isEmpty {
            topicsToDiscuss.append("Discuss markers outside standard range with your healthcare provider")
        }

        if !metabolic.isEmpty {
            topicsToDiscuss.append("Discuss your metabolic panel results with your healthcare provider")
        }

        if topicsToDiscuss.isEmpty {
            topicsToDiscuss.append("Continue your current wellness routine and discuss with your healthcare provider at your next visit")
            topicsToDiscuss.append("Continue regular blood testing to track trends over time")
        }

        topicsToDiscuss.append("For deeper AI-powered data comparison with your OpenAI API key, go to Settings")

        var suggestedNextSteps: [String] = []

        if !critical.isEmpty {
            suggestedNextSteps.append("Share these results with your healthcare provider to discuss \(critical.map(\.canonicalName).joined(separator: ", "))")
        }

        if !slightlyOff.isEmpty {
            suggestedNextSteps.append("Consider tracking \(slightlyOff.map(\.canonicalName).joined(separator: ", ")) at your next blood test")
        }

        if suggestedNextSteps.isEmpty {
            suggestedNextSteps.append("Continue routine check-ups as recommended by your healthcare provider")
        }

        suggestedNextSteps.append("Add your OpenAI API key in Settings for AI-powered data comparison")

        return AIAnalysis(
            summary: summary,
            keyFindings: keyFindings,
            correlations: correlations,
            topicsToDiscuss: topicsToDiscuss,
            suggestedNextSteps: suggestedNextSteps,
            isAIGenerated: false
        )
    }
}
