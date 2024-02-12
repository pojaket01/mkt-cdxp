
public func Track(eventName:String, eventData: [String:String], completion: @escaping (Result<String, Error>)-> Void) {
    let endpoint = UserDefaults.standard.string(forKey: "endPoint")
    let projId = UserDefaults.standard.integer(forKey: "userProjectId")
    let cookie = UserDefaults.standard.string(forKey: "userCookie") ?? ""
    let hardId = UserDefaults.standard.string(forKey: "userHardId") ?? ""
    let secretKey = UserDefaults.standard.string(forKey: "secretKey")
    
    let endpointApi = "\(endpoint ?? "")/api/Track/\(projId)/customer/events"
    
    guard let url = URL(string: endpointApi) else {
        completion(.failure(InitialError.InvalidURL))
        return
    }
    
    let inData = [
        "device": getDevice(),
        "os": getOperatingSystem(),
        "browser": "",
        "www_location": getLocation(),
    ]
    
    let data = trackedEventModel(
        hardId: hardId,
        cookie: cookie,
        eventName: eventName,
        eventData: eventData,
        data: inData
    )
    
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(secretKey, forHTTPHeaderField: "secret-key")
    
    
    do {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(data)
        request.httpBody = jsonData
    } catch {
        completion(.failure(InitialError.InvalidFormat))
    }
    
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
            let decoded = try decoder.decode(Response.self, from: data).message
            completion(.success(decoded))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

internal struct trackedEventModel : Codable {
    var hardId: String
    var cookie: String
    var eventName: String
    var eventData: [String:String]
    var data: [String:String]
}
