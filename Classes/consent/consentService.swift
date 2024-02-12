public func Consent(completion: @escaping (Result<[[String: String]], Error>)  -> Void) {
    let endpoint = UserDefaults.standard.string(forKey: "endPoint")
    let projId = UserDefaults.standard.integer(forKey: "userProjectId")
    let secretKey = UserDefaults.standard.string(forKey: "secretKey") ?? ""
    
    
    let endpointApi = "\(endpoint ?? "")/api/Track/\(projId)/customer/consents"
    
    guard let url = URL(string: endpointApi) else {
        completion(.failure(InitialError.InvalidURL))
        return
    }
    
    if let storedData = UserDefaults.standard.data(forKey: "userInitial") {
        do{
            
            let initialData = try JSONDecoder().decode(ResponseInitializeData.self, from: storedData)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(secretKey, forHTTPHeaderField: "secret-key")
            
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                
                let jsonData = try encoder.encode(initialData)
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
                    let decoded = try decoder.decode([[String: String]].self, from: data)
                    
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
            
        }
        catch{
            completion(.failure(error))
        }
    }
    else{
        completion(.failure(InitialError.Failure))
    }
    
}
