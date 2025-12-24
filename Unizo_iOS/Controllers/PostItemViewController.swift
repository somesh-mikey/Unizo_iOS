//
//  PostItemViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 26/11/25.
//

import UIKit

class PostItemViewController: UIViewController,
                               UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate {

    // MARK: UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let titleLabel = UILabel()

    // Upload card
    private let uploadCard = UIView()
    private let uploadImageView = UIImageView()
    private let sizeLabel = UILabel()
    private let uploadButton = UIButton(type: .system)

    // Product details
    private let productDetailsLabel = UILabel()
    private let productCard = UIView()

    // Editable fields
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

    // Negotiable options
    private let negotiableContainer = UIStackView()
    private let negButton = UIButton(type: .system)
    private let nonNegButton = UIButton(type: .system)
    private let negLabel = UILabel()
    private let nonNegLabel = UILabel()
    private var isNegotiable = true { didSet { updateNegotiableButtons() } }

    // Upload Product Button
    private let finalUploadButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true

        setupScrollView()
        setupHeader()
        setupUploadCard()
        setupProductDetails()
        setupNegotiableSection()
        setupFinalUploadButton()
        updateNegotiableButtons()
    }

    // MARK: - ScrollView Setup
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

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
        titleLabel.text = "Post Item"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
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
        contentView.addSubview(uploadCard)

        NSLayoutConstraint.activate([
            uploadCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            uploadCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uploadCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        uploadImageView.image = UIImage(systemName: "camera")
        uploadImageView.tintColor = .gray
        uploadImageView.contentMode = .scaleAspectFit
        uploadImageView.clipsToBounds = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false

        sizeLabel.text = "Maximum size: 2 MB"
        sizeLabel.font = UIFont.systemFont(ofSize: 12)
        sizeLabel.textAlignment = .center
        sizeLabel.textColor = .gray
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false

        uploadButton.setTitle("Upload Photo", for: .normal)
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.backgroundColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        uploadButton.layer.cornerRadius = 22
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)

        uploadCard.addSubview(uploadImageView)
        uploadCard.addSubview(sizeLabel)
        uploadCard.addSubview(uploadButton)

        NSLayoutConstraint.activate([
            uploadImageView.topAnchor.constraint(equalTo: uploadCard.topAnchor, constant: 20),
            uploadImageView.centerXAnchor.constraint(equalTo: uploadCard.centerXAnchor),
            
            uploadImageView.widthAnchor.constraint(equalTo: uploadCard.widthAnchor),
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

    // MARK: - Product Details Card
    private func setupProductDetails() {
        productDetailsLabel.text = "Product Details"
        productDetailsLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        productDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productDetailsLabel)

        NSLayoutConstraint.activate([
            productDetailsLabel.topAnchor.constraint(equalTo: uploadCard.bottomAnchor, constant: 25),
            productDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        productCard.backgroundColor = .white
        productCard.layer.cornerRadius = 20
        productCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productCard)

        NSLayoutConstraint.activate([
            productCard.topAnchor.constraint(equalTo: productDetailsLabel.bottomAnchor, constant: 10),
            productCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        var last: UIView? = nil
        for (i, title) in fieldTitles.enumerated() {
            let field = UITextField()
            field.placeholder = title
            field.font = UIFont.systemFont(ofSize: 15)
            field.translatesAutoresizingMaskIntoConstraints = false
            field.setLeftPaddingPoints(18)
            productCard.addSubview(field)
            fields.append(field)

            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: productCard.leadingAnchor),
                field.trailingAnchor.constraint(equalTo: productCard.trailingAnchor),
                field.heightAnchor.constraint(equalToConstant: 50)
            ])

            if let prev = last {
                field.topAnchor.constraint(equalTo: prev.bottomAnchor).isActive = true
            } else {
                field.topAnchor.constraint(equalTo: productCard.topAnchor).isActive = true
            }

            if i < fieldTitles.count - 1 {
                let sep = UIView()
                sep.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                sep.translatesAutoresizingMaskIntoConstraints = false
                productCard.addSubview(sep)

                NSLayoutConstraint.activate([
                    sep.heightAnchor.constraint(equalToConstant: 1),
                    sep.leadingAnchor.constraint(equalTo: productCard.leadingAnchor, constant: 16),
                    sep.trailingAnchor.constraint(equalTo: productCard.trailingAnchor, constant: -16),
                    sep.bottomAnchor.constraint(equalTo: field.bottomAnchor)
                ])
            }

            last = field
        }

        last?.bottomAnchor.constraint(equalTo: productCard.bottomAnchor, constant: -12).isActive = true
    }

    // MARK: - Negotiable Section
    private func setupNegotiableSection() {
        negotiableContainer.axis = .horizontal
        negotiableContainer.alignment = .center
        negotiableContainer.distribution = .equalSpacing
        negotiableContainer.translatesAutoresizingMaskIntoConstraints = false

        setupRadio(negButton)
        setupRadio(nonNegButton)

        negLabel.text = "Negotiable"
        nonNegLabel.text = "Non - Negotiable"
        negLabel.font = UIFont.systemFont(ofSize: 15)
        nonNegLabel.font = UIFont.systemFont(ofSize: 15)

        let left = UIStackView(arrangedSubviews: [negButton, negLabel])
        left.axis = .horizontal
        left.spacing = 8

        let right = UIStackView(arrangedSubviews: [nonNegButton, nonNegLabel])
        right.axis = .horizontal
        right.spacing = 8

        negotiableContainer.addArrangedSubview(left)
        negotiableContainer.addArrangedSubview(right)

        contentView.addSubview(negotiableContainer)

        NSLayoutConstraint.activate([
            negotiableContainer.topAnchor.constraint(equalTo: productCard.bottomAnchor, constant: 25),
            negotiableContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            negotiableContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
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

    @objc private func setNegotiable() { isNegotiable = true }
    @objc private func setNonNegotiable() { isNegotiable = false }

    // MARK: - Upload Product Button
    private func setupFinalUploadButton() {
        finalUploadButton.setTitle("Upload Product", for: .normal)
        finalUploadButton.setTitleColor(.white, for: .normal)
        finalUploadButton.backgroundColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
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

    // MARK: - Gallery Picker
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
            uploadImageView.clipsToBounds = true
        }

        dismiss(animated: true)
    }
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

// Helper for padding
//extension UITextField {
//    func setLeftPaddingPoints(_ amount: CGFloat) {
//        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
//        leftView = padding
//        leftViewMode = .always
//    }
//}
    
