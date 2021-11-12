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
    func saveVaccineVard(vaccineQR: String, name: String, birthdate: String, userId: String, phn: String? = nil, federalPass: String? = nil, vaxDates: [String]? = nil) -> Bool {
        guard let context = managedContext, let user = fetchUser(id: userId) else {return false}
        let sortOrder = Int64(fetchVaccineCards(for: userId).count)
        let card = VaccineCard(context: context)
        card.code = vaccineQR
        card.name = name
        card.user = user
        card.birthdate = birthdate
        card.federalPass = federalPass
        card.vaxDates = vaxDates
        card.phn = phn
        card.sortOrder = sortOrder
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
            var cards = try context.fetch(VaccineCard.createFetchRequest())
            guard let item = cards.filter({$0.code == code}).first else {return}
            // Delete from core data
            context.delete(item)
            // Filter cards with the same use and sort by sort order
            cards = cards.filter({$0.user?.userId == item.user?.userId}).sorted {
                $0.sortOrder < $1.sortOrder
            }
            // Remove card at index
            cards.removeAll { card in
                card.code == code
            }
            // update sort order based on array index
            for (index, card) in cards.enumerated() {
                card.sortOrder = Int64(index)
            }
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
            var cards = try context.fetch(VaccineCard.createFetchRequest())
            guard let cardToMove = cards.filter({$0.code == code}).first else {return}
            // Filter cards that have the same user id and sort by sort order
            cards = cards.filter({$0.user?.userId == cardToMove.user?.userId}).sorted {
                $0.sortOrder < $1.sortOrder
            }
            // Move card in array
            cards.move(cardToMove, to: newPosition)
            // Loop and update card sort orders based on array index
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
            card.vaxDates = model.vaxDates
            card.federalPass = model.fedCode
            card.phn = model.phn
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
        // TODO: Will need to get vax dates from the processed result and add to model below
        BCVaccineValidator.shared.validate(code: code) { result in
            let model = result.toLocal(federalPass: cardToProcess.federalPass ?? "", phn: cardToProcess.phn ?? "")
            processedCards.append(AppVaccinePassportModel(codableModel: model))
            self.recursivelyProcessStored(cards: remainingCards, processed: processedCards, completion: completion)
        }
    }
}
