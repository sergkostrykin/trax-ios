//
//  Router.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import SwiftUI

final class Router: ObservableObject {
    
    enum Route: String, Codable, Hashable, CaseIterable {
        case gallery = "Gallery"
    }
    
    @Published var navigationPath = NavigationPath()
    
    @MainActor
    func showHomeScreen() {
        navigate(to: .gallery)
    }
    
    @MainActor
    func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    @MainActor
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    @MainActor
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
