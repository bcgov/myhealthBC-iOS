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
    
    var managedContext: NSManagedObjectContext?
    
    
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
    func saveVaccineVard(vaccineQR: String, name: String, birthdate: String, userId: String, hash: String, phn: String? = nil, federalPass: String? = nil, vaxDates: [String]? = nil) -> Bool {
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
        card.firHash = hash
        do {
            try context.save()
            storeImmunizaionRecords(card: card)
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
    
    func updateVaccineCard(newData model: LocallyStoredVaccinePassportModel, completion: @escaping(Bool)->Void) {
        guard let context = managedContext else {return}
        do {
            let cards = try context.fetch(VaccineCard.createFetchRequest())
            guard let card = cards.filter({$0.name == model.name && $0.birthdate == model.birthdate}).first else {return}
            card.code = model.code
            card.vaxDates = model.vaxDates
            card.federalPass = model.fedCode
            card.phn = model.phn
            card.firHash = model.hash
            try context.save()
            DispatchQueue.main.async {
                return completion(true)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            DispatchQueue.main.async {
                return completion(false)
            }
        }
    }
    
    func updateVaccineCardFedCode(newData model: LocallyStoredVaccinePassportModel, completion: @escaping(Bool)->Void) {
        guard let context = managedContext else {return}
        do {
            let cards = try context.fetch(VaccineCard.createFetchRequest())
            guard let card = cards.filter({$0.name == model.name && $0.birthdate == model.birthdate}).first else {return}
            card.federalPass = model.fedCode
            if card.phn == nil || card.phn?.count ?? 0 < 1 {
                card.phn = model.phn
            }
            try context.save()
            DispatchQueue.main.async {
                return completion(true)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            DispatchQueue.main.async {
                return completion(false)
            }
        }
    }
//
    public func getVaccineCardsForCurrentUser(completion: @escaping([AppVaccinePassportModel]) -> Void) {
        let userId = AuthManager().userId()
        let cards = fetchVaccineCards(for: userId)
        recursivelyProcessStored(cards: cards, processed: []) { processed in
            return completion(processed)
        }
    }
    
    // Note: This is used for health records flow
//    public func getVaccineCardsForNameWithCards(cards: [VaccineCard], completion: @escaping([HealthRecordsWrapperModelHack]) -> Void ) {
//        recursivelyProcessStoredForHealthRecords(cards: cards, processed: []) { processed in
//            return completion(processed)
//        }
//    }
//     TODO: We will need to refactor this - just adding duplicate function below for now
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
            if let model = result.toLocal(federalPass: cardToProcess.federalPass, phn: cardToProcess.phn) {
                processedCards.append(AppVaccinePassportModel(codableModel: model))
                self.recursivelyProcessStored(cards: remainingCards, processed: processedCards, completion: completion)
            } else {
                self.recursivelyProcessStored(cards: remainingCards, processed: processedCards, completion: completion)
            }
        }
    }
    
//    private func recursivelyProcessStoredForHealthRecords(cards: [VaccineCard], processed: [HealthRecordsWrapperModelHack], completion: @escaping([HealthRecordsWrapperModelHack]) -> Void) {
//        if cards.isEmpty {
//            return completion(processed)
//        }
//        var processedCards = processed
//        var remainingCards = cards
//        guard let cardToProcess = remainingCards.popLast(),
//              let code = cardToProcess.code else {
//                  return recursivelyProcessStoredForHealthRecords(cards: remainingCards, processed: processed, completion: completion)
//              }
//        // TODO: Will need to get vax dates from the processed result and add to model below
//        BCVaccineValidator.shared.validate(code: code) { result in
//            if let model = result.toLocal(federalPass: cardToProcess.federalPass, phn: cardToProcess.phn) {
//                let appVaxPassModel = AppVaccinePassportModel(codableModel: model)
//                let immunizations = cardToProcess.getCovidImmunizations()
//                let hackModel = HealthRecordsWrapperModelHack(appModel: appVaxPassModel, immunizationRecords: immunizations)
//                processedCards.append(hackModel)
//                self.recursivelyProcessStoredForHealthRecords(cards: remainingCards, processed: processedCards, completion: completion)
//            } else {
//                self.recursivelyProcessStoredForHealthRecords(cards: remainingCards, processed: processedCards, completion: completion)
//            }
//        }
//    }

    
    fileprivate func getState(of card: AppVaccinePassportModel, completion: @escaping(AppVaccinePassportModel.CardState) -> Void) {
        
        func addedFederalCode(to otherCard: AppVaccinePassportModel) -> Bool {
            if let newFedCode = card.transform().fedCode, newFedCode.count > 1, otherCard.transform().fedCode?.count ?? 0 < 1 {
                return true
            } else {
                return false
            }
        }
        StorageService.shared.getVaccineCardsForCurrentUser { localDS in
            guard !localDS.isEmpty else { return completion(.isNew) }
            
            // Check if card is duplicate
            if let existing = localDS.map({$0.transform()}).first(where: {$0.hash == card.codableModel.hash}) {
                let isNewer = card.codableModel.isNewer(than: existing)
                if addedFederalCode(to: existing.transform()) {
                    return completion(.UpdatedFederalPass)
                }
                return completion(isNewer ? .canUpdateExisting : .isOutdated)
            }
            
            // Check if card for with the same name and dob exist
            if let existing = localDS.map({$0.transform()}).first(where: {$0.name == card.codableModel.name && $0.birthdate == card.codableModel.birthdate}) {
                let isNewer = card.codableModel.isNewer(than: existing)
                if addedFederalCode(to: existing.transform()) {
                    return completion(.canUpdateExisting)
                }
                return completion(isNewer ? .canUpdateExisting : .isOutdated)
            }
            
            return completion(.isNew)
        }
    }
    
}


extension AppVaccinePassportModel {
    enum CardState {
        case exists
        case isNew
        case canUpdateExisting
        case isOutdated
        case UpdatedFederalPass
    }
    func state(completion: @escaping(CardState) -> Void) {
        StorageService.shared.getState(of: self, completion: completion)
    }
}

//struct HealthRecordsWrapperModelHack {
//    let appModel: AppVaccinePassportModel
//    let immunizationRecords: [CovidImmunizationRecord]
//}

