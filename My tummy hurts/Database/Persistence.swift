//
//  Persistence.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "My_tummy_hurts")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveChanges() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Could not save changes to Core Data: ", error.localizedDescription)
            }
        }
    }
    
    func createMealNote(ingredients: String, createdAt: Date) {
        let entity = MealNote(context: container.viewContext)
       
        entity.id = UUID()
        entity.createdAt = createdAt
        entity.ingredients = ingredients
        
        saveChanges()
    }
    
    func createSymptomNote(symptoms: String, createdAt: Date) {
        let entity = SymptomNote(context: container.viewContext)
       
        entity.id = UUID()
        entity.createdAt = createdAt
        entity.symptoms = symptoms
        entity.critical = false
        
        saveChanges()
    }
    
    func readMealNotes(predicateFormat: String? = nil, fetchLimit: Int? = nil) -> [MealNote] {
        var results: [MealNote] = []
        let request = NSFetchRequest<MealNote>(entityName: "MealNote")

        if predicateFormat != nil {
            request.predicate = NSPredicate(format: predicateFormat!)
        }
        
        if fetchLimit != nil {
            request.fetchLimit = fetchLimit!
        }

        do {
            results = try container.viewContext.fetch(request)
        } catch {
            print("Could not fetch notes from Core Data.")
        }

        return results
    }
    
    func readSymptomNotes(predicateFormat: String? = nil, fetchLimit: Int? = nil) -> [SymptomNote] {
        var results: [SymptomNote] = []
        let request = NSFetchRequest<SymptomNote>(entityName: "SymptomNote")

        if predicateFormat != nil {
            request.predicate = NSPredicate(format: predicateFormat!)
        }
        
        if fetchLimit != nil {
            request.fetchLimit = fetchLimit!
        }

        do {
            results = try container.viewContext.fetch(request)
        } catch {
            print("Could not fetch notes from Core Data.")
        }

        return results
    }

    func updateMealNote(entity: MealNote, createdAt: Date? = nil, ingredients: String? = nil) {
        var hasChanges: Bool = false

        if createdAt != nil {
            entity.createdAt = createdAt!
            hasChanges = true
        }
        if ingredients != nil {
            entity.ingredients = ingredients!
            hasChanges = true
        }

        if hasChanges {
            saveChanges()
        }
    }
    
    func updateSymptomNote(entity: SymptomNote, createdAt: Date? = nil, symptoms: String? = nil, critical: Bool? = nil) {
        var hasChanges: Bool = false

        if createdAt != nil {
            entity.createdAt = createdAt!
            hasChanges = true
        }
        
        if symptoms != nil {
            entity.symptoms = symptoms!
            hasChanges = true
        }
        
        if critical != nil {
            entity.critical = critical!
            hasChanges = true
        }

        if hasChanges {
            saveChanges()
        }
    }
    
    func deleteMealNote(_ entity: MealNote) {
        container.viewContext.delete(entity)
        saveChanges()
    }
    
    func deleteSymptomNote(_ entity: SymptomNote) {
        container.viewContext.delete(entity)
        saveChanges()
    }
    
    func deleteAll() {
        let context = container.viewContext

        context.perform {
            func runBatch<T: NSManagedObject>(_ type: T.Type) throws -> [NSManagedObjectID] {
                let fetch: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
                let req = NSBatchDeleteRequest(fetchRequest: fetch)
                req.resultType = .resultTypeObjectIDs

                let result = try context.execute(req) as? NSBatchDeleteResult
                return (result?.result as? [NSManagedObjectID]) ?? []
            }

            do {
                let deletedMeals = try runBatch(MealNote.self)
                let deletedSymptoms = try runBatch(SymptomNote.self)

                let changes: [AnyHashable: Any] = [
                    NSDeletedObjectsKey: deletedMeals + deletedSymptoms
                ]

                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                context.processPendingChanges()
            } catch {
                print("Batch delete failed:", error)
            }
        }
    }

}
