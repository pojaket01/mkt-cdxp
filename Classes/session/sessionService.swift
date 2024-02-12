import Foundation

internal func intervalUpdateSession() {
    print("Start interval")
    Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { timer in
        do{
            try updateSessionStart()
        }catch{
            print("Error in updateSessionStart: \(error)")
        }
    }
}

internal func updateSessionStart() throws {
    print("start update session")
    let endpoint = UserDefaults.standard.string(forKey: "endPoint")
    let projId = UserDefaults.standard.integer(forKey: "userProjectId")
    let secretKey = UserDefaults.standard.string(forKey: "secretKey")
    
    let endpointApi = "\(endpoint ?? "")/api/Track/\(projId)/update-session"
    guard let url = URL(string: endpointApi) else {
        throw InitialError.InvalidURL
    }
    
    if let storedData = UserDefaults.standard.data(forKey: "userInitial") {
        do {
            let initialData = try JSONDecoder().decode(ResponseInitializeData.self, from: storedData)
            
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            print("cookie : \(initialData.cookie) date: \(currentDate)")
            
            var data = InitializeData(
                hardId: initialData.hardId,
                referrer: initialData.referrer,
                cookie: initialData.cookie,
                eventTime: currentDate,
                projId: initialData.projId,
                data: initialData.data,
                session: SessionData(
                    sessionId: initialData.session.sessionId,
                    sessionStart: nil,
                    sessionLast: nil
                ),
                auto: initialData.auto,
                visit: initialData.visit
            )
            
            if let sessionStart = dateFormatter.date(from: initialData.session.sessionStart),
               let sessionLast = dateFormatter.date(from: initialData.session.sessionLast){
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
                throw InitialError.InvalidFormat
            }
            
            let session = URLSession.shared
            
            
            let task = session.dataTask(with: request) { data, _, error in
                if let error = error {
                    print("Something went wrong: \(error.localizedDescription)")
                    print(error)
                    return
                }
                
                
                guard let data = data else {
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    _ = try decoder.decode(Response.self, from: data).message
                    UserDefaults.standard.set(currentDate, forKey: "lastPingTime")
                } catch {
                    
                }
                
            }
            
            task.resume()
        } catch {
            print("Error decoding object: \(error)")
        }
    }
}

