import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - ScrollView & Content
    private let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alwaysBounceVertical = true
        return v
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Profile Image + Camera Button
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "nishtha")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 2
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let cameraButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "camera.fill", withConfiguration: config), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.backgroundColor = UIColor(red: 16/255, green: 88/255, blue: 104/255, alpha: 1)
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.15
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        return btn
    }()

    // MARK: - Date Picker
    private let dobPicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .wheels
        dp.maximumDate = Date()
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    // MARK: - Section Titles
    private let personalInfoTitle = ProfileViewController.makeSectionLabel("Personal Information")
    private let addressInfoTitle = ProfileViewController.makeSectionLabel("Address Information")
    private let preferencesTitle = ProfileViewController.makeSectionLabel("Preferences")

    // MARK: - Containers
    private let personalContainer = ProfileViewController.makeSectionContainer()
    private let addressContainer = ProfileViewController.makeSectionContainer()
    private let preferencesContainer = ProfileViewController.makeSectionContainer()

    // MARK: - Personal Info Fields
    private let firstNameTF = ProfileViewController.makeFormTextField(placeholder: "First Name")
    private let lastNameTF = ProfileViewController.makeFormTextField(placeholder: "Last Name")
    private let emailTF = ProfileViewController.makeFormTextField(placeholder: "Email")
    private let phoneTF = ProfileViewController.makeFormTextField(placeholder: "Phone")
    private let dobTF = ProfileViewController.makeFormTextField(placeholder: "Date of Birth")
    private let genderTF = ProfileViewController.makeFormTextField(placeholder: "Gender")

    // MARK: - Address Fields
    private let addressTF = ProfileViewController.makeFormTextField(placeholder: "Address")
    private let cityTF = ProfileViewController.makeFormTextField(placeholder: "City")
    private let stateTF = ProfileViewController.makeFormTextField(placeholder: "State")
    private let zipTF = ProfileViewController.makeFormTextField(placeholder: "ZIP Code")

    // MARK: - Preferences
    private let emailSwitch = UISwitch()
    private let smsSwitch = UISwitch()

    // MARK: - Constants
    private let horizontalPadding: CGFloat = 16

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Profile"

        setupHierarchy()
        setupConstraints()
        setupDataPlaceholder()
        configureInteractions()
        setupDOBPicker()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        // Restore floating tab bar style if custom class
        if let tab = tabBarController as? MainTabBarController {
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }

    // MARK: - UI Setup (Hierarchy)
    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileImageView)
        contentView.addSubview(cameraButton)

        contentView.addSubview(personalInfoTitle)
        contentView.addSubview(personalContainer)

        contentView.addSubview(addressInfoTitle)
        contentView.addSubview(addressContainer)

        contentView.addSubview(preferencesTitle)
        contentView.addSubview(preferencesContainer)

        // MARK: Personal Stack
        let personalStack = makeFormStack(rows: [
            makeLabelledRow(title: "First Name", field: firstNameTF),
            makeLabelledRow(title: "Last Name", field: lastNameTF),
            makeLabelledRow(title: "Email", field: emailTF),
            makeLabelledRow(title: "Phone", field: phoneTF),
            makeLabelledRow(title: "Date of Birth", field: dobTF),
            makeLabelledRow(title: "Gender", field: genderTF)
        ])
        personalContainer.addSubview(personalStack)

        // MARK: Address Stack
        let addressStack = makeFormStack(rows: [
            makeLabelledRow(title: "Address", field: addressTF),
            makeLabelledRow(title: "City", field: cityTF),
            makeLabelledRow(title: "State", field: stateTF),
            makeLabelledRow(title: "ZIP Code", field: zipTF)
        ])
        addressContainer.addSubview(addressStack)

        // MARK: Preferences Stack
        let preferencesStack = UIStackView(arrangedSubviews: [
            makeLabelledSwitchRow(title: "Email Notifications", sw: emailSwitch),
            makeLabelledSwitchRow(title: "SMS Notifications", sw: smsSwitch)
        ])
        preferencesStack.axis = .vertical
        preferencesStack.spacing = 12
        preferencesStack.translatesAutoresizingMaskIntoConstraints = false
        preferencesContainer.addSubview(preferencesStack)
    }

    // MARK: - Constraints
    private func setupConstraints() {
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

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 110),
            profileImageView.heightAnchor.constraint(equalToConstant: 110),

            cameraButton.widthAnchor.constraint(equalToConstant: 40),
            cameraButton.heightAnchor.constraint(equalToConstant: 40),
            cameraButton.centerXAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: profileImageView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            personalInfoTitle.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            personalInfoTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            personalInfoTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),

            personalContainer.topAnchor.constraint(equalTo: personalInfoTitle.bottomAnchor, constant: 10),
            personalContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            personalContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])

        if let personalStack = personalContainer.subviews.first as? UIStackView {
            NSLayoutConstraint.activate([
                personalStack.topAnchor.constraint(equalTo: personalContainer.topAnchor, constant: 12),
                personalStack.leadingAnchor.constraint(equalTo: personalContainer.leadingAnchor, constant: 12),
                personalStack.trailingAnchor.constraint(equalTo: personalContainer.trailingAnchor, constant: -12),
                personalStack.bottomAnchor.constraint(equalTo: personalContainer.bottomAnchor, constant: -12)
            ])
        }

        NSLayoutConstraint.activate([
            addressInfoTitle.topAnchor.constraint(equalTo: personalContainer.bottomAnchor, constant: 24),
            addressInfoTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            addressInfoTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),

            addressContainer.topAnchor.constraint(equalTo: addressInfoTitle.bottomAnchor, constant: 10),
            addressContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            addressContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])

        if let addressStack = addressContainer.subviews.first as? UIStackView {
            NSLayoutConstraint.activate([
                addressStack.topAnchor.constraint(equalTo: addressContainer.topAnchor, constant: 12),
                addressStack.leadingAnchor.constraint(equalTo: addressContainer.leadingAnchor, constant: 12),
                addressStack.trailingAnchor.constraint(equalTo: addressContainer.trailingAnchor, constant: -12),
                addressStack.bottomAnchor.constraint(equalTo: addressContainer.bottomAnchor, constant: -12)
            ])
        }

        NSLayoutConstraint.activate([
            preferencesTitle.topAnchor.constraint(equalTo: addressContainer.bottomAnchor, constant: 24),
            preferencesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            preferencesTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),

            preferencesContainer.topAnchor.constraint(equalTo: preferencesTitle.bottomAnchor, constant: 10),
            preferencesContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            preferencesContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            preferencesContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])

        if let preferencesStack = preferencesContainer.subviews.first as? UIStackView {
            NSLayoutConstraint.activate([
                preferencesStack.topAnchor.constraint(equalTo: preferencesContainer.topAnchor, constant: 12),
                preferencesStack.leadingAnchor.constraint(equalTo: preferencesContainer.leadingAnchor, constant: 12),
                preferencesStack.trailingAnchor.constraint(equalTo: preferencesContainer.trailingAnchor, constant: -12),
                preferencesStack.bottomAnchor.constraint(equalTo: preferencesContainer.bottomAnchor, constant: -12)
            ])
        }
    }

    // MARK: - Data Placeholder
    private func setupDataPlaceholder() {
        firstNameTF.text = "Nishtha"
        lastNameTF.text = "Goyal"
        emailTF.text = "ng7389@srmist.edu.in"
        phoneTF.text = "+91 75877 87910"
        dobTF.text = "June 2024"
        genderTF.text = "Female"
        addressTF.text = "123 Main Street"
        cityTF.text = "New York"
        stateTF.text = "NY"
        zipTF.text = "10001"
        emailSwitch.isOn = true
        smsSwitch.isOn = false
    }

    // MARK: - Interactions
    private func configureInteractions() {
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)
    }

    @objc private func cameraTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .automatic
        present(picker, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - DOB Picker Setup
    private func setupDOBPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDOBPicker))
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDOBPicker))

        toolbar.setItems([cancel, space, done], animated: false)

        dobTF.inputView = dobPicker
        dobTF.inputAccessoryView = toolbar
    }

    @objc private func doneDOBPicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        dobTF.text = formatter.string(from: dobPicker.date)
        view.endEditing(true)
    }

    @objc private func cancelDOBPicker() {
        view.endEditing(true)
    }
}

// MARK: - Image Picker
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        defer { picker.dismiss(animated: true) }

        if let img = info[.originalImage] as? UIImage {
            profileImageView.image = img
        } else if let img = info[.editedImage] as? UIImage {
            profileImageView.image = img
        }
    }
}

// MARK: - UI Builders
private extension ProfileViewController {

    static func makeSectionLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 17, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    static func makeSectionContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 14
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        return view
    }

    static func makeFormTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.textAlignment = .right
        tf.font = .systemFont(ofSize: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }

    func makeFormStack(rows: [UIStackView]) -> UIStackView {
        let v = UIStackView(arrangedSubviews: rows)
        v.axis = .vertical
        v.spacing = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    func makeLabelledRow(title: String, field: UITextField) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        let spacer = UIView()

        let row = UIStackView(arrangedSubviews: [titleLabel, spacer, field])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true

        let wrapper = UIStackView(arrangedSubviews: [row, divider])
        wrapper.axis = .vertical
        wrapper.spacing = 6
        return wrapper
    }

    func makeLabelledSwitchRow(title: String, sw: UISwitch) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title

        let spacer = UIView()

        let row = UIStackView(arrangedSubviews: [titleLabel, spacer, sw])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true

        let wrapper = UIStackView(arrangedSubviews: [row, divider])
        wrapper.axis = .vertical
        wrapper.spacing = 6
        return wrapper
    }
}
