//
//  StorageService+Notifications.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-05-26.
//

import Foundation

protocol NotificationStorage {
    func store(notifications: AuthenticatedNotificationResponse, for patient: Patient, completion: @escaping([GatewayNotification])->Void)
    func fetchNotifications() -> [GatewayNotification]
    func delete(notificationId: String)
}

extension StorageService: NotificationStorage {
    func fetchNotifications() -> [GatewayNotification] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(GatewayNotification.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not fetch. \(error), \(error.userInfo)", type: .storage)
            return []
        }
    }
    
    func delete(notificationId: String) {
        guard let context = managedContext else {return}
        guard let item = fetchNotifications().filter({$0.id == notificationId}).first else {return}
        delete(object: item)
        AppStates.shared.updatedNotifications()
    }
    
    func deleteNotifications() {
        deleteAllRecords(in: fetchNotifications())
        AppStates.shared.updatedNotifications()
    }
    
    func store(notifications: AuthenticatedNotificationResponse, for patient: Patient, completion: @escaping([GatewayNotification])->Void) {
        var storedObjects: [GatewayNotification] = []
        let group = DispatchGroup()
        for notification in notifications {
            group.enter()
            store(notification: notification, patient: patient) {storedObject in
                if let storedObject = storedObject {
                    storedObjects.append(storedObject)
                }
                group.leave()
            }
            
        }
        group.notify(queue: .main) {
            AppStates.shared.updatedNotifications()
            return completion(storedObjects)
        }
        
    }
    
    func store(
        notification: AuthenticatedNotificationResponseElement,
        patient: Patient,
        completion: @escaping(GatewayNotification?)->Void
    ) {
        delete(notificationId: notification.id)
        guard let context = managedContext else {
            return completion(nil)
        }
        let model = GatewayNotification(context: context)
        model.patient = patient
        model.id = notification.id
        model.categoryName = notification.categoryName
        model.displayText = notification.displayText
        model.actionURL = notification.actionURL
        model.actionType = notification.actionType?.rawValue
        model.scheduledDate = notification.scheduledDateTimeUTC?.getGatewayDate()
        do {
            try context.save()
            return completion(model)
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return completion(nil)
        }
    }
    
    
}
