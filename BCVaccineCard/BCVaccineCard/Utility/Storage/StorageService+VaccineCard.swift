//
//  StorageService+VaccineCard.swift
//  BCVaccineCard
//
//  Created by Amir on 2021-12-03.
//

import Foundation
import BCVaccineValidator

protocol StorageVaccineCardManager {
    
    // MARK: Store
    /// Store a vaccine card for a given user id
    /// - Parameters:
    ///   - vaccineQR: Vaccine card code
    ///   - name: card holder name
    ///   - issueDate: card's issue date
    ///   - hash: hash of the qr code's payload. use as id
    ///   - patient: patient to store this card for
    ///   - authenticated: Indicating if this record is for an authenticated user
    ///   - federalPass: federal pass if available
    ///   - vaxDates: vaccine dates
    /// - Returns: created object
    func storeVaccineVard(
        vaccineQR: String,
        name: String,
        issueDate: Date,
        hash: String,
        patient: Patient,
        authenticated: Bool,
        federalPass: String?,
        vaxDates: [String]?,
        sortOrder: Int64?,
        completion: @escaping(VaccineCard?)->Void
    )
    
    func createImmunizationRecords(for card: VaccineCard, completion: @escaping([ImmunizationRecord])->Void)
    
    // MARK: Update
    
    /// Update a stored vaccine card to a add federal pass
    func updateVaccineCard(card: VaccineCard, federalPass: String, completion: @escaping(VaccineCard?)->Void)
    
    /// Updated a stored vaccine card with new data from
    func updateVaccineCard(newData model: LocallyStoredVaccinePassportModel, completion: @escaping(VaccineCard?)->Void)
    
    /// Update a vaccine card's sort order
    func updateVaccineCardSortOrder(card: VaccineCard, newPosition: Int)
    
    
    // MARK: Delete
    func deleteVaccineCard(vaccineQR code: String, resort: Bool?)
    
    // MARK: Fetch
    func fetchVaccineCards() -> [VaccineCard]
    func fetchVaccineCard(code: String) -> VaccineCard?
}

extension StorageService: StorageVaccineCardManager {
    // MARK: Store
    func storeVaccineVard(vaccineQR: String,
                          name: String,
                          issueDate: Date,
                          hash: String,
                          patient: Patient,
                          authenticated: Bool,
                          federalPass: String? = nil,
                          vaxDates: [String]? = nil,
                          sortOrder: Int64? = nil,
                          completion: @escaping(VaccineCard?)->Void
    ) {
        guard let context = managedContext else {return completion(nil)}
        let cardSortOrder: Int64
        if let sortOrderPosition = sortOrder {
            cardSortOrder = sortOrderPosition
        } else {
            cardSortOrder = Int64(fetchVaccineCards().count)
        }
        
        let card = VaccineCard(context: context)
        card.authenticated = authenticated
        card.code = vaccineQR
        card.name = name
        card.patient = patient
        card.federalPass = federalPass
        card.vaxDates = vaxDates
        card.sortOrder = cardSortOrder
        card.firHash = hash
        card.issueDate = issueDate
        createImmunizationRecords(for: card) { records in
            for record in records {
                card.addToImmunizationRecord(record)
            }
            do {
                try context.save()
                self.notify(event: StorageEvent(event: .Save, entity: .VaccineCard, object: card))
                completion(card)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completion(nil)
            }
        }
    }
    
    // MARK: Update
    func updateVaccineCard(card: VaccineCard, federalPass: String, completion: @escaping (VaccineCard?) -> Void) {
        guard let context = managedContext else {return completion(nil)}
        do {
            card.federalPass = federalPass
            try context.save()
            DispatchQueue.main.async {[weak self] in
                guard let `self` = self else {return}
                self.notify(event: StorageEvent(event: .Update, entity: .VaccineCard, object: card))
                return completion(card)
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            DispatchQueue.main.async {
                return completion(nil)
            }
        }
    }
    
    func updateVaccineCard(newData model: LocallyStoredVaccinePassportModel, completion: @escaping (VaccineCard?) -> Void) {
        guard let context = managedContext, let card = fetchVaccineCards().filter({$0.name == model.name && $0.birthDateString == model.birthdate}).first else {return completion(nil)}
        do {
            card.code = model.code
            card.vaxDates = model.vaxDates
            card.federalPass = model.fedCode
            card.firHash = model.hash
            try context.save()
            DispatchQueue.main.async {[weak self] in
                guard let `self` = self else {return}
                self.notify(event: StorageEvent(event: .Update, entity: .VaccineCard, object: card))
                return completion(card)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            DispatchQueue.main.async {
                return completion(nil)
            }
        }
    }
    
    func updateVaccineCardSortOrder(card: VaccineCard, newPosition: Int) {
        guard let context = managedContext else {return}
        do {
            var cards = fetchVaccineCards()
            guard let cardToMove = cards.filter({$0.code == card.code}).first else {return}
            cards = cards.sorted {
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
    
    // MARK: Delete
    func deleteVaccineCard(vaccineQR code: String, resort: Bool? = true) {
        guard let context = managedContext else {return}
        
        var cards = fetchVaccineCards()
        guard let item = cards.filter({$0.code == code}).first else {return}
        
        cards = cards.sorted {
            $0.sortOrder < $1.sortOrder
        }
        cards.removeAll { card in
            card.code == code
        }
        
        // Delete from core data
        delete(object: item)
        
        // Blocking re-sort:
        if let resort = resort, !resort {
            return
        }
        // update sort order for stored cards based on array index
        do {
           
            for (index, card) in cards.enumerated() {
                card.sortOrder = Int64(index)
            }
            notify(event: StorageEvent(event: .Delete, entity: .VaccineCard, object: item))
            try context.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
    }
    
    // MARK: Fetch
    func fetchVaccineCards() -> [VaccineCard] {
        let patients = fetchPatients()
        let cards = patients.map({$0.vaccineCardArray})
        return Array(cards.joined()).sorted(by: {$0.sortOrder < $1.sortOrder})
    }
    
    func fetchVaccineCard(code: String) -> VaccineCard? {
        fetchVaccineCards().filter({$0.code == code}).first
    }
    
    // MARK: Helpers
    func createImmunizationRecords(for card: VaccineCard, completion: @escaping([ImmunizationRecord])->Void) {
        guard let qrCode = card.code, let context = managedContext else {return completion([])}
        BCVaccineValidator.shared.validate(code: qrCode) { result in
            guard let result = result.result else {return completion([])}
            var immunizations: [ImmunizationRecord] = []
            for record in result.immunizations {
                let model = ImmunizationRecord(context: context)
                model.snomed = record.snomed
                if let dateString = record.date, let date = Date.Formatter.yearMonthDay.date(from: dateString) {
                    model.date = date
                }
                model.provider = record.provider
                model.lotNumber = record.lotNumber
                model.date = record.date?.vaxDate()
                model.snomed = record.snomed
                immunizations.append(model)
            }
            return completion(immunizations)
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
        let cards = fetchVaccineCards()
        cards.toAppVaccinePassportModel { localDS in
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

fileprivate extension String {
    func vaxDate() -> Date? {
        let dateFormatter = Date.Formatter.yearMonthDay
        return dateFormatter.date(from:self)
    }
}
