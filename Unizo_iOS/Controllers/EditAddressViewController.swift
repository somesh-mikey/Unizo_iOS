//
//  EditAddressViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 19/11/25.
//

import UIKit

class EditAddressViewController: UIViewController {

    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!   // hidden like previous screen
    @IBOutlet weak var fieldsContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!

    // UI Elements
    let backButton = UIButton()
    let heartButton = UIButton()
    let titleLabel = UILabel()

    let sectionLabel = UILabel()

    let nameField = UITextField()
    let phoneField = UITextField()
    let address1Field = UITextField()
    let address2Field = UITextField()
    let cityField = UITextField()
    let stateField = UITextField()
    let pincodeField = UITextField()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1.0)

        titleContainer.isHidden = true

        applyContainerConstraints()
        setupTopBar()
        setupFields()
        setupSaveButton()
    }


    // ------------------------------------------------------------
    // FIXED CONTAINER LAYOUT
    // ------------------------------------------------------------
    func applyContainerConstraints() {

        topBarContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        fieldsContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // TOP BAR (same height as figma)
            topBarContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 60),

            titleContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 1),

            fieldsContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: 20),
            fieldsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fieldsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fieldsContainer.bottomAnchor.constraint(lessThanOrEqualTo: saveButton.topAnchor, constant: -20)
        ])
    }


    // ------------------------------------------------------------
    // TOP BAR — identical to Add New Address
    // ------------------------------------------------------------
    func setupTopBar() {

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.translatesAutoresizingMaskIntoConstraints = false

        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .black
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Edit Address"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        topBarContainer.addSubview(backButton)
        topBarContainer.addSubview(heartButton)
        topBarContainer.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            heartButton.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 28),
            heartButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.centerXAnchor.constraint(equalTo: topBarContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor)
        ])
    }


    // ------------------------------------------------------------
    // FIELDS — prefilled values + same layout as Add New Address
    // ------------------------------------------------------------
    func setupFields() {

        sectionLabel.text = "Current Address"
        sectionLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        fieldsContainer.addSubview(sectionLabel)

        // PREFILLED DATA (edit mode)
        nameField.text = "Jonathan"
        phoneField.text = "90078 91599"
        address1Field.text = "4517 Washington Ave, Manchester"
        address2Field.text = ""
        cityField.text = "Manchester"
        stateField.text = "Kentucky"
        pincodeField.text = "39495"

        let stack = UIStackView(arrangedSubviews: [
            nameField,
            phoneField,
            address1Field,
            address2Field,
            cityField,
            stateField,
            pincodeField
        ])
        stack.axis = .vertical
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false

        fieldsContainer.addSubview(stack)

        setupTextField(nameField, "")
        setupTextField(phoneField, "")
        setupTextField(address1Field, "")
        setupTextField(address2Field, "Address Line 2 (Optional)")
        setupTextField(cityField, "")
        setupTextField(stateField, "")
        setupTextField(pincodeField, "")

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: fieldsContainer.topAnchor),
            sectionLabel.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor, constant: 20),

            stack.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 15),
            stack.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: fieldsContainer.trailingAnchor, constant: -20)
        ])
    }


    func setupTextField(_ tf: UITextField, _ placeholder: String) {
        tf.placeholder = placeholder
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        tf.setLeftPaddingPoints(12)
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }


    // ------------------------------------------------------------
    // SAVE BUTTON
    // ------------------------------------------------------------
    func setupSaveButton() {

        saveButton.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
        saveButton.setTitle("Save", for: .normal)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 24
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}

