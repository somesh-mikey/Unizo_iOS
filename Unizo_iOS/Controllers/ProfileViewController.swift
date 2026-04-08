import UIKit
import FirebaseStorage
import FirebaseAuth

final class ProfileViewController: UIViewController {

    // MARK: - Edit Mode State
    private var isEditMode = false

    // MARK: - Data
    private let userRepository = UserRepository()
    private let addressRepository = AddressRepository()
    private var currentUser: UserDTO?
    private var currentAddress: AddressDTO?

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
    private let genderOptions = ["Male".localized, "Female".localized, "Neutral".localized]
    private let genderPicker = UIPickerView()

    // MARK: - Section Titles
    private let personalInfoTitle = ProfileViewController.makeSectionLabel("Personal Information".localized)
    private let addressInfoTitle = ProfileViewController.makeSectionLabel("Hotspot Information".localized)
    private let preferencesTitle = ProfileViewController.makeSectionLabel("Preferences".localized)

    // MARK: - Containers
    private let personalContainer = ProfileViewController.makeSectionContainer()
    private let addressContainer = ProfileViewController.makeSectionContainer()
    private let preferencesContainer = ProfileViewController.makeSectionContainer()

    // MARK: - Personal Info Fields (all start non-editable until Edit is tapped)
    private let firstNameTF = ProfileViewController.makeFormTextField(placeholder: "First Name".localized, isEditable: false)
    private let lastNameTF = ProfileViewController.makeFormTextField(placeholder: "Last Name".localized, isEditable: false)
    private let emailTF = ProfileViewController.makeFormTextField(placeholder: "Email".localized, isEditable: false) // Email tied to auth, never editable
    private let phoneTF = ProfileViewController.makeFormTextField(placeholder: "Phone".localized, isEditable: false)
    private let dobTF = ProfileViewController.makeFormTextField(placeholder: "Date of Birth".localized, isEditable: false)
    private let genderTF = ProfileViewController.makeFormTextField(placeholder: "Gender".localized, isEditable: false)

    // MARK: - Address Fields
    private let addressTF = ProfileViewController.makeFormTextField(placeholder: "Address".localized, isEditable: false)
    private let cityTF = ProfileViewController.makeFormTextField(placeholder: "City".localized, isEditable: false)
    private let stateTF = ProfileViewController.makeFormTextField(placeholder: "State".localized, isEditable: false)
    private let zipTF = ProfileViewController.makeFormTextField(placeholder: "ZIP Code".localized, isEditable: false)

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
        btn.setTitle("Save Changes".localized, for: .normal)
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
        navigationItem.title = "Profile".localized

        setupNavigationBar()
        setupHierarchy()
        setupConstraints()
        configureInteractions()
        setupDOBPicker()
        setupGenderPicker()
        setupNumericKeyboards()
        setupKeyboardHandling()
        loadUserData()
        setEditMode(false) // Start in view-only mode
    }

    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        // Edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit".localized,
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }

    @objc private func editButtonTapped() {
        if isEditMode {
            // Save and exit edit mode
            saveProfileTapped()
        } else {
            // Enter edit mode
            setEditMode(true)
        }
    }

    // MARK: - Edit Mode Toggle
    private func setEditMode(_ editing: Bool) {
        isEditMode = editing

        // Update navigation button with proper SF Symbol
        if editing {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            let checkmarkImage = UIImage(systemName: "checkmark", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            let checkmarkButton = UIBarButtonItem(
                image: checkmarkImage,
                style: .plain,
                target: self,
                action: #selector(editButtonTapped)
            )
            checkmarkButton.tintColor = .black
            navigationItem.rightBarButtonItem = checkmarkButton
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit".localized,
                style: .plain,
                target: self,
                action: #selector(editButtonTapped)
            )
        }

        // Toggle personal info field editability (except email which is never editable)
        let personalEditableFields = [firstNameTF, lastNameTF, phoneTF, dobTF, genderTF]
        for field in personalEditableFields {
            field.isUserInteractionEnabled = editing
            field.textColor = editing ? .systemBlue : .label
        }

        // Email is never editable (tied to authentication)
        emailTF.isUserInteractionEnabled = false
        emailTF.textColor = .label

        // Toggle address/hotspot field editability
        let addressEditableFields = [addressTF, cityTF, stateTF, zipTF]
        for field in addressEditableFields {
            field.isUserInteractionEnabled = editing
            field.textColor = editing ? .systemBlue : .label
        }

        // Camera button visibility
        cameraButton.isHidden = !editing

        // Save button visibility
        saveButton.isHidden = !editing

        // Animate the transition
        UIView.animate(withDuration: 0.25) {
            self.cameraButton.alpha = editing ? 1 : 0
            self.saveButton.alpha = editing ? 1 : 0
        }
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
            makeLabelledRow(title: "First Name".localized, field: firstNameTF),
            makeLabelledRow(title: "Last Name".localized, field: lastNameTF),
            makeLabelledRow(title: "Email".localized, field: emailTF),
            makeLabelledRow(title: "Phone".localized, field: phoneTF),
            makeLabelledRow(title: "Date of Birth".localized, field: dobTF),
            makeLabelledRow(title: "Gender".localized, field: genderTF)
        ])
        personalContainer.addSubview(personalStack)

        // MARK: Address Stack
        let addressStack = makeFormStack(rows: [
            makeLabelledRow(title: "Address".localized, field: addressTF),
            makeLabelledRow(title: "City".localized, field: cityTF),
            makeLabelledRow(title: "State".localized, field: stateTF),
            makeLabelledRow(title: "ZIP Code".localized, field: zipTF)
        ])
        addressContainer.addSubview(addressStack)

        // MARK: Preferences Stack
        let preferencesStack = UIStackView(arrangedSubviews: [
            makeLabelledSwitchRow(title: "Email Notifications".localized, sw: emailSwitch),
            makeLabelledSwitchRow(title: "SMS Notifications".localized, sw: smsSwitch)
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
            var user: UserDTO?
            var defaultAddress: AddressDTO?

            do {
                user = try await userRepository.fetchCurrentUser()
            } catch {
                print("Failed to load profile user:", error)
            }

            do {
                let addresses = try await addressRepository.fetchAddresses()
                defaultAddress = addresses.first(where: { $0.is_default }) ?? addresses.first
            } catch {
                print("Failed to load hotspot info:", error)
            }

            await MainActor.run {
                self.currentUser = user
                self.currentAddress = defaultAddress
                self.populateUserData(user, address: defaultAddress)
            }
        }
    }

    private func populateUserData(_ user: UserDTO?, address: AddressDTO?) {
        let authUser = Auth.auth().currentUser

        let authDisplayName = authUser?.displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nameParts = authDisplayName
            .split(separator: " ", omittingEmptySubsequences: true)
            .map(String.init)
        let fallbackFirstName = nameParts.first ?? ""
        let fallbackLastName = nameParts.dropFirst().joined(separator: " ")
        let fallbackEmail = authUser?.email ?? ""
        let fallbackPhone = authUser?.phoneNumber ?? ""

        let resolvedFirstName = user?.first_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resolvedLastName = user?.last_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resolvedEmail = user?.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resolvedPhone = user?.phone?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Personal info
        firstNameTF.text = resolvedFirstName.isEmpty ? fallbackFirstName : resolvedFirstName
        lastNameTF.text = resolvedLastName.isEmpty ? fallbackLastName : resolvedLastName
        emailTF.text = resolvedEmail.isEmpty ? fallbackEmail : resolvedEmail
        phoneTF.text = resolvedPhone.isEmpty ? fallbackPhone : resolvedPhone
        dobTF.text = user?.date_of_birth ?? ""
        genderTF.text = user?.gender ?? ""

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
        emailSwitch.isOn = user?.email_notifications ?? false
        smsSwitch.isOn = user?.sms_notifications ?? false

        // Profile image
        if let imageUrlString = user?.profile_image_url,
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
        saveButton.setTitle("Saving...".localized, for: .normal)

        // Temporarily disable the checkmark button during save
        navigationItem.rightBarButtonItem?.isEnabled = false

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
                let addressUpdate = try await buildAddressUpdateIfNeeded()

                try await userRepository.updateProfile(profileUpdate)

                if let addressUpdate {
                    if addressUpdate.id == nil {
                        try await addressRepository.createAddress(addressUpdate)
                    } else {
                        try await addressRepository.updateAddress(addressUpdate)
                    }
                }

                await MainActor.run {
                    // Update local currentUser
                    currentUser?.first_name = profileUpdate.first_name
                    currentUser?.last_name = profileUpdate.last_name
                    currentUser?.phone = profileUpdate.phone
                    currentUser?.date_of_birth = profileUpdate.date_of_birth
                    currentUser?.gender = profileUpdate.gender

                    if let addressUpdate {
                        currentAddress = addressUpdate
                    }

                    // Reset button state
                    saveButton.isEnabled = true
                    saveButton.setTitle("Save Changes".localized, for: .normal)
                    navigationItem.rightBarButtonItem?.isEnabled = true

                    // Exit edit mode after successful save
                    setEditMode(false)

                    // Reload to sync with server state (especially new address IDs).
                    loadUserData()

                    // Show success feedback (brief toast or just visual change)
                    print("✅ Profile updated successfully")
                }
            } catch {
                print("Failed to save profile:", error)
                await MainActor.run {
                    saveButton.isEnabled = true
                    saveButton.setTitle("Save Changes".localized, for: .normal)
                    navigationItem.rightBarButtonItem?.isEnabled = true
                    showAlert(title: "Error".localized, message: "\("Failed to save profile:".localized) \(error.localizedDescription)")
                }
            }
        }
    }

    private func buildAddressUpdateIfNeeded() async throws -> AddressDTO? {
        let line1 = addressTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let city = cityTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let state = stateTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let postalCode = zipTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let hasAnyHotspotInput = ![line1, city, state, postalCode].allSatisfy { $0.isEmpty }
        guard hasAnyHotspotInput else { return nil }

        guard !line1.isEmpty, !city.isEmpty, !state.isEmpty, !postalCode.isEmpty else {
            throw NSError(
                domain: "ProfileViewController",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Please complete all hotspot fields before saving.".localized]
            )
        }

        let profileName = [
            firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            lastNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ]
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let fallbackName = currentUser?.displayName ?? "Home"
        let resolvedName = profileName.isEmpty ? fallbackName : profileName

        let profilePhone = phoneTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resolvedPhone = profilePhone.isEmpty ? (currentUser?.phone ?? "") : profilePhone

        if var existingAddress = currentAddress {
            existingAddress.name = resolvedName
            existingAddress.phone = resolvedPhone
            existingAddress.line1 = line1
            existingAddress.city = city
            existingAddress.state = state
            existingAddress.postal_code = postalCode
            return existingAddress
        }

        guard let userId = await AuthManager.shared.currentUserId else {
            throw NSError(
                domain: "ProfileViewController",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated".localized]
            )
        }

        return AddressDTO(
            id: nil,
            user_id: userId,
            name: resolvedName,
            phone: resolvedPhone,
            line1: line1,
            city: city,
            state: state,
            postal_code: postalCode,
            country: currentAddress?.country ?? "India",
            is_default: true
        )
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(alert, animated: true)
    }

    @objc private func cameraTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
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

        let doneStyle: UIBarButtonItem.Style
        if #available(iOS 26.0, *) {
            doneStyle = .prominent
        } else {
            doneStyle = .done
        }

        let cancel = UIBarButtonItem(title: "Cancel".localized, style: .plain, target: self, action: #selector(cancelDOBPicker))
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(title: "Done".localized, style: doneStyle, target: self, action: #selector(doneDOBPicker))

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

        let doneStyle: UIBarButtonItem.Style
        if #available(iOS 26.0, *) {
            doneStyle = .prominent
        } else {
            doneStyle = .done
        }

        let cancel = UIBarButtonItem(title: "Cancel".localized, style: .plain, target: self, action: #selector(cancelGenderPicker))
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(title: "Done".localized, style: doneStyle, target: self, action: #selector(doneGenderPicker))

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

    // MARK: - Numeric Keyboard Setup
    private func setupNumericKeyboards() {
        // Phone field - phone pad
        phoneTF.keyboardType = .phonePad
        let phoneToolbar = UIToolbar()
        phoneToolbar.sizeToFit()
        let phoneDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        phoneToolbar.items = [UIBarButtonItem.flexibleSpace(), phoneDoneButton]
        phoneTF.inputAccessoryView = phoneToolbar

        // ZIP Code field - number pad
        zipTF.keyboardType = .numberPad
        let zipToolbar = UIToolbar()
        zipToolbar.sizeToFit()
        let zipDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        zipToolbar.items = [UIBarButtonItem.flexibleSpace(), zipDoneButton]
        zipTF.inputAccessoryView = zipToolbar
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
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            return
        }

        // Show the selected image immediately for feedback
        profileImageView.image = image

        // Upload the image to storage
        uploadProfileImage(image)
    }

    private func uploadProfileImage(_ image: UIImage) {
        // Spinner overlay on the profileImageView
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        overlayView.layer.cornerRadius = 55
        overlayView.clipsToBounds = true
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor)
        ])
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        overlayView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
        ])
        
        // Prevent saving while uploading
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false

        Task {
            defer {
                Task { @MainActor in
                    overlayView.removeFromSuperview()
                    self.saveButton.isEnabled = true
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
            do {
                guard let imageData = image.jpegData(compressionQuality: 0.75) else {
                    throw NSError(domain: "ProfileImage", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "Image compression failed"])
                }
                print("📸 Compressed image size: \(imageData.count) bytes")

                guard let userId = await AuthManager.shared.currentUserId else {
                    throw NSError(domain: "ProfileImage", code: 401,
                                  userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                }
                print("👤 Uploading for user: \(userId)")

                // Fixed per-user path so repeated saves overwrite the same file
                let filePath = "profiles/\(userId)/avatar.jpg"
                print("📁 Storage path: \(filePath)")

                let storageRef = Storage.storage().reference()
                    .child("product-images")
                    .child(filePath)

                // Retry upload up to 3 times to handle transient network drops.
                var uploadError: Error?
                for attempt in 1...3 {
                    do {
                        _ = try await storageRef.putDataAsync(imageData)
                        print("✅ Storage upload complete (attempt \(attempt))")
                        uploadError = nil
                        break
                    } catch {
                        let nsErr = error as NSError
                        print("⚠️ Upload attempt \(attempt) error — domain:\(nsErr.domain) code:\(nsErr.code)")
                        uploadError = error
                        if attempt < 3 {
                            print("🔄 Retrying in 1.5s...")
                            try await Task.sleep(nanoseconds: 1_500_000_000)
                        }
                    }
                }
                if let err = uploadError { throw err }

                let publicURL = try await storageRef.downloadURL()

                let urlString = publicURL.absoluteString
                let separator = urlString.contains("?") ? "&" : "?"
                let cacheBusted = urlString + "\(separator)v=\(Int(Date().timeIntervalSince1970))"
                print("🌐 Public URL: \(cacheBusted)")

                try await userRepository.updateProfileImageURL(cacheBusted)
                print("✅ DB row updated")

                await MainActor.run {
                    self.currentUser?.profile_image_url = cacheBusted
                    self.profileImageView.image = image
                    self.profileImageView.tintColor = nil
                    print("✅ UI updated successfully")
                }

            } catch {
                print("❌ uploadProfileImage failed: \(error)")
                await MainActor.run {
                    if let url = self.currentUser?.profile_image_url, !url.isEmpty {
                        self.profileImageView.loadImage(from: url)
                    } else {
                        self.profileImageView.image = UIImage(systemName: "person.circle.fill")
                        self.profileImageView.tintColor = .systemGray3
                    }
                    self.showAlert(title: "Upload Failed".localized,
                                   message: "Could not save your picture: \(error.localizedDescription)")
                }
            }
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
        divider.heightAnchor.constraint(equalToConstant: 1 / max(view.traitCollection.displayScale, 1)).isActive = true

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
        divider.heightAnchor.constraint(equalToConstant: 1 / max(view.traitCollection.displayScale, 1)).isActive = true

        let wrapper = UIStackView(arrangedSubviews: [row, divider])
        wrapper.axis = .vertical
        wrapper.spacing = 6
        return wrapper
    }
}
