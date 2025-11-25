//
//  AddNewAddressViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 18/11/25.
//

import UIKit

struct UserAddress {
    var name: String
    var phone: String
    var address1: String
    var address2: String
    var city: String
    var state: String
    var pincode: String
}

class AddNewAddressViewController: UIViewController {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let navBar = UIView()
    private let backButton = UIButton(type: .system)
    private let heartButton = UIButton(type: .system)
    private let titleLabel = UILabel()

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

    var savedAddress: UserAddress?

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

    // MARK: NAVBAR (exact Figma)
    private func setupNavBar() {
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -55),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 100) // Reduced height like iOS navbar
        ])


        // Back Button
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navBar.addSubview(backButton)

        // Heart Button
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .black
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(heartButton)

        // Title
        titleLabel.text = "Add New Address"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor, constant: 2),

            heartButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor, constant: 2),

            titleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navBar.centerYAnchor, constant: 2)
        ])
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
            scrollView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 10),
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
        sectionLabel.text = "Current Address"
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

    // MARK: TEXT FIELDS EXACT LIKE FIGMA
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
            field.setLeftPaddingPoints(10)

            whiteContainer.addSubview(field)

            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: whiteContainer.leadingAnchor, constant: 15),
                field.trailingAnchor.constraint(equalTo: whiteContainer.trailingAnchor, constant: -15),
                field.heightAnchor.constraint(equalToConstant: 50)
            ])

            if let lastField = last {
                field.topAnchor.constraint(equalTo: lastField.bottomAnchor, constant: 0.3).isActive = true

                // Divider line
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

        // Constrain container bottom
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

        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: whiteContainer.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: Save Handler
    @objc private func saveAddress() {
        savedAddress = UserAddress(
            name: nameField.text ?? "",
            phone: phoneField.text ?? "",
            address1: address1Field.text ?? "",
            address2: address2Field.text ?? "",
            city: cityField.text ?? "",
            state: stateField.text ?? "",
            pincode: pincodeField.text ?? ""
        )

        let alert = UIAlertController(title: "Success", message: "Address Saved Successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}





//// ----------------------------------------------------------------------
//// MARK: - UITextField Padding Extension
//// ----------------------------------------------------------------------
//extension UITextField {
//    func setLeftPaddingPoints(_ amount: CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//    }
//}

//// Padding helper
//extension UITextField {
//    func setLeftPaddingPoints(_ amount: CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
//        leftView = paddingView
//        leftViewMode = .always
//    }
//}

//// Padding helper
//extension UITextField {
//    func setLeftPaddingPoints(_ amount: CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//    }
//}
