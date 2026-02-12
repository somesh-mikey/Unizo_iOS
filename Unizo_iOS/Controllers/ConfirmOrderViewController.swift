//
//  ConfirmOrderViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 19/11/25.
//

import UIKit

class ConfirmOrderViewController: UIViewController {

    // MARK: - Data
    var selectedAddress: AddressDTO?
    var orderItems: [OrderItem] = []

    private var totalAmount: Double {
        orderItems.reduce(0) { $0 + $1.totalPrice }
    }

    // MARK: - Repositories
    private let orderRepository = OrderRepository()

    // MARK: - Outlets from XIB
    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet weak var stepIndicatorContainer: UIView!
    @IBOutlet weak var addressContainer: UIView!
    @IBOutlet weak var itemDetailContainer: UIView!
    @IBOutlet weak var paymentMethodContainer: UIView!
    @IBOutlet weak var instructionsContainer: UIView!
    @IBOutlet weak var placeOrderButton: UIButton!

    // MARK: - Top bar elements
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // MARK: - Step indicator elements
    private let stepStack = UIStackView()

    // MARK: - Address card elements
    private let addressCard = UIView()
    private let addressTitleLabel = UILabel()
    private let addressSubtitleLabel = UILabel()

    // MARK: - Item detail card elements
    private let itemsScrollView = UIScrollView()
    private let itemsStackView = UIStackView()
    private let subtotalAmountLabel = UILabel()

    // MARK: - Colors
    private let bgColor = UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1.0)
    private let primaryTeal = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
    private let accentTeal = UIColor(red: 0.0, green: 0.62, blue: 0.71, alpha: 1.0)

    private var isAddressSelected = true
    private var addressSelected = true

    @objc private func toggleAddressSelection() {
        addressSelected.toggle()
        updateAddressRadio()
    }

    private func updateAddressRadio() {
        if let bullet = addressCard.subviews.first(where: { $0 is UIButton }) as? UIButton {
            UIView.animate(withDuration: 0.2) {
                bullet.backgroundColor = self.addressSelected ? self.accentTeal : .clear
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = bgColor

        layoutContainers()
        setupTopBar()
        setupStepIndicator()
        setupAddressSection()
        setupItemDetailSection()
        setupPlaceOrderButton()

        placeOrderButton.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false

        // Restore floating tab bar frame when returning
        if let mainTab = tabBarController as? MainTabBarController {
        }
    }

    // MARK: - Container layout

    private func layoutContainers() {
        // Ensure Auto Layout is used for all containers
        [topBarContainer,
         stepIndicatorContainer,
         addressContainer,
         itemDetailContainer,
         placeOrderButton
        ].forEach { container in
            container?.translatesAutoresizingMaskIntoConstraints = false
        }

        // Hide unused containers from XIB
        paymentMethodContainer?.isHidden = true
        instructionsContainer?.isHidden = true

        NSLayoutConstraint.activate([
            // Top bar
            topBarContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 56),

            // Step indicator
            stepIndicatorContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            stepIndicatorContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepIndicatorContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stepIndicatorContainer.heightAnchor.constraint(equalToConstant: 40),

            // Address container
            addressContainer.topAnchor.constraint(equalTo: stepIndicatorContainer.bottomAnchor, constant: 8),
            addressContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addressContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addressContainer.heightAnchor.constraint(equalToConstant: 110),

            // Item detail container - dynamic height based on number of items
            itemDetailContainer.topAnchor.constraint(equalTo: addressContainer.bottomAnchor, constant: 8),
            itemDetailContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemDetailContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Place Order button
            placeOrderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            placeOrderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            placeOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            placeOrderButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    // MARK: - Top Bar

    private func setupTopBar() {
        topBarContainer.backgroundColor = bgColor

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 22
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.1
        backButton.layer.shadowRadius = 8
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Confirm Your Order"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        topBarContainer.addSubview(backButton)
        topBarContainer.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: topBarContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor)
        ])
    }

    // MARK: - Step Indicator

    // ---------- STEP INDICATOR FIX ----------
    private func setupStepIndicator() {

        stepIndicatorContainer.backgroundColor = bgColor

        stepStack.axis = .horizontal
        stepStack.alignment = .center
        stepStack.spacing = 45     // ⭐ SHIFT "Confirm Order" RIGHT (previously ~20–22)
        stepStack.translatesAutoresizingMaskIntoConstraints = false

        // --- STEP 1 ---
        let step1Circle = UIView()
        step1Circle.backgroundColor = UIColor(white: 0.85, alpha: 1.0) // light gray circle
        step1Circle.layer.cornerRadius = 10
        step1Circle.translatesAutoresizingMaskIntoConstraints = false
        step1Circle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        step1Circle.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let step1Number = UILabel()
        step1Number.text = "1"
        step1Number.textColor = .white
        step1Number.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        step1Number.textAlignment = .center
        step1Number.translatesAutoresizingMaskIntoConstraints = false
        step1Circle.addSubview(step1Number)

        NSLayoutConstraint.activate([
            step1Number.centerXAnchor.constraint(equalTo: step1Circle.centerXAnchor),
            step1Number.centerYAnchor.constraint(equalTo: step1Circle.centerYAnchor)
        ])

        let step1Label = UILabel()
        step1Label.text = "Set Hotspot"
        step1Label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        step1Label.textColor = .black

        let step1Stack = UIStackView(arrangedSubviews: [step1Circle, step1Label])
        step1Stack.axis = .horizontal
        step1Stack.spacing = 6

        // Arrow →
        let arrow = UILabel()
        arrow.text = "›"
        arrow.textColor = UIColor.gray
        arrow.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        // --- STEP 2 ---
        let step2Circle = UIView()
        step2Circle.backgroundColor = UIColor(red: 0.45, green: 0.91, blue: 0.85, alpha: 1.0) // #74E7DA
        step2Circle.layer.cornerRadius = 10
        step2Circle.translatesAutoresizingMaskIntoConstraints = false
        step2Circle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        step2Circle.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let step2Number = UILabel()
        step2Number.text = "2"
        step2Number.textColor = .black
        step2Number.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        step2Number.textAlignment = .center
        step2Number.translatesAutoresizingMaskIntoConstraints = false
        step2Circle.addSubview(step2Number)

        NSLayoutConstraint.activate([
            step2Number.centerXAnchor.constraint(equalTo: step2Circle.centerXAnchor),
            step2Number.centerYAnchor.constraint(equalTo: step2Circle.centerYAnchor)
        ])

        let step2Label = UILabel()
        step2Label.text = "Confirm Order"
        step2Label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        step2Label.textColor = UIColor.black

        let step2Stack = UIStackView(arrangedSubviews: [step2Circle, step2Label])
        step2Stack.axis = .horizontal
        step2Stack.spacing = 6

        // Add everything to main stack
        stepStack.addArrangedSubview(step1Stack)
        stepStack.addArrangedSubview(arrow)
        stepStack.addArrangedSubview(step2Stack)

        stepIndicatorContainer.addSubview(stepStack)

        NSLayoutConstraint.activate([
            stepStack.leadingAnchor.constraint(equalTo: stepIndicatorContainer.leadingAnchor, constant: 20),
            stepStack.topAnchor.constraint(equalTo: stepIndicatorContainer.topAnchor)
        ])
    }

    // MARK: - Address Section

    private func setupAddressSection() {
        addressContainer.backgroundColor = bgColor
        addressCard.layer.borderWidth = 2
        addressCard.layer.borderColor = accentTeal.cgColor

        let bullet = UIButton(type: .custom)
        bullet.translatesAutoresizingMaskIntoConstraints = false
        bullet.layer.cornerRadius = 7
        bullet.layer.borderWidth = 2
        bullet.layer.borderColor = accentTeal.cgColor
        bullet.widthAnchor.constraint(equalToConstant: 14).isActive = true
        bullet.heightAnchor.constraint(equalToConstant: 14).isActive = true
        bullet.backgroundColor = accentTeal  // Always selected

        // Use actual address data
        let address = selectedAddress
        addressTitleLabel.text = "\(address?.name ?? "No Name")  \(address?.phone ?? "")"
        addressTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        addressSubtitleLabel.text = "\(address?.line1 ?? ""),\n\(address?.city ?? ""), \(address?.state ?? "") \(address?.postal_code ?? "")"
        addressSubtitleLabel.font = UIFont.systemFont(ofSize: 12)
        addressSubtitleLabel.textColor = .darkGray
        addressSubtitleLabel.numberOfLines = 2

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .lightGray
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addressCard.translatesAutoresizingMaskIntoConstraints = false
        addressCard.backgroundColor = .white
        addressCard.layer.cornerRadius = 16
        addressCard.layer.shadowColor = UIColor.black.cgColor
        addressCard.layer.shadowOpacity = 0.06
        addressCard.layer.shadowRadius = 6
        addressCard.layer.shadowOffset = CGSize(width: 0, height: 2)

        addressContainer.addSubview(addressCard)

        [bullet, addressTitleLabel, addressSubtitleLabel, chevron].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addressCard.addSubview($0)
        }

        NSLayoutConstraint.activate([
            addressCard.leadingAnchor.constraint(equalTo: addressContainer.leadingAnchor, constant: 20),
            addressCard.trailingAnchor.constraint(equalTo: addressContainer.trailingAnchor, constant: -20),
            addressCard.topAnchor.constraint(equalTo: addressContainer.topAnchor, constant: 8),
            addressCard.bottomAnchor.constraint(equalTo: addressContainer.bottomAnchor, constant: -8),

            bullet.leadingAnchor.constraint(equalTo: addressCard.leadingAnchor, constant: 16),
            bullet.topAnchor.constraint(equalTo: addressCard.topAnchor, constant: 16),
            bullet.widthAnchor.constraint(equalToConstant: 12),
            bullet.heightAnchor.constraint(equalToConstant: 12),

            addressTitleLabel.leadingAnchor.constraint(equalTo: bullet.trailingAnchor, constant: 10),
            addressTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            addressTitleLabel.topAnchor.constraint(equalTo: addressCard.topAnchor, constant: 14),

            addressSubtitleLabel.leadingAnchor.constraint(equalTo: addressTitleLabel.leadingAnchor),
            addressSubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            addressSubtitleLabel.topAnchor.constraint(equalTo: addressTitleLabel.bottomAnchor, constant: 4),
            addressSubtitleLabel.bottomAnchor.constraint(equalTo: addressCard.bottomAnchor, constant: -14),

            chevron.centerYAnchor.constraint(equalTo: addressCard.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: addressCard.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 10)
        ])
    }

    // MARK: - Item Detail Section

    private func setupItemDetailSection() {
        itemDetailContainer.backgroundColor = bgColor

        // Use orderItems passed from AddressViewController
        let items = orderItems
        print(" ConfirmOrder - Order items count: \(items.count)")
        for (index, item) in items.enumerated() {
            print("  Item \(index + 1): \(item.product.name) - ₹\(item.product.price) x \(item.quantity)")
        }

        let sectionTitle = UILabel()
        sectionTitle.text = "Item Detail (\(items.count) items)"
        sectionTitle.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        itemDetailContainer.addSubview(sectionTitle)

        // Setup scroll view for items
        itemsScrollView.translatesAutoresizingMaskIntoConstraints = false
        itemsScrollView.showsVerticalScrollIndicator = true
        itemsScrollView.alwaysBounceVertical = true
        itemDetailContainer.addSubview(itemsScrollView)

        // Setup stack view for item cards
        itemsStackView.axis = .vertical
        itemsStackView.spacing = 10
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        itemsScrollView.addSubview(itemsStackView)

        // Subtotal bar
        let subtotalBar = UIView()
        subtotalBar.backgroundColor = .white
        subtotalBar.layer.cornerRadius = 12
        subtotalBar.translatesAutoresizingMaskIntoConstraints = false
        itemDetailContainer.addSubview(subtotalBar)

        let subtotalLabel = UILabel()
        subtotalLabel.text = "Subtotal"
        subtotalLabel.font = UIFont.systemFont(ofSize: 13)
        subtotalLabel.textColor = .darkGray

        // Use actual cart total
        subtotalAmountLabel.text = "₹\(Int(totalAmount))"
        subtotalAmountLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        subtotalAmountLabel.textColor = .black
        subtotalAmountLabel.textAlignment = .right

        [subtotalLabel, subtotalAmountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            subtotalBar.addSubview($0)
        }

        // Calculate height based on number of items (show max 2 items, scroll for more)
        let itemCardHeight: CGFloat = 120
        let spacing: CGFloat = 10
        let itemCount = max(items.count, 1) // At least 1 to avoid zero height
        let maxVisibleItems = min(itemCount, 2)
        let scrollViewHeight = CGFloat(maxVisibleItems) * itemCardHeight + CGFloat(max(0, maxVisibleItems - 1)) * spacing

        NSLayoutConstraint.activate([
            sectionTitle.topAnchor.constraint(equalTo: itemDetailContainer.topAnchor),
            sectionTitle.leadingAnchor.constraint(equalTo: itemDetailContainer.leadingAnchor, constant: 20),

            itemsScrollView.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 8),
            itemsScrollView.leadingAnchor.constraint(equalTo: itemDetailContainer.leadingAnchor, constant: 20),
            itemsScrollView.trailingAnchor.constraint(equalTo: itemDetailContainer.trailingAnchor, constant: -20),
            itemsScrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight),

            itemsStackView.topAnchor.constraint(equalTo: itemsScrollView.topAnchor),
            itemsStackView.leadingAnchor.constraint(equalTo: itemsScrollView.leadingAnchor),
            itemsStackView.trailingAnchor.constraint(equalTo: itemsScrollView.trailingAnchor),
            itemsStackView.bottomAnchor.constraint(equalTo: itemsScrollView.bottomAnchor),
            itemsStackView.widthAnchor.constraint(equalTo: itemsScrollView.widthAnchor),

            subtotalBar.topAnchor.constraint(equalTo: itemsScrollView.bottomAnchor, constant: 10),
            subtotalBar.leadingAnchor.constraint(equalTo: itemDetailContainer.leadingAnchor, constant: 20),
            subtotalBar.trailingAnchor.constraint(equalTo: itemDetailContainer.trailingAnchor, constant: -20),
            subtotalBar.heightAnchor.constraint(equalToConstant: 32),
            subtotalBar.bottomAnchor.constraint(equalTo: itemDetailContainer.bottomAnchor, constant: -4),

            subtotalLabel.centerYAnchor.constraint(equalTo: subtotalBar.centerYAnchor),
            subtotalLabel.leadingAnchor.constraint(equalTo: subtotalBar.leadingAnchor, constant: 12),

            subtotalAmountLabel.centerYAnchor.constraint(equalTo: subtotalBar.centerYAnchor),
            subtotalAmountLabel.trailingAnchor.constraint(equalTo: subtotalBar.trailingAnchor, constant: -12)
        ])

        // Create a card for each order item
        for item in items {
            let itemCard = createItemCard(for: item)
            itemsStackView.addArrangedSubview(itemCard)
        }
    }

    // MARK: - Create Item Card
    private func createItemCard(for orderItem: OrderItem) -> UIView {
        let product = orderItem.product

        let itemCard = UIView()
        itemCard.translatesAutoresizingMaskIntoConstraints = false
        itemCard.backgroundColor = .white
        itemCard.layer.cornerRadius = 16
        itemCard.layer.shadowColor = UIColor.black.cgColor
        itemCard.layer.shadowOpacity = 0.06
        itemCard.layer.shadowRadius = 6
        itemCard.layer.shadowOffset = CGSize(width: 0, height: 2)

        // Product image
        let productImage = UIImageView()
        productImage.contentMode = .scaleAspectFill
        productImage.layer.cornerRadius = 8
        productImage.clipsToBounds = true
        productImage.translatesAutoresizingMaskIntoConstraints = false

        if let imageURL = product.imageURL, !imageURL.isEmpty {
            if imageURL.hasPrefix("http") {
                productImage.loadImage(from: imageURL)
            } else {
                productImage.image = UIImage(named: imageURL)
            }
        }

        let categoryLabel = UILabel()
        categoryLabel.text = product.category
        categoryLabel.font = UIFont.systemFont(ofSize: 11)
        categoryLabel.textColor = .gray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false

        let itemTitleLabel = UILabel()
        itemTitleLabel.text = product.name
        itemTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let priceLabel = UILabel()
        priceLabel.text = "₹\(Int(product.price))"
        priceLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        priceLabel.textAlignment = .right
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        // LEFT SIDE LABELS (TEAL)
        func teal(_ text: String) -> UILabel {
            let l = UILabel()
            l.text = text
            l.font = UIFont.systemFont(ofSize: 11)
            l.textColor = accentTeal
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }

        let colourLabel = teal("Colour")
        let sizeLabel = teal("Size")
        let qtyLabel = teal("Quantity")

        // RIGHT SIDE VALUES
        func value(_ text: String) -> UILabel {
            let l = UILabel()
            l.text = text
            l.font = UIFont.systemFont(ofSize: 11)
            l.textColor = .black
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }

        let colourValue = value(product.colour ?? "—")
        let sizeValue = value(product.size ?? "—")
        let qtyValue = value("\(orderItem.quantity)")

        [productImage, categoryLabel, itemTitleLabel, priceLabel,
         colourLabel, sizeLabel, qtyLabel,
         colourValue, sizeValue, qtyValue].forEach {
            itemCard.addSubview($0)
        }

        NSLayoutConstraint.activate([
            itemCard.heightAnchor.constraint(equalToConstant: 120),

            productImage.leadingAnchor.constraint(equalTo: itemCard.leadingAnchor, constant: 12),
            productImage.centerYAnchor.constraint(equalTo: itemCard.centerYAnchor),
            productImage.widthAnchor.constraint(equalToConstant: 60),
            productImage.heightAnchor.constraint(equalToConstant: 60),

            categoryLabel.leadingAnchor.constraint(equalTo: productImage.trailingAnchor, constant: 12),
            categoryLabel.topAnchor.constraint(equalTo: itemCard.topAnchor, constant: 12),

            itemTitleLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            itemTitleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 2),

            priceLabel.trailingAnchor.constraint(equalTo: itemCard.trailingAnchor, constant: -12),
            priceLabel.topAnchor.constraint(equalTo: itemCard.topAnchor, constant: 14),

            // LEFT COLUMN
            colourLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            colourLabel.topAnchor.constraint(equalTo: itemTitleLabel.bottomAnchor, constant: 6),

            sizeLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            sizeLabel.topAnchor.constraint(equalTo: colourLabel.bottomAnchor, constant: 3),

            qtyLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            qtyLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 3),

            // RIGHT COLUMN under price
            colourValue.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            colourValue.topAnchor.constraint(equalTo: colourLabel.topAnchor),

            sizeValue.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            sizeValue.topAnchor.constraint(equalTo: sizeLabel.topAnchor),

            qtyValue.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            qtyValue.topAnchor.constraint(equalTo: qtyLabel.topAnchor)
        ])

        return itemCard
    }

    // MARK: - Place Order Button

    private func setupPlaceOrderButton() {
        placeOrderButton.backgroundColor = primaryTeal
        placeOrderButton.setTitle("Place Order", for: .normal)
        placeOrderButton.setTitleColor(.white, for: .normal)
        placeOrderButton.layer.cornerRadius = 24
        placeOrderButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        placeOrderButton.titleLabel?.numberOfLines = 1
        placeOrderButton.titleLabel?.lineBreakMode = .byClipping
    }

    @objc private func placeOrderTapped() {
        guard let address = selectedAddress else {
            showAlert(title: "Error", message: "Please select a delivery hotspot")
            return
        }

        guard !orderItems.isEmpty else {
            showAlert(title: "Error", message: "No items to order")
            return
        }

        // Disable button to prevent double-tap
        placeOrderButton.isEnabled = false

        let savedTotal = totalAmount

        Task {
            do {
                // Create order in Supabase
                let orderId = try await orderRepository.createOrder(
                    addressId: address.id,
                    items: orderItems,
                    totalAmount: savedTotal,
                    paymentMethod: "Cash",  // Default payment method
                    instructions: nil
                )

                // Get categories from ordered items for suggestions
                let orderedCategories = orderItems.compactMap { $0.product.category }

                await MainActor.run {
                    // Navigate to OrderPlacedViewController with order data
                    let vc = OrderPlacedViewController()
                    vc.orderId = orderId
                    vc.orderAddress = address
                    vc.orderedCategories = orderedCategories
                    vc.orderTotal = savedTotal

                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .coverVertical

                    self.present(vc, animated: true)
                }
            } catch {
                print("❌ Failed to create order:", error)
                await MainActor.run {
                    self.placeOrderButton.isEnabled = true
                    self.showAlert(title: "Error", message: "Failed to place order: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func goBack() {
        // If this screen was pushed in a navigation controller
        if let nav = navigationController {
            nav.popViewController(animated: true)
            return
        }

        // If this screen was presented modally (full screen slide up)
        dismiss(animated: true)
    }

}
