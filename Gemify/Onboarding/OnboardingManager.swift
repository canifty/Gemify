//
//  OnboardingManager.swift
//  Gemify
//
//  Created by Can Dindar on 15/10/25.
//

import Foundation

struct OnboardingManager {
    private static let key = "onboardingCount"
    
    static func incrementOnboardingCount() {
        let defaults = UserDefaults.standard
        let newCount = defaults.integer(forKey: key) + 1
        defaults.set(newCount, forKey: key)
    }
    
    static func shouldOnboardingDisplay() -> Bool {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: key)
        if count >= 1 {
            return false
        } else {
            return true
        }
    }
}
