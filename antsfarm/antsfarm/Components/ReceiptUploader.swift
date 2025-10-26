import Foundation
import UIKit

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
