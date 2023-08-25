//
//  Storage+Notes.swift
//  BCVaccineCard
//
//  Created by Connor Ogilvie on 2023-06-06.
//

import Foundation
import CoreData

protocol StorageNoteManager {
    func storeNotes(in object: AuthenticatedNotesResponseModel, for patient: Patient, completion: @escaping([Note]?)->Void)
    func storeNote(remoteObject: NoteResponse, patient: Patient) -> Note?
    func storeLocalNote(object: PostNote, id: String, hdid: String, patient: Patient) -> Note?
    
    func fetchNotes() -> [Note]
}

extension StorageService: StorageNoteManager {
    func storeNotes(in object: AuthenticatedNotesResponseModel, for patient: Patient, completion: @escaping ([Note]?) -> Void) {
        if let notesToDelete = notesArray(for: patient)?.filter({ $0.addedToTimeline == true }) {
            deleteAllRecords(in: notesToDelete)
        }
        let notes: [NoteResponse] = object.resourcePayload
       
        guard !notes.isEmpty else {
            Logger.log(string: "No Notes", type: .storage)
            return completion([])
        }
        var storedNotes: [Note] = []
        let group = DispatchGroup()
        for note in notes {
            group.enter()
            if let stored = storeNote(remoteObject: note, patient: patient) {
                storedNotes.append(stored)
            }
            group.leave()
        }
        group.notify(queue: .main) {
            self.notify(event: StorageEvent(event: .Save, entity: .Notes, object: storedNotes))
            return completion(storedNotes)
        }
    }
    
    func storeNote(remoteObject object: NoteResponse, patient: Patient) -> Note? {
        guard let context = managedContext else {
            return nil
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
            return note
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    func storeLocalNote(object: PostNote, id: String, hdid: String, patient: Patient) -> Note? {
        guard let context = managedContext else {
            return nil
        }
        let note = Note(context: context)
        note.id = id
        note.hdid = hdid
        note.title = object.title
        note.text = object.text
        note.journalDate = object.journalDate.getGatewayDate()
        note.createdDateTime = Date()
        note.createdBy = hdid
        note.updatedDateTime = Date()
        note.updatedBy = hdid
        note.addedToTimeline = object.addedToTimeline
        do {
            try context.save()
            self.notify(event: StorageEvent(event: .Save, entity: .Notes, object: note))
            return note
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
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
    
    public func updateNote(originalNoteID id: String, newNote: NoteResponse, for patient: Patient) -> Note? {
        guard let noteToUpdate = fetchNote(id: id) else {
            return storeNote(remoteObject: newNote, patient: patient)
        }
        guard let context = managedContext else {return nil}
        var note = noteToUpdate
        do {
            note.id = newNote.id
            note.hdid = newNote.hdID
            note.title = newNote.title
            note.text = newNote.text
            note.journalDate = newNote.journalDate?.getGatewayDate()
            note.createdDateTime = newNote.createdDateTime?.getGatewayDate()
            note.createdBy = newNote.createdBy
            note.updatedDateTime = newNote.updatedDateTime?.getGatewayDate()
            note.updatedBy = newNote.updatedBy
            try context.save()
            self.notify(event: StorageEvent(event: .Update, entity: .Notes, object: note))
            return note
        } catch let error as NSError {
            Logger.log(string: "Could not save. \(error), \(error.userInfo)", type: .storage)
            return nil
        }
    }
    
    public func fetchNote(id: String) -> Note? {
        let notes = fetchNotes()
       
        return notes.filter { $0.id == id }.first
    }
    
    public func deleteNote(note: Note, for patient: Patient) {
        guard let id = note.id, let object = fetchNote(id: id) else {return}
        delete(object: object)
        notify(event: StorageEvent(event: .Delete, entity: .Notes, object: object))
    }
}
