//
//  Splash.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import SwiftUI

struct SplashView: View {
    
    @EnvironmentObject var router: Router
    @ObservedObject private var viewModel = SplashViewModel()
    
    var body: some View {
        ZStack {
            Color.splashBackground
            Image("logo")
        }
        .task {
            await viewModel.start(with: router)
        }
        .ignoresSafeArea()
        
    }
}
