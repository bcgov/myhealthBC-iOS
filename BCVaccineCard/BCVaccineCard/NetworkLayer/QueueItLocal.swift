//
//  RemoteRequestAccessor.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2021-10-10.
import Foundation

class QueueItLocal {
    
    static func saveValueToDefaults(customerID: String? = nil, eventAlias: String? = nil, queueitToken: String? = nil, cookieHeader: [String: String]? = nil) {
        if let customerID = customerID {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.customerID = customerID
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: customerID, eventAlias: nil, queueitToken: nil, cookieHeader: nil)
            }
        }
        if let eventAlias = eventAlias {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.eventAlias = eventAlias
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: nil, eventAlias: eventAlias, queueitToken: nil, cookieHeader: nil)
            }
        }
        if let queueitToken = queueitToken {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.queueitToken = queueitToken
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: nil, eventAlias: nil, queueitToken: queueitToken, cookieHeader: nil)
            }
        }
        if let cookieHeader = cookieHeader {
            if let _ = Defaults.cachedQueueItObject {
                Defaults.cachedQueueItObject?.cookieHeader = cookieHeader
            } else {
                Defaults.cachedQueueItObject = QueueItCachedObject(customerID: customerID, eventAlias: nil, queueitToken: nil, cookieHeader: cookieHeader)
            }
        }
    }
    
    static func fetchValueFromDefaults() -> QueueItCachedObject? {
        guard let cached = Defaults.cachedQueueItObject else { return nil }
        return cached
    }
    
    static func reset() {
        Defaults.cachedQueueItObject = nil
    }
}
