import Foundation
import UIKit
import SwiftUI

// Helpers relacionados con Data / multipart y resize
fileprivate extension Data {
    mutating func appendString(_ string: String) {
        if let d = string.data(using: .utf8) {
            append(d)
        }
    }
}

public func resize(image: UIImage, maxDimension: CGFloat) -> UIImage {
    let maxSide = max(image.size.width, image.size.height)
    guard maxSide > maxDimension else { return image }
    let scale = maxDimension / maxSide
    let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let resized = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resized ?? image
}

/// Sube un recibo al endpoint especificado.
/// - Parameters:
///   - userId: id del usuario (campo form "user_id")
///   - image: UIImage a enviar
///   - serverURL: URL del endpoint (por ejemplo https://mi-backend/api/expenses/analyze)
///   - authToken: opcional Bearer token
/// - Returns: Diccionario resultante del JSON devuelto por el backend
public func uploadReceipt(userId: Int, image: UIImage, serverURL: URL, authToken: String? = nil) async throws -> [String: Any] {
    // 1) Prepara imagen (resize + jpeg)
    let resized = resize(image: image, maxDimension: 1600)
    guard let imageData = resized.jpegData(compressionQuality: 0.75) else {
        throw NSError(domain: "Upload", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen"])
    }

    // 2) Construir multipart body
    let boundary = "Boundary-\(UUID().uuidString)"
    var request = URLRequest(url: serverURL)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    if let token = authToken {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    var body = Data()
    // Campo user_id
    body.appendString("--\(boundary)\r\n")
    body.appendString("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n")
    body.appendString("\(userId)\r\n")

    // Campo image
    let filename = "receipt.jpg"
    let mimeType = "image/jpeg"
    body.appendString("--\(boundary)\r\n")
    body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
    body.appendString("Content-Type: \(mimeType)\r\n\r\n")
    body.append(imageData)
    body.appendString("\r\n")
    body.appendString("--\(boundary)--\r\n")

    // Debug prints
    print("➡️ Request URL: \(request.url?.absoluteString ?? "nil")")
    print("➡️ Request headers: \(request.allHTTPHeaderFields ?? [:])")
    print("➡️ Body size (bytes): \(body.count)")

    // 3) Upload (async)
    let (data, response) = try await URLSession.shared.upload(for: request, from: body)

    guard let http = response as? HTTPURLResponse else {
        throw NSError(domain: "Upload", code: 0, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
    }

    guard (200...299).contains(http.statusCode) else {
        let text = String(data: data, encoding: .utf8) ?? "<no body>"
        throw NSError(domain: "Upload", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(text)"])
    }

    // 4) Parsear JSON genérico
    let jsonAny = try JSONSerialization.jsonObject(with: data, options: [])
    if let dict = jsonAny as? [String: Any] {
        return dict
    } else {
        return ["result": jsonAny]
    }
}

/// Aplica el expense devuelto por el backend a las propiedades de GoalData (sumando el amount a la variable correspondiente).
/// - Parameters:
///   - resp: diccionario resultante del uploadReceipt (espera key "expense")
///   - goalData: instancia de GoalData (ObservableObject)
func applyExpenseToGoalData(from resp: [String: Any], goalData: GoalData) async {
    // Helper local para parsear amount en Double
    func parseAmount(_ any: Any?) -> Double? {
        if any == nil { return nil }
        if let d = any as? Double { return d }
        if let f = any as? Float { return Double(f) }
        if let i = any as? Int { return Double(i) }
        if let ns = any as? NSNumber { return ns.doubleValue }
        if let s = any as? String {
            let cleaned = s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
            return Double(cleaned)
        }
        return nil
    }

    guard let expenseAny = resp["expense"] else { return }
    guard let expense = expenseAny as? [String: Any] else { return }

    guard let amount = parseAmount(expense["amount"]), amount > 0 else {
        print("⚠️ No se pudo parsear amount del expense:", expense["amount"] ?? "nil")
        return
    }

    // Determinar category_id preferente
    var categoryId: Int? = nil
    if let cid = expense["category_id"] as? Int { categoryId = cid }
    else if let ns = expense["category_id"] as? NSNumber { categoryId = ns.intValue }
    else if let s = expense["category_id"] as? String, let intVal = Int(s) { categoryId = intVal }

    // Determinar category_name en minúsculas como fallback
    var categoryName: String? = nil
    if let cname = expense["category_name"] as? String { categoryName = cname.lowercased() }

    await MainActor.run {
        switch categoryId {
        case 1:
            goalData.foodAmt += amount
            print("✅ Added \(amount) to foodAmt -> now \(goalData.foodAmt)")
        case 2:
            goalData.drinkAmt += amount
            print("✅ Added \(amount) to drinkAmt -> now \(goalData.drinkAmt)")
        case 3:
            goalData.subsAmt += amount
            print("✅ Added \(amount) to subsAmt -> now \(goalData.subsAmt)")
        case 4:
            goalData.smallPayAmt += amount
            print("✅ Added \(amount) to smallPayAmt -> now \(goalData.smallPayAmt)")
        case 5:
            goalData.transportAmt += amount
            print("✅ Added \(amount) to transportAmt -> now \(goalData.transportAmt)")
        case 6:
            goalData.otherAmt += amount
            print("✅ Added \(amount) to otherAmt -> now \(goalData.otherAmt)")
        default:
            // Fallback por category_name si no vino id
            if let name = categoryName {
                if name.contains("food") {
                    goalData.foodAmt += amount
                    print("✅ (by name) Added \(amount) to foodAmt -> now \(goalData.foodAmt)")
                } else if name.contains("drink") {
                    goalData.drinkAmt += amount
                    print("✅ (by name) Added \(amount) to drinkAmt -> now \(goalData.drinkAmt)")
                } else if name.contains("subs") || name.contains("subscription") {
                    goalData.subsAmt += amount
                    print("✅ (by name) Added \(amount) to subsAmt -> now \(goalData.subsAmt)")
                } else if name.contains("small") || name.contains("tip") || name.contains("payment") {
                    goalData.smallPayAmt += amount
                    print("✅ (by name) Added \(amount) to smallPayAmt -> now \(goalData.smallPayAmt)")
                } else if name.contains("transport") || name.contains("uber") || name.contains("gas") {
                    goalData.transportAmt += amount
                    print("✅ (by name) Added \(amount) to transportAmt -> now \(goalData.transportAmt)")
                } else {
                    goalData.otherAmt += amount
                    print("✅ (by name fallback) Added \(amount) to otherAmt -> now \(goalData.otherAmt)")
                }
            } else {
                goalData.otherAmt += amount
                print("⚠️ Sin categoría identificada: Added \(amount) to otherAmt -> now \(goalData.otherAmt)")
            }
        }
    }
}
