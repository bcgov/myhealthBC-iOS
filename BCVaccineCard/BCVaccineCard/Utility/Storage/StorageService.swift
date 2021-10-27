//
//  StorageService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-22.
//

import Foundation
import CoreData
import UIKit
import BCVaccineValidator

//private enum Entities: String {
//    case User = "User"
//    case VaccineCard = "VaccineCard"
//}

private enum VaccineCardKey: String {
    case code = "code"
}

class StorageService {
    
    public static let shared = StorageService()
    
    fileprivate var managedContext: NSManagedObjectContext?

    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        managedContext = appDelegate.persistentContainer.viewContext
        
        // TODO: Refactor when authentication is added
        createUserIfneeded()
    }
    
    func createUserIfneeded() {
        // TODO: add appropriate name when authentication is added
        if fetchUser(id: AuthManager().userId()) == nil {
            _ = saveUser(id: AuthManager().userId(), name: AuthManager().userId())
        }
    }
    
    
    ///  Save a new user with user id and user name
    /// - Parameters:
    ///   - id: Unique user id
    ///   - name: user's name
    /// - Returns: boolean indicating success or failure
    func saveUser(id: String, name: String) -> Bool {
        guard let context = managedContext else {return false}
        let user = User(context: context)
        user.id = id
        user.name = name
        do {
            try context.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /// Fetch a user by user id
    /// - Parameter id: user id
    /// - Returns: user
    func fetchUser(id: String) -> User? {
        guard let context = managedContext else {return nil}
        do {
            let users = try context.fetch(User.createFetchRequest())
            guard let filtered = users.filter({$0.userId == id}).first else {return nil}
            return filtered
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    /// Store a vaccine card for a given user id
    /// - Parameters:
    ///   - vaccineQR: Vaccine card code
    ///   - name: card holder name: NOT the name of the user storing data
    ///   - userId: User id under which this card is to be stored
    /// - Returns: boolean indicating success or failure
    func saveVaccineVard(vaccineQR: String, name: String, userId: String) -> Bool {
        guard let context = managedContext, let user = fetchUser(id: userId) else {return false}
        let card = VaccineCard(context: context)
        card.code = vaccineQR
        card.name = name
        card.user = user
        do {
            try context.save()
            return true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func deleteVaccineCard(vaccineQR code: String) {
        guard let context = managedContext else {return}
        do {
            let cards = try context.fetch(VaccineCard.createFetchRequest())
            guard let filtered = cards.filter({$0.code == code}).first else {return}
            context.delete(filtered)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
    }
    
    /// Fetch all Vaccine Cards stored for a user
    /// - Parameter user: user id
    /// - Returns: array of vaccine cards
    func fetchVaccineCards(for userId: String) -> [VaccineCard] {
        guard let context = managedContext else {return []}
        do {
            let users = try context.fetch(User.createFetchRequest())
            guard let current = users.filter({$0.userId == userId}).first else {return []}
            return current.vaccineCardArray
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    public func getVaccineCardsForCurrentUser(completion: @escaping([AppVaccinePassportModel]) -> Void) {
        let userId = AuthManager().userId()
        let cards = fetchVaccineCards(for: userId)
        let dispatchGroup = DispatchGroup()
        var models: [AppVaccinePassportModel] = []
        for vaxCard in cards where vaxCard.code != nil {
            dispatchGroup.enter()
            let code = vaxCard.code!
            BCVaccineValidator.shared.validate(code: code) { result in
                if let processed = result.result {
                    var status: VaccineStatus
                    switch processed.status {
                    case .Fully:
                        status = .fully
                    case .Partially:
                        status = .partially
                    case .None:
                        status = .notVaxed
                    }
                    let model = LocallyStoredVaccinePassportModel(code: code, birthdate: processed.birthdate, name: processed.name, issueDate: processed.issueDate, status: status, source: .imported)
                    models.append(AppVaccinePassportModel(codableModel: model))
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            return completion(models)
        }
    }
    
    public func storeVaccineCardsForCurrentUser(cards: [AppVaccinePassportModel]) {
        cards.forEach { card in
            let code = card.codableModel.code
            let name = card.codableModel.name
            let userId = AuthManager().userId()
            _ = StorageService.shared.saveVaccineVard(vaccineQR: code, name: name, userId: userId)
        }
    }
}
