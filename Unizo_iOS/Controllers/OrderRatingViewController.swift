//
//  OrderRatingViewController.swift
//  Unizo_iOS
//

import UIKit

class OrderRatingViewController: UIViewController {
    
    // MARK: - Properties
    var orderId: UUID?
    var currentUserId: UUID?
    var ratedUserId: UUID?
    var orderRepository: OrderRepository?
    var onRatingSuccess: (() -> Void)?
    
    private var selectedRating: Int = 0
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let starsContainer = UIStackView()
    private var starButtons: [UIButton] = []
    private let reviewTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
    }
    
    // MARK: - Setup Navigation
    private func setupNavigationBar() {
        navigationItem.title = "Rate Order".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title
        titleLabel.text = "How would you rate this order?".localized
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        // Subtitle
        subtitleLabel.text = "Your feedback helps us improve".localized
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        // Stars Container
        starsContainer.axis = .horizontal
        starsContainer.alignment = .center
        starsContainer.distribution = .equalSpacing
        starsContainer.spacing = 16
        
        // Create 5 star buttons
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.setImage(UIImage(systemName: "star"), for: .normal)
            starButton.tintColor = .systemGray3
            starButton.tag = i
            starButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            starButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(starButton)
            starsContainer.addArrangedSubview(starButton)
        }
        
        // Review TextEditor
        reviewTextView.font = .systemFont(ofSize: 15)
        reviewTextView.textColor = .label
        reviewTextView.backgroundColor = .secondarySystemBackground
        reviewTextView.layer.cornerRadius = 12
        reviewTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        reviewTextView.placeholder = "Share your feedback (optional)".localized
        
        // Submit Button
        submitButton.setTitle("Submit Rating".localized, for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = UIColor(red: 0, green: 76/255, blue: 97/255, alpha: 1.0)
        submitButton.layer.cornerRadius = 12
        submitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        // Loading Indicator
        loadingIndicator.hidesWhenStopped = true
        
        [titleLabel, subtitleLabel, starsContainer, reviewTextView, submitButton, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Stars Container
            starsContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            starsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starsContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Review TextView
            reviewTextView.topAnchor.constraint(equalTo: starsContainer.bottomAnchor, constant: 32),
            reviewTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reviewTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reviewTextView.heightAnchor.constraint(equalToConstant: 120),
            
            // Submit Button
            submitButton.topAnchor.constraint(equalTo: reviewTextView.bottomAnchor, constant: 24),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 52),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarDisplay()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func submitTapped() {
        guard selectedRating > 0 else {
            showAlert(title: "Error".localized, message: "Please select a rating".localized)
            return
        }
        
        guard let orderId = orderId,
              let ratedUserId = ratedUserId else {
            showAlert(title: "Error".localized, message: "Unable to submit rating".localized)
            return
        }
        
        submitButton.isEnabled = false
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let review = reviewTextView.text?.isEmpty ?? true ? nil : reviewTextView.text
                try await orderRepository?.submitOrderRating(
                    orderId: orderId,
                    ratedUserId: ratedUserId,
                    rating: selectedRating,
                    review: review
                )
                
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.showAlert(
                        title: "Success".localized,
                        message: "Rating submitted successfully".localized
                    ) { [weak self] in
                        self?.onRatingSuccess?()
                        self?.dismiss(animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.submitButton.isEnabled = true
                    self.loadingIndicator.stopAnimating()
                    self.showAlert(
                        title: "Error".localized,
                        message: "Failed to submit rating".localized
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func updateStarDisplay() {
        for (index, button) in starButtons.enumerated() {
            let isFilled = index < selectedRating
            let starImage = UIImage(systemName: isFilled ? "star.fill" : "star")
            button.setImage(starImage, for: .normal)
            button.tintColor = isFilled ? .systemYellow : .systemGray3
        }
    }
    
    // MARK: - Helper Alert
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextView Placeholder
extension UITextView {
    var placeholder: String? {
        get {
            if let placeholderLabel = viewWithTag(999) as? UILabel {
                return placeholderLabel.text
            }
            return nil
        }
        set {
            if let placeholderLabel = viewWithTag(999) as? UILabel {
                placeholderLabel.text = newValue
            } else if let newValue = newValue {
                let placeholderLabel = UILabel()
                placeholderLabel.tag = 999
                placeholderLabel.text = newValue
                placeholderLabel.font = font
                placeholderLabel.textColor = .tertiaryLabel
                addSubview(placeholderLabel)
                placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainerInset.left + textContainer.lineFragmentPadding),
                    placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top)
                ])
                
                // Hide placeholder when text is entered
                NotificationCenter.default.addObserver(
                    forName: UITextView.textDidChangeNotification,
                    object: self,
                    queue: .main
                ) { [weak self] _ in
                    placeholderLabel.isHidden = !(self?.text.isEmpty ?? true)
                }
            }
        }
    }
}
