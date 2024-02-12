import Foundation


public func MKTInitializeApp() throws {
    var initModel: InitializeModel = InitializeModel(secretKey: "", projId: nil, endPoint: "", track: nil, auto: false, visit: false)
    
    if let config = readConfig(){
        guard config.mktProject != 0 else { fatalError("Project Id is required.") }
        guard !config.mktSecretKey.isEmpty else { fatalError("Secret key is required") }
        guard !config.mktServer.isEmpty else { fatalError("Endpoint is required") }
        initModel.projId = config.mktProject
        initModel.secretKey = config.mktSecretKey
        initModel.endPoint = config.mktServer
        initModel.track?.auto = config.mktTrack.auto
        initModel.track?.visit = config.mktTrack.visit
        initModel.auto = config.mktTrack.auto
        initModel.visit = config.mktTrack.visit
        
        if !config.mktTrack.defaultProperties!.isEmpty {
            initModel.track?.defaultProperties = config.mktTrack.defaultProperties
        }
        
    } else {
        fatalError("Not Found mkt-config.json file")
    }
    
    UserDefaults.standard.set(initModel.secretKey, forKey: "secretKey")
    UserDefaults.standard.set(initModel.endPoint, forKey: "endPoint")
    let projId = "\(initModel.projId ?? 0)"
    
    let endpoint = "\(initModel.endPoint)/api/Track/\(projId)/initialize"
    
    guard let url = URL(string: endpoint) else {
        fatalError("Invalid URL")
    }
    
    let referer = getReferrer()
    let location = getLocation()
    let currentDate = Date()
    
    var inData = [
        "device": getDevice(),
        "os": getOperatingSystem(),
        "browser": "",
        "www_location": location
    ]
    
    let track = initModel.track
    if let defaultProperties = track?.defaultProperties {
        for (key, value) in defaultProperties {
            inData[key] = value as String
        }
    }
    
    
    var default_hardId = ""
    
    if let hardId = UserDefaults.standard.string(forKey: "userHardId"), !hardId.isEmpty {
        default_hardId = hardId
    } else {
        default_hardId = ""
    }
    
    let default_cookie = UserDefaults.standard.string(forKey: "userCookie") ?? ""
    
    let default_sessionId = UserDefaults.standard.string(forKey: "sessionId") ?? ""
    
    let default_sessionStart = UserDefaults.standard.string(forKey: "startSession") ?? ""
    
    let default_sessionLast = UserDefaults.standard.string(forKey: "lastPingTime") ?? ""
    
    var data = InitializeData(
        hardId: default_hardId,
        referrer: referer,
        cookie: default_cookie,
        eventTime: currentDate,
        projId: initModel.projId,
        data: inData,
        session: SessionData(
            sessionId: default_sessionId,
            sessionStart: nil,
            sessionLast: nil
        ),
        auto: initModel.track?.auto ?? false,
        visit: initModel.track?.visit ?? false
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
    request.setValue(initModel.secretKey, forHTTPHeaderField: "secret-key")
    
    do {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(data)
        request.httpBody = jsonData
    } catch {
        fatalError("Invalid Format")
    }
    
    let session = URLSession.shared
    
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Something went wrong: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            print("Response data is empty.")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            
            let result = try decoder.decode(ResponseInitializeData.self, from: data)
            UserDefaults.standard.set(result.hardId, forKey: "userHardId")
            UserDefaults.standard.set(result.projId, forKey: "userProjectId")
            UserDefaults.standard.set(result.cookie, forKey: "userCookie")
            UserDefaults.standard.set(result.session.sessionId, forKey: "sessionId")
            
            do {
                let encodedData = try JSONEncoder().encode(result)
                UserDefaults.standard.set(encodedData, forKey: "userInitial")
            } catch {
                print("Error encoding object: \(error)")
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            if let sessionStart = dateFormatter.date(from: result.session.sessionStart), let sessionLast = dateFormatter.date(from: result.session.sessionLast) {
                UserDefaults.standard.set(sessionStart, forKey: "startSession")
                UserDefaults.standard.set(sessionLast, forKey: "lastPingTime")
                
                if (result.auto) {
                    try? updateSessionStart()
                }
            }
        } catch {
            print("Failed to convert: \(error.localizedDescription)")
            print(error)
        }
    }
    task.resume()
    if ((initModel.auto) != nil){
        intervalUpdateSession()
    }
}

internal struct InitializeModel: Codable {
    var secretKey:String
    var projId:Int64?
    var endPoint:String
    var track: InitializeTrackModel?
    var auto:Bool?
    var visit:Bool?
}

internal struct InitializeData : Codable {
    let hardId: String
    let referrer: String
    let cookie: String
    let eventTime: Date?
    let projId: Int64?
    let data: [String:String]
    var session: SessionData
    var auto: Bool
    var visit: Bool
}

internal struct SessionData : Codable {
    var sessionId: String
    var sessionStart: Date?
    var sessionLast: Date?
}

struct ResponseInitializeData : Codable {
    let hardId: String
    let referrer: String
    let cookie: String
    let eventTime: String
    let projId: Int64?
    let data: [String:String]
    let session: ResponseSessionData
    let auto: Bool
    let visit: Bool
}

struct ResponseSessionData : Codable {
    let sessionId: String
    let sessionStart: String
    let sessionLast: String
}
