//
//  Main.swift
//  MKT
//
//  Created by Anumart Chaichana on 12/2/2567 BE.
//
//pod  - ERROR | [iOS] unknown: Encountered an unknown error (Pod::DSLError) during validation.
import Foundation

public func SystemTime(completion:  @escaping (Result<String, Error>) -> Void) {
    let endpoint = UserDefaults.standard.string(forKey: "endPoint")
    let secretKey = UserDefaults.standard.string(forKey: "secretKey")
    
    let endpointApi = "\(endpoint ?? "")/api/Track/system-time"
    
    guard let url = URL(string: endpointApi) else {
        completion(.failure(InitialError.InvalidURL))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(secretKey, forHTTPHeaderField: "secret-key")
    
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NetworkError.emptyResponseData))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ResponseSystemTime.self, from: data)
            completion(.success(decoded.dateTime))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

internal struct ResponseSystemTime : Codable {
    let dateTime: String
}

internal enum InitialError: Error {
    case InvalidURL
    case InvaidResponse
    case InvalidFormat
    case Failure
}

internal enum NetworkError: Error {
    case emptyResponseData
    case invalidURL
    // Add more cases as needed
}

internal struct Response: Codable {
    let message: String
}
