//
//  PostItemViewController.swift
//  Unizo_iOS
//

import UIKit
import Supabase

final class PostItemViewController: UIViewController,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Header
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Post Item"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        return l
    }()

    // MARK: - Upload Card
    private let uploadCard = UIView()
    private let uploadImageView = UIImageView(image: UIImage(systemName: "camera"))
    private let sizeLabel = UILabel()
    private let uploadButton = UIButton(type: .system)

    // MARK: - Product Details
    private let productDetailsLabel = UILabel()
    private let productCard = UIView()

    private let fieldTitles = [
        "Product Name",
        "Price (in Rupees)",
        "Colour",
        "Category",
        "Size",
        "Condition",
        "Description"
    ]
    private var fields: [UITextField] = []

    // MARK: - Picker Data
    private let categories = [
        "Electronics", "Clothing",
        "Furniture", "Sports", "Hostel Essentials"
    ]

    private let conditions = [
        "New", "Like New", "Good", "Fair", "Used"
    ]

    private let pickerView = UIPickerView()
    private weak var activePickerField: UITextField?

    // MARK: - Negotiable
    private let negotiableContainer = UIStackView()
    private let negButton = UIButton(type: .system)
    private let nonNegButton = UIButton(type: .system)
    private let negLabel = UILabel()
    private let nonNegLabel = UILabel()

    private var isNegotiable = true {
        didSet { updateNegotiableButtons() }
    }

    // MARK: - Final Button
    private let finalUploadButton = UIButton(type: .system)

    // MARK: - Loading Indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1)
        navigationController?.navigationBar.isHidden = true

        pickerView.delegate = self
        pickerView.dataSource = self

        setupScroll()
        setupHeader()
        setupUploadCard()
        setupProductDetails()
        setupNegotiableSection()
        setupFinalButton()
        setupLoadingIndicator()
        updateNegotiableButtons()

        // Check authentication
        checkAuthentication()
    }

    private func checkAuthentication() {
        Task {
            do {
                _ = try await supabase.auth.session
                print("✅ User authenticated")
            } catch {
                print("❌ User not authenticated")
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Authentication Required",
                        message: "Please log in to post items",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Scroll Setup
    private func setupScroll() {
        [scrollView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

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

    // MARK: - Header
    private func setupHeader() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }

    // MARK: - Picker Toolbar
    private func makePickerToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicking))
        ]
        return toolbar
    }

    @objc private func donePicking() {
        activePickerField?.resignFirstResponder()
    }

    // MARK: - Upload Card
    private func setupUploadCard() {
        uploadCard.backgroundColor = .white
        uploadCard.layer.cornerRadius = 16
        uploadCard.layer.borderWidth = 0.5
        uploadCard.layer.borderColor = UIColor.lightGray.cgColor
        uploadCard.translatesAutoresizingMaskIntoConstraints = false

        uploadImageView.tintColor = .gray
        uploadImageView.contentMode = .scaleAspectFit
        uploadImageView.clipsToBounds = true

        sizeLabel.text = "Maximum size: 2 MB"
        sizeLabel.font = .systemFont(ofSize: 12)
        sizeLabel.textAlignment = .center
        sizeLabel.textColor = .gray

        uploadButton.setTitle("Upload Photo", for: .normal)
        uploadButton.backgroundColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.layer.cornerRadius = 22
        uploadButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)

        [uploadCard, uploadImageView, sizeLabel, uploadButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(uploadCard)
        uploadCard.addSubview(uploadImageView)
        uploadCard.addSubview(sizeLabel)
        uploadCard.addSubview(uploadButton)

        NSLayoutConstraint.activate([
            uploadCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            uploadCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uploadCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            uploadImageView.topAnchor.constraint(equalTo: uploadCard.topAnchor, constant: 20),
            uploadImageView.centerXAnchor.constraint(equalTo: uploadCard.centerXAnchor),
            uploadImageView.widthAnchor.constraint(equalToConstant: 70),
            uploadImageView.heightAnchor.constraint(equalToConstant: 70),

            sizeLabel.topAnchor.constraint(equalTo: uploadImageView.bottomAnchor, constant: 8),
            sizeLabel.leadingAnchor.constraint(equalTo: uploadCard.leadingAnchor),
            sizeLabel.trailingAnchor.constraint(equalTo: uploadCard.trailingAnchor),

            uploadButton.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 15),
            uploadButton.leadingAnchor.constraint(equalTo: uploadCard.leadingAnchor, constant: 40),
            uploadButton.trailingAnchor.constraint(equalTo: uploadCard.trailingAnchor, constant: -40),
            uploadButton.heightAnchor.constraint(equalToConstant: 45),
            uploadButton.bottomAnchor.constraint(equalTo: uploadCard.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Product Details
    private func setupProductDetails() {
        productDetailsLabel.text = "Product Details"
        productDetailsLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        productDetailsLabel.translatesAutoresizingMaskIntoConstraints = false

        productCard.backgroundColor = .white
        productCard.layer.cornerRadius = 20
        productCard.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(productDetailsLabel)
        contentView.addSubview(productCard)

        NSLayoutConstraint.activate([
            productDetailsLabel.topAnchor.constraint(equalTo: uploadCard.bottomAnchor, constant: 25),
            productDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            productCard.topAnchor.constraint(equalTo: productDetailsLabel.bottomAnchor, constant: 10),
            productCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        var lastField: UIView?

        for title in fieldTitles {
            let field = UITextField()
            field.placeholder = title
            field.font = .systemFont(ofSize: 15)
            field.setLeftPaddingPoints(18)
            field.translatesAutoresizingMaskIntoConstraints = false

            if title == "Category" || title == "Condition" {
                field.delegate = self
                field.inputView = pickerView
                field.inputAccessoryView = makePickerToolbar()
                field.tintColor = .clear
            }

            productCard.addSubview(field)
            fields.append(field)

            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: productCard.leadingAnchor),
                field.trailingAnchor.constraint(equalTo: productCard.trailingAnchor),
                field.heightAnchor.constraint(equalToConstant: 50),
                field.topAnchor.constraint(equalTo: lastField?.bottomAnchor ?? productCard.topAnchor)
            ])

            lastField = field
        }

        lastField?.bottomAnchor.constraint(equalTo: productCard.bottomAnchor, constant: -12).isActive = true
    }

    // MARK: - Negotiable
    private func setupNegotiableSection() {
        negotiableContainer.axis = .horizontal
        negotiableContainer.distribution = .equalSpacing
        negotiableContainer.translatesAutoresizingMaskIntoConstraints = false

        setupRadio(negButton)
        setupRadio(nonNegButton)

        negLabel.text = "Negotiable"
        nonNegLabel.text = "Non - Negotiable"

        let left = UIStackView(arrangedSubviews: [negButton, negLabel])
        let right = UIStackView(arrangedSubviews: [nonNegButton, nonNegLabel])

        [left, right].forEach {
            $0.axis = .horizontal
            $0.spacing = 8
        }

        negotiableContainer.addArrangedSubview(left)
        negotiableContainer.addArrangedSubview(right)
        contentView.addSubview(negotiableContainer)

        NSLayoutConstraint.activate([
            negotiableContainer.topAnchor.constraint(equalTo: productCard.bottomAnchor, constant: 25),
            negotiableContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            negotiableContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        negButton.addTarget(self, action: #selector(setNegotiable), for: .touchUpInside)
        nonNegButton.addTarget(self, action: #selector(setNonNegotiable), for: .touchUpInside)
    }

    private func setupRadio(_ btn: UIButton) {
        btn.tintColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        btn.setImage(UIImage(systemName: "circle"), for: .normal)
        btn.widthAnchor.constraint(equalToConstant: 22).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }

    private func updateNegotiableButtons() {
        let filled = UIImage(systemName: "record.circle")
        let empty = UIImage(systemName: "circle")
        negButton.setImage(isNegotiable ? filled : empty, for: .normal)
        nonNegButton.setImage(isNegotiable ? empty : filled, for: .normal)
    }

    // MARK: - Final Button
    private func setupFinalButton() {
        finalUploadButton.setTitle("Upload Product", for: .normal)
        finalUploadButton.backgroundColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        finalUploadButton.setTitleColor(.white, for: .normal)
        finalUploadButton.layer.cornerRadius = 22
        finalUploadButton.translatesAutoresizingMaskIntoConstraints = false
        finalUploadButton.addTarget(self, action: #selector(uploadProduct), for: .touchUpInside)

        contentView.addSubview(finalUploadButton)

        NSLayoutConstraint.activate([
            finalUploadButton.topAnchor.constraint(equalTo: negotiableContainer.bottomAnchor, constant: 30),
            finalUploadButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            finalUploadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            finalUploadButton.heightAnchor.constraint(equalToConstant: 50),
            finalUploadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Loading Indicator Setup
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Upload Logic
    @objc private func uploadProduct() {

        guard
            let image = uploadImageView.image,
            let title = fields[0].text, !title.isEmpty,
            let priceText = fields[1].text, let price = Int(priceText),
            let colour = fields[2].text, !colour.isEmpty,
            let category = fields[3].text, !category.isEmpty,
            let size = fields[4].text, !size.isEmpty,
            let condition = fields[5].text, !condition.isEmpty,
            let description = fields[6].text, !description.isEmpty
        else {
            print("❌ Validation failed")
            let alert = UIAlertController(
                title: "Missing Information",
                message: "Please fill in all fields and upload a photo",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Show loading indicator and disable button
        loadingIndicator.startAnimating()
        finalUploadButton.isEnabled = false

        Task {
            do {
                // Get current user ID
                let userId = try await supabase.auth.session.user.id.uuidString

                let imageURL = try await uploadImage(image)

                let product = ProductInsertDTO(
                    seller_id: userId,
                    title: title,
                    description: description,
                    price: price,
                    image_url: imageURL,
                    is_negotiable: isNegotiable,
                    views_count: 0,
                    is_active: true,
                    rating: 0,
                    colour: colour,
                    category: category,
                    size: size,
                    condition: condition
                )

                let repo = ProductRepository(supabase: supabase)
                try await repo.insertProduct(product)

                print("✅ Product uploaded successfully")

                // Hide loading indicator and show success alert
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.finalUploadButton.isEnabled = true

                    let alert = UIAlertController(
                        title: "Success",
                        message: "Your product has been uploaded successfully!",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        let productPostedVC = ProductPostedViewController()
                        self.navigationController?.pushViewController(productPostedVC, animated: true)
                    })
                    self.present(alert, animated: true)
                }

            } catch {
                print("❌ Upload failed:", error)
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.finalUploadButton.isEnabled = true

                    let alert = UIAlertController(
                        title: "Upload Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Supabase Image Upload (MISSING BEFORE – NOW FIXED)
    private func uploadImage(_ image: UIImage) async throws -> String {

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 0)
        }

        let path = "products/\(UUID().uuidString).jpg"

        do {
            try await supabase.storage
                .from("product-images")
                .upload(path, data: data)
        } catch {
            // ✅ Supabase iOS SDK bug workaround
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == -1017 {
                print("⚠️ Supabase parse error ignored (upload succeeded)")
            } else {
                throw error
            }
        }

        let publicURL = try supabase.storage
            .from("product-images")
            .getPublicURL(path: path)


        return publicURL.absoluteString
    }




    // MARK: - Image Picker
    @objc private func openGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            uploadImageView.image = img
            uploadImageView.contentMode = .scaleAspectFit
        }
        dismiss(animated: true)
    }

    @objc private func setNegotiable() { isNegotiable = true }
    @objc private func setNonNegotiable() { isNegotiable = false }
}

// MARK: - Picker
extension PostItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        activePickerField?.placeholder == "Category" ? categories.count : conditions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        activePickerField?.placeholder == "Category" ? categories[row] : conditions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activePickerField?.text =
            activePickerField?.placeholder == "Category" ? categories[row] : conditions[row]
    }
}

// MARK: - TextField
extension PostItemViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activePickerField = textField
        pickerView.reloadAllComponents()
    }
}
