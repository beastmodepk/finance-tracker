import SwiftUI
import UIKit
import Vision

/// What the receipt parser managed to pull out of a photo. Everything
/// is a suggestion — the Add Transaction sheet is prefilled with it and
/// the user confirms/edits before anything is saved.
struct ReceiptDraft {
    var merchant: String = ""
    var total: Double? = nil
    var date: Date? = nil
}

/// On-device receipt OCR (Vision) + a small heuristic parser.
/// Nothing leaves the phone.
enum ReceiptScanner {
    static func recognize(_ image: UIImage, completion: @escaping (ReceiptDraft?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        let request = VNRecognizeTextRequest { request, _ in
            let lines = (request.results as? [VNRecognizedTextObservation] ?? [])
                .compactMap { $0.topCandidates(1).first?.string }
            let draft = parse(lines: lines)
            DispatchQueue.main.async { completion(draft) }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    // MARK: - Parsing (pure, deterministic)

    private static let amountRegex = try? NSRegularExpression(
        pattern: #"([0-9]{1,3}(?:,[0-9]{3})*\.[0-9]{2}|[0-9]+\.[0-9]{2})"#)
    private static let dateRegex = try? NSRegularExpression(
        pattern: #"(0?[1-9]|1[0-2])/(0?[1-9]|[12][0-9]|3[01])/([0-9]{4}|[0-9]{2})"#)

    static func amounts(in line: String) -> [Double] {
        guard let regex = amountRegex else { return [] }
        let range = NSRange(line.startIndex..., in: line)
        return regex.matches(in: line, range: range).compactMap { match in
            guard let r = Range(match.range(at: 1), in: line) else { return nil }
            return Double(line[r].replacingOccurrences(of: ",", with: ""))
        }
    }

    static func parse(lines: [String]) -> ReceiptDraft {
        var draft = ReceiptDraft()

        // Merchant: first line with real letters and no money on it —
        // receipts put the store name at the top.
        for line in lines {
            let letters = line.filter { $0.isLetter }.count
            if letters >= 3 && amounts(in: line).isEmpty {
                draft.merchant = line.trimmingCharacters(in: .whitespaces)
                break
            }
        }

        // Total: prefer a "total" line that isn't a subtotal (take the
        // last one — the grand total comes after tax lines); otherwise
        // the largest amount anywhere on the receipt.
        var totalFromLabel: Double? = nil
        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()
            guard lower.contains("total"), !lower.contains("subtotal"), !lower.contains("sub-total") else { continue }
            if let amount = amounts(in: line).last {
                totalFromLabel = amount
            } else if index + 1 < lines.count, let amount = amounts(in: lines[index + 1]).first {
                totalFromLabel = amount
            }
        }
        draft.total = totalFromLabel ?? lines.flatMap { amounts(in: $0) }.max()

        // Date: first MM/DD/YY(YY) on the receipt.
        if let regex = dateRegex {
            outer: for line in lines {
                let range = NSRange(line.startIndex..., in: line)
                for match in regex.matches(in: line, range: range) {
                    guard let r = Range(match.range, in: line) else { continue }
                    let text = String(line[r])
                    for format in ["M/d/yyyy", "M/d/yy"] {
                        let formatter = DateFormatter()
                        formatter.dateFormat = format
                        if let date = formatter.date(from: text) {
                            draft.date = date
                            break outer
                        }
                    }
                }
            }
        }
        return draft
    }
}

/// Minimal camera wrapper (the simulator has no camera; the caller
/// checks `UIImagePickerController.isSourceTypeAvailable(.camera)`).
struct CameraPicker: UIViewControllerRepresentable {
    var onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImage(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
