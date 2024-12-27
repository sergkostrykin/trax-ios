//
//  trax_iosApp.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import SwiftUI
import SwiftData

@main
struct TraxApp: App {
    
    @ObservedObject var router = Router()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Photo.self,
            DetectionData.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navigationPath) {
                SplashView()
                    .navigationDestination(for: Router.Route.self) { route in
                        switch route {
                        case .gallery:
                            GalleryView()
                                .navigationBarBackButtonHidden(true)
                        }
                    }
            }
            .environmentObject(router)
            .modelContainer(sharedModelContainer)
        }
    }
}
