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
    private var onPatientFetch: [(()->Void)] = []
    
    func listen() {
        NotificationCenter.default.addObserver(self, selector: #selector(authStatusChanged), name: .authStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(patientAPIFetched), name: .patientAPIFetched, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storageChangeEvent), name: .storageChangeEvent, object: nil)
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
    
    func listenToStorage(change: @escaping(_ event: StorageService.StorageEvent<Any>)->Void) {
        onStorageChage.append(change)
    }
    
    func listenToAuth(change: @escaping(_ authenticated: Bool)->Void) {
        onAuthChange.append(change)
    }
    
    func listenToPatient(fetch: @escaping()->Void) {
        onPatientFetch.append(fetch)
    }
}
