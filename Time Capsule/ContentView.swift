//
//  ContentView.swift
//  Time Capsule
//
//  Created by Abraham Guerrero on 8/27/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingCreateCapsule = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TimeCapsule.createdDate, ascending: false)],
        animation: .default)
    private var timeCapsules: FetchedResults<TimeCapsule>

    var body: some View {
        NavigationView {
            List {
                ForEach(timeCapsules) { capsule in
                    NavigationLink {
                        TimeCapsuleDetailView(timeCapsule: capsule)
                    } label: {
                        TimeCapsuleRowView(timeCapsule: capsule)
                    }
                }
                .onDelete(perform: deleteCapsules)
            }
            .navigationTitle("Time Capsules")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingCreateCapsule = true }) {
                        Label("Create Time Capsule", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateCapsule) {
                CreateTimeCapsuleView()
            }
            
            if timeCapsules.isEmpty {
                VStack {
                    Image(systemName: "archivebox")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Time Capsules")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Create your first time capsule to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Select a time capsule")
                    .foregroundColor(.secondary)
            }
        }
    }

    private func deleteCapsules(offsets: IndexSet) {
        withAnimation {
            offsets.map { timeCapsules[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Failed to delete time capsule: \(nsError.localizedDescription)")
            }
        }
    }
}

struct TimeCapsuleRowView: View {
    let timeCapsule: TimeCapsule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timeCapsule.name ?? "Untitled Capsule")
                .font(.headline)
            
            HStack {
                if isUnlocked {
                    Label("Unlocked", systemImage: "lock.open")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Label("Locked until \(timeCapsule.openDate ?? Date(), formatter: dateFormatter)", systemImage: "lock")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
                
                Spacer()
                
                Text("\(timeCapsule.contents?.count ?? 0) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var isUnlocked: Bool {
        guard let openDate = timeCapsule.openDate else { return false }
        return Date() >= openDate
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
