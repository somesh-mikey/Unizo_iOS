//
//  EditAddressViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 19/11/25.
//

import UIKit

final class EditAddressViewController: UIViewController {

    private let repository = AddressRepository()
    private var address: AddressDTO
    var onSave: (() -> Void)?

    // MARK: - Fields
    private let nameField = UITextField()
    private let phoneField = UITextField()
    private let line1Field = UITextField()
    private let cityField = UITextField()
    private let stateField = UITextField()
    private let pincodeField = UITextField()
    private let defaultSwitch = UISwitch()

    // MARK: - Init
    init(address: AddressDTO) {
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1, alpha: 1)

        setupNavBar()
        setupForm()
        populateFields()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - UI
    private func setupNavBar() {
        title = "Edit Address"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(savePressed)
        )
    }

    private func setupForm() {
        let stack = UIStackView(arrangedSubviews: [
            field("Name", nameField),
            field("Phone", phoneField),
            field("Address Line", line1Field),
            field("City", cityField),
            field("State", stateField),
            field("Pincode", pincodeField),
            defaultRow()
        ])

        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        phoneField.keyboardType = .phonePad
        pincodeField.keyboardType = .numberPad
    }

    private func field(_ title: String, _ field: UITextField) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)

        field.borderStyle = .roundedRect
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 6

        return stack
    }

    private func defaultRow() -> UIView {
        let label = UILabel()
        label.text = "Set as default address"
        label.font = .systemFont(ofSize: 14, weight: .medium)

        let row = UIStackView(arrangedSubviews: [label, defaultSwitch])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    // MARK: - Data
    private func populateFields() {
        nameField.text = address.name
        phoneField.text = address.phone
        line1Field.text = address.line1
        cityField.text = address.city
        stateField.text = address.state
        pincodeField.text = address.postal_code
        defaultSwitch.isOn = address.is_default
    }

    // MARK: - Actions
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func savePressed() {
        guard validate() else { return }

        address.name = nameField.text!
        address.phone = phoneField.text!
        address.line1 = line1Field.text!
        address.city = cityField.text!
        address.state = stateField.text!
        address.postal_code = pincodeField.text!
        address.is_default = defaultSwitch.isOn

        Task {
            do {
                try await repository.updateAddress(address)
                await MainActor.run {
                    onSave?()
                    navigationController?.popViewController(animated: true)
                }
            } catch {
                showError("Failed to save address")
            }
        }
    }

    // MARK: - Validation
    private func validate() -> Bool {
        if phoneField.text?.count != 10 {
            showError("Phone number must be 10 digits")
            return false
        }

        if pincodeField.text?.count != 6 {
            showError("Pincode must be 6 digits")
            return false
        }

        return true
    }

    private func showError(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
