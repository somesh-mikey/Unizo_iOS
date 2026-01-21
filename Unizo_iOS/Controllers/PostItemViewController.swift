//
//  PostItemViewController.swift
//  Unizo_iOS
//

import UIKit

final class PostItemViewController: UIViewController,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {

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

    // MARK: - Final Button
    private let finalUploadButton = UIButton(type: .system)

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
        updateNegotiableButtons()
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

    // MARK: - Upload Card
    private func setupUploadCard() {
        uploadCard.backgroundColor = .white
        uploadCard.layer.cornerRadius = 16
        uploadCard.layer.borderWidth = 0.5
        uploadCard.layer.borderColor = UIColor.lightGray.cgColor
        uploadCard.translatesAutoresizingMaskIntoConstraints = false

        uploadImageView.tintColor = .gray
        uploadImageView.contentMode = .scaleAspectFit

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
            uploadImageView.heightAnchor.constraint(equalToConstant: 70),
            uploadImageView.widthAnchor.constraint(equalTo: uploadCard.widthAnchor),

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
        
        for (index, title) in fieldTitles.enumerated() {
            
            let field = UITextField()
            field.placeholder = title
            field.font = .systemFont(ofSize: 15)
            field.setLeftPaddingPoints_Local(18)
            field.translatesAutoresizingMaskIntoConstraints = false
            
            // Picker fields
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
            
            // 🔹 Separator (except last field)
            if index < fieldTitles.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                separator.translatesAutoresizingMaskIntoConstraints = false
                productCard.addSubview(separator)
                
                NSLayoutConstraint.activate([
                    separator.topAnchor.constraint(equalTo: field.bottomAnchor),
                    separator.leadingAnchor.constraint(equalTo: productCard.leadingAnchor, constant: 16),
                    separator.trailingAnchor.constraint(equalTo: productCard.trailingAnchor, constant: -16),
                    separator.heightAnchor.constraint(equalToConstant: 1)
                ])
            }
            
            lastField = field
        }
        
        lastField?.bottomAnchor
            .constraint(equalTo: productCard.bottomAnchor, constant: -12)
            .isActive = true
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
        
        finalUploadButton.addTarget(self, action: #selector(uploadProductTapped), for: .touchUpInside)

        contentView.addSubview(finalUploadButton)

        NSLayoutConstraint.activate([
            finalUploadButton.topAnchor.constraint(equalTo: negotiableContainer.bottomAnchor, constant: 30),
            finalUploadButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            finalUploadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            finalUploadButton.heightAnchor.constraint(equalToConstant: 50),
            finalUploadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Picker Toolbar
    private func makePickerToolbar() -> UIToolbar {
        let bar = UIToolbar()
        bar.sizeToFit()
        bar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicking))
        ]
        return bar
    }

    @objc private func donePicking() {
        activePickerField?.resignFirstResponder()
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
            uploadImageView.contentMode = .scaleAspectFill
        }
        dismiss(animated: true)
    }

    @objc private func setNegotiable() { isNegotiable = true }
    @objc private func setNonNegotiable() { isNegotiable = false }

    @objc private func uploadProductTapped() {
        // Optionally: validate fields & prepare product info here before navigating
        let postedVC = ProductPostedViewController()
        // Prefer pushing onto navigation stack (keeps back behaviour)
        if let nav = navigationController {
            nav.pushViewController(postedVC, animated: true)
            return
        }
        // Fallback — present modally if there's no navigation controller
        postedVC.modalPresentationStyle = .fullScreen
        present(postedVC, animated: true)
    }
}

// MARK: - Picker Delegates
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

// MARK: - TextField Delegate
extension PostItemViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activePickerField = textField
        pickerView.reloadAllComponents()
    }
}

// Helper for padding
extension UITextField {
    func setLeftPaddingPoints_Local(_ amount: CGFloat) {
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftView = padding
        leftViewMode = .always
    }
}
