//
//  PostEventViewController.swift
//  Unizo_iOS
//

import UIKit
import Supabase
import PhotosUI

final class PostEventViewController: UIViewController,
                                     PHPickerViewControllerDelegate {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - Scroll
    private let scrollView = TouchPassThroughScrollView()
    private let contentView = UIView()

    // MARK: - Image Upload
    private var selectedImage: UIImage?

    private let uploadCard: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let imagePreview: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let uploadPlaceholderIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "photo.badge.plus"))
        iv.tintColor = .brandPrimary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let uploadHintLabel: UILabel = {
        let l = UILabel()
        l.text = "Tap to add an event image".localized
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Event Details Card
    private let detailsCard: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let eventDetailsLabel: UILabel = {
        let l = UILabel()
        l.text = "Event Details".localized
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Text fields
    private let titleField    = PostEventViewController.makeTextField(placeholder: "Event Title".localized)
    private let venueField    = PostEventViewController.makeTextField(placeholder: "Venue".localized)
    private let priceField: UITextField = {
        let tf = PostEventViewController.makeTextField(placeholder: "Price (in Rupees)".localized)
        tf.keyboardType = .numberPad
        return tf
    }()

    // Date / Time pickers
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.minimumDate = Date()
        dp.tintColor = .brandPrimary
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    private let timePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .compact
        dp.tintColor = .brandPrimary
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    // Free toggle
    private let freeSwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .brandPrimary
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // Description
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 10
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let descriptionPlaceholder: UILabel = {
        let l = UILabel()
        l.text = "Describe your event...".localized
        l.font = .systemFont(ofSize: 16)
        l.textColor = .placeholderText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Post Button
    private let postButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Post Event".localized, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.backgroundColor = UIColor(red: 4/255, green: 68/255, blue: 95/255, alpha: 1)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 28
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Loading
    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupScrollView()
        setupImageUploadCard()
        setupDetailsCard()
        setupPostButton()
        setupKeyboardDismiss()

        freeSwitch.addTarget(self, action: #selector(freeSwitchChanged), for: .valueChanged)
        postButton.addTarget(self, action: #selector(postEventTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        (tabBarController as? MainTabBarController)?.hideFloatingTabBar()
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Navigation Bar

    private func setupNavBar() {
        title = "Post Event".localized
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Scroll View

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delaysContentTouches = false

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
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    // MARK: - Image Upload Card

    private func setupImageUploadCard() {
        contentView.addSubview(uploadCard)
        uploadCard.addSubview(imagePreview)
        uploadCard.addSubview(uploadPlaceholderIcon)
        uploadCard.addSubview(uploadHintLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        uploadCard.addGestureRecognizer(tap)
        uploadCard.isUserInteractionEnabled = true

        NSLayoutConstraint.activate([
            uploadCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            uploadCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uploadCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            uploadCard.heightAnchor.constraint(equalToConstant: 200),

            imagePreview.topAnchor.constraint(equalTo: uploadCard.topAnchor, constant: 12),
            imagePreview.leadingAnchor.constraint(equalTo: uploadCard.leadingAnchor, constant: 12),
            imagePreview.trailingAnchor.constraint(equalTo: uploadCard.trailingAnchor, constant: -12),
            imagePreview.bottomAnchor.constraint(equalTo: uploadCard.bottomAnchor, constant: -12),

            uploadPlaceholderIcon.centerXAnchor.constraint(equalTo: uploadCard.centerXAnchor),
            uploadPlaceholderIcon.centerYAnchor.constraint(equalTo: uploadCard.centerYAnchor, constant: -14),
            uploadPlaceholderIcon.widthAnchor.constraint(equalToConstant: 40),
            uploadPlaceholderIcon.heightAnchor.constraint(equalToConstant: 40),

            uploadHintLabel.topAnchor.constraint(equalTo: uploadPlaceholderIcon.bottomAnchor, constant: 8),
            uploadHintLabel.centerXAnchor.constraint(equalTo: uploadCard.centerXAnchor),
        ])
    }

    // MARK: - Details Card

    private func setupDetailsCard() {
        contentView.addSubview(eventDetailsLabel)
        contentView.addSubview(detailsCard)

        let dateLabel = makeRowLabel("Date".localized)
        let timeLabel = makeRowLabel("Time".localized)
        let freeLabel = makeRowLabel("Free Event".localized)
        let descLabel = makeRowLabel("Description".localized)

        let fields: [UIView] = [
            titleField,
            venueField,
            makeDateRow(label: dateLabel, picker: datePicker),
            makeDateRow(label: timeLabel, picker: timePicker),
            priceField,
            makeSwitchRow(label: freeLabel, toggle: freeSwitch),
            descLabel,
            descriptionTextView,
        ]

        // Stack inside card
        let stack = UIStackView(arrangedSubviews: fields)
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        detailsCard.addSubview(stack)

        // Description placeholder
        descriptionTextView.addSubview(descriptionPlaceholder)
        descriptionTextView.delegate = self

        NSLayoutConstraint.activate([
            eventDetailsLabel.topAnchor.constraint(equalTo: uploadCard.bottomAnchor, constant: 28),
            eventDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            detailsCard.topAnchor.constraint(equalTo: eventDetailsLabel.bottomAnchor, constant: 12),
            detailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            stack.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -20),

            titleField.heightAnchor.constraint(equalToConstant: 48),
            venueField.heightAnchor.constraint(equalToConstant: 48),
            priceField.heightAnchor.constraint(equalToConstant: 48),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 12),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 13),
        ])
    }

    // MARK: - Post Button

    private func setupPostButton() {
        contentView.addSubview(postButton)
        postButton.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            postButton.topAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: 32),
            postButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            postButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            postButton.heightAnchor.constraint(equalToConstant: 56),
            postButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

            loadingIndicator.centerXAnchor.constraint(equalTo: postButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: postButton.centerYAnchor),
        ])
    }

    // MARK: - Keyboard Dismiss

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Helpers

    private static func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 16)
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }

    private func makeRowLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeDateRow(label: UILabel, picker: UIDatePicker) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        row.addSubview(picker)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            picker.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            picker.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            row.heightAnchor.constraint(equalToConstant: 44),
        ])
        return row
    }

    private func makeSwitchRow(label: UILabel, toggle: UISwitch) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        row.addSubview(toggle)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            row.heightAnchor.constraint(equalToConstant: 44),
        ])
        return row
    }

    // MARK: - Actions

    @objc private func freeSwitchChanged() {
        priceField.isEnabled = !freeSwitch.isOn
        priceField.alpha = freeSwitch.isOn ? 0.4 : 1.0
        if freeSwitch.isOn {
            priceField.text = ""
        }
    }

    @objc private func pickImage() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - PHPicker Delegate

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.selectedImage = image
                self.imagePreview.image = image
                self.uploadPlaceholderIcon.isHidden = true
                self.uploadHintLabel.isHidden = true
            }
        }
    }

    // MARK: - Post Event

    @objc private func postEventTapped() {
        guard let eventTitle = titleField.text, !eventTitle.isEmpty,
              let venue = venueField.text, !venue.isEmpty,
              let desc = descriptionTextView.text, !desc.isEmpty
        else {
            showAlert(title: "Missing Information".localized,
                      message: "Please fill in all required fields.".localized)
            return
        }

        let isFree = freeSwitch.isOn
        let price: Double
        if isFree {
            price = 0
        } else {
            guard let priceText = priceField.text, let parsed = Double(priceText) else {
                showAlert(title: "Missing Information".localized,
                          message: "Please enter a valid price or mark the event as free.".localized)
                return
            }
            price = parsed
        }

        loadingIndicator.startAnimating()
        postButton.isEnabled = false
        postButton.setTitle("", for: .normal)

        Task {
            do {
                let userId = try await supabase.auth.session.user.id.uuidString

                // Upload image if selected
                var imageURL: String?
                if let image = selectedImage {
                    imageURL = try await uploadEventImage(image)
                }

                // Format date / time
                let dateFmt = DateFormatter()
                dateFmt.dateFormat = "yyyy-MM-dd"
                let dateString = dateFmt.string(from: datePicker.date)

                let timeFmt = DateFormatter()
                timeFmt.dateFormat = "HH:mm"
                let timeString = timeFmt.string(from: timePicker.date)

                let dto = EventInsertDTO(
                    organizer_id: userId,
                    title: eventTitle,
                    description: desc,
                    venue: venue,
                    event_date: dateString,
                    event_time: timeString,
                    price: price,
                    is_free: isFree,
                    image_url: imageURL
                )

                let repo = EventRepository()
                try await repo.insertEvent(dto)

                print("✅ Event posted successfully")

                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    postButton.isEnabled = true
                    postButton.setTitle("Post Event".localized, for: .normal)

                    clearForm()

                    let alert = UIAlertController(
                        title: "Success".localized,
                        message: "Your event has been posted successfully!".localized,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { _ in
                        let vc = EventPostedViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                    self.present(alert, animated: true)
                }

            } catch {
                print("❌ Event post failed:", error)
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    postButton.isEnabled = true
                    postButton.setTitle("Post Event".localized, for: .normal)
                    showAlert(title: "Upload Failed".localized, message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Image Upload

    private func uploadEventImage(_ image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
        }

        let path = "events/\(UUID().uuidString).jpg"

        do {
            try await supabase.storage
                .from("event-images")
                .upload(path, data: data)
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == -1017 {
                print("⚠️ Supabase parse error ignored (upload succeeded)")
            } else {
                throw error
            }
        }

        let publicURL = try supabase.storage
            .from("event-images")
            .getPublicURL(path: path)

        return publicURL.absoluteString
    }

    // MARK: - Clear Form

    private func clearForm() {
        titleField.text = ""
        venueField.text = ""
        priceField.text = ""
        descriptionTextView.text = ""
        descriptionPlaceholder.isHidden = false
        selectedImage = nil
        imagePreview.image = nil
        uploadPlaceholderIcon.isHidden = false
        uploadHintLabel.isHidden = false
        freeSwitch.isOn = false
        priceField.isEnabled = true
        priceField.alpha = 1.0
    }

    // MARK: - Alerts

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension PostEventViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }
}
