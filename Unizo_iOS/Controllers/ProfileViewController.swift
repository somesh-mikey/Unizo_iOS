import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Data
    private let userRepository = UserRepository()
    private let addressRepository = AddressRepository()
    private var currentUser: UserDTO?

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
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = UIColor.systemGray3
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

    // MARK: - Gender Picker
    private let genderOptions = ["Male", "Female", "Neutral"]
    private let genderPicker = UIPickerView()

    // MARK: - Section Titles
    private let personalInfoTitle = ProfileViewController.makeSectionLabel("Personal Information")
    private let addressInfoTitle = ProfileViewController.makeSectionLabel("Hotspot Information")
    private let preferencesTitle = ProfileViewController.makeSectionLabel("Preferences")

    // MARK: - Containers
    private let personalContainer = ProfileViewController.makeSectionContainer()
    private let addressContainer = ProfileViewController.makeSectionContainer()
    private let preferencesContainer = ProfileViewController.makeSectionContainer()

    // MARK: - Personal Info Fields
    private let firstNameTF = ProfileViewController.makeFormTextField(placeholder: "First Name", isEditable: true)
    private let lastNameTF = ProfileViewController.makeFormTextField(placeholder: "Last Name", isEditable: true)
    private let emailTF = ProfileViewController.makeFormTextField(placeholder: "Email", isEditable: false) // Email tied to auth, not editable
    private let phoneTF = ProfileViewController.makeFormTextField(placeholder: "Phone", isEditable: true)
    private let dobTF = ProfileViewController.makeFormTextField(placeholder: "Date of Birth", isEditable: true)
    private let genderTF = ProfileViewController.makeFormTextField(placeholder: "Gender", isEditable: true)

    // MARK: - Address Fields
    private let addressTF = ProfileViewController.makeFormTextField(placeholder: "Address", isEditable: false)
    private let cityTF = ProfileViewController.makeFormTextField(placeholder: "City", isEditable: false)
    private let stateTF = ProfileViewController.makeFormTextField(placeholder: "State", isEditable: false)
    private let zipTF = ProfileViewController.makeFormTextField(placeholder: "ZIP Code", isEditable: false)

    // MARK: - Preferences
    private let emailSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)
        return sw
    }()
    private let smsSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)
        return sw
    }()

    // MARK: - Save Button
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Changes", for: .normal)
        btn.backgroundColor = UIColor(red: 0/255, green: 76/255, blue: 97/255, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Constants
    private let horizontalPadding: CGFloat = 16

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Profile"

        setupHierarchy()
        setupConstraints()
        configureInteractions()
        setupDOBPicker()
        setupGenderPicker()
        loadUserData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        // Restore floating tab bar style if custom class
        if let tab = tabBarController as? MainTabBarController {
        }
        self.tabBarController?.tabBar.isHidden = false
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
        contentView.addSubview(saveButton)

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
            preferencesContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])

        // Save Button constraints
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: preferencesContainer.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
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

    // MARK: - Load User Data
    private func loadUserData() {
        Task {
            do {
                // Fetch user profile
                let user = try await userRepository.fetchCurrentUser()
                // Fetch default address
                let addresses = try await addressRepository.fetchAddresses()
                let defaultAddress = addresses.first(where: { $0.is_default }) ?? addresses.first

                await MainActor.run {
                    self.currentUser = user
                    self.populateUserData(user, address: defaultAddress)
                }
            } catch {
                print("Failed to load user data:", error)
            }
        }
    }

    private func populateUserData(_ user: UserDTO?, address: AddressDTO?) {
        guard let user = user else { return }

        // Personal info
        firstNameTF.text = user.first_name ?? ""
        lastNameTF.text = user.last_name ?? ""
        emailTF.text = user.email ?? ""
        phoneTF.text = user.phone ?? ""
        dobTF.text = user.date_of_birth ?? ""
        genderTF.text = user.gender ?? ""

        // Address info (from default address)
        if let address = address {
            addressTF.text = address.line1
            cityTF.text = address.city
            stateTF.text = address.state
            zipTF.text = address.postal_code
        } else {
            addressTF.text = ""
            cityTF.text = ""
            stateTF.text = ""
            zipTF.text = ""
        }

        // Notification preferences
        emailSwitch.isOn = user.email_notifications ?? false
        smsSwitch.isOn = user.sms_notifications ?? false

        // Profile image
        if let imageUrlString = user.profile_image_url,
           let imageUrl = URL(string: imageUrlString) {
            loadProfileImage(from: imageUrl)
        }
    }

    private func loadProfileImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.profileImageView.image = image
                        self.profileImageView.tintColor = nil
                    }
                }
            } catch {
                print("Failed to load profile image:", error)
            }
        }
    }

    // MARK: - Interactions
    private func configureInteractions() {
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveProfileTapped), for: .touchUpInside)

        // Notification toggle handlers
        emailSwitch.addTarget(self, action: #selector(emailSwitchChanged), for: .valueChanged)
        smsSwitch.addTarget(self, action: #selector(smsSwitchChanged), for: .valueChanged)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)
    }

    @objc private func emailSwitchChanged() {
        saveNotificationPreferences()
    }

    @objc private func smsSwitchChanged() {
        saveNotificationPreferences()
    }

    private func saveNotificationPreferences() {
        Task {
            do {
                try await userRepository.updatePreferences(
                    emailNotifications: emailSwitch.isOn,
                    smsNotifications: smsSwitch.isOn
                )
                print("Notification preferences saved")
            } catch {
                print("Failed to save notification preferences:", error)
                // Revert the switch on error
                await MainActor.run {
                    if let user = currentUser {
                        emailSwitch.isOn = user.email_notifications ?? false
                        smsSwitch.isOn = user.sms_notifications ?? false
                    }
                }
            }
        }
    }

    @objc private func saveProfileTapped() {
        // Dismiss keyboard
        view.endEditing(true)

        // Show loading state
        saveButton.isEnabled = false
        saveButton.setTitle("Saving...", for: .normal)

        let profileUpdate = UserProfileUpdate(
            first_name: firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            last_name: lastNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phoneTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            date_of_birth: dobTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            gender: genderTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            profile_image_url: currentUser?.profile_image_url
        )

        Task {
            do {
                try await userRepository.updateProfile(profileUpdate)

                await MainActor.run {
                    // Update local currentUser
                    currentUser?.first_name = profileUpdate.first_name
                    currentUser?.last_name = profileUpdate.last_name
                    currentUser?.phone = profileUpdate.phone
                    currentUser?.date_of_birth = profileUpdate.date_of_birth
                    currentUser?.gender = profileUpdate.gender

                    // Reset button state
                    saveButton.isEnabled = true
                    saveButton.setTitle("Save Changes", for: .normal)

                    // Show success alert
                    showAlert(title: "Success", message: "Profile updated successfully")
                }
            } catch {
                print("Failed to save profile:", error)
                await MainActor.run {
                    saveButton.isEnabled = true
                    saveButton.setTitle("Save Changes", for: .normal)
                    showAlert(title: "Error", message: "Failed to save profile: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

    // MARK: - Gender Picker Setup
    private func setupGenderPicker() {
        genderPicker.delegate = self
        genderPicker.dataSource = self

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelGenderPicker))
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneGenderPicker))

        toolbar.setItems([cancel, space, done], animated: false)

        genderTF.inputView = genderPicker
        genderTF.inputAccessoryView = toolbar

        // Pre-select current value if exists
        if let currentGender = genderTF.text, !currentGender.isEmpty,
           let index = genderOptions.firstIndex(of: currentGender) {
            genderPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }

    @objc private func doneGenderPicker() {
        let selectedRow = genderPicker.selectedRow(inComponent: 0)
        genderTF.text = genderOptions[selectedRow]
        view.endEditing(true)
    }

    @objc private func cancelGenderPicker() {
        view.endEditing(true)
    }
}

// MARK: - Gender Picker Delegate
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTF.text = genderOptions[row]
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

    static func makeFormTextField(placeholder: String, isEditable: Bool = true) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.textAlignment = .right
        tf.font = .systemFont(ofSize: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isUserInteractionEnabled = isEditable
        if !isEditable {
            tf.textColor = .label
        }
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
