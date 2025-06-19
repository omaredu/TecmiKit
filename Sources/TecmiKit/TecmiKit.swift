//
//  TecmiKit.swift
//  TecmiKit
//
//  Created by Omar Sánchez on 18/06/25.
//

import Foundation

let ERROR_MESSAGE = "Ay! Mi cerebro anda loquillo. Creo que hay un problema."

public struct Chatbot {
    let llave: String
    let descripcion: String

    private let baseURL: String = "https://chat-api-wild-pine-498.fly.dev"
    private var chatId: UUID = UUID()

    public init(llave: String, descripcion: String) {
        self.llave = llave
        self.descripcion = descripcion
        guard checkHealth() else {
            fatalError(
                "El servidor no está disponible. Por favor, verifica la URL o el estado del servidor."
            )
        }
    }

    public mutating func reiniciar() {
        chatId = UUID()
    }

    public func enviarMensaje(_ mensaje: String) -> String {
        guard let url = URL(string: "\(baseURL)/chat") else {
            return "Invalid URL"
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(llave)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "message": mensaje,
            "system_prompt": descripcion,
            "chat_id": chatId.uuidString,
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error serializing JSON body")
            return ERROR_MESSAGE
        }

        request.httpBody = httpBody

        var result = ERROR_MESSAGE
        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: request) { data, _, error in
            defer { semaphore.signal() }

            if let error = error {
                print("Error making request: \(error)")
                return
            }

            guard let data = data else {
                print("No data in response")
                return
            }

            print("RAW:\n", String(data: data, encoding: .utf8) ?? "<non-UTF8>")

            do {
                let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
                result = decoded.answer
            } catch {
                print("Decode error: \(error)")
            }

        }.resume()

        semaphore.wait()
        return result
    }

    private func checkHealth() -> Bool {
        guard let url = URL(string: "\(baseURL)/health"),
            let data = try? Data(contentsOf: url),
            let response = String(data: data, encoding: .utf8)
        else {
            return false
        }

        return response == "OK"
    }
}
