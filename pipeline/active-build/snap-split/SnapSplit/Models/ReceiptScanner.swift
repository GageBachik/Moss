import Vision
import UIKit

/// Handles OCR scanning of receipt images using iOS Vision framework
class ReceiptScanner {

    struct ScanResult {
        var items: [(name: String, price: Double)]
        var subtotal: Double?
        var tax: Double?
        var total: Double?
    }

    /// Perform OCR on a receipt image and extract line items
    static func scan(image: UIImage, completion: @escaping (ScanResult) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ScanResult(items: [], subtotal: nil, tax: nil, total: nil))
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    completion(ScanResult(items: [], subtotal: nil, tax: nil, total: nil))
                }
                return
            }

            let lines = observations.compactMap { observation -> String? in
                observation.topCandidates(1).first?.string
            }

            let result = parseReceiptLines(lines)
            DispatchQueue.main.async {
                completion(result)
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    /// Parse OCR text lines into structured receipt data
    private static func parseReceiptLines(_ lines: [String]) -> ScanResult {
        var items: [(name: String, price: Double)] = []
        var subtotal: Double?
        var tax: Double?
        var total: Double?

        // Price pattern: matches $X.XX or X.XX at end of line
        let pricePattern = #"\$?\s*(\d+\.\d{2})\s*$"#
        let priceRegex = try? NSRegularExpression(pattern: pricePattern)

        // Keywords that indicate non-item lines
        let subtotalKeywords = ["subtotal", "sub total", "sub-total"]
        let taxKeywords = ["tax", "sales tax", "hst", "gst"]
        let totalKeywords = ["total", "amount due", "balance"]
        let skipKeywords = ["thank", "visa", "mastercard", "amex", "change", "cash", "card", "receipt", "server", "table", "guest", "date", "time", "order"]

        for line in lines {
            let lower = line.lowercased().trimmingCharacters(in: .whitespaces)

            // Skip empty or irrelevant lines
            if lower.count < 3 { continue }
            if skipKeywords.contains(where: { lower.contains($0) }) { continue }

            // Try to extract a price from this line
            let range = NSRange(lower.startIndex..., in: lower)
            guard let match = priceRegex?.firstMatch(in: lower, range: range),
                  let priceRange = Range(match.range(at: 1), in: lower),
                  let price = Double(lower[priceRange]) else {
                continue
            }

            // Categorize the line
            if subtotalKeywords.contains(where: { lower.contains($0) }) {
                subtotal = price
            } else if taxKeywords.contains(where: { lower.contains($0) }) {
                tax = price
            } else if totalKeywords.contains(where: { lower.contains($0) }) {
                total = price
            } else {
                // This is a line item
                // Extract the item name (everything before the price)
                let nameEndIndex = line.range(of: #"\$?\s*\d+\.\d{2}\s*$"#, options: .regularExpression)?.lowerBound ?? line.endIndex
                let name = String(line[line.startIndex..<nameEndIndex])
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: CharacterSet(charactersIn: ".-"))
                    .trimmingCharacters(in: .whitespaces)

                if !name.isEmpty && price > 0 && price < 500 {
                    items.append((name: name, price: price))
                }
            }
        }

        // Infer subtotal if not found
        if subtotal == nil {
            subtotal = items.reduce(0) { $0 + $1.price }
        }

        return ScanResult(items: items, subtotal: subtotal, tax: tax, total: total)
    }
}
