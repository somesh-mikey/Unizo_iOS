//
//  EditListingViewController.swift
//  Unizo_iOS
//
//  Created by Soham Bhattacharya on 29/01/26.
//

import UIKit
import Supabase

final class EditListingViewController: UIViewController,
                                       UIImagePickerControllerDelegate,
                                       UINavigationControllerDelegate {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - Product Data
    var product: ProductDTO!

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Header
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Edit Listing"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .black
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .black
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
        "Electronics", "Clothing", "Books",
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

    // MARK: - Save Button
    private let saveButton = UIButton(type: .system)

    // MARK: - Loading Indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
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
        setupSaveButton()
        setupLoadingIndicator()
        updateNegotiableButtons()

        // Populate with existing product data
        populateFields()
    }

    // MARK: - Scroll Setup
    private func setupScroll() {
        [scrollView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
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

    // MARK: - Header Setup
    private func setupHeader() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(favoriteButton)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            favoriteButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
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

        sizeLabel.text = "Size: 2 MB"
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
            uploadCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
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

        var previousField: UITextField?

        for (i, title) in fieldTitles.enumerated() {
            let field = UITextField()
            field.placeholder = title
            field.font = .systemFont(ofSize: 16)
            field.translatesAutoresizingMaskIntoConstraints = false

            if i == 3 || i == 5 {
                field.inputView = pickerView
                field.delegate = self
            }

            productCard.addSubview(field)
            fields.append(field)

            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: productCard.leadingAnchor, constant: 20),
                field.trailingAnchor.constraint(equalTo: productCard.trailingAnchor, constant: -20),
                field.heightAnchor.constraint(equalToConstant: 50)
            ])

            if i == 0 {
                field.topAnchor.constraint(equalTo: productCard.topAnchor, constant: 16).isActive = true
            } else {
                field.topAnchor.constraint(equalTo: previousField!.bottomAnchor, constant: 0).isActive = true
            }

            if i < fieldTitles.count - 1 {
                let sep = UIView()
                sep.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                sep.translatesAutoresizingMaskIntoConstraints = false
                productCard.addSubview(sep)

                NSLayoutConstraint.activate([
                    sep.topAnchor.constraint(equalTo: field.bottomAnchor),
                    sep.leadingAnchor.constraint(equalTo: field.leadingAnchor),
                    sep.trailingAnchor.constraint(equalTo: field.trailingAnchor),
                    sep.heightAnchor.constraint(equalToConstant: 1)
                ])
            } else {
                field.bottomAnchor.constraint(equalTo: productCard.bottomAnchor, constant: -16).isActive = true
            }

            previousField = field
        }
    }

    // MARK: - Negotiable Section
    private func setupNegotiableSection() {
        negotiableContainer.axis = .horizontal
        negotiableContainer.distribution = .fillEqually
        negotiableContainer.spacing = 12
        negotiableContainer.translatesAutoresizingMaskIntoConstraints = false

        let left = UIStackView()
        left.axis = .horizontal
        left.spacing = 8
        setupRadio(negButton)
        negLabel.text = "Negotiable"
        negLabel.font = .systemFont(ofSize: 14)
        left.addArrangedSubview(negButton)
        left.addArrangedSubview(negLabel)

        let right = UIStackView()
        right.axis = .horizontal
        right.spacing = 8
        setupRadio(nonNegButton)
        nonNegLabel.text = "Non - Negotiable"
        nonNegLabel.font = .systemFont(ofSize: 14)
        right.addArrangedSubview(nonNegButton)
        right.addArrangedSubview(nonNegLabel)

        [left, right].forEach {
            $0.distribution = .fill
            $0.alignment = .center
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

    // MARK: - Save Button
    private func setupSaveButton() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 22
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveProduct), for: .touchUpInside)

        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: negotiableContainer.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure scroll view content is properly laid out
        scrollView.contentInsetAdjustmentBehavior = .never
    }

    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Populate Fields
    private func populateFields() {
        fields[0].text = product.title
        fields[1].text = String(Int(product.price))
        fields[2].text = product.colour
        fields[3].text = product.category
        fields[4].text = product.size
        fields[5].text = product.condition
        fields[6].text = product.description

        isNegotiable = product.isNegotiable ?? true

        // Load existing image
        if let imageURLString = product.imageUrl, let url = URL(string: imageURLString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            uploadImageView.image = image
                            uploadImageView.contentMode = .scaleAspectFit
                        }
                    }
                } catch {
                    print("❌ Failed to load image:", error)
                }
            }
        }
    }

    // MARK: - Save Logic
    @objc private func saveProduct() {

        guard
            let title = fields[0].text, !title.isEmpty,
            let priceText = fields[1].text, let price = Int(priceText),
            let colour = fields[2].text, !colour.isEmpty,
            let category = fields[3].text, !category.isEmpty,
            let size = fields[4].text, !size.isEmpty,
            let condition = fields[5].text, !condition.isEmpty,
            let description = fields[6].text, !description.isEmpty
        else {
            print("❌ Validation failed")
            return
        }

        // Show loading indicator
        loadingIndicator.startAnimating()
        saveButton.isEnabled = false
        saveButton.alpha = 0.6

        Task {
            do {
                var imageURL = product.imageUrl ?? ""

                // Upload new image if changed
                if let newImage = uploadImageView.image,
                   uploadImageView.image != UIImage(systemName: "camera") {
                    imageURL = try await uploadImage(newImage)
                }

                // Update product in Supabase
                let updateData = ProductUpdateDTO(
                    title: title,
                    description: description,
                    price: price,
                    image_url: imageURL,
                    is_negotiable: isNegotiable,
                    colour: colour,
                    category: category,
                    size: size,
                    condition: condition
                )

                try await supabase
                    .from("products")
                    .update(updateData)
                    .eq("id", value: product.id.uuidString)
                    .execute()

                print("✅ Product updated successfully")

                // Hide loading indicator and show success message
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    saveButton.isEnabled = true
                    saveButton.alpha = 1.0

                    let alert = UIAlertController(
                        title: "Success",
                        message: "Product updated successfully!",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    present(alert, animated: true)
                }

            } catch {
                print("❌ Update failed:", error)
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    saveButton.isEnabled = true
                    saveButton.alpha = 1.0

                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to update product: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Image Upload
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

    @objc private func openGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
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
extension EditListingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if activePickerField == fields[3] { return categories.count }
        if activePickerField == fields[5] { return conditions.count }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if activePickerField == fields[3] { return categories[row] }
        if activePickerField == fields[5] { return conditions[row] }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if activePickerField == fields[3] {
            activePickerField?.text = categories[row]
        } else if activePickerField == fields[5] {
            activePickerField?.text = conditions[row]
        }
    }
}

// MARK: - TextField
extension EditListingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activePickerField = textField
        pickerView.reloadAllComponents()
    }
}

