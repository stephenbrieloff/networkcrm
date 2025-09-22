import SwiftUI

@main
struct NetworkCRMApp: App {
    let persistenceController = PersistenceController.shared
    let notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(notificationManager)
                .onAppear {
                    Task {
                        await notificationManager.requestAuthorization()
                    }
                }
        }
    }
}
