//
//  AnalyticsService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-19.
//

import Foundation
import SnowplowTracker

class AnalyticsService: NSObject, RequestCallback {
    public static let shared = AnalyticsService()
    
    fileprivate let endPoint = "spt.apps.gov.bc.ca"
    fileprivate let namespace = "iOS"
    fileprivate let schema = "iglu:ca.bc.gov.gateway/action/jsonschema/1-0-0"
    fileprivate let schema2 = "iglu:ca.bc.gov.gateway/action/jsonschema/2-0-0"
    
    fileprivate let userDefaultsKey = "analyticsEnabled"
    
    var isEnabled: Bool {
        return UserDefaults.standard.value(forKey: userDefaultsKey) as? Bool ?? false
    }
    
    var tracker : TrackerController?
    
    override init() {
        super.init()
    }
    
    public func setup() {
        if isEnabled {
            enable()
        } else {
            disable()
        }
    }
    
    public func enable() {
        if tracker == nil {
            tracker = initTracker(endPoint, method: .post)
        } else {
            tracker?.resume()
        }
        
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }
    
    public func disable() {
        tracker?.pause()
        UserDefaults.standard.set(false, forKey: userDefaultsKey)
    }
    
    /// Track an Action with a custom string. eg: a url
    /// - Parameters:
    ///   - action: AnalyticsAction enum describing the event
    ///   - text: String destribing the action
    public func track(action: AnalyticsAction, text: String) {
        let actionString = action.rawValue
        let event = SelfDescribing(schema: schema, payload: ["action": actionString as NSObject, "text": text as NSObject])
        tracker?.track(event)
    }
    
    /// Track an action with a pre-defined text in AnalyticsText
    /// - Parameters:
    ///   - action: AnalyticsAction enum describing the event
    ///   - text: AnalyticsText enum destribing the action
    public func track(action: AnalyticsAction, text: AnalyticsText) {
        let actionString = action.rawValue
        let actionTextString = text.rawValue
        let event = SelfDescribing(schema: schema, payload: ["action": actionString as NSObject, "text": actionTextString as NSObject])
        tracker?.track(event)
    }
    
    /// Track an action with a pre-defined text in AnalyticsText along with additional values
    /// - Parameters:
    ///   - action: AnalyticsAction enum describing the event
    ///   - text: AnalyticsText enum destribing the action
    ///   - additionalProperties: AnalyticsAdditionalProperties struct describing additional keys and values for the event
    public func track(action: AnalyticsAction, text: AnalyticsText, additionalProperties: [AnalyticsAdditionalProperties]) {
        let actionString = action.rawValue
        let actionTextString = text.rawValue
        var payload: [String: NSObject] = ["action": actionString as NSObject, "text": actionTextString as NSObject]
        for property in additionalProperties {
            payload[property.key.rawValue] = property.value.rawValue as NSObject
        }
        // NOTE: This will have to be reworked to support other schema's - using schema2 for now for BC Cancer
        let event = SelfDescribing(schema: schema2, payload: payload)
        tracker?.track(event)
    }
    
    /// Track an Action only
    /// - Parameter action: AnalyticsAction enum describing the event
    public func track(action: AnalyticsAction) {
        let actionString = action.rawValue
        let event = SelfDescribing(schema: schema, payload: ["action": actionString as NSObject])
        tracker?.track(event)
    }
    
    // Manual screen view tracking - not needed
    public func trackScreenView(name: String, screenId: UUID) {
        let event = ScreenView(name: name, screenId: screenId)
        tracker?.track(event)
    }
    
    fileprivate func initTracker(_ url: String, method: HttpMethodOptions) -> TrackerController {
        let eventStore = SQLiteEventStore(namespace: appID)
        let network = DefaultNetworkConnection.build { (builder) in
            builder.setUrlEndpoint(url)
            builder.setHttpMethod(method)
            builder.setEmitThreadPoolSize(20)
            builder.setByteLimitPost(52000)
        }
        let networkConfig = NetworkConfiguration(networkConnection: network)
        let trackerConfig = TrackerConfiguration()
            .base64Encoding(false)
            .sessionContext(true)
            .platformContext(true)
            .lifecycleAutotracking(true)
            .screenViewAutotracking(true)
            .screenContext(true)
            .applicationContext(true)
            .exceptionAutotracking(true)
            .installAutotracking(true)
            .diagnosticAutotracking(true)
            .logLevel(.verbose)
            .loggerDelegate(self)
            .appId(appID)
        
        let emitterConfig = EmitterConfiguration()
            .eventStore(eventStore)
            .emitRange(500)
            .requestCallback(self)
        
        let gdprConfig = GDPRConfiguration(basis: .consent, documentId: "id", documentVersion: "1.0", documentDescription: "description")
        
        
        let tracker = Snowplow.createTracker(namespace: namespace, network: networkConfig, configurations: [trackerConfig, emitterConfig, gdprConfig])
        
        return tracker
    }

}

extension AnalyticsService: LoggerDelegate {
    func error(_ tag: String, message: String) {
        Logger.log(string: "[Error] \(tag): \(message)", type: .Analytics)
    }
    
    func debug(_ tag: String, message: String) {
        Logger.log(string: "[Debug] \(tag): \(message)", type: .Analytics)
    }
    
    func verbose(_ tag: String, message: String) {
        Logger.log(string: "[Verbose] \(tag): \(message)", type: .Analytics)
    }
    
    func onSuccess(withCount successCount: Int) {
        Logger.log(string: "\(successCount)", type: .Analytics)
    }
    
    func onFailure(withCount failureCount: Int, successCount: Int) {
        Logger.log(string: "\(failureCount)", type: .Analytics)
    }
}

