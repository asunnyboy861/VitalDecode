import Foundation

struct BiomarkerParser {

    static func parse(from text: String) -> [OCRService.ExtractedBiomarker] {
        var results: [OCRService.ExtractedBiomarker] = []
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        let valuePattern = try? NSRegularExpression(
            pattern: #"([A-Za-z\s\-\(\)0-9]+?)\s+([\d]+\.?[\d]*)\s*([a-zA-Z/%μµ]+(?:/[a-zA-Z]+)?)?\s*(?:\(?\s*([\d]+\.?[\d]*\s*[-–—]\s*[\d]+\.?[\d]*)\s*\)?)?"#,
            options: .caseInsensitive
        )

        for line in lines {
            guard let regex = valuePattern else { continue }
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, options: [], range: range) else { continue }

            let nameStr = (line as NSString).substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
            let valueStr = (line as NSString).substring(with: match.range(at: 2))
            var unitStr = match.range(at: 3).location != NSNotFound ?
                (line as NSString).substring(with: match.range(at: 3)) : ""
            let refStr = match.range(at: 4).location != NSNotFound ?
                (line as NSString).substring(with: match.range(at: 4)) : nil

            unitStr = unitStr.replacingOccurrences(of: "uL", with: "\u{00B5}L")
                .replacingOccurrences(of: "ug", with: "\u{00B5}g")

            guard let definition = BiomarkerDefinitions.find(matching: nameStr) else { continue }
            guard Double(valueStr) != nil else { continue }

            let confidence: Float = refStr != nil ? 0.95 : 0.75

            results.append(OCRService.ExtractedBiomarker(
                name: definition.canonicalName,
                value: valueStr,
                unit: unitStr.isEmpty ? definition.unit : unitStr,
                referenceRange: refStr,
                confidence: confidence
            ))
        }

        var seen = Set<String>()
        results = results.filter { marker in
            if seen.contains(marker.name) { return false }
            seen.insert(marker.name)
            return true
        }

        return results
    }
}
