//
//  SplashViewModel.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import Foundation
import Combine

class SplashViewModel: ObservableObject {
    
    func start(with router: Router) async {
        
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        await router.showHomeScreen()
    }
}
