import Foundation

actor AIAnalysisService {

    struct AIAnalysis: Codable {
        let summary: String
        let keyFindings: [String]
        let correlations: [String]
        let recommendations: [String]
        let actionItems: [String]
    }

    enum AIError: Error {
        case invalidAPIKey
        case requestFailed(String)
        case decodingFailed
        case noData
    }

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }

    func analyze(biomarkers: [Biomarker], userProfile: UserProfile) async throws -> AIAnalysis {
        guard !apiKey.isEmpty else {
            throw AIError.invalidAPIKey
        }

        let biomarkerSummary = biomarkers.map { marker in
            "\(marker.canonicalName): \(marker.value) \(marker.unit) (Status: \(marker.status.rawValue), Ref: \(marker.referenceLow)-\(marker.referenceHigh), Optimal: \(marker.optimalLow)-\(marker.optimalHigh))"
        }.joined(separator: "\n")

        let prompt = """
        You are a health data analyst. Analyze the following blood test results and provide insights in plain English. Do NOT provide medical diagnosis or treatment advice. This is for informational purposes only.

        User Profile: Age \(userProfile.age), Gender \(userProfile.gender.rawValue)

        Blood Test Results:
        \(biomarkerSummary)

        Provide your analysis as JSON with these fields:
        - summary: A 2-3 sentence plain English overview of the results
        - keyFindings: Array of 3-5 key findings, each as a short sentence
        - correlations: Array of 2-3 correlations between biomarkers (e.g., "Your ferritin and CRP suggest possible inflammation affecting iron storage")
        - recommendations: Array of 3-5 actionable lifestyle recommendations (diet, exercise, supplements to discuss with doctor)
        - actionItems: Array of 2-3 specific next steps (e.g., "Discuss Vitamin D supplementation with your healthcare provider")

        Return ONLY valid JSON, no markdown.
        """

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a health data analyst providing informational analysis of blood test results. Never provide medical diagnosis or treatment advice. Always recommend consulting a healthcare professional."],
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
            let analysis = try JSONDecoder().decode(AIAnalysis.self, from: contentData)
            return analysis
        } catch {
            throw AIError.decodingFailed
        }
    }
}
