//
//  StorageService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2021-10-22.
//

import Foundation
import CoreData
import UIKit

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
    
    func deleteAllStoredData(for userId: String? = AuthManager().userId()) {
        /**
         We could do this, but then we would have to add do this with each new record type:
         
         let vaccineCards = fetchVaccineCards()
         let tests = fetchTestResults()
         deleteAllRecords(in: vaccineCards)
         deleteAllRecords(in: tests)
         */
       
        /**
         Or we can delete the user record.
         this will delete objects related to it as well because of the
         cascade delete rule on the relationships
         then we can create the user again with the same properties.
         */
        if let user = fetchUser(id: userId), let userID = user.id {
            // cache user data
            let userName = user.name ?? ""
            
            /// delete user record.
            /// this will delete objects related to it as well because of the
            /// cascade delete rule on the relationships
            deleteAllRecords(in: [user])
            // store user again
            _ = saveUser(id: userID, name: userName)
        }
        
    }
    
    fileprivate func deleteAllRecords(in array: [NSManagedObject]) {
        for object in array {
           delete(object: object)
        }
    }
    
    func delete(object: NSManagedObject) {
        let context = managedContext
        do {
            context?.delete(object)
            try context?.save()
        } catch {
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
        BCVaccineValidator.shared.validate(code: code.lowercased()) { result in
            if let model = result.toLocal(federalPass: cardToProcess.federalPass, phn: cardToProcess.phn) {
                processedCards.append(AppVaccinePassportModel(codableModel: model))
                self.recursivelyProcessStored(cards: remainingCards, processed: processedCards, completion: completion)
            } else {
                self.recursivelyProcessStored(cards: remainingCards, processed: processedCards, completion: completion)
            }
        }
    }
    
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
