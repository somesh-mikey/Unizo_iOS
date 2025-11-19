//
//  AddNewAddressViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 18/11/25.
//

import UIKit

class AddNewAddressViewController: UIViewController {

    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!   // we will hide this
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

        titleContainer.isHidden = true  // ❗ remove white bar entirely

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

            // TOP BAR — same as figma single bar
            topBarContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 60),

            // Since titleContainer is hidden we keep minimal height
            titleContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 1),

            // FIELDS CONTAINER
            fieldsContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: 20),
            fieldsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fieldsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fieldsContainer.bottomAnchor.constraint(lessThanOrEqualTo: saveButton.topAnchor, constant: -20)
        ])
    }


    // ------------------------------------------------------------
    // TOP BAR — includes title centered with icons
    // ------------------------------------------------------------
    func setupTopBar() {

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.translatesAutoresizingMaskIntoConstraints = false

        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .black
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Add New Address"
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

            // Title centered between back + heart buttons
            titleLabel.centerXAnchor.constraint(equalTo: topBarContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor)
        ])
    }


    // ------------------------------------------------------------
    // FIELDS (same as before)
    // ------------------------------------------------------------
    func setupFields() {

        sectionLabel.text = "Current Address"
        sectionLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

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

        fieldsContainer.addSubview(sectionLabel)
        fieldsContainer.addSubview(stack)

        setupTextField(nameField, "Name")
        setupTextField(phoneField, "Phone Number")
        setupTextField(address1Field, "Address Line 1")
        setupTextField(address2Field, "Address Line 2 (Optional)")
        setupTextField(cityField, "City")
        setupTextField(stateField, "State")
        setupTextField(pincodeField, "Pincode")

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


// Padding helper
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
