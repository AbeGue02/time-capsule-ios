//
//  TimeCapsuleDetailView.swift
//  Time Capsule
//
//  Created by Abraham Guerrero on 8/27/25.
//

import SwiftUI
import CoreData

struct TimeCapsuleDetailView: View {
    let timeCapsule: TimeCapsule
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(timeCapsule.name ?? "Untitled Capsule")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let notes = timeCapsule.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Created: \(timeCapsule.createdDate ?? Date(), formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Status Section
                VStack(alignment: .leading, spacing: 12) {
                    if isUnlocked {
                        // Unlocked state
                        HStack {
                            Image(systemName: "lock.open.fill")
                                .foregroundColor(.green)
                            Text("Time Capsule Unlocked!")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    } else {
                        // Locked state
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.orange)
                                Text("Locked until: \(timeCapsule.openDate ?? Date(), formatter: dateFormatter)")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            
                            if timeRemaining > 0 {
                                Text("Time remaining: \(formatTimeRemaining(timeRemaining))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Contents Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Contents (\(timeCapsule.contents?.count ?? 0) items)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if isUnlocked {
                        // Show actual content when unlocked
                        if let contents = timeCapsule.contents?.allObjects as? [TimeCapsuleContent] {
                            LazyVStack(spacing: 12) {
                                ForEach(contents.sorted(by: { $0.createdDate ?? Date() < $1.createdDate ?? Date() }), id: \.id) { content in
                                    TimeCapsuleContentView(content: content)
                                }
                            }
                        }
                    } else {
                        // Show placeholder content when locked
                        VStack(spacing: 12) {
                            ForEach(0..<(timeCapsule.contents?.count ?? 0), id: \.self) { index in
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)
                                    Text("Hidden content \(index + 1)")
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        if timeCapsule.contents?.count == 0 {
                            Text("This time capsule is empty")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateTimeRemaining()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var isUnlocked: Bool {
        guard let openDate = timeCapsule.openDate else { return false }
        return Date() >= openDate
    }
    
    private func updateTimeRemaining() {
        guard let openDate = timeCapsule.openDate else { return }
        timeRemaining = max(0, openDate.timeIntervalSince(Date()))
    }
    
    private func startTimer() {
        guard !isUnlocked else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
            if timeRemaining <= 0 {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = Int(timeInterval) % 86400 / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m \(seconds)s"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

struct TimeCapsuleContentView: View {
    let content: TimeCapsuleContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForContentType(content.contentType ?? ""))
                    .foregroundColor(.blue)
                Text(titleForContentType(content.contentType ?? ""))
                    .font(.headline)
                Spacer()
                Text(content.createdDate ?? Date(), formatter: timeFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            switch content.contentType {
            case "text":
                if let textContent = content.textContent {
                    Text(textContent)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            case "image":
                if let imageData = content.data,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(8)
                }
            default:
                Text("Unknown content type")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func iconForContentType(_ type: String) -> String {
        switch type {
        case "text":
            return "text.alignleft"
        case "image":
            return "photo"
        default:
            return "doc"
        }
    }
    
    private func titleForContentType(_ type: String) -> String {
        switch type {
        case "text":
            return "Text Entry"
        case "image":
            return "Photo"
        default:
            return "Content"
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .short
    return formatter
}()

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let capsule = TimeCapsule(context: context)
    capsule.name = "My First Time Capsule"
    capsule.notes = "This is a test capsule"
    capsule.createdDate = Date()
    capsule.openDate = Date().addingTimeInterval(86400)
    
    return NavigationView {
        TimeCapsuleDetailView(timeCapsule: capsule)
    }
    .environment(\.managedObjectContext, context)
}