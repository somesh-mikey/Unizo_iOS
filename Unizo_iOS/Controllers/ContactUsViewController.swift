//
//  ContactUsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 24/12/25.
//

import UIKit

class ContactUsViewController: UIViewController {

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

    // MARK: - Data
    private let categoryOptions = ["General Inquiry", "Bug Report", "Feature Request", "Account Issue", "Payment Issue", "Other"]
    private var selectedCategory: String = "General Inquiry"

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
        messageTextView.text = "Write your message here...".localized
        messageTextView.textColor = .tertiaryLabel
        messageTextView.font = .systemFont(ofSize: 16)
        messageTextView.backgroundColor = .white
        messageTextView.layer.cornerRadius = 14
        messageTextView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)

        // Submit
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        submitButton.backgroundColor = primaryColor
        submitButton.layer.cornerRadius = 28

        [
            reachLabel,
            contactSegment,
            contactField,
            helpLabel,
            categoryButton,
            explainLabel,
            messageTextView,
            submitButton
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
}

