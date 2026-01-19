//
//  ConfirmOrderViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 19/11/25.
//

import UIKit

class ConfirmOrderViewController: UIViewController,UITextViewDelegate {

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
    private let heartButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // MARK: - Step indicator elements
    private let stepStack = UIStackView()

    // MARK: - Address card elements
    private let addressCard = UIView()

    // MARK: - Item detail card elements
    private let itemCard = UIView()

    // MARK: - Payment method elements
    private let paymentTitleLabel = UILabel()
    private let cashButton = UIButton(type: .system)
    private let upiButton = UIButton(type: .system)

    // MARK: - Instructions elements
    private let instructionsTitleLabel = UILabel()
    private let instructionsTextView = UITextView()

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
        setupPaymentMethodSection()
        setupInstructionsSection()
        setupPlaceOrderButton()
        
        placeOrderButton.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)
        instructionsTextView.delegate = self
        
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
         paymentMethodContainer,
         instructionsContainer,
         placeOrderButton
        ].forEach { container in
            container?.translatesAutoresizingMaskIntoConstraints = false
        }

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

            // Item detail container
            itemDetailContainer.topAnchor.constraint(equalTo: addressContainer.bottomAnchor, constant: 8),
            itemDetailContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemDetailContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemDetailContainer.heightAnchor.constraint(equalToConstant: 220),

            // Payment method container
            paymentMethodContainer.topAnchor.constraint(equalTo: itemDetailContainer.bottomAnchor, constant: 8),
            paymentMethodContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentMethodContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paymentMethodContainer.heightAnchor.constraint(equalToConstant: 150),

            // Instructions container
            instructionsContainer.topAnchor.constraint(equalTo: paymentMethodContainer.bottomAnchor, constant: 8),
            instructionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            instructionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            instructionsContainer.bottomAnchor.constraint(lessThanOrEqualTo: placeOrderButton.topAnchor, constant: -16),
            instructionsContainer.heightAnchor.constraint(equalToConstant: 130),


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
        backButton.translatesAutoresizingMaskIntoConstraints = false

        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .black
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Confirm Your Order"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        topBarContainer.addSubview(backButton)
        topBarContainer.addSubview(heartButton)
        topBarContainer.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            heartButton.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 28),
            heartButton.heightAnchor.constraint(equalToConstant: 28),

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
        step1Label.text = "Set Address"
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
        //bullet.addTarget(self, action: #selector(toggleAddressSelection), for: .touchUpInside)

        bullet.widthAnchor.constraint(equalToConstant: 14).isActive = true
        bullet.heightAnchor.constraint(equalToConstant: 14).isActive = true

        // Make card tappable
        //addressCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleAddressSelection)))

        // After placing bullet
        //updateAddressRadio()
        
        bullet.backgroundColor = accentTeal  // Always selected

        let titleLabel = UILabel()
        titleLabel.text = "Jonathan  (+91) 90078 91599"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "4517 Washington Ave,\nManchester, Kentucky 39495"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 2

        

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

        [bullet, titleLabel, subtitleLabel, chevron].forEach {
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

            titleLabel.leadingAnchor.constraint(equalTo: bullet.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: addressCard.topAnchor, constant: 14),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: addressCard.bottomAnchor, constant: -14),

            chevron.centerYAnchor.constraint(equalTo: addressCard.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: addressCard.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 10)
        ])
    }

    // MARK: - Item Detail Section

    private func setupItemDetailSection() {
        itemDetailContainer.backgroundColor = bgColor

        let sectionTitle = UILabel()
        sectionTitle.text = "Item Detail"
        sectionTitle.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        itemDetailContainer.addSubview(sectionTitle)

        // Main Card
        itemCard.translatesAutoresizingMaskIntoConstraints = false
        itemCard.backgroundColor = .white
        itemCard.layer.cornerRadius = 16
        itemCard.layer.shadowColor = UIColor.black.cgColor
        itemCard.layer.shadowOpacity = 0.06
        itemCard.layer.shadowRadius = 6
        itemCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        itemDetailContainer.addSubview(itemCard)

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

        let subtotalAmount = UILabel()
        subtotalAmount.text = "₹500"
        subtotalAmount.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        subtotalAmount.textColor = .black
        subtotalAmount.textAlignment = .right

        [subtotalLabel, subtotalAmount].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            subtotalBar.addSubview($0)
        }

        NSLayoutConstraint.activate([
            sectionTitle.topAnchor.constraint(equalTo: itemDetailContainer.topAnchor),
            sectionTitle.leadingAnchor.constraint(equalTo: itemDetailContainer.leadingAnchor, constant: 20),

            itemCard.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 8),
            itemCard.leadingAnchor.constraint(equalTo: itemDetailContainer.leadingAnchor, constant: 20),
            itemCard.trailingAnchor.constraint(equalTo: itemDetailContainer.trailingAnchor, constant: -20),
            itemCard.heightAnchor.constraint(equalToConstant: 140),

            subtotalBar.topAnchor.constraint(equalTo: itemCard.bottomAnchor, constant: 10),
            subtotalBar.leadingAnchor.constraint(equalTo: itemDetailContainer.leadingAnchor, constant: 20),
            subtotalBar.trailingAnchor.constraint(equalTo: itemDetailContainer.trailingAnchor, constant: -20),
            subtotalBar.heightAnchor.constraint(equalToConstant: 32),
            subtotalBar.bottomAnchor.constraint(lessThanOrEqualTo: itemDetailContainer.bottomAnchor, constant: -4),

            subtotalLabel.centerYAnchor.constraint(equalTo: subtotalBar.centerYAnchor),
            subtotalLabel.leadingAnchor.constraint(equalTo: subtotalBar.leadingAnchor, constant: 12),

            subtotalAmount.centerYAnchor.constraint(equalTo: subtotalBar.centerYAnchor),
            subtotalAmount.trailingAnchor.constraint(equalTo: subtotalBar.trailingAnchor, constant: -12)
        ])

        // Inside card
        let productImage = UIImageView()
        productImage.image = UIImage(named: "Cap")
        productImage.layer.cornerRadius = 8
        productImage.clipsToBounds = true
        productImage.translatesAutoresizingMaskIntoConstraints = false

        let categoryLabel = UILabel()
        categoryLabel.text = "Fashion"
        categoryLabel.font = UIFont.systemFont(ofSize: 11)
        categoryLabel.textColor = .gray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false

        let itemTitleLabel = UILabel()
        itemTitleLabel.text = "Under Armour Cap"
        itemTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let priceLabel = UILabel()
        priceLabel.text = "₹500"
        priceLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        priceLabel.textAlignment = .right
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        // LEFT SIDE LABELS (TEAL)
        func teal(_ text: String) -> UILabel {
            let l = UILabel()
            l.text = text
            l.font = UIFont.systemFont(ofSize: 11)
            l.textColor = accentTeal   // ⭐ teal text
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

        let colourValue = value("White")
        let sizeValue = value("Large")
        let qtyValue = value("1")

        [productImage, categoryLabel, itemTitleLabel, priceLabel,
         colourLabel, sizeLabel, qtyLabel,
         colourValue, sizeValue, qtyValue].forEach {
            itemCard.addSubview($0)
        }

        NSLayoutConstraint.activate([

            productImage.leadingAnchor.constraint(equalTo: itemCard.leadingAnchor, constant: 12),
            productImage.centerYAnchor.constraint(equalTo: itemCard.centerYAnchor, constant: -8),
            productImage.widthAnchor.constraint(equalToConstant: 70),
            productImage.heightAnchor.constraint(equalToConstant: 70),

            categoryLabel.leadingAnchor.constraint(equalTo: productImage.trailingAnchor, constant: 12),
            categoryLabel.topAnchor.constraint(equalTo: itemCard.topAnchor, constant: 14),

            itemTitleLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            itemTitleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 2),

            priceLabel.trailingAnchor.constraint(equalTo: itemCard.trailingAnchor, constant: -12),
            priceLabel.topAnchor.constraint(equalTo: itemCard.topAnchor, constant: 18),

            // LEFT COLUMN
            colourLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            colourLabel.topAnchor.constraint(equalTo: itemTitleLabel.bottomAnchor, constant: 8),

            sizeLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            sizeLabel.topAnchor.constraint(equalTo: colourLabel.bottomAnchor, constant: 4),

            qtyLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            qtyLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 4),

            // RIGHT COLUMN under price
            colourValue.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            colourValue.topAnchor.constraint(equalTo: colourLabel.topAnchor),

            sizeValue.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            sizeValue.topAnchor.constraint(equalTo: sizeLabel.topAnchor),

            qtyValue.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            qtyValue.topAnchor.constraint(equalTo: qtyLabel.topAnchor)
        ])
    }

    // MARK: - Payment Method Section

    private func setupPaymentMethodSection() {
        paymentMethodContainer.backgroundColor = bgColor

        paymentTitleLabel.text = "Payment Method"
        paymentTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        paymentTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Setup toggle buttons
        configurePaymentButton(cashButton, title: "Cash")
        configurePaymentButton(upiButton, title: "UPI")

        cashButton.addTarget(self, action: #selector(selectCash), for: .touchUpInside)
        upiButton.addTarget(self, action: #selector(selectUPI), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [cashButton, upiButton])
        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        paymentMethodContainer.addSubview(paymentTitleLabel)
        paymentMethodContainer.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            paymentTitleLabel.topAnchor.constraint(equalTo: paymentMethodContainer.topAnchor),
            paymentTitleLabel.leadingAnchor.constraint(equalTo: paymentMethodContainer.leadingAnchor, constant: 20),

            buttonStack.topAnchor.constraint(equalTo: paymentTitleLabel.bottomAnchor, constant: 14),
            buttonStack.leadingAnchor.constraint(equalTo: paymentMethodContainer.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: paymentMethodContainer.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 64)
        ])
    }


    private func configurePaymentButton(_ button: UIButton, title: String) {

        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        //button.layer.borderColor = accentTeal.cgColor
        button.layer.borderColor = UIColor(red: 0.09, green: 0.60, blue: 0.71, alpha: 1.0).cgColor  // #189AB4
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false

        // Remove old content
        button.subviews.forEach { $0.removeFromSuperview() }

        // Circle
        let circle = UIView()
        circle.tag = 99 // so we can find it later
        circle.layer.cornerRadius = 7
        circle.layer.borderWidth = 2
        circle.layer.borderColor = accentTeal.cgColor
        circle.translatesAutoresizingMaskIntoConstraints = false

        // Title
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(circle)
        button.addSubview(label)

        NSLayoutConstraint.activate([
            circle.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 18),
            circle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 14),
            circle.heightAnchor.constraint(equalToConstant: 14),

            label.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }


    // MARK: - Instructions Section

    // MARK: - Instructions Section
    private func setupInstructionsSection() {
        instructionsContainer.backgroundColor = bgColor
        instructionsContainer.isHidden = false

        // ----- TITLE LABEL -----
        instructionsTitleLabel.text = "Instructions"
        instructionsTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        instructionsTitleLabel.textColor = .black
        instructionsTitleLabel.backgroundColor = .clear
        instructionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // ----- TEXTVIEW -----
        instructionsTextView.text = "Add a message..."
        instructionsTextView.font = UIFont.systemFont(ofSize: 14)
        instructionsTextView.textColor = .lightGray
        instructionsTextView.layer.cornerRadius = 12
        instructionsTextView.layer.borderWidth = 0.5
        instructionsTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        instructionsTextView.backgroundColor = .white
        instructionsTextView.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews (force rebuild)
        instructionsContainer.addSubview(instructionsTitleLabel)
        instructionsContainer.addSubview(instructionsTextView)
        instructionsContainer.bringSubviewToFront(instructionsTitleLabel)

        NSLayoutConstraint.activate([
            // Title label
            instructionsTitleLabel.topAnchor.constraint(equalTo: instructionsContainer.topAnchor),
            instructionsTitleLabel.leadingAnchor.constraint(equalTo: instructionsContainer.leadingAnchor, constant: 20),
            instructionsTitleLabel.trailingAnchor.constraint(equalTo: instructionsContainer.trailingAnchor, constant: -20),

            // TextView under heading
            instructionsTextView.topAnchor.constraint(equalTo: instructionsTitleLabel.bottomAnchor, constant: 10),
            instructionsTextView.leadingAnchor.constraint(equalTo: instructionsContainer.leadingAnchor, constant: 20),
            instructionsTextView.trailingAnchor.constraint(equalTo: instructionsContainer.trailingAnchor, constant: -20),
            instructionsTextView.heightAnchor.constraint(equalToConstant: 80),
            instructionsTextView.bottomAnchor.constraint(equalTo: instructionsContainer.bottomAnchor, constant: -10)
        ])
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
    
    // MARK: - PAYMENT TOGGLE
    @objc private func selectCash() {
        updatePaymentSelection(cashSelected: true)
    }

    @objc private func selectUPI() {
        updatePaymentSelection(cashSelected: false)
    }

    private func updatePaymentSelection(cashSelected: Bool) {

        highlightPaymentButton(cashButton, selected: cashSelected)
        highlightPaymentButton(upiButton, selected: !cashSelected)
    }

    private func highlightPaymentButton(_ button: UIButton, selected: Bool) {

        let circle = button.viewWithTag(99) as! UIView
        circle.subviews.forEach { $0.removeFromSuperview() }  // clear dot

        if selected {
            let dot = UIView()
            dot.backgroundColor = accentTeal
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            circle.addSubview(dot)

            NSLayoutConstraint.activate([
                dot.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                dot.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
                dot.widthAnchor.constraint(equalToConstant: 8),
                dot.heightAnchor.constraint(equalToConstant: 8)
            ])

            //button.layer.borderColor = accentTeal.cgColor
            button.layer.borderColor = UIColor(red: 0.09, green: 0.60, blue: 0.71, alpha: 1.0).cgColor  // #189AB4
        } else {
            button.layer.borderColor = accentTeal.withAlphaComponent(0.4).cgColor
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add a message..." {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a message..."
            textView.textColor = .lightGray
        }
    }
    
    @objc private func placeOrderTapped() {
        let vc = OrderPlacedViewController()

        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical

        present(vc, animated: true)
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
