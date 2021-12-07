//
//  StorageService+VaccineCard.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-03.
//

import Foundation
import BCVaccineValidator

extension StorageService {
    
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
            var cards = try context.fetch(VaccineCard.fetchRequest())
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
    func fetchVaccineCards(for userId: String? = AuthManager().userId()) -> [VaccineCard] {
        guard let context = managedContext else {return []}
        do {
            let users = try context.fetch(User.fetchRequest())
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
            var cards = try context.fetch(VaccineCard.fetchRequest())
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
            let cards = try context.fetch(VaccineCard.fetchRequest())
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
            let cards = try context.fetch(VaccineCard.fetchRequest())
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

