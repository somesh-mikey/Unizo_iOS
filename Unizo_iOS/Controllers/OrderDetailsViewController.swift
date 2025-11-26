//
//  OrderDetailsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 20/11/25.
//

import UIKit

class OrderDetailsViewController: UIViewController {

    // MARK: - Colors
    private let bgColor = UIColor(red: 0.96, green: 0.97, blue: 1.00, alpha: 1.0)
    private let darkTeal = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1.0) // checkout color
    private let accentTeal = UIColor(red: 0.00, green: 0.62, blue: 0.71, alpha: 1.0)
    private let lightGrayText = UIColor(white: 0.55, alpha: 1.0)

    // MARK: - Non-scrolling top bar
    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let navTitleLabel = UILabel()
    private let heartButton = UIButton(type: .system)

    // MARK: - Scroll + content
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Status card
    private let statusCard = UIView()
    private let statusCircle = UIView()
    private let statusCheck = UIImageView()
    private let statusTitleLabel = UILabel()
    private let statusTimeLabel = UILabel()
    private let orderIdLabel = UILabel()
    private let totalAmountLabel = UILabel()

    // MARK: - Timeline
    private let timelineLabel = UILabel()
    private let timelineStack = UIStackView()

    // MARK: - Item card
    private let orderItemsTitle = UILabel()
    private let itemCard = UIView()
    private let itemImageView = UIImageView()
    private let itemCategoryLabel = UILabel()
    private let itemTitleLabel = UILabel()
    private let leftLabelsStack = UIStackView()   // Colour / Size / Quantity
    private let rightValuesStack = UIStackView()  // Price + values
    private let priceLabel = UILabel()

    // MARK: - Delivery info
    private let deliveryTitle = UILabel()
    private let deliveryNameLabel = UILabel()
    private let deliveryAddressLabel = UILabel()

    // MARK: - Order summary
    private let orderSummaryTitle = UILabel()
    private let summaryCard = UIView()

    // MARK: - Bottom buttons
    private let bottomButtonsContainer = UIStackView()
    private let rateButton = UIButton(type: .system)
    private let helpButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor

        setupTopBar()
        setupScrollHierarchy()
        setupStatusCard()
        setupTimeline()
        setupItemCard()
        setupDeliveryInfo()
        setupOrderSummary()
        setupBottomButtons()
    }

    // MARK: - Top (fixed) bar
    private func setupTopBar() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)

        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .black
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        navTitleLabel.text = "Order Details"
        navTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        topBar.addSubview(backButton)
        topBar.addSubview(navTitleLabel)
        topBar.addSubview(heartButton)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 56),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            heartButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -12),
            heartButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 40),
            heartButton.heightAnchor.constraint(equalToConstant: 40),

            navTitleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            navTitleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
    }

    // MARK: - Scroll + content layout (scrollable content BELOW topBar)
    private func setupScrollHierarchy() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            // scroll view sits below topBar
            scrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
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

    // MARK: - Status Card
    private func setupStatusCard() {
        statusCard.translatesAutoresizingMaskIntoConstraints = false
        statusCard.backgroundColor = darkTeal
        statusCard.layer.cornerRadius = 14
        contentView.addSubview(statusCard)

        // check circle
        statusCircle.translatesAutoresizingMaskIntoConstraints = false
        statusCircle.layer.cornerRadius = 22
        statusCircle.layer.masksToBounds = true
        // for demo: show filled teal circle for confirmed
        statusCircle.backgroundColor = darkTeal

        statusCheck.image = UIImage(systemName: "checkmark")
        statusCheck.tintColor = .white
        statusCheck.translatesAutoresizingMaskIntoConstraints = false
        statusCircle.addSubview(statusCheck)

        statusTitleLabel.text = "Order Confirmed"
        statusTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        statusTitleLabel.textColor = .white
        statusTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        statusTimeLabel.text = "Today, 2:30 PM"
        statusTimeLabel.font = UIFont.systemFont(ofSize: 12)
        statusTimeLabel.textColor = UIColor(white: 1.0, alpha: 0.95)
        statusTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        orderIdLabel.text = "#ORD-2024-1156"
        orderIdLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        orderIdLabel.textColor = .white
        orderIdLabel.translatesAutoresizingMaskIntoConstraints = false

        totalAmountLabel.text = "₹500"
        totalAmountLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        totalAmountLabel.textColor = .white
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false

        statusCard.addSubview(statusCircle)
        statusCard.addSubview(statusTitleLabel)
        statusCard.addSubview(statusTimeLabel)
        statusCard.addSubview(orderIdLabel)
        statusCard.addSubview(totalAmountLabel)

        NSLayoutConstraint.activate([
            statusCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statusCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusCard.heightAnchor.constraint(equalToConstant: 110),

            statusCircle.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 12),
            statusCircle.centerYAnchor.constraint(equalTo: statusCard.centerYAnchor),
            statusCircle.widthAnchor.constraint(equalToConstant: 44),
            statusCircle.heightAnchor.constraint(equalToConstant: 44),

            statusCheck.centerXAnchor.constraint(equalTo: statusCircle.centerXAnchor),
            statusCheck.centerYAnchor.constraint(equalTo: statusCircle.centerYAnchor),

            statusTitleLabel.leadingAnchor.constraint(equalTo: statusCircle.trailingAnchor, constant: 12),
            statusTitleLabel.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 20),

            statusTimeLabel.leadingAnchor.constraint(equalTo: statusTitleLabel.leadingAnchor),
            statusTimeLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 2),

            totalAmountLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -12),
            totalAmountLabel.centerYAnchor.constraint(equalTo: statusCard.centerYAnchor),

            orderIdLabel.leadingAnchor.constraint(equalTo: statusCircle.trailingAnchor, constant: 12),
            orderIdLabel.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -14)
        ])
    }

    // MARK: - Timeline label + rows
    private func setupTimeline() {
        // label
        timelineLabel.text = "Order Timeline"
        timelineLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        timelineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timelineLabel)

        timelineStack.axis = .vertical
        timelineStack.spacing = 12
        timelineStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timelineStack)

        NSLayoutConstraint.activate([
            timelineLabel.topAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: 14),
            timelineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            timelineStack.topAnchor.constraint(equalTo: timelineLabel.bottomAnchor, constant: 12),
            timelineStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timelineStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // rows: pending (grey circle with white tick), completed (dark teal with white tick)
        timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Delivery", subtitle: "Pending", completed: false))
        timelineStack.addArrangedSubview(makeTimelineRow(title: "Order Confirmed", subtitle: "Today, 12:15 PM", completed: true))
    }

    private func makeTimelineRow(title: String, subtitle: String, completed: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // dot
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.cornerRadius = 14
        dot.layer.masksToBounds = true

        if completed {
            dot.backgroundColor = darkTeal
        } else {
            dot.backgroundColor = UIColor(white: 0.78, alpha: 1.0) // grey
        }

        // white checkmark inside
        let check = UIImageView(image: UIImage(systemName: "checkmark"))
        check.tintColor = .white
        check.translatesAutoresizingMaskIntoConstraints = false
        dot.addSubview(check)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(dot)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 28),
            dot.heightAnchor.constraint(equalToConstant: 28),

            check.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: dot.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])

        return container
    }

    // MARK: - Item Card (labels left, values right)
    // MARK: - Item Card (Perfect row alignment)
    private func setupItemCard() {
        orderItemsTitle.text = "Order Items"
        orderItemsTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        orderItemsTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orderItemsTitle)

        NSLayoutConstraint.activate([
            orderItemsTitle.topAnchor.constraint(equalTo: timelineStack.bottomAnchor, constant: 18),
            orderItemsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])

        // Card
        itemCard.translatesAutoresizingMaskIntoConstraints = false
        itemCard.backgroundColor = .white
        itemCard.layer.cornerRadius = 12
        itemCard.layer.shadowColor = UIColor.black.cgColor
        itemCard.layer.shadowOpacity = 0.05
        itemCard.layer.shadowRadius = 6
        itemCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(itemCard)

        // Image
        itemImageView.image = UIImage(named: "cap")
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.translatesAutoresizingMaskIntoConstraints = false

        // Category
        itemCategoryLabel.text = "Fashion"
        itemCategoryLabel.font = UIFont.systemFont(ofSize: 12)
        itemCategoryLabel.textColor = .gray
        itemCategoryLabel.translatesAutoresizingMaskIntoConstraints = false

        // Title
        itemTitleLabel.text = "Under Armour Cap"
        itemTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Left labels
        let labelColour = smallTeal(text: "Colour")
        let labelSize = smallTeal(text: "Size")
        let labelQty = smallTeal(text: "Quantity")

        // Right values
        let valuePrice = UILabel()
        valuePrice.text = "₹500"
        valuePrice.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        valuePrice.textColor = .black     // <-- MAKE PRICE BLACK

        let valueColour = smallValue(text: "White")
        let valueSize = smallValue(text: "Large")
        let valueQty = smallValue(text: "1")

        // Create four horizontal rows
        func makeRow(left: UIView, right: UIView) -> UIStackView {
            let row = UIStackView(arrangedSubviews: [left, right])
            row.axis = .horizontal
            row.alignment = .center
            row.distribution = .equalSpacing
            return row
        }

        let row1 = makeRow(left: itemTitleLabel, right: valuePrice)
        let row2 = makeRow(left: labelColour, right: valueColour)
        let row3 = makeRow(left: labelSize, right: valueSize)
        let row4 = makeRow(left: labelQty, right: valueQty)

        let rowsStack = UIStackView(arrangedSubviews: [
            itemCategoryLabel,
            row1,
            row2,
            row3,
            row4
        ])
        rowsStack.axis = .vertical
        rowsStack.spacing = 6
        rowsStack.translatesAutoresizingMaskIntoConstraints = false

        itemCard.addSubview(itemImageView)
        itemCard.addSubview(rowsStack)

        NSLayoutConstraint.activate([
            itemCard.topAnchor.constraint(equalTo: orderItemsTitle.bottomAnchor, constant: 12),
            itemCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            itemImageView.leadingAnchor.constraint(equalTo: itemCard.leadingAnchor, constant: 12),
            itemImageView.centerYAnchor.constraint(equalTo: itemCard.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 70),
            itemImageView.heightAnchor.constraint(equalToConstant: 70),

            rowsStack.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 12),
            rowsStack.trailingAnchor.constraint(equalTo: itemCard.trailingAnchor, constant: -12),
            rowsStack.topAnchor.constraint(equalTo: itemCard.topAnchor, constant: 12),
            rowsStack.bottomAnchor.constraint(equalTo: itemCard.bottomAnchor, constant: -12)
        ])
    }

    private func smallTeal(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textColor = accentTeal
        return l
    }

    private func smallValue(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .darkGray
        return l
    }

    // MARK: - Delivery Info
    private func setupDeliveryInfo() {
        deliveryTitle.text = "Delivery Information"
        deliveryTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        deliveryTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deliveryTitle)

        deliveryNameLabel.text = "Jonathan  (+91) 90078 91599"
        deliveryNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        deliveryNameLabel.textColor = .darkGray
        deliveryNameLabel.translatesAutoresizingMaskIntoConstraints = false

        deliveryAddressLabel.text = "4517 Washington Ave,\nManchester, Kentucky 39495"
        deliveryAddressLabel.font = UIFont.systemFont(ofSize: 13)
        deliveryAddressLabel.textColor = lightGrayText
        deliveryAddressLabel.numberOfLines = 0
        deliveryAddressLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(deliveryNameLabel)
        contentView.addSubview(deliveryAddressLabel)

        NSLayoutConstraint.activate([
            deliveryTitle.topAnchor.constraint(equalTo: itemCard.bottomAnchor, constant: 16),
            deliveryTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            deliveryNameLabel.topAnchor.constraint(equalTo: deliveryTitle.bottomAnchor, constant: 12),
            deliveryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            deliveryAddressLabel.topAnchor.constraint(equalTo: deliveryNameLabel.bottomAnchor, constant: 8),
            deliveryAddressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deliveryAddressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Order Summary
    private func setupOrderSummary() {
        orderSummaryTitle.text = "Order Summary"
        orderSummaryTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        orderSummaryTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orderSummaryTitle)

        NSLayoutConstraint.activate([
            orderSummaryTitle.topAnchor.constraint(equalTo: deliveryAddressLabel.bottomAnchor, constant: 18),
            orderSummaryTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])

        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.backgroundColor = .white
        summaryCard.layer.cornerRadius = 12
        summaryCard.layer.shadowColor = UIColor.black.cgColor
        summaryCard.layer.shadowOpacity = 0.03
        summaryCard.layer.shadowRadius = 6
        summaryCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(summaryCard)

        let subLabel = UILabel(); subLabel.text = "Subtotal"; subLabel.font = UIFont.systemFont(ofSize: 14)
        let subValue = UILabel(); subValue.text = "₹500"; subValue.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        let negotiLabel = UILabel(); negotiLabel.text = "Negotiation Discount"; negotiLabel.font = UIFont.systemFont(ofSize: 14)
        let negotiValue = UILabel(); negotiValue.text = "₹0"; negotiValue.font = UIFont.systemFont(ofSize: 14, weight: .semibold); negotiValue.textColor = UIColor(red: 0.86, green: 0.33, blue: 0.33, alpha: 1.0)

        let divider = UIView(); divider.backgroundColor = UIColor(white: 0.92, alpha: 1.0); divider.translatesAutoresizingMaskIntoConstraints = false

        let totalLabel = UILabel(); totalLabel.text = "Total"; totalLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let totalValue = UILabel(); totalValue.text = "₹500"; totalValue.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        [subLabel, subValue, negotiLabel, negotiValue, divider, totalLabel, totalValue].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; summaryCard.addSubview($0) }

        NSLayoutConstraint.activate([
            summaryCard.topAnchor.constraint(equalTo: orderSummaryTitle.bottomAnchor, constant: 12),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            summaryCard.heightAnchor.constraint(equalToConstant: 160),

            subLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 18),
            subLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            subValue.centerYAnchor.constraint(equalTo: subLabel.centerYAnchor),
            subValue.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),

            negotiLabel.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 14),
            negotiLabel.leadingAnchor.constraint(equalTo: subLabel.leadingAnchor),

            negotiValue.centerYAnchor.constraint(equalTo: negotiLabel.centerYAnchor),
            negotiValue.trailingAnchor.constraint(equalTo: subValue.trailingAnchor),

            divider.topAnchor.constraint(equalTo: negotiLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -12),
            divider.heightAnchor.constraint(equalToConstant: 1),

            totalLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            totalLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            totalValue.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            totalValue.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Bottom Buttons
    private func setupBottomButtons() {
        bottomButtonsContainer.axis = .horizontal
        bottomButtonsContainer.spacing = 12
        bottomButtonsContainer.distribution = .fillEqually
        bottomButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomButtonsContainer)

        rateButton.setTitle("Rate Order", for: .normal)
        rateButton.setTitleColor(darkTeal, for: .normal)
        rateButton.layer.cornerRadius = 12
        rateButton.layer.borderWidth = 2
        rateButton.layer.borderColor = darkTeal.cgColor
        rateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        rateButton.addTarget(self, action: #selector(rateTapped), for: .touchUpInside)

        helpButton.setTitle("Get Help", for: .normal)
        helpButton.setTitleColor(darkTeal, for: .normal)
        helpButton.layer.cornerRadius = 12
        helpButton.layer.borderWidth = 2
        helpButton.layer.borderColor = darkTeal.cgColor
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)

        bottomButtonsContainer.addArrangedSubview(rateButton)
        bottomButtonsContainer.addArrangedSubview(helpButton)

        NSLayoutConstraint.activate([
            bottomButtonsContainer.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 18),
            bottomButtonsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomButtonsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomButtonsContainer.heightAnchor.constraint(equalToConstant: 54),

            contentView.bottomAnchor.constraint(equalTo: bottomButtonsContainer.bottomAnchor, constant: 24)
        ])
    }

    @objc private func rateTapped() {
        print("Rate tapped")
    }

    @objc private func helpTapped() {
        print("Help tapped")
    }
    @objc private func backPressed() {

        // If screen is inside a navigation controller → go to LandingScreen
        if let nav = navigationController {
            let vc = LandingScreenViewController()
            nav.setViewControllers([vc], animated: true)
            return
        }

        // Otherwise → presented modally, so present LandingScreen
        let vc = LandingScreenViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
}
