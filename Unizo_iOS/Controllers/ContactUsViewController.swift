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

    // Subject row
    private let subjectContainer = UIView()
    private let subjectLeftLabel = UILabel()
    private let subjectField = UITextField()
    private let pickerView = UIPickerView()

    private let messageTextView = UITextView()
    private let submitButton = UIButton(type: .system)

    // MARK: - Data
    private let subjectOptions = ["Help", "Bug Report", "Feedback", "Account Issue"]

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

        explainLabel.text = "Briefly Explain What's Going On".localized
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

        // Subject container
        subjectContainer.backgroundColor = .white
        subjectContainer.layer.cornerRadius = 14

        subjectLeftLabel.text = "Subject".localized
        subjectLeftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subjectLeftLabel.textColor = .label

        subjectField.placeholder = "Help".localized
        subjectField.font = .systemFont(ofSize: 16)
        subjectField.tintColor = .clear

        let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevron.tintColor = .secondaryLabel
        subjectField.rightView = chevron
        subjectField.rightViewMode = .always

        pickerView.delegate = self
        pickerView.dataSource = self
        subjectField.inputView = pickerView

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
            subjectContainer,
            explainLabel,
            messageTextView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [subjectLeftLabel, subjectField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            subjectContainer.addSubview($0)
        }

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(submitButton)
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
        } else {
            contactField.placeholder = "Phone Number".localized
            contactField.keyboardType = .numberPad
        }
        contactField.reloadInputViews()
    }

    // MARK: - Constraints (SUBMIT FIXED AT BOTTOM)
    // MARK: - Constraints
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

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

            contactSegment.topAnchor.constraint(equalTo: reachLabel.bottomAnchor, constant: 12),
            contactSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contactSegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contactSegment.heightAnchor.constraint(equalToConstant: 36),

            contactField.topAnchor.constraint(equalTo: contactSegment.bottomAnchor, constant: 0),
            contactField.leadingAnchor.constraint(equalTo: contactSegment.leadingAnchor),
            contactField.trailingAnchor.constraint(equalTo: contactSegment.trailingAnchor),
            contactField.heightAnchor.constraint(equalToConstant: 52),

            helpLabel.topAnchor.constraint(equalTo: contactField.bottomAnchor, constant: 24),
            helpLabel.leadingAnchor.constraint(equalTo: reachLabel.leadingAnchor),

            subjectContainer.topAnchor.constraint(equalTo: helpLabel.bottomAnchor, constant: 12),
            subjectContainer.leadingAnchor.constraint(equalTo: contactField.leadingAnchor),
            subjectContainer.trailingAnchor.constraint(equalTo: contactField.trailingAnchor),
            subjectContainer.heightAnchor.constraint(equalToConstant: 52),

            subjectLeftLabel.leadingAnchor.constraint(equalTo: subjectContainer.leadingAnchor, constant: 16),
            subjectLeftLabel.centerYAnchor.constraint(equalTo: subjectContainer.centerYAnchor),

            subjectField.trailingAnchor.constraint(equalTo: subjectContainer.trailingAnchor, constant: -16),
            subjectField.centerYAnchor.constraint(equalTo: subjectContainer.centerYAnchor),
            subjectField.widthAnchor.constraint(equalToConstant: 120),

            explainLabel.topAnchor.constraint(equalTo: subjectContainer.bottomAnchor, constant: 24),
            explainLabel.leadingAnchor.constraint(equalTo: reachLabel.leadingAnchor),

            messageTextView.topAnchor.constraint(equalTo: explainLabel.bottomAnchor, constant: 12),
            messageTextView.leadingAnchor.constraint(equalTo: contactField.leadingAnchor),
            messageTextView.trailingAnchor.constraint(equalTo: contactField.trailingAnchor),
            messageTextView.heightAnchor.constraint(equalToConstant: 120),

            // ✅ SUBMIT BUTTON — ONLY CHANGE
            submitButton.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 200),
            submitButton.leadingAnchor.constraint(equalTo: contactField.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: contactField.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 56),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 180)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Picker
extension ContactUsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        subjectOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        subjectOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subjectField.text = subjectOptions[row]
    }
}

// MARK: - Padding
//private extension UITextField {
//    func setLeftPadding(_ amount: CGFloat) {
//        let v = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
//        leftView = v
//        leftViewMode = .always
//    }
//}
