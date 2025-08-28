//
//  Persistence.swift
//  Time Capsule
//
//  Created by Abraham Guerrero on 8/27/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample time capsules for preview
        let capsule1 = TimeCapsule(context: viewContext)
        capsule1.id = UUID()
        capsule1.name = "My Childhood Memories"
        capsule1.notes = "Photos and memories from when I was 10 years old"
        capsule1.createdDate = Date().addingTimeInterval(-86400) // Created yesterday
        capsule1.openDate = Date().addingTimeInterval(86400) // Opens tomorrow
        
        let capsule2 = TimeCapsule(context: viewContext)
        capsule2.id = UUID()
        capsule2.name = "College Graduation"
        capsule2.notes = "Memories from my graduation day"
        capsule2.createdDate = Date().addingTimeInterval(-172800) // Created 2 days ago
        capsule2.openDate = Date().addingTimeInterval(-3600) // Opened 1 hour ago
        
        // Add some sample content to the unlocked capsule
        let textContent = TimeCapsuleContent(context: viewContext)
        textContent.id = UUID()
        textContent.contentType = "text"
        textContent.textContent = "What an amazing day! I can't believe I finally graduated. All those late nights studying were worth it."
        textContent.createdDate = Date().addingTimeInterval(-172800)
        textContent.timeCapsule = capsule2
        
        let textContent2 = TimeCapsuleContent(context: viewContext)
        textContent2.id = UUID()
        textContent2.contentType = "text"
        textContent2.textContent = "Mom and Dad were so proud. I'll never forget the look on their faces when I walked across that stage."
        textContent2.createdDate = Date().addingTimeInterval(-172800)
        textContent2.timeCapsule = capsule2
        
        // Add content to the locked capsule (won't be visible until unlocked)
        let lockedContent = TimeCapsuleContent(context: viewContext)
        lockedContent.id = UUID()
        lockedContent.contentType = "text"
        lockedContent.textContent = "This is a secret message that won't be revealed until the time capsule opens!"
        lockedContent.createdDate = Date().addingTimeInterval(-86400)
        lockedContent.timeCapsule = capsule1
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Time_Capsule")
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
}
