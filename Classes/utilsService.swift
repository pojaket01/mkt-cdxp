internal func getReferrer() -> String {
    
    var referrer = "Unknow Referrer"
    
    
    if let urlScheme = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
        let urlTypes = urlScheme.first as? [String: Any],
        let urlSchemes = urlTypes["CFBundleURLSchemes"] as? [String],
        let firstScheme = urlSchemes.first {
        referrer = firstScheme
    }
    
    return referrer
}

internal func getLocation() -> String {
    var referrer = ""
    
    if #available(iOS 13.0, *) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let current = windowScene.windows.first?.rootViewController {
            if let vcName = NSStringFromClass(type(of: current)).components(separatedBy: ".").last {
                referrer = vcName
            }
        }
    } else {
        // Handle iOS versions earlier than 13.0 if needed
        // For example, use a different approach or provide a default value
    }
    
    return referrer
}

internal func getDevice() -> String {
    let current_device = UIDevice.current
    var device = "Unknow Device"
    
    if current_device.userInterfaceIdiom == .phone {
        device = current_device.name
    } else if current_device.userInterfaceIdiom == .pad {
        device = current_device.name
    } else if current_device.userInterfaceIdiom == .carPlay {
        device = current_device.name
    } else if current_device.userInterfaceIdiom == .tv {
        device = current_device.name
    } else if current_device.userInterfaceIdiom == .unspecified {
        device = current_device.name
    }
    
    return device
}

internal func getOperatingSystem() -> String {
    
    var os = "Unknown OS"
    let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
    
    let osVersionString = "\(operatingSystemVersion.majorVersion).\(operatingSystemVersion.minorVersion).\(operatingSystemVersion.patchVersion)"
            
    #if os(iOS)
            os = "iOS (\(osVersionString))"
    #elseif os(macOS)
            os = "macOS (\(osVersionString))"
    #elseif os(tvOS)
            os = "tvOS (\(osVersionString))"
    #elseif os(watchOS)
            os = "watchOS (\(osVersionString))"
    #elseif os(Linux)
            os = "Linux (\(osVersionString))"
    #elseif os(Windows)
            os = "Windows (\(osVersionString))"
    #else
            os = "Unknown OS"
    #endif
            
    return os
}

internal func readConfig() -> MKTAppConfig? {
    do {
        if let fileUrl = Bundle.main.url(forResource: "mkt-config", withExtension: "json") {
            let data = try Data(contentsOf: fileUrl)
            let decoder = JSONDecoder()
            let config = try decoder.decode(MKTAppConfig.self, from: data)
            return config
        } else {
            print("Config file not found.")
            return nil
        }
    } catch {
        print("Error decoding config file: \(error.localizedDescription)")
        print(error)
        return nil
    }
}

internal struct MKTAppConfig: Codable {
    let mktSecretKey: String
    let mktServer: String
    let mktProject: Int64
    let mktTrack: InitializeTrackModel
}

internal struct InitializeTrackModel: Codable {
    var auto:Bool?
    var visit:Bool?
    var defaultProperties: [String:String]?
}
