import Foundation
import SwiftUI

@Observable
final class UserSettings {

    var dailyBudget: Double = 20.0 {
        didSet { UserDefaults.standard.set(dailyBudget, forKey: "dailyBudget") }
    }

    var reminderEnabled: Bool = false {
        didSet { UserDefaults.standard.set(reminderEnabled, forKey: "reminderEnabled") }
    }

    var reminderHour: Int = 20 {
        didSet { UserDefaults.standard.set(reminderHour, forKey: "reminderHour") }
    }

    var reminderMinute: Int = 0 {
        didSet { UserDefaults.standard.set(reminderMinute, forKey: "reminderMinute") }
    }

    var challengeMode: ChallengeMode = .ongoing {
        didSet { UserDefaults.standard.set(challengeMode.rawValue, forKey: "challengeMode") }
    }

    var hasSeenOnboarding: Bool = false {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding") }
    }

    init() {
        let defaults = UserDefaults.standard
        let budget = defaults.double(forKey: "dailyBudget")
        if budget > 0 { self.dailyBudget = budget }
        self.reminderEnabled = defaults.bool(forKey: "reminderEnabled")
        if let hour = defaults.object(forKey: "reminderHour") as? Int { self.reminderHour = hour }
        if let minute = defaults.object(forKey: "reminderMinute") as? Int { self.reminderMinute = minute }
        if let modeRaw = defaults.string(forKey: "challengeMode"),
           let mode = ChallengeMode(rawValue: modeRaw) {
            self.challengeMode = mode
        }
        self.hasSeenOnboarding = defaults.bool(forKey: "hasSeenOnboarding")
    }
}

enum ChallengeMode: String, CaseIterable, Identifiable {
    case ongoing = "ongoing"
    case week = "7-day"
    case month = "30-day"
    case hundred = "100-day"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ongoing: return "Ongoing"
        case .week: return "7-Day Challenge"
        case .month: return "30-Day Challenge"
        case .hundred: return "100-Day Challenge"
        }
    }

    var targetDays: Int? {
        switch self {
        case .ongoing: return nil
        case .week: return 7
        case .month: return 30
        case .hundred: return 100
        }
    }
}
