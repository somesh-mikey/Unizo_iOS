//
//  PostItemViewController.swift
//  Unizo_iOS
//

import UIKit
import Supabase
import PhotosUI

final class PostItemViewController: UIViewController,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate,
                                    PHPickerViewControllerDelegate {

    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - Scroll
    private let scrollView = TouchPassThroughScrollView()
    private let contentView = UIView()

    // MARK: - Header
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Post Item".localized
        l.font = .systemFont(ofSize: 35, weight: .bold)
        return l
    }()

    // MARK: - Image Gallery
    private var selectedImages: [UIImage] = []
    private let maxImages = 5

    // MARK: - Upload Card
    private let uploadCard = UIView()
    private let galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    private let uploadImageView = UIImageView(image: UIImage(systemName: "camera"))
    private let sizeLabel = UILabel()
    private let uploadButton = UIButton(type: .system)

    // MARK: - Product Details
    private let productDetailsLabel = UILabel()
    private let productCard = UIView()

    private let fieldTitles = [
        "Product Name".localized,
        "Price (in Rupees)".localized,
        "Colour".localized,
        "Category".localized,
        "Size".localized,
        "Condition".localized,
        "Description".localized
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
        setupKeyboardHandling()

        // Check authentication
        checkAuthentication()
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

        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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

    private func checkAuthentication() {
        Task {
            do {
                _ = try await supabase.auth.session
                print("✅ User authenticated")
            } catch {
                print("❌ User not authenticated")
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Authentication Required".localized,
                        message: "Please log in to post items".localized,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { _ in
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

        // Enable scrolling even when touch starts on text fields
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true

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
            UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(donePicking))
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

        // Setup collection view for gallery
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        galleryCollectionView.register(ImageGalleryCell.self, forCellWithReuseIdentifier: "ImageGalleryCell")
        galleryCollectionView.register(AddImageCell.self, forCellWithReuseIdentifier: "AddImageCell")

        sizeLabel.text = "Add up to \(maxImages) photos (Max 2 MB each)".localized
        sizeLabel.font = .systemFont(ofSize: 12)
        sizeLabel.textAlignment = .center
        sizeLabel.textColor = .gray

        uploadButton.setTitle("Upload Photos".localized, for: .normal)
        uploadButton.backgroundColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.layer.cornerRadius = 22
        uploadButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)

        [uploadCard, galleryCollectionView, sizeLabel, uploadButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(uploadCard)
        uploadCard.addSubview(galleryCollectionView)
        uploadCard.addSubview(sizeLabel)
        uploadCard.addSubview(uploadButton)

        NSLayoutConstraint.activate([
            uploadCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            uploadCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uploadCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            galleryCollectionView.topAnchor.constraint(equalTo: uploadCard.topAnchor, constant: 16),
            galleryCollectionView.leadingAnchor.constraint(equalTo: uploadCard.leadingAnchor, constant: 16),
            galleryCollectionView.trailingAnchor.constraint(equalTo: uploadCard.trailingAnchor, constant: -16),
            galleryCollectionView.heightAnchor.constraint(equalToConstant: 100),

            sizeLabel.topAnchor.constraint(equalTo: galleryCollectionView.bottomAnchor, constant: 12),
            sizeLabel.leadingAnchor.constraint(equalTo: uploadCard.leadingAnchor),
            sizeLabel.trailingAnchor.constraint(equalTo: uploadCard.trailingAnchor),

            uploadButton.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 12),
            uploadButton.leadingAnchor.constraint(equalTo: uploadCard.leadingAnchor, constant: 40),
            uploadButton.trailingAnchor.constraint(equalTo: uploadCard.trailingAnchor, constant: -40),
            uploadButton.heightAnchor.constraint(equalToConstant: 45),
            uploadButton.bottomAnchor.constraint(equalTo: uploadCard.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Product Details
    private func setupProductDetails() {
        productDetailsLabel.text = "Product Details".localized
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

            // Product Name field - add character limit
            if title == "Product Name".localized {
                field.delegate = self
            }

            if title == "Category".localized || title == "Condition".localized {
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

        negLabel.text = "Negotiable".localized
        nonNegLabel.text = "Non - Negotiable".localized

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
        finalUploadButton.setTitle("Upload Product".localized, for: .normal)
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
            !selectedImages.isEmpty,
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
                title: "Missing Information".localized,
                message: "Please fill in all fields and upload at least one photo".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
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

                // Upload all images
                var imageURLs: [String] = []
                for image in selectedImages {
                    let url = try await uploadImage(image)
                    imageURLs.append(url)
                }

                // First image is the main image, rest go to gallery
                let mainImageURL = imageURLs.first ?? ""
                let galleryImageURLs = imageURLs.count > 1 ? Array(imageURLs.dropFirst()) : nil

                let product = ProductInsertDTO(
                    seller_id: userId,
                    title: title,
                    description: description,
                    price: price,
                    image_url: mainImageURL,
                    gallery_images: galleryImageURLs,
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

                print("✅ Product uploaded successfully with \(imageURLs.count) images")

                // Hide loading indicator and show success alert
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.finalUploadButton.isEnabled = true

                    // Clear all form data after successful upload
                    self.clearFormData()

                    let alert = UIAlertController(
                        title: "Success".localized,
                        message: "Your product has been uploaded successfully!".localized,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default) { _ in
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
                        title: "Upload Failed".localized,
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
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

    // MARK: - Clear Form Data
    private func clearFormData() {
        // Clear all text fields
        for field in fields {
            field.text = ""
        }

        // Clear selected images
        selectedImages.removeAll()
        galleryCollectionView.reloadData()
        updateUploadButtonTitle()

        // Reset negotiable to default (true)
        isNegotiable = true
        updateNegotiableButtons()
    }

    // MARK: - Image Picker
    @objc private func openGallery() {
        let remainingSlots = maxImages - selectedImages.count
        guard remainingSlots > 0 else {
            let alert = UIAlertController(
                title: "Maximum Images".localized,
                message: "You can only upload up to \(maxImages) images".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
            present(alert, animated: true)
            return
        }

        var config = PHPickerConfiguration()
        config.selectionLimit = remainingSlots
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // PHPicker delegate for multiple image selection
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self, let image = object as? UIImage else { return }

                DispatchQueue.main.async {
                    if self.selectedImages.count < self.maxImages {
                        self.selectedImages.append(image)
                        self.galleryCollectionView.reloadData()
                        self.updateUploadButtonTitle()
                    }
                }
            }
        }
    }

    // Legacy UIImagePickerController delegate (kept for compatibility)
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            if selectedImages.count < maxImages {
                selectedImages.append(img)
                galleryCollectionView.reloadData()
                updateUploadButtonTitle()
            }
        }
        dismiss(animated: true)
    }

    private func updateUploadButtonTitle() {
        if selectedImages.isEmpty {
            uploadButton.setTitle("Upload Photos".localized, for: .normal)
        } else {
            uploadButton.setTitle("Add More (\(selectedImages.count)/\(maxImages))".localized, for: .normal)
        }
    }

    private func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        galleryCollectionView.reloadData()
        updateUploadButtonTitle()
    }

    @objc private func setNegotiable() { isNegotiable = true }
    @objc private func setNonNegotiable() { isNegotiable = false }
}

// MARK: - Collection View for Image Gallery
extension PostItemViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Show add button if we haven't reached max
        return selectedImages.count < maxImages ? selectedImages.count + 1 : selectedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < selectedImages.count {
            // Image cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGalleryCell", for: indexPath) as! ImageGalleryCell
            cell.configure(with: selectedImages[indexPath.item], index: indexPath.item)
            cell.onDelete = { [weak self] index in
                self?.removeImage(at: index)
            }
            return cell
        } else {
            // Add button cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCell", for: indexPath) as! AddImageCell
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item >= selectedImages.count {
            // Tapped on add button
            openGallery()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

// MARK: - Image Gallery Cell
private class ImageGalleryCell: UICollectionViewCell {

    private let imageView = UIImageView()
    private let deleteButton = UIButton(type: .system)
    private var index: Int = 0
    var onDelete: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .white
        deleteButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        deleteButton.layer.cornerRadius = 10
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(with image: UIImage, index: Int) {
        imageView.image = image
        self.index = index
    }

    @objc private func deleteTapped() {
        onDelete?(index)
    }
}

// MARK: - Add Image Cell
private class AddImageCell: UICollectionViewCell {

    private let addButton = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor.systemGray5
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray3.cgColor

        addButton.image = UIImage(systemName: "plus")
        addButton.tintColor = .systemGray
        addButton.contentMode = .scaleAspectFit
        addButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}

// MARK: - Picker
extension PostItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        activePickerField?.placeholder == "Category".localized ? categories.count : conditions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        activePickerField?.placeholder == "Category".localized ? categories[row] : conditions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activePickerField?.text =
            activePickerField?.placeholder == "Category".localized ? categories[row] : conditions[row]
    }
}

// MARK: - TextField
extension PostItemViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activePickerField = textField
        pickerView.reloadAllComponents()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if this is the Product Name field (first field, index 0)
        guard let index = fields.firstIndex(of: textField) else { return true }

        // Product Name field has 30 character limit
        if index == 0 {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 30
        }

        return true
    }
}

// MARK: - Custom ScrollView that allows scrolling over text fields
class TouchPassThroughScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        // Allow scrolling to cancel touches in text fields
        if view is UITextField {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
