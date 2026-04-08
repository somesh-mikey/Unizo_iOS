//
//  FeedbackViewController.swift
//  Unizo_iOS
//
//  Allows users to submit feedback to Firestore.
//

import UIKit
import FirebaseFirestore

final class FeedbackViewController: UIViewController, UITextViewDelegate {

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "We'd love your feedback!"
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = Spacing.cornerRadiusMedium
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.borderColor.cgColor
        tv.backgroundColor = .backgroundSecondary
        tv.textContainerInset = UIEdgeInsets(
            top: Spacing.md,
            left: Spacing.sm,
            bottom: Spacing.md,
            right: Spacing.sm
        )
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Share your thoughts about Unizo..."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .textPlaceholder
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Category", for: .normal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .backgroundSecondary
        button.layer.cornerRadius = Spacing.cornerRadiusMedium
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.borderColor.cgColor
        button.contentHorizontalAlignment = .leading
        if #available(iOS 15.0, *) {
            var config = button.configuration ?? UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: Spacing.lg,
                bottom: 0,
                trailing: Spacing.lg
            )
            config.imagePadding = Spacing.sm
            button.configuration = config
        } else {
            button.contentEdgeInsets = UIEdgeInsets(
                top: 0,
                left: Spacing.lg,
                bottom: 0,
                right: Spacing.lg
            )
        }
        // Add a chevron on the right
        let chevron = UIImage(systemName: "chevron.down")
        button.setImage(chevron, for: .normal)
        button.tintColor = .textSecondary
        button.semanticContentAttribute = .forceRightToLeft
        if #unavailable(iOS 15.0) {
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: Spacing.sm, bottom: 0, right: -Spacing.sm)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .brandPrimary
        button.layer.cornerRadius = Spacing.cornerRadiusMedium
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let maybeLaterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Maybe Later", for: .normal)
        button.setTitleColor(.brandPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - State

    private let categories = ["Bug Report", "Feature Request", "General Feedback", "Other"]
    private var selectedCategory: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .formSheet
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardDismissal()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .backgroundPrimary

        view.addSubview(titleLabel)
        view.addSubview(categoryButton)
        view.addSubview(messageTextView)
        messageTextView.addSubview(placeholderLabel)
        view.addSubview(submitButton)
        submitButton.addSubview(activityIndicator)
        view.addSubview(maybeLaterButton)

        messageTextView.delegate = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.sectionSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.contentMargin),

            // Category button
            categoryButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.sectionSpacing),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.contentMargin),
            categoryButton.heightAnchor.constraint(equalToConstant: Spacing.buttonHeight),

            // Text view
            messageTextView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: Spacing.lg),
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.contentMargin),
            messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),

            // Placeholder
            placeholderLabel.topAnchor.constraint(equalTo: messageTextView.topAnchor, constant: Spacing.md),
            placeholderLabel.leadingAnchor.constraint(equalTo: messageTextView.leadingAnchor, constant: Spacing.sm + 4),

            // Submit button
            submitButton.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: Spacing.sectionSpacing),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.contentMargin),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.contentMargin),
            submitButton.heightAnchor.constraint(equalToConstant: 50),

            // Activity indicator centered in submit button
            activityIndicator.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),

            // Maybe later
            maybeLaterButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: Spacing.md),
            maybeLaterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maybeLaterButton.heightAnchor.constraint(equalToConstant: Spacing.minTouchTarget),
        ])
    }

    // MARK: - Actions

    private func setupActions() {
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        maybeLaterButton.addTarget(self, action: #selector(maybeLaterTapped), for: .touchUpInside)
    }

    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Category Selection

    @objc private func categoryTapped() {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)

        for category in categories {
            alert.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.selectedCategory = category
                self?.categoryButton.setTitle(category, for: .normal)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad popover support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = categoryButton
            popover.sourceRect = categoryButton.bounds
        }

        present(alert, animated: true)
    }

    // MARK: - Submit

    @objc private func submitTapped() {
        guard let category = selectedCategory else {
            showAlert(title: "Missing Category", message: "Please select a feedback category.")
            return
        }

        let message = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty, placeholderLabel.isHidden else {
            showAlert(title: "Missing Message", message: "Please enter your feedback message.")
            return
        }

        guard NetworkMonitor.shared.isReachable() else {
            showAlert(title: "No Connection", message: "Please check your internet connection and try again.")
            return
        }

        setSubmitting(true)

        Task { [weak self] in
            guard let self = self else { return }

            do {
                guard let userId = await AuthManager.shared.currentUserId else {
                    await MainActor.run { [weak self] in
                        self?.setSubmitting(false)
                        self?.showAlert(title: "Error", message: "You must be logged in to submit feedback.")
                    }
                    return
                }

                let payload: [String: Any] = [
                    "user_id": userId,
                    "category": category,
                    "message": message,
                    "created_at": ISO8601DateFormatter().string(from: Date())
                ]

                try await Firestore.firestore()
                    .collection("feedback")
                    .addDocument(data: payload)

                await MainActor.run { [weak self] in
                    self?.setSubmitting(false)
                    self?.showThankYouAlert()
                }
            } catch {
                print("Failed to submit feedback: \(error)")
                await MainActor.run { [weak self] in
                    self?.setSubmitting(false)
                    self?.showAlert(title: "Error", message: "Failed to submit feedback. Please try again later.")
                }
            }
        }
    }

    // MARK: - Maybe Later

    @objc private func maybeLaterTapped() {
        FeedbackManager.shared.snooze()
        dismiss(animated: true)
    }

    // MARK: - UITextViewDelegate (Placeholder Behavior)

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    // MARK: - Helpers

    private func setSubmitting(_ submitting: Bool) {
        submitButton.isEnabled = !submitting
        maybeLaterButton.isEnabled = !submitting
        categoryButton.isEnabled = !submitting
        messageTextView.isEditable = !submitting

        if submitting {
            submitButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        } else {
            submitButton.setTitle("Submit", for: .normal)
            activityIndicator.stopAnimating()
        }
    }

    private func showThankYouAlert() {
        let alert = UIAlertController(
            title: "Thank You!",
            message: "Thank you for your feedback!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
