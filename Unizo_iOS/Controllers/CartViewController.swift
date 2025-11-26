//
//  CartViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 13/11/25.
//

import UIKit

class CartViewController: UIViewController {

    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Top Cart Item Card
    private let mainItemCard = UIView()
    private let mainItemImage = UIImageView()
    private let mainItemCategory = UILabel()
    private let mainItemTitle = UILabel()
    private let mainItemSeller = UILabel()
    private let mainItemPrice = UILabel()

   

    // Section labels
    private let itemsTitle = UILabel()
    private let suggestionsTitle = UILabel()

    // Grid Container
    private let suggestionsContainer = UIStackView()

    // Bottom Bar
    private let bottomBar = UIView()
    private let itemsCountLabel = UILabel()
    private let totalPriceLabel = UILabel()
    private let checkoutButton = UIButton()

    // DARK TEAL (same as Checkout)
    
    private let checkBoxButton = UIButton(type: .system)
    private let darkTeal = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)

    @objc private func toggleCheckbox() {
        if checkBoxButton.currentImage == UIImage(systemName: "square") {
            checkBoxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            checkBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1)

        setupNavBar()
        setupScrollView()
        setupTopItemCard()
        setupSuggestions()
        setupBottomBar()
    }

    // MARK: - Navigation Bar
    private func setupNavBar() {
        title = "Cart(1)"
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backPressed)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: nil
        )
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - ScrollView Layout
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Top Main Item Card
    private func setupTopItemCard() {

        itemsTitle.text = "Items"
        itemsTitle.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        itemsTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemsTitle)

        NSLayoutConstraint.activate([
            itemsTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            itemsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        mainItemCard.backgroundColor = .white
        mainItemCard.layer.cornerRadius = 14
        mainItemCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainItemCard)

        // CLICKABLE CHECKBOX
        checkBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkBoxButton.tintColor = darkTeal
        checkBoxButton.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)
        checkBoxButton.translatesAutoresizingMaskIntoConstraints = false
        mainItemCard.addSubview(checkBoxButton)

        // MAIN IMAGE
        mainItemImage.image = UIImage(named: "cap")
        mainItemImage.contentMode = .scaleAspectFill
        mainItemImage.layer.cornerRadius = 12
        mainItemImage.clipsToBounds = true
        mainItemImage.translatesAutoresizingMaskIntoConstraints = false
        mainItemCard.addSubview(mainItemImage)

        // CATEGORY
        mainItemCategory.text = "Fashion"
        mainItemCategory.textColor = .gray
        mainItemCategory.font = UIFont.systemFont(ofSize: 12)
        mainItemCategory.translatesAutoresizingMaskIntoConstraints = false

        // TITLE
        mainItemTitle.text = "Under Armour Cap"
        mainItemTitle.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        mainItemTitle.translatesAutoresizingMaskIntoConstraints = false

        // SOLD BY (teal + gray)
        let soldByLabel = UILabel()
        soldByLabel.text = "Sold by"
        soldByLabel.textColor = darkTeal
        soldByLabel.font = UIFont.systemFont(ofSize: 12)
        soldByLabel.translatesAutoresizingMaskIntoConstraints = false

        mainItemSeller.text = "Paul McKinney"
        mainItemSeller.textColor = .gray
        mainItemSeller.font = UIFont.systemFont(ofSize: 12)
        mainItemSeller.translatesAutoresizingMaskIntoConstraints = false

        // EDIT ICON
        let editIcon = UIButton(type: .system)
        editIcon.setImage(UIImage(systemName: "pencil"), for: .normal)
        editIcon.tintColor = darkTeal
        editIcon.translatesAutoresizingMaskIntoConstraints = false
        editIcon.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        // DELETE ICON
        let deleteIcon = UIButton(type: .system)
        deleteIcon.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteIcon.tintColor = darkTeal
        deleteIcon.translatesAutoresizingMaskIntoConstraints = false
        deleteIcon.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        // PRICE
        mainItemPrice.text = "₹500"
        mainItemPrice.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        mainItemPrice.translatesAutoresizingMaskIntoConstraints = false

        // Add all
        for v in [mainItemCategory, mainItemTitle, soldByLabel, mainItemSeller, editIcon, deleteIcon, mainItemPrice] {
            mainItemCard.addSubview(v)
        }

        // --- Layout ---
        NSLayoutConstraint.activate([
            mainItemCard.topAnchor.constraint(equalTo: itemsTitle.bottomAnchor, constant: 15),
            mainItemCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainItemCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainItemCard.heightAnchor.constraint(equalToConstant: 150),

            checkBoxButton.leadingAnchor.constraint(equalTo: mainItemCard.leadingAnchor, constant: 12),
            checkBoxButton.centerYAnchor.constraint(equalTo: mainItemCard.centerYAnchor),
            checkBoxButton.widthAnchor.constraint(equalToConstant: 24),
            checkBoxButton.heightAnchor.constraint(equalToConstant: 24),

            mainItemImage.leadingAnchor.constraint(equalTo: checkBoxButton.trailingAnchor, constant: 10),
            mainItemImage.topAnchor.constraint(equalTo: mainItemCard.topAnchor, constant: 20),
            mainItemImage.widthAnchor.constraint(equalToConstant: 60),
            mainItemImage.heightAnchor.constraint(equalToConstant: 60),

            mainItemCategory.topAnchor.constraint(equalTo: mainItemCard.topAnchor, constant: 18),
            mainItemCategory.leadingAnchor.constraint(equalTo: mainItemImage.trailingAnchor, constant: 12),

            mainItemTitle.topAnchor.constraint(equalTo: mainItemCategory.bottomAnchor, constant: 2),
            mainItemTitle.leadingAnchor.constraint(equalTo: mainItemCategory.leadingAnchor),

            soldByLabel.topAnchor.constraint(equalTo: mainItemTitle.bottomAnchor, constant: 3),
            soldByLabel.leadingAnchor.constraint(equalTo: mainItemCategory.leadingAnchor),

            mainItemSeller.centerYAnchor.constraint(equalTo: soldByLabel.centerYAnchor),
            mainItemSeller.leadingAnchor.constraint(equalTo: soldByLabel.trailingAnchor, constant: 4),

            // EDIT BUTTON (under Sold By)
            editIcon.topAnchor.constraint(equalTo: soldByLabel.bottomAnchor, constant: 6),
            editIcon.leadingAnchor.constraint(equalTo: soldByLabel.leadingAnchor),
            editIcon.widthAnchor.constraint(equalToConstant: 18),
            editIcon.heightAnchor.constraint(equalToConstant: 18),

            // DELETE BUTTON (next to edit button)
            deleteIcon.centerYAnchor.constraint(equalTo: editIcon.centerYAnchor),
            deleteIcon.leadingAnchor.constraint(equalTo: editIcon.trailingAnchor, constant: 12),
            deleteIcon.widthAnchor.constraint(equalToConstant: 18),
            deleteIcon.heightAnchor.constraint(equalToConstant: 18),

            // PRICE
            mainItemPrice.trailingAnchor.constraint(equalTo: mainItemCard.trailingAnchor, constant: -12),
            mainItemPrice.topAnchor.constraint(equalTo: mainItemCard.topAnchor, constant: 20)
        ])
    }

    @objc private func editTapped() {
        print("EDIT tapped")
    }

    @objc private func deleteTapped() {
        print("DELETE tapped")
    }

    // MARK: - You May Also Like
    private func setupSuggestions() {

        suggestionsTitle.text = "You may also like:"
        suggestionsTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        suggestionsTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(suggestionsTitle)

        NSLayoutConstraint.activate([
            suggestionsTitle.topAnchor.constraint(equalTo: mainItemCard.bottomAnchor, constant: 25),
            suggestionsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        // Vertical grid container
        suggestionsContainer.axis = .vertical
        suggestionsContainer.spacing = 18
        suggestionsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(suggestionsContainer)

        NSLayoutConstraint.activate([
            suggestionsContainer.topAnchor.constraint(equalTo: suggestionsTitle.bottomAnchor, constant: 15),
            suggestionsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            suggestionsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        // Create rows of 2 cards each
        let items = [
            ("pinkbicycle", "Pink Bicycle", "4.1", "Negotiable", "₹7500"),
            ("bat", "BAS Size 6 Cricket Bat", "4.1", "Negotiable", "₹899"),
            ("Rackets", "Tennis Rackets", "3.9", "Negotiable", "₹2300"),
            ("NoiseHeadphone", "Noise Two Wireless", "2.9", "Negotiable", "₹1800")
        ]

        var rowStack: UIStackView?

        for (index, item) in items.enumerated() {

            if index % 2 == 0 {
                rowStack = UIStackView()
                rowStack?.axis = .horizontal
                rowStack?.distribution = .fillEqually
                rowStack?.spacing = 14
                suggestionsContainer.addArrangedSubview(rowStack!)
            }

            let card = createSuggestionCard(
                imageName: item.0,
                title: item.1,
                rating: item.2,
                negotiable: item.3,
                price: item.4
            )
            rowStack?.addArrangedSubview(card)
        }

        // Bottom space
        let bottomSpace = UIView()
        bottomSpace.heightAnchor.constraint(equalToConstant: 60).isActive = true
        contentView.addSubview(bottomSpace)

        bottomSpace.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSpace.topAnchor.constraint(equalTo: suggestionsContainer.bottomAnchor),
            bottomSpace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSpace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSpace.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Suggestion Card (Wide Cards + Full Details)
    private func createSuggestionCard(
        imageName: String,
        title: String,
        rating: String,
        negotiable: String,
        price: String
    ) -> UIView {

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false

        let img = UIImageView(image: UIImage(named: imageName))
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.cornerRadius = 10
        img.translatesAutoresizingMaskIntoConstraints = false

        // Separator line
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let ratingLabel = UILabel()
        ratingLabel.text = "★ \(rating)  |  \(negotiable)"
        ratingLabel.textColor = darkTeal
        ratingLabel.font = UIFont.systemFont(ofSize: 12)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.textColor = darkTeal
        priceLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        for v in [img, line, titleLabel, ratingLabel, priceLabel] {
            card.addSubview(v)
        }

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 210),

            img.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            img.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            img.widthAnchor.constraint(equalToConstant: 85),
            img.heightAnchor.constraint(equalToConstant: 110),

            line.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 8),
            line.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            line.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            line.heightAnchor.constraint(equalToConstant: 1),

            titleLabel.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            priceLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])

        return card
    }

    // MARK: - Bottom Checkout Bar
    private func setupBottomBar() {

        bottomBar.backgroundColor = .white
        bottomBar.layer.cornerRadius = 30
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        itemsCountLabel.text = "1 item"
        itemsCountLabel.font = UIFont.systemFont(ofSize: 15)
        itemsCountLabel.translatesAutoresizingMaskIntoConstraints = false

        totalPriceLabel.text = "₹500"
        totalPriceLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false

        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.backgroundColor = darkTeal
        checkoutButton.layer.cornerRadius = 22
        checkoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)

        for v in [itemsCountLabel, totalPriceLabel, checkoutButton] {
            bottomBar.addSubview(v)
        }

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 95),

            itemsCountLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            itemsCountLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 30),

            totalPriceLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            totalPriceLabel.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),

            checkoutButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -25),
            checkoutButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            checkoutButton.widthAnchor.constraint(equalToConstant: 130),
            checkoutButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    @objc private func checkoutButtonTapped() {
        let vc = AddressViewController()
        vc.flowSource = .fromCart    // ← IMPORTANT


        // FULL SCREEN + SLIDES FROM BOTTOM (same style as your Cart screen)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical

        self.present(vc, animated: true, completion: nil)
    }
}
