//
//  FeedbackManager.swift
//  Unizo_iOS
//
//  Controls when to prompt logged-in users for in-app feedback.
//  The interval between prompts is randomised (10–15 days) and
//  persisted in UserDefaults so it survives app restarts.
//

import UIKit

final class FeedbackManager {
    static let shared = FeedbackManager()

    private enum Keys {
        static let lastFeedbackDate     = "feedback_lastFeedbackDate"
        static let feedbackIntervalDays = "feedback_intervalDays"
    }

    private let defaults = UserDefaults.standard

    private init() {
        if defaults.object(forKey: Keys.feedbackIntervalDays) == nil {
            defaults.set(Int.random(in: 10...15), forKey: Keys.feedbackIntervalDays)
        }
    }

    // MARK: - Private State

    private var lastFeedbackDate: Date? {
        get { defaults.object(forKey: Keys.lastFeedbackDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastFeedbackDate) }
    }

    private var intervalDays: Int {
        let stored = defaults.integer(forKey: Keys.feedbackIntervalDays)
        return stored > 0 ? stored : 10
    }

    // MARK: - Public Interface

    /// Returns `true` when enough time has elapsed since the last prompt
    /// and the user is signed in. Always returns `false` for guests.
    func shouldShowFeedback() -> Bool {
        guard AuthManager.shared.isLoggedInSync else { return false }
        guard let last = lastFeedbackDate else { return true }   // first-time user
        let elapsed = Calendar.current.dateComponents([.day], from: last, to: Date())
        return (elapsed.day ?? 0) >= intervalDays
    }

    /// Shows the feedback sheet modally if `shouldShowFeedback()` is true.
    func presentFeedbackIfNeeded(from viewController: UIViewController) {
        guard shouldShowFeedback() else { return }

        let feedbackVC = FeedbackViewController()
        feedbackVC.modalPresentationStyle = .formSheet

        viewController.present(feedbackVC, animated: true) { [weak self] in
            self?.recordFeedbackShown()
        }
    }

    /// Marks today as the last shown date and picks a new random interval.
    func recordFeedbackShown() {
        lastFeedbackDate = Date()
        defaults.set(Int.random(in: 10...15), forKey: Keys.feedbackIntervalDays)
    }

    /// Defers the next prompt by 5 days by adjusting the last-shown reference date.
    func snooze() {
        // Backdate so that `intervalDays - 5` days appear to have already elapsed.
        let snoozeTarget = Calendar.current.date(
            byAdding: .day, value: -(intervalDays - 5), to: Date()
        ) ?? Date()
        lastFeedbackDate = snoozeTarget
    }
}
