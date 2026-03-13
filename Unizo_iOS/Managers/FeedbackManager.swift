//
//  FeedbackManager.swift
//  Unizo_iOS
//
//  Manages periodic feedback prompts for logged-in users
//

import UIKit

final class FeedbackManager {
    static let shared = FeedbackManager()

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let lastFeedbackDate = "feedback_lastFeedbackDate"
        static let feedbackIntervalDays = "feedback_intervalDays"
    }

    private let defaults = UserDefaults.standard

    private init() {
        // Generate a random interval on first launch if one doesn't exist
        if defaults.object(forKey: Keys.feedbackIntervalDays) == nil {
            defaults.set(Int.random(in: 10...15), forKey: Keys.feedbackIntervalDays)
        }
    }

    // MARK: - Stored Properties

    /// The date feedback was last shown (or snoozed).
    private var lastFeedbackDate: Date? {
        get { defaults.object(forKey: Keys.lastFeedbackDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastFeedbackDate) }
    }

    /// Random interval in days (10-15) between feedback prompts.
    private var intervalDays: Int {
        let stored = defaults.integer(forKey: Keys.feedbackIntervalDays)
        return stored > 0 ? stored : 10
    }

    // MARK: - Public Methods

    /// Returns `true` if the required interval has elapsed since the last feedback prompt
    /// and the user is currently logged in.
    func shouldShowFeedback() -> Bool {
        // Never prompt logged-out users
        guard AuthManager.shared.isLoggedInSync else { return false }

        guard let last = lastFeedbackDate else {
            // Never shown before -- eligible
            return true
        }

        let elapsed = Calendar.current.dateComponents([.day], from: last, to: Date())
        return (elapsed.day ?? 0) >= intervalDays
    }

    /// Presents the feedback screen modally if enough time has elapsed.
    func presentFeedbackIfNeeded(from viewController: UIViewController) {
        guard shouldShowFeedback() else { return }

        let feedbackVC = FeedbackViewController()
        feedbackVC.modalPresentationStyle = .formSheet

        viewController.present(feedbackVC, animated: true) { [weak self] in
            self?.recordFeedbackShown()
        }
    }

    /// Records the current date as the last feedback prompt date and
    /// regenerates the random interval for the next cycle.
    func recordFeedbackShown() {
        lastFeedbackDate = Date()
        defaults.set(Int.random(in: 10...15), forKey: Keys.feedbackIntervalDays)
    }

    /// Snoozes the feedback prompt for 5 days from now.
    func snooze() {
        // Set the last feedback date to 'intervalDays - 5' days ago so
        // the remaining wait is exactly 5 days.
        let calendar = Calendar.current
        let snoozeTarget = calendar.date(byAdding: .day, value: -(intervalDays - 5), to: Date()) ?? Date()
        lastFeedbackDate = snoozeTarget
    }
}
