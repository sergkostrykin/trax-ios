//
//  LottieView.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 25/12/2024.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    var animationFileName: String
    var tintColor: UIColor? = nil
    let loopMode: LottieLoopMode
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if let tintColor = tintColor {
            let colorValueProvider = ColorValueProvider(tintColor.convertToLottieColor())
            uiView.setValueProvider(colorValueProvider, keypath: AnimationKeypath(keypath: "**.Color"))
        }
    }
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: animationFileName)
        animationView.loopMode = loopMode
        animationView.play()
        animationView.contentMode = .scaleAspectFill
        
        if let tintColor = tintColor {
            let colorValueProvider = ColorValueProvider(tintColor.convertToLottieColor())
            animationView.setValueProvider(colorValueProvider, keypath: AnimationKeypath(keypath: "**.Color"))
        }
        
        return animationView
    }
}

extension UIColor {
    func convertToLottieColor() -> LottieColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return LottieColor(r: Double(red), g: Double(green), b: Double(blue), a: Double(alpha))
        }
        
        var white: CGFloat = 0
        if self.getWhite(&white, alpha: &alpha) {
            return LottieColor(r: Double(white), g: Double(white), b: Double(white), a: Double(alpha))
        }
        
        return LottieColor(r: 0, g: 0, b: 0, a: 0)
    }
}
