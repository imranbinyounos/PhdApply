//
//  PhdApplyApp.swift
//  PhdApply
//
//  Created by Imran on 9/8/25.
//

import SwiftUI
import SwiftData

@main
struct PhdApplyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ApplicationRecord.self,
            LinkItem.self,
            InteractionLog.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup("GradKit Pro") {
            GradKitProMainView()
                .onAppear { NotificationService.requestAuthorization() }
        }
        .modelContainer(sharedModelContainer)
    }
}
