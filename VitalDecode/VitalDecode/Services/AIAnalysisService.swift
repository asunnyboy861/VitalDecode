import Foundation

actor AIAnalysisService {

    struct AIAnalysis: Codable {
        let summary: String
        let keyFindings: [String]
        let correlations: [String]
        let recommendations: [String]
        let actionItems: [String]
        let isAIGenerated: Bool

        init(summary: String, keyFindings: [String], correlations: [String], recommendations: [String], actionItems: [String], isAIGenerated: Bool = false) {
            self.summary = summary
            self.keyFindings = keyFindings
            self.correlations = correlations
            self.recommendations = recommendations
            self.actionItems = actionItems
            self.isAIGenerated = isAIGenerated
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            summary = try container.decode(String.self, forKey: .summary)
            keyFindings = try container.decode([String].self, forKey: .keyFindings)
            correlations = try container.decode([String].self, forKey: .correlations)
            recommendations = try container.decode([String].self, forKey: .recommendations)
            actionItems = try container.decode([String].self, forKey: .actionItems)
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
                return "An OpenAI API key is required for AI-powered analysis. Please enter your key in Settings, or use the built-in analysis instead."
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
        You are a data visualization assistant that helps users understand their blood test report data. Analyze the following blood test results and provide informational insights in plain English. Do NOT provide medical diagnosis or treatment advice. This is for informational purposes only.

        User Profile: Age \(userProfile.age), Gender \(userProfile.gender.rawValue)

        Blood Test Results:
        \(biomarkerSummary)

        Provide your analysis as JSON with these fields:
        - summary: A 2-3 sentence plain English overview of the results
        - keyFindings: Array of 3-5 key findings, each as a short sentence
        - correlations: Array of 2-3 correlations between biomarkers (e.g., "Ferritin and CRP values suggest a pattern worth discussing with your healthcare provider")
        - recommendations: Array of 3-5 general lifestyle topics to discuss with a healthcare provider (diet, exercise, supplements)
        - actionItems: Array of 2-3 specific next steps (e.g., "Discuss Vitamin D levels with your healthcare provider")

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
                ["role": "system", "content": "You are a data visualization assistant helping users understand their blood test report data. Never provide medical diagnosis or treatment advice. Always recommend consulting a healthcare professional. This is informational only."],
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
                recommendations: analysis.recommendations,
                actionItems: analysis.actionItems,
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
            let direction = marker.status == .criticalHigh ? "critically high" : "critically low"
            keyFindings.append("\(marker.canonicalName) is \(direction) at \(marker.value) \(marker.unit) (reference: \(marker.referenceLow)-\(marker.referenceHigh))")
        }

        for marker in slightlyOff {
            let direction = marker.status == .high ? "slightly elevated" : "slightly below optimal"
            keyFindings.append("\(marker.canonicalName) is \(direction) at \(marker.value) \(marker.unit) (optimal: \(marker.optimalLow)-\(marker.optimalHigh))")
        }

        if !optimal.isEmpty {
            keyFindings.append("\(optimal.count) biomarker(s) are at optimal levels, including \(optimal.prefix(3).map(\.canonicalName).joined(separator: ", "))")
        }

        if keyFindings.isEmpty {
            keyFindings.append("All \(biomarkers.count) biomarkers are within standard reference ranges")
        }

        var correlations: [String] = []
        let ironRelated = biomarkers.filter { ["Ferritin", "Iron", "TIBC", "Transferrin Saturation"].contains($0.canonicalName) }
        if ironRelated.count >= 2 {
            let outOfRange = ironRelated.filter { $0.status != .normal && $0.status != .optimal }
            if !outOfRange.isEmpty {
                correlations.append("Iron-related markers (\(outOfRange.map(\.canonicalName).joined(separator: ", "))) show patterns worth discussing with your healthcare provider")
            }
        }

        let inflammatory = biomarkers.filter { ["CRP", "ESR", "Homocysteine"].contains($0.canonicalName) && ($0.status == .high || $0.status == .criticalHigh) }
        if !inflammatory.isEmpty {
            correlations.append("Inflammatory marker(s) (\(inflammatory.map(\.canonicalName).joined(separator: ", "))) are outside standard ranges and may be related to other values")
        }

        let metabolic = biomarkers.filter { ["Glucose", "HbA1c", "Insulin"].contains($0.canonicalName) && ($0.status != .normal && $0.status != .optimal) }
        if metabolic.count >= 2 {
            correlations.append("Multiple metabolic markers (\(metabolic.map(\.canonicalName).joined(separator: ", "))) are outside standard ranges, which may indicate patterns worth discussing with your provider")
        }

        if correlations.isEmpty {
            correlations.append("No strong correlations detected between out-of-range biomarkers based on standard patterns")
        }

        var recommendations: [String] = []

        let vitaminD = biomarkers.first { $0.canonicalName == "Vitamin D" }
        if let vd = vitaminD, vd.status == .low || vd.status == .criticalLow {
            recommendations.append("Vitamin D is outside standard range — discuss with your healthcare provider")
        }

        let b12 = biomarkers.first { $0.canonicalName == "Vitamin B12" }
        if let b = b12, b.status == .low || b.status == .criticalLow {
            recommendations.append("Vitamin B12 is outside standard range — discuss with your healthcare provider")
        }

        if !ironRelated.filter({ $0.status == .low || $0.status == .criticalLow }).isEmpty {
            recommendations.append("Low iron markers detected — discuss with your provider before making dietary changes")
        }

        if !inflammatory.isEmpty {
            recommendations.append("Elevated inflammatory markers — discuss with your healthcare provider")
        }

        if !metabolic.isEmpty {
            recommendations.append("Metabolic markers outside standard range — discuss with your provider")
        }

        if recommendations.isEmpty {
            recommendations.append("Maintain your current healthy lifestyle with balanced nutrition and regular physical activity")
            recommendations.append("Continue regular blood testing to track trends over time")
        }

        recommendations.append("For deeper AI-powered analysis with personalized insights, add your OpenAI API key in Settings")

        var actionItems: [String] = []

        if !critical.isEmpty {
            actionItems.append("Schedule a follow-up with your healthcare provider to discuss \(critical.map(\.canonicalName).joined(separator: ", "))")
        }

        if !slightlyOff.isEmpty {
            actionItems.append("Monitor \(slightlyOff.map(\.canonicalName).joined(separator: ", ")) at your next blood test")
        }

        if actionItems.isEmpty {
            actionItems.append("Continue routine health check-ups as recommended by your healthcare provider")
        }

        actionItems.append("Add your OpenAI API key in Settings for AI-powered personalized analysis with deeper insights")

        return AIAnalysis(
            summary: summary,
            keyFindings: keyFindings,
            correlations: correlations,
            recommendations: recommendations,
            actionItems: actionItems,
            isAIGenerated: false
        )
    }
}
