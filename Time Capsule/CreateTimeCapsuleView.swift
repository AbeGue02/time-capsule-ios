//
//  CreateTimeCapsuleView.swift
//  Time Capsule
//
//  Created by Abraham Guerrero on 8/27/25.
//

import SwiftUI
import CoreData
import PhotosUI

struct CreateTimeCapsuleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var notes = ""
    @State private var openDate = Date().addingTimeInterval(86400) // Default to 1 day from now
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var textEntries: [String] = []
    @State private var newTextEntry = ""
    @State private var showingPhotoPicker = false
    @State private var showingTextEntrySheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time Capsule Details")) {
                    TextField("Name", text: $name)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Open Date")) {
                    DatePicker("When should this open?", selection: $openDate, in: Date()...)
                        .datePickerStyle(.compact)
                }
                
                Section(header: Text("Contents")) {
                    Button(action: { showingPhotoPicker = true }) {
                        Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    Button(action: { showingTextEntrySheet = true }) {
                        Label("Add Text Entry", systemImage: "text.append")
                    }
                    
                    if !selectedPhotos.isEmpty {
                        Text("\(selectedPhotos.count) photos selected")
                            .foregroundColor(.secondary)
                    }
                    
                    if !textEntries.isEmpty {
                        Text("\(textEntries.count) text entries added")
                            .foregroundColor(.secondary)
                    }
                }
                
                if !textEntries.isEmpty {
                    Section(header: Text("Text Entries")) {
                        ForEach(Array(textEntries.enumerated()), id: \.offset) { index, entry in
                            Text(entry)
                                .lineLimit(3)
                                .swipeActions {
                                    Button("Delete") {
                                        textEntries.remove(at: index)
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
            }
            .navigationTitle("New Time Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTimeCapsule()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotos, matching: .images)
            .sheet(isPresented: $showingTextEntrySheet) {
                AddTextEntryView(textEntry: $newTextEntry) { entry in
                    if !entry.isEmpty {
                        textEntries.append(entry)
                    }
                }
            }
        }
    }
    
    private func createTimeCapsule() {
        withAnimation {
            let newCapsule = TimeCapsule(context: viewContext)
            newCapsule.id = UUID()
            newCapsule.name = name
            newCapsule.notes = notes.isEmpty ? nil : notes
            newCapsule.createdDate = Date()
            newCapsule.openDate = openDate
            
            // Add text entries
            for textEntry in textEntries {
                let content = TimeCapsuleContent(context: viewContext)
                content.id = UUID()
                content.contentType = "text"
                content.textContent = textEntry
                content.createdDate = Date()
                content.timeCapsule = newCapsule
            }
            
            // Process selected photos
            if !selectedPhotos.isEmpty {
                Task {
                    for photoItem in selectedPhotos {
                        if let data = try? await photoItem.loadTransferable(type: Data.self) {
                            let content = TimeCapsuleContent(context: viewContext)
                            content.id = UUID()
                            content.contentType = "image"
                            content.data = data
                            content.fileName = "photo_\(Date().timeIntervalSince1970).jpg"
                            content.createdDate = Date()
                            content.timeCapsule = newCapsule
                        }
                    }
                    
                    await MainActor.run {
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            print("Failed to save time capsule: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                // Save immediately if no photos
                do {
                    try viewContext.save()
                    dismiss()
                } catch {
                    print("Failed to save time capsule: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct AddTextEntryView: View {
    @Binding var textEntry: String
    @Environment(\.dismiss) private var dismiss
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Text Entry")) {
                    TextEditor(text: $textEntry)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("Add Text Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(textEntry)
                        textEntry = ""
                        dismiss()
                    }
                    .disabled(textEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateTimeCapsuleView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}