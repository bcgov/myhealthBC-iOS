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
    func saveVaccineVard(vaccineQR: String, name: String, birthdate: String, userId: String) -> Bool {
        guard let context = managedContext, let user = fetchUser(id: userId) else {return false}
        let card = VaccineCard(context: context)
        card.code = vaccineQR
        card.name = name
        card.user = user
        card.birthdate = birthdate
        card.sortOrder = Int64(fetchVaccineCards(for: userId).count)
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
            guard let item = cards.filter({$0.code == code}).first else {return}
            context.delete(item)
            try context.save()
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
    
    func changeVaccineCardSortOrder(cardQR code: String, newPosition: Int) {
        guard let context = managedContext else {return}
        do {
            var cards = try context.fetch(VaccineCard.createFetchRequest()).sorted {
                $0.sortOrder < $1.sortOrder
            }
            guard let cardToMove = cards.filter({$0.code == code}).first else {return}
            cards.move(cardToMove, to: newPosition)
            for (index, card) in cards.enumerated() {
                card.sortOrder = Int64(index)
            }
            try context.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
    }
    
    func updateVaccineCard(newData model: LocallyStoredVaccinePassportModel) {
        guard let context = managedContext else {return}
        do {
            let cards = try context.fetch(VaccineCard.createFetchRequest())
            guard let card = cards.filter({$0.name == model.name && $0.birthdate == model.birthdate}).first else {return}
            card.code = model.code
            try context.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
    }
    
    public func getVaccineCardsForCurrentUser(completion: @escaping([AppVaccinePassportModel]) -> Void) {
        let userId = AuthManager().userId()
        let cards = fetchVaccineCards(for: userId)
        recursivelyProcessStored(cards: cards, processed: []) { processed in
            return completion(processed)
        }
    }
    
    private func recursivelyProcessStored(cards: [VaccineCard], processed: [AppVaccinePassportModel], completion: @escaping([AppVaccinePassportModel]) -> Void) {
        if cards.isEmpty {
            return completion(processed)
        }
        var processedCards = processed
        var remainingCards = cards
        guard let cardToProcess = remainingCards.popLast(),
              let code = cardToProcess.code else {
            return recursivelyProcessStored(cards: remainingCards, processed: processed, completion: completion)
        }
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
                processedCards.append(AppVaccinePassportModel(codableModel: model))
                self.recursivelyProcessStored(cards: remainingCards, processed: processedCards, completion: completion)
            }
        }
    }
}
