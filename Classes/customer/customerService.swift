import Foundation

public func Identify(customerId:String, customerData:[String:String], completion: @escaping (Result<String, Error>)-> Void) {
    let endpoint = UserDefaults.standard.string(forKey: "endPoint")
    let projId = UserDefaults.standard.integer(forKey: "userProjectId")
    let secretKey = UserDefaults.standard.string(forKey: "secretKey") ?? ""
    
    let endpointApi = "\(endpoint ?? "")/api/Track/\(projId)/customer/identify"
    
    
    
    guard let url = URL(string: endpointApi) else {
        completion(.failure(InitialError.InvalidURL))
        return
    }
    
    let referer = getReferrer()
    let currentDate = Date()
    
    
    var default_hardId = ""
    
    if let hardId = UserDefaults.standard.string(forKey: "userHardId"), !hardId.isEmpty {
        default_hardId = hardId
    } else {
        default_hardId = customerId
    }
    
    let default_cookie = UserDefaults.standard.string(forKey: "userCookie") ?? ""
    
    let default_sessionId = UserDefaults.standard.string(forKey: "sessionId") ?? ""
    
    let default_sessionStart = UserDefaults.standard.string(forKey: "startSession") ?? ""
    
    let default_sessionLast = UserDefaults.standard.string(forKey: "lastPingTime") ?? ""
    
    var data = identifyModel(
        referrer: referer,
        cookie: default_cookie,
        hardId: default_hardId,
        eventTime: currentDate,
        session: SessionData(
            sessionId: default_sessionId,
            sessionStart: nil,
            sessionLast: nil
            
        ),
        customerData: customerData
    )
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    if let sessionStart = dateFormatter.date(from: default_sessionStart), let sessionLast = dateFormatter.date(from: default_sessionLast) {
        data.session.sessionStart = sessionStart
        data.session.sessionLast = sessionLast
    }
    
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
            let decoded = try decoder.decode(String.self, from: data)
            completion(.success(decoded))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

public func UpdateCustomer(customerId:String, customerData:[String:String], completion: @escaping (Result<[[String: String]], Error>)-> Void) {
    let endpoint = UserDefaults.standard.string(forKey: "endPoint")
    let projId = UserDefaults.standard.integer(forKey: "userProjectId")
    let secretKey = UserDefaults.standard.string(forKey: "secretKey") ?? ""
    
    
    let endpointApi = "\(endpoint ?? "")/api/Track/\(projId)/customer"
    
    
    
    guard let url = URL(string: endpointApi) else {
        completion(.failure(InitialError.InvalidURL))
        return
    }
    
    let referer = getReferrer()
    let currentDate = Date()
    
    let default_hardId = customerId
    
    let default_cookie = UserDefaults.standard.string(forKey: "userCookie") ?? ""
    
    let default_sessionId = UserDefaults.standard.string(forKey: "sessionId") ?? ""
    
    let default_sessionStart = UserDefaults.standard.string(forKey: "startSession") ?? ""
    
    let default_sessionLast = UserDefaults.standard.string(forKey: "lastPingTime") ?? ""
    
    if let storedData = UserDefaults.standard.data(forKey: "userInitial") {
        do{
            
            let initialData = try JSONDecoder().decode(ResponseInitializeData.self, from: storedData)
            
            var data = updateCustomerModel(
                referrer: referer,
                cookie: default_cookie,
                hardId: default_hardId,
                eventTime: currentDate,
                session: SessionData(
                    sessionId: default_sessionId,
                    sessionStart: nil,
                    sessionLast: nil
                    
                ),
                data: initialData.data,
                customerData: customerData
            )
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            if let sessionStart = dateFormatter.date(from: default_sessionStart), let sessionLast = dateFormatter.date(from: default_sessionLast) {
                data.session.sessionStart = sessionStart
                data.session.sessionLast = sessionLast
            }
            
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
                    let decoded = try decoder.decode([[String: String]].self, from: data)
                    UserDefaults.standard.set(customerId, forKey: "userHardId")
                    
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

public func Anonymous(completion: @escaping (Result<String, Error>)-> Void) {
    let endpoint = UserDefaults.standard.string(forKey: "endPoint")
    let projId = UserDefaults.standard.integer(forKey: "userProjectId")
    let secretKey = UserDefaults.standard.string(forKey: "secretKey") ?? ""
    
    
    let endpointApi = "\(endpoint ?? "")/api/Track/\(projId)/anonymous"
    
    
    
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
                
                guard data != nil else {
                    completion(.failure(NetworkError.emptyResponseData))
                    return
                }
                
                do {
                    UserDefaults.standard.removeObject(forKey: "userHardId")
                    UserDefaults.standard.removeObject(forKey: "userProjectId")
                    UserDefaults.standard.removeObject(forKey: "userCookie")
                    UserDefaults.standard.removeObject(forKey: "sessionId")
                    UserDefaults.standard.removeObject(forKey: "startSession")
                    UserDefaults.standard.removeObject(forKey: "lastPingTime")
                    UserDefaults.standard.removeObject(forKey: "userInitial")
                    
                    
                    try MKTInitializeApp()
                    
                    completion(.success("success"))
                } catch {
                    print(error)
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


internal struct identify : Codable {
    var hardId: String
    var customerData: [String:String]
}

internal struct identifyModel : Codable {
    var referrer: String
    var cookie: String
    var hardId: String
    var eventTime: Date
    var session: SessionData
    var customerData: [String:String]
}

internal struct updateCustomer : Codable {
    var hardId: String
    var customerData: [String:String]
}

internal struct updateCustomerModel : Codable {
    var referrer: String
    var cookie: String
    var hardId: String
    var eventTime: Date
    var session: SessionData
    var data: [String: String]
    var customerData: [String: String]
}
