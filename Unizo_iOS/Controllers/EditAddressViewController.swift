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
    private weak var activeTextField: UITextField?

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
        setupKeyboardHandling()
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        applyKeyboardShift(0, notification: notification)
    }

    @objc private func handleKeyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let activeField = activeTextField
        else {
            return
        }

        let keyboardFrame = view.convert(endFrameValue.cgRectValue, from: nil)
        let fieldFrame = activeField.convert(activeField.bounds, to: view)
        let overlap = fieldFrame.maxY + 16 - keyboardFrame.minY
        applyKeyboardShift(max(0, overlap), notification: notification)
    }

    private func applyKeyboardShift(_ shift: CGFloat, notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRawValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue
            ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
        let options = UIView.AnimationOptions(rawValue: curveRawValue << 16)

        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -max(0, shift))
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        title = "Edit Hotspot".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )

        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Save".localized,
                style: .prominent,
                target: self,
                action: #selector(savePressed)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Save".localized,
                style: .done,
                target: self,
                action: #selector(savePressed)
            )
        }
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

        [nameField, phoneField, line1Field, cityField, stateField, pincodeField].forEach {
            $0.delegate = self
        }
        nameField.returnKeyType = .next
        line1Field.returnKeyType = .next
        cityField.returnKeyType = .next
        stateField.returnKeyType = .next
        pincodeField.returnKeyType = .done

        // Add Done toolbar for numeric keypads (no Return key)
        let phoneToolbar = UIToolbar()
        phoneToolbar.sizeToFit()
        let phoneDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        phoneToolbar.items = [UIBarButtonItem.flexibleSpace(), phoneDoneButton]
        phoneField.inputAccessoryView = phoneToolbar

        let pincodeToolbar = UIToolbar()
        pincodeToolbar.sizeToFit()
        let pincodeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        pincodeToolbar.items = [UIBarButtonItem.flexibleSpace(), pincodeDoneButton]
        pincodeField.inputAccessoryView = pincodeToolbar
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
        label.text = "Set as default hotspot".localized
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
                showError("Failed to save hotspot")
            }
        }
    }

    // MARK: - Validation
    private func validate() -> Bool {
        //if phoneField.text?.count != 10 {
            //showError("Phone number must be 10 digits")
        // Extract only digits from phone number (ignores +91, spaces, etc.)
                let phoneDigits = phoneField.text?.filter { $0.isNumber } ?? ""
                if phoneDigits.count < 10 {
                    showError("Phone number must have at least 10 digits")
            return false
        }

        //if pincodeField.text?.count != 6 {
        let pincodeDigits = pincodeField.text?.filter { $0.isNumber } ?? ""
                if pincodeDigits.count != 6 {
            showError("Pincode must be 6 digits")
            return false
        }

        return true
    }

    private func showError(_ msg: String) {
        let alert = UIAlertController(title: "Error".localized, message: msg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK".localized, style: .default))
        present(alert, animated: true)
    }
}

extension EditAddressViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if activeTextField === textField {
            activeTextField = nil
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            line1Field.becomeFirstResponder()
        case line1Field:
            cityField.becomeFirstResponder()
        case cityField:
            stateField.becomeFirstResponder()
        case stateField:
            pincodeField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
