//
//  AddNewAddressViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 18/11/25.
//

import UIKit

class AddNewAddressViewController: UIViewController {
    private let addressRepository = AddressRepository(client: supabase)
    var onSave: (() -> Void)?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let sectionLabel = UILabel()
    private let whiteContainer = UIView()

    // Text fields
    private let nameField = UITextField()
    private let phoneField = UITextField()
    private let address1Field = UITextField()
    private let address2Field = UITextField()
    private let cityField = UITextField()
    private let stateField = UITextField()
    private let pincodeField = UITextField()

    private let saveButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private var isSaving = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1, alpha: 1)

        setupNavBar()
        setupScrollView()
        setupSection()
        setupWhiteContainer()
        setupFields()
        setupSaveButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    private func validate() -> Bool {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else {
            showError("Name is required")
            return false
        }
        // Extract only digits from phone number (ignores +91, spaces, etc.)
        let phoneDigits = phoneField.text?.filter { $0.isNumber } ?? ""
        if phoneDigits.count < 10 {
            showError("Phone must have at least 10 digits")
            return false
        }
        guard let address1 = address1Field.text?.trimmingCharacters(in: .whitespaces), !address1.isEmpty else {
            showError("Address Line 1 is required")
            return false
        }
        guard let city = cityField.text?.trimmingCharacters(in: .whitespaces), !city.isEmpty else {
            showError("City is required")
            return false
        }
        guard let state = stateField.text?.trimmingCharacters(in: .whitespaces), !state.isEmpty else {
            showError("State is required")
            return false
        }
        let pincodeDigits = pincodeField.text?.filter { $0.isNumber } ?? ""
        if pincodeDigits.count != 6 {
            showError("Pincode must be 6 digits")
            return false
        }
        return true
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


    // MARK: - Navigation Bar
    private func setupNavBar() {
        title = "Add New Hotspot"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: Scroll View
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: Section Label
    private func setupSection() {
        sectionLabel.text = "Hotspot Details"
        sectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sectionLabel)

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }

    // MARK: White Container
    private func setupWhiteContainer() {
        whiteContainer.backgroundColor = .white
        whiteContainer.layer.cornerRadius = 20
        whiteContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(whiteContainer)

        NSLayoutConstraint.activate([
            whiteContainer.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            whiteContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            whiteContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: TEXT FIELDS
    private func setupFields() {

        let fields = [
            (nameField, "Name"),
            (phoneField, "Phone Number"),
            (address1Field, "Address Line 1"),
            (address2Field, "Address Line 2 (Optional)"),
            (cityField, "City"),
            (stateField, "State"),
            (pincodeField, "Pincode")
        ]

        var last: UIView? = nil

        for (field, placeholder) in fields {

            field.translatesAutoresizingMaskIntoConstraints = false
            field.placeholder = placeholder
            field.backgroundColor = .white
            field.font = UIFont.systemFont(ofSize: 15)

            whiteContainer.addSubview(field)

            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: whiteContainer.leadingAnchor, constant: 15),
                field.trailingAnchor.constraint(equalTo: whiteContainer.trailingAnchor, constant: -15),
                field.heightAnchor.constraint(equalToConstant: 50)
            ])

            if let lastField = last {
                field.topAnchor.constraint(equalTo: lastField.bottomAnchor, constant: 0.3).isActive = true

                let divider = UIView()
                divider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                divider.translatesAutoresizingMaskIntoConstraints = false
                whiteContainer.addSubview(divider)

                NSLayoutConstraint.activate([
                    divider.topAnchor.constraint(equalTo: lastField.bottomAnchor),
                    divider.leadingAnchor.constraint(equalTo: whiteContainer.leadingAnchor, constant: 15),
                    divider.trailingAnchor.constraint(equalTo: whiteContainer.trailingAnchor, constant: -15),
                    divider.heightAnchor.constraint(equalToConstant: 1)
                ])

            } else {
                field.topAnchor.constraint(equalTo: whiteContainer.topAnchor, constant: 15).isActive = true
            }

            last = field
        }

        if let lastField = last {
            lastField.bottomAnchor.constraint(equalTo: whiteContainer.bottomAnchor, constant: -15).isActive = true
        }
    }

    // MARK: Save Button
    private func setupSaveButton() {

        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)
        saveButton.layer.cornerRadius = 25
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveAddress), for: .touchUpInside)

        // Setup loading indicator
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(saveButton)
        saveButton.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: whiteContainer.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

            // Center loading indicator in button
            loadingIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }

    private func setLoading(_ loading: Bool) {
        isSaving = loading
        saveButton.isEnabled = !loading

        if loading {
            saveButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            saveButton.setTitle("Save", for: .normal)
            loadingIndicator.stopAnimating()
        }
    }

    // MARK: Save Handler
    @objc private func saveAddress() {
        guard !isSaving else { return }
        guard validate() else { return }

        setLoading(true)

        Task {
            do {
                // Get current user ID
                guard let userId = await AuthManager.shared.currentUserId else {
                    await MainActor.run {
                        self.setLoading(false)
                        self.showError("You must be logged in to add a hotspot")
                    }
                    return
                }

                let name = nameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
                let phone = phoneField.text?.trimmingCharacters(in: .whitespaces) ?? ""
                let line1 = address1Field.text?.trimmingCharacters(in: .whitespaces) ?? ""
                let city = cityField.text?.trimmingCharacters(in: .whitespaces) ?? ""
                let state = stateField.text?.trimmingCharacters(in: .whitespaces) ?? ""
                let postalCode = pincodeField.text?.trimmingCharacters(in: .whitespaces) ?? ""

                // Check for duplicate address
                let existingAddresses = try await addressRepository.fetchAddresses()
                let isDuplicate = existingAddresses.contains { existing in
                    existing.name.lowercased() == name.lowercased() &&
                    existing.phone == phone &&
                    existing.line1.lowercased() == line1.lowercased() &&
                    existing.city.lowercased() == city.lowercased() &&
                    existing.state.lowercased() == state.lowercased() &&
                    existing.postal_code == postalCode
                }

                if isDuplicate {
                    await MainActor.run {
                        self.setLoading(false)
                        self.showAlert(title: "Duplicate Address", message: "Hotspot already added")
                    }
                    return
                }

                let newAddress = AddressDTO(
                    id: UUID(),
                    user_id: userId,
                    name: name,
                    phone: phone,
                    line1: line1,
                    city: city,
                    state: state,
                    postal_code: postalCode,
                    country: "India",
                    is_default: false
                )

                try await addressRepository.createAddress(newAddress)

                await MainActor.run {
                    self.setLoading(false)
                    self.onSave?()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("❌ Failed to save hotspot:", error)
                await MainActor.run {
                    self.setLoading(false)
                    self.showError("Failed to save hotspot: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

