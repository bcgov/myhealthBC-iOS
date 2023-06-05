//
//  AppStates.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-10-21.
//

import Foundation

class AppStates {
    public static var shared = AppStates()
    private init() {}
    private var onAuthChange: [((_ authenticated: Bool)->Void)] = []
    private var onStorageChage: [((_ event: StorageService.StorageEvent<Any>)->Void)] = []
    private var onTermsOfServiceAgreementChange: [((_ accepted: Bool)->Void)] = []
    private var onPatientFetch: [(()->Void)] = []
    private var onLocalAuth: [(()->Void)] = []
    private var onShouldSync: [(()->Void)] = []
    private var onSyncPerformed: [(()->Void)] = []
    private var onNotificationsChange: [(()->Void)] = []
    
    func listen() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldSync), name: .shouldSync, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authStatusChanged), name: .authStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(patientAPIFetched), name: .patientAPIFetched, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storageChangeEvent), name: .storageChangeEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(performedAuth), name: .performedAuth, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncPerformed), name: .syncPerformed, object: nil)
    }
    
    @objc private func performedAuth(_ notification: Notification) {
        onLocalAuth.forEach({$0()})
    }
    
    /// Request data sync manually.
    public func requestSync() {
        NotificationCenter.default.post(name: .shouldSync, object: nil, userInfo: nil)
    }
    
    public func updatedTermsOfService(accepted: Bool) {
        onTermsOfServiceAgreementChange.forEach({$0(accepted)})
    }
    
    func updatedNotifications() {
        onNotificationsChange.forEach({$0()})
    }
    
    @objc private func shouldSync(_ notification: Notification) {
        onShouldSync.forEach({$0()})
    }
    
    @objc private func syncPerformed(_ notification: Notification) {
        onSyncPerformed.forEach({$0()})
    }
    
    @objc private func authStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Bool] else { return }
        guard let authenticated = userInfo[Constants.AuthStatusKey.key] else { return }
        onAuthChange.forEach({$0(authenticated)})
    }
    
    @objc private func storageChangeEvent(_ notification: Notification) {
        guard let event = notification.object as? StorageService.StorageEvent<Any> else {return}
        onStorageChage.forEach({$0(event)})
    }
    
    @objc private func patientAPIFetched(_ notification: Notification) {
        onPatientFetch.forEach({$0()})
    }
    
    func listenToNotificationChange(onChange: @escaping()->Void) {
        onNotificationsChange.append(onChange)
    }
    
    func listenToSyncRequest(onRequest: @escaping()->Void) {
        onShouldSync.append(onRequest)
    }
    
    func listenToSyncCompletion(onRequest: @escaping()->Void) {
        onSyncPerformed.append(onRequest)
    }
    
    func listenToStorage(change: @escaping(_ event: StorageService.StorageEvent<Any>)->Void) {
        onStorageChage.append(change)
    }
    
    func listenToAuth(change: @escaping(_ authenticated: Bool)->Void) {
        onAuthChange.append(change)
    }
    
    func listenToPatient(fetch: @escaping()->Void) {
        onPatientFetch.append(fetch)
    }
    
    func listenLocalAuth(success: @escaping()->Void) {
        onLocalAuth.append(success)
    }
    
    func listenToTermsOfServiceAgreement(change: @escaping(_ accepted: Bool)->Void) {
        onTermsOfServiceAgreementChange.append(change)
    }
}
