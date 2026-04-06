//
//  ContactUsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 24/12/25.
//

import UIKit
import FirebaseFirestore

class ContactUsViewController: UIViewController, UITextViewDelegate {

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Labels
    private let reachLabel = UILabel()
    private let helpLabel = UILabel()
    private let explainLabel = UILabel()

    // MARK: - Controls
    private let contactSegment = UISegmentedControl(items: ["Email".localized, "Phone".localized])
    private let contactField = UITextField()

    // Category row
    private let categoryButton = UIButton(type: .system)

    private let messageTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    private let successBanner = UILabel()

    // MARK: - Data
    private let categoryOptions = ["General Inquiry", "Bug Report", "Feature Request", "Account Issue", "Payment Issue", "Other"]
    private var selectedCategory: String = "General Inquiry"
    private let defaultMessagePlaceholder = "Write your message here..."
    private var isSubmitting = false

    // MARK: - Colors
    private let primaryColor = UIColor(red: 0.12, green: 0.28, blue: 0.35, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateContactField()
        setupKeyboardHandling()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        navigationItem.title = "Contact Us".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Labels
        reachLabel.text = "How Can We Reach You?".localized
        reachLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        helpLabel.text = "What Can We Help You With?".localized
        helpLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        explainLabel.text = "Could You Please Explain".localized
        explainLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        // Segment
        contactSegment.selectedSegmentIndex = 0
        contactSegment.backgroundColor = .systemGray6
        contactSegment.selectedSegmentTintColor = .white
        contactSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        // Contact field
        configureTextField(contactField)
        contactField.placeholder = "Email Address".localized
        contactField.keyboardType = .emailAddress

        // Category button
        var categoryConfig = UIButton.Configuration.filled()
        categoryConfig.baseBackgroundColor = .white
        categoryConfig.baseForegroundColor = .label
        categoryConfig.cornerStyle = .large
        categoryConfig.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        categoryConfig.title = selectedCategory.localized
        categoryConfig.image = UIImage(systemName: "chevron.down")
        categoryConfig.imagePlacement = .trailing
        categoryConfig.imagePadding = 8
        categoryConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        categoryButton.configuration = categoryConfig
        categoryButton.configurationUpdateHandler = { button in
            // Ensure the button stretches across its full width
            button.contentHorizontalAlignment = .fill
        }
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)

        // Message
        messageTextView.text = defaultMessagePlaceholder.localized
        messageTextView.textColor = .tertiaryLabel
        messageTextView.font = .systemFont(ofSize: 16)
        messageTextView.backgroundColor = .white
        messageTextView.layer.cornerRadius = 14
        messageTextView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        messageTextView.delegate = self

        // Submit
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        submitButton.backgroundColor = primaryColor
        submitButton.layer.cornerRadius = 28
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        // Success banner
        successBanner.text = "Submitted successfully".localized
        successBanner.textColor = .white
        successBanner.backgroundColor = .systemGreen
        successBanner.textAlignment = .center
        successBanner.font = .systemFont(ofSize: 14, weight: .semibold)
        successBanner.layer.cornerRadius = 10
        successBanner.clipsToBounds = true
        successBanner.alpha = 0

        [
            reachLabel,
            contactSegment,
            contactField,
            helpLabel,
            categoryButton,
            explainLabel,
            messageTextView,
            submitButton,
            successBanner
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func configureTextField(_ tf: UITextField) {
        tf.font = .systemFont(ofSize: 16)
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 14
        tf.setLeftPadding(16)
    }

    // MARK: - Segment Logic
    @objc private func segmentChanged() {
        updateContactField()
    }

    private func updateContactField() {
        if contactSegment.selectedSegmentIndex == 0 {
            contactField.placeholder = "Email Address".localized
            contactField.keyboardType = .emailAddress
            contactField.inputAccessoryView = nil
        } else {
            contactField.placeholder = "Phone Number".localized
            contactField.keyboardType = .phonePad
            // Add Done toolbar for phone pad (no Return key)
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
            toolbar.items = [UIBarButtonItem.flexibleSpace(), doneButton]
            contactField.inputAccessoryView = toolbar
        }
        contactField.reloadInputViews()
    }

    // MARK: - Constraints
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0)

        NSLayoutConstraint.activate([
            // Scroll
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            reachLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            reachLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            contactSegment.topAnchor.constraint(equalTo: reachLabel.bottomAnchor, constant: 16),
            contactSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contactSegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contactSegment.heightAnchor.constraint(equalToConstant: 36),

            contactField.topAnchor.constraint(equalTo: contactSegment.bottomAnchor, constant: 16),
            contactField.leadingAnchor.constraint(equalTo: contactSegment.leadingAnchor),
            contactField.trailingAnchor.constraint(equalTo: contactSegment.trailingAnchor),
            contactField.heightAnchor.constraint(equalToConstant: 52),

            helpLabel.topAnchor.constraint(equalTo: contactField.bottomAnchor, constant: 24),
            helpLabel.leadingAnchor.constraint(equalTo: reachLabel.leadingAnchor),

            categoryButton.topAnchor.constraint(equalTo: helpLabel.bottomAnchor, constant: 16),
            categoryButton.leadingAnchor.constraint(equalTo: contactField.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: contactField.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 52),

            explainLabel.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 24),
            explainLabel.leadingAnchor.constraint(equalTo: reachLabel.leadingAnchor),

            messageTextView.topAnchor.constraint(equalTo: explainLabel.bottomAnchor, constant: 16),
            messageTextView.leadingAnchor.constraint(equalTo: contactField.leadingAnchor),
            messageTextView.trailingAnchor.constraint(equalTo: contactField.trailingAnchor),
            messageTextView.heightAnchor.constraint(equalToConstant: 120),

            submitButton.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 32),
            submitButton.leadingAnchor.constraint(equalTo: contactField.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: contactField.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 56),

            successBanner.leadingAnchor.constraint(equalTo: submitButton.leadingAnchor),
            successBanner.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor),
            successBanner.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -12),
            successBanner.heightAnchor.constraint(equalToConstant: 36),

            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Category Selection
    @objc private func categoryButtonTapped() {
        let alert = UIAlertController(
            title: "Select Category".localized,
            message: nil,
            preferredStyle: .actionSheet
        )

        for option in categoryOptions {
            alert.addAction(UIAlertAction(title: option.localized, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.selectedCategory = option
                var config = self.categoryButton.configuration
                config?.title = option.localized
                self.categoryButton.configuration = config
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        present(alert, animated: true)
    }

    @objc private func backTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Submit
    @objc private func submitTapped() {
        guard !isSubmitting else { return }
        dismissKeyboard()

        let contactValue = (contactField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let message = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmailMode = contactSegment.selectedSegmentIndex == 0

        guard !contactValue.isEmpty else {
            showAlert(title: "Missing Contact".localized, message: "Please enter your contact information.".localized)
            return
        }

        if isEmailMode {
            guard isValidEmail(contactValue) else {
                showAlert(title: "Invalid Email".localized, message: "Please enter a valid email address.".localized)
                return
            }
        } else {
            guard isValidPhone(contactValue) else {
                showAlert(title: "Invalid Phone".localized, message: "Please enter a valid phone number.".localized)
                return
            }
        }

        guard !message.isEmpty, message != defaultMessagePlaceholder.localized else {
            showAlert(title: "Missing Message".localized, message: "Please explain your issue before submitting.".localized)
            return
        }

        guard NetworkMonitor.shared.isReachable() else {
            showAlert(title: "No Connection".localized, message: "Please check your internet connection and try again.".localized)
            return
        }

        Task {
            do {
                guard let userId = await AuthManager.shared.currentUserId, !userId.isEmpty else {
                    await MainActor.run {
                        self.showAlert(title: "Sign In Required".localized, message: "Please sign in before submitting Contact Us.".localized)
                    }
                    return
                }

                await MainActor.run { self.setSubmitting(true) }

                let payload: [String: Any] = [
                    "user_id": userId,
                    "contact_method": isEmailMode ? "email" : "phone",
                    "contact_value": contactValue,
                    "category": selectedCategory,
                    "message": message,
                    "created_at": FieldValue.serverTimestamp(),
                    "status": "new"
                ]

                try await Firestore.firestore()
                    .collection("contact_submissions")
                    .addDocument(data: payload)

                await MainActor.run {
                    self.setSubmitting(false)
                    self.resetFormAfterSuccess()
                    self.showSuccessBanner()
                }
            } catch {
                await MainActor.run {
                    self.setSubmitting(false)
                    self.showAlert(
                        title: "Submission Failed".localized,
                        message: "Could not submit your request. Please try again.".localized
                    )
                }
                print("❌ Contact submission failed: \(error)")
            }
        }
    }

    private func setSubmitting(_ submitting: Bool) {
        isSubmitting = submitting
        submitButton.isEnabled = !submitting
        contactField.isEnabled = !submitting
        contactSegment.isEnabled = !submitting
        categoryButton.isEnabled = !submitting
        messageTextView.isEditable = !submitting
        submitButton.alpha = submitting ? 0.7 : 1.0

        let title = submitting ? "Submitting...".localized : "Submit".localized
        submitButton.setTitle(title, for: .normal)
    }

    private func resetFormAfterSuccess() {
        contactField.text = ""
        selectedCategory = "General Inquiry"
        var config = categoryButton.configuration
        config?.title = selectedCategory.localized
        categoryButton.configuration = config

        messageTextView.text = defaultMessagePlaceholder.localized
        messageTextView.textColor = .tertiaryLabel
    }

    private func showSuccessBanner() {
        UIView.animate(withDuration: 0.2, animations: {
            self.successBanner.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 2.0, options: [], animations: {
                self.successBanner.alpha = 0
            })
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: value)
    }

    private func isValidPhone(_ value: String) -> Bool {
        let digits = value.filter { $0.isNumber }
        return digits.count >= 7 && digits.count <= 15
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultMessagePlaceholder.localized {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = defaultMessagePlaceholder.localized
            textView.textColor = .tertiaryLabel
        }
    }
}

