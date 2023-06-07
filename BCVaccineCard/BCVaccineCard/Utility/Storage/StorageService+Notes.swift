//
//  Storage+Notes.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//

import Foundation
import CoreData

protocol StorageNoteManager {
    func storeNotes(in object: AuthenticatedNotesResponseModel, completion: @escaping([Note])->Void)
    func storeNote(remoteObject: NoteResponse, completion: @escaping(Note?)->Void)
    func storeLocalNote(object: PostNote, id: String, hdid: String, completion: @escaping(Note?)->Void)
    
    func fetchNotes() -> [Note]
}

extension StorageService: StorageNoteManager {
    func storeNotes(in object: AuthenticatedNotesResponseModel, completion: @escaping ([Note]) -> Void) {
        let notes: [NoteResponse] = object.resourcePayload
       
        guard !notes.isEmpty else {
            Logger.log(string: "No Notes", type: .storage)
            return completion([])
        }
        var storedNotes: [Note] = []
        let group = DispatchGroup()
        for note in notes {
            group.enter()
            storeNote(remoteObject: note, completion: { result in
                if let stored = result {
                    storedNotes.append(stored)
                }
                group.leave()
            })
        }
        group.notify(queue: .main) {
            self.notify(event: StorageEvent(event: .Save, entity: .Notes, object: storedNotes))
            return completion(storedNotes)
        }
    }
    
    func storeNote(remoteObject object: NoteResponse, completion: @escaping(Note?)->Void) {
        guard let context = managedContext else {
            return completion(nil)
        }
        let note = Note(context: context)
        note.id = object.id
        note.hdid = object.hdID
        note.title = object.title
        note.text = object.text
        note.journalDate = object.journalDate?.getGatewayDate()
        note.version = Int64(object.version ?? 0)
        note.createdDateTime = object.createdDateTime?.getGatewayDate()
        note.createdBy = object.createdBy
        note.updatedDateTime = object.updatedDateTime?.getGatewayDate()
        note.updatedBy = object.updatedBy
        note.addedToTimeline = true
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .Notes, object: note))
            return completion(note)
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return completion(nil)
        }
    }
    
    func storeLocalNote(object: PostNote, id: String, hdid: String, completion: @escaping (Note?) -> Void) {
        guard let context = managedContext else {
            return completion(nil)
        }
        let note = Note(context: context)
        note.id = id
        note.hdid = hdid
        note.title = object.title
        note.text = object.text
        note.journalDate = object.journalDate.getGatewayDate()
        note.createdDateTime = object.createdDateTime.getGatewayDate()
        note.createdBy = hdid
        note.updatedDateTime = object.createdDateTime.getGatewayDate()
        note.updatedBy = hdid
        note.addedToTimeline = object.addedToTimeline
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .Notes, object: note))
            return completion(note)
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return completion(nil)
        }
    }
    
    func fetchNotes() -> [Note] {
        guard let context = managedContext else {return []}
        do {
            return try context.fetch(Note.fetchRequest())
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return []
        }

    }
}
