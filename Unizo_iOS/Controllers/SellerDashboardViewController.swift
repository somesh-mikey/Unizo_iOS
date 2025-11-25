//
//  SellerDashboardViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 25/11/25.
//

import UIKit

struct Order {
    let category: String
    let title: String
    let statusText: String
    let priceText: String
    let imageName: String?
}

// MARK: - LegendItemView
private final class LegendItemView: UIView {
    private let colorView = UIView()
    private let textLabel = UILabel()

    init(color: UIColor, text: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 6
        colorView.layer.masksToBounds = true

        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 12)
        textLabel.textColor = .secondaryLabel

        addSubview(colorView)
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 12),
            colorView.heightAnchor.constraint(equalToConstant: 12),

            textLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - SellerOrderCardView
private final class SellerOrderCardView: UIView {
    private let container = UIView()
    private let productImageView = UIImageView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let upcomingIconView = UIImageView()
    private let statusLabel = UILabel()
    private let priceLabel = UILabel()

    init(order: Order) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        container.layer.shadowRadius = 6
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowOpacity = 1

        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        if let name = order.imageName, let img = UIImage(named: name) {
            productImageView.image = img
        } else {
            productImageView.image = UIImage(systemName: "photo")
            productImageView.tintColor = .tertiaryLabel
            productImageView.backgroundColor = UIColor.secondarySystemBackground
        }

        categoryLabel.text = order.category
        categoryLabel.font = .systemFont(ofSize: 12)
        categoryLabel.textColor = .secondaryLabel
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = order.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.text = order.statusText
        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor = (order.statusText.lowercased().contains("pending")) ?
            UIColor.systemOrange : UIColor.systemGreen
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        priceLabel.text = order.priceText
        priceLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        priceLabel.textAlignment = .right
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)
        container.addSubview(productImageView)
        container.addSubview(categoryLabel)
        container.addSubview(titleLabel)
        container.addSubview(statusLabel)
        container.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            productImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            productImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 68),
            productImageView.heightAnchor.constraint(equalToConstant: 68),

            categoryLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -12),

            // STATUS (TOP RIGHT)
            statusLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            // PRICE (BELOW STATUS)
            priceLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - SimplePieChartView
private final class SimplePieChartView: UIView {
    private var segments: [(color: UIColor, value: CGFloat)] = []

    func configure(segments: [(UIColor, CGFloat)]) {
        self.segments = segments
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let radius = min(bounds.width, bounds.height) / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let total = segments.reduce(0) { $0 + $1.value }
        var startAngle = -CGFloat.pi / 2

        for segment in segments {
            let endAngle = startAngle + (segment.value / max(total, 0.0001)) * 2 * .pi
            let path = UIBezierPath()
            path.addArc(
                withCenter: center,
                radius: radius - 20,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )

            let arcLayer = CAShapeLayer()
            arcLayer.path = path.cgPath
            arcLayer.strokeColor = segment.color.cgColor
            arcLayer.fillColor = UIColor.clear.cgColor
            arcLayer.lineWidth = 28
            arcLayer.lineCap = .round
            arcLayer.strokeStart = 0
            arcLayer.strokeEnd = 1
            layer.addSublayer(arcLayer)

            startAngle = endAngle
        }
    }
}

// MARK: - SellerDashboardViewController
final class SellerDashboardViewController: UIViewController {

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Navbar
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Dashboard"
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Profile
    private let profileContainer = UIView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let salesProgressView = UIProgressView(progressViewStyle: .default)
    private let salesAmountLabel = UILabel()

    // Upcoming Payment
    private let upcomingContainer = UIView()
    private let upcomingIconView = UIImageView()
    private let upcomingHeaderLabel = UILabel()   // <-- ADD THIS
    private let upcomingSubtitleLabel = UILabel()
    private let reminderButton = UIButton(type: .system)

    // MARK: - Breakdown
    private let breakdownTitle = UILabel()
    private let pieChartView = SimplePieChartView()
    private let itemsSoldLabel = UILabel()
    private let legendStack = UIStackView()

    // MARK: - Orders List
    private let ordersStack = UIStackView()

    // Temporary demo data
    private let demoOrders: [Order] = [

        // --------------------
        //  PENDING ITEMS (TOP)
        // --------------------
        Order(
            category: "Sports",
            title: "SS Size 5 Bat",
            statusText: "Pending",
            priceText: "₹1299",
            imageName: "SSbat"
        ),

        Order(
            category: "Fashion",
            title: "Under Armour Cap",
            statusText: "Pending",
            priceText: "₹500",
            imageName: "cap"
        ),

        Order(
            category: "Gadgets",
            title: "JBL T450BT",
            statusText: "Pending",
            priceText: "₹1500",
            imageName: "jblheadphones"
        ),

        Order(
            category: "Hostel Essentials",
            title: "Table Fan",
            statusText: "Pending",
            priceText: "₹849",
            imageName: "tablefan"
        ),

        Order(
            category: "Sports",
            title: "Badminton Racket",
            statusText: "Pending",
            priceText: "₹550",
            imageName: "badmintonracket"
        ),


        // --------------------
        //  SOLD FOR ITEMS
        // --------------------
        Order(
            category: "Hostel Essentials",
            title: "Prestige Electric Kettle",
            statusText: "Sold for",
            priceText: "₹649",
            imageName: "electrickettle"
        ),

        Order(
            category: "Gadgets",
            title: "Noise Two Wireless",
            statusText: "Sold for",
            priceText: "₹1800",
            imageName: "noisetwowireless"
        ),

        Order(
            category: "Furniture",
            title: "Ergonomic Mesh Office Chair",
            statusText: "Sold for",
            priceText: "₹1299",
            imageName: "ergonomicmeshchair"
        ),

        Order(
            category: "Sports",
            title: "Carrom Board",
            statusText: "Sold for",
            priceText: "₹700",
            imageName: "carromboard"
        ),

        Order(
            category: "Fashion",
            title: "Blue Cap",
            statusText: "Sold for",
            priceText: "₹200",
            imageName: "streetcap"
        )
    ]



    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupConstraints()
        configureData()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Navbar
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)

        // Profile Container
        profileContainer.translatesAutoresizingMaskIntoConstraints = false
        profileContainer.backgroundColor = UIColor(red: 0.10, green: 0.42, blue: 0.60, alpha: 1)
        contentView.addSubview(profileContainer)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textColor = .white

        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = .systemFont(ofSize: 14)
        emailLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        salesProgressView.translatesAutoresizingMaskIntoConstraints = false
        salesProgressView.progressTintColor = .systemGray6
        salesProgressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        salesProgressView.layer.cornerRadius = 6
        salesProgressView.clipsToBounds = true

        salesAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        salesAmountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        salesAmountLabel.textColor = .white

        [nameLabel, emailLabel, salesProgressView, salesAmountLabel].forEach { profileContainer.addSubview($0) }

        // Upcoming Payment
        upcomingContainer.translatesAutoresizingMaskIntoConstraints = false
        upcomingContainer.backgroundColor = UIColor(red: 4/255, green: 68/255, blue: 95/255, alpha: 1)
        contentView.addSubview(upcomingContainer)

        // Bell icon
        upcomingIconView.translatesAutoresizingMaskIntoConstraints = false
        upcomingIconView.image = UIImage(systemName: "bell.fill")
        upcomingIconView.tintColor = .white
        upcomingContainer.addSubview(upcomingIconView)

        // "Upcoming Payment" label
        upcomingHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        upcomingHeaderLabel.text = "Upcoming Payment"
        upcomingHeaderLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        upcomingHeaderLabel.textColor = .white
        upcomingContainer.addSubview(upcomingHeaderLabel)

        // Subtitle
        upcomingSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        upcomingSubtitleLabel.text = "Sep 30, 2025 • ₹200"
        upcomingSubtitleLabel.font = .systemFont(ofSize: 14)
        upcomingSubtitleLabel.textColor = .white
        upcomingContainer.addSubview(upcomingSubtitleLabel)

        // Button
        reminderButton.translatesAutoresizingMaskIntoConstraints = false
        reminderButton.setTitle("Send Reminder", for: .normal)
        reminderButton.setTitleColor(.systemBlue, for: .normal)
        reminderButton.backgroundColor = .white
        reminderButton.layer.cornerRadius = 16
        reminderButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        upcomingContainer.addSubview(reminderButton)

        reminderButton.translatesAutoresizingMaskIntoConstraints = false
        reminderButton.setTitle("Send Reminder", for: .normal)
        reminderButton.setTitleColor(.systemBlue, for: .normal)
        reminderButton.backgroundColor = .white
        reminderButton.layer.cornerRadius = 16
        reminderButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)

        upcomingContainer.addSubview(reminderButton)

        // Breakdown
        breakdownTitle.translatesAutoresizingMaskIntoConstraints = false
        breakdownTitle.text = "Breakdown"
        breakdownTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        contentView.addSubview(breakdownTitle)

        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        itemsSoldLabel.translatesAutoresizingMaskIntoConstraints = false
        itemsSoldLabel.text = "12"
        itemsSoldLabel.font = .systemFont(ofSize: 28, weight: .bold)
        itemsSoldLabel.textAlignment = .center
        contentView.addSubview(pieChartView)
        contentView.addSubview(itemsSoldLabel)

        legendStack.translatesAutoresizingMaskIntoConstraints = false
        legendStack.axis = .vertical
        legendStack.spacing = 8   // spacing between the two rows
        contentView.addSubview(legendStack)

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 24
        row1.alignment = .center
        row1.distribution = .equalCentering

        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 24
        row2.alignment = .center
        row2.distribution = .equalCentering

        legendStack.addArrangedSubview(row1)
        legendStack.addArrangedSubview(row2)

        // Add legend items to rows
        row1.addArrangedSubview(LegendItemView(color: .systemGreen, text: "Hostel Essentials 8"))
        row1.addArrangedSubview(LegendItemView(color: .systemBlue, text: "Fashion 7"))

        // Row 2
        row2.addArrangedSubview(LegendItemView(color: .systemYellow, text: "Sports 12"))
        row2.addArrangedSubview(LegendItemView(color: .systemRed, text: "Gadgets 10"))

        legendStack.spacing = 16
        contentView.addSubview(legendStack)

        // Orders
        ordersStack.translatesAutoresizingMaskIntoConstraints = false
        ordersStack.axis = .vertical
        ordersStack.spacing = 12
        contentView.addSubview(ordersStack)
    }

    private func setupConstraints() {

        // Scroll + contentView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Navbar
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])

        // Profile Container
        NSLayoutConstraint.activate([
            profileContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 18),
            profileContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            profileContainer.heightAnchor.constraint(equalToConstant: 160)
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 18),
            nameLabel.leadingAnchor.constraint(equalTo: profileContainer.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: profileContainer.trailingAnchor, constant: -16),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            salesProgressView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 18),
            salesProgressView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            salesProgressView.trailingAnchor.constraint(equalTo: profileContainer.trailingAnchor, constant: -16),
            salesProgressView.heightAnchor.constraint(equalToConstant: 10),

            salesAmountLabel.topAnchor.constraint(equalTo: salesProgressView.bottomAnchor, constant: 8),
            salesAmountLabel.trailingAnchor.constraint(equalTo: salesProgressView.trailingAnchor)
        ])

        // Upcoming container
        NSLayoutConstraint.activate([
            upcomingContainer.topAnchor.constraint(equalTo: profileContainer.bottomAnchor),
            upcomingContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            upcomingContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            upcomingContainer.heightAnchor.constraint(equalToConstant: 90),

            // Bell icon
            upcomingIconView.leadingAnchor.constraint(equalTo: upcomingContainer.leadingAnchor, constant: 16),
            upcomingIconView.centerYAnchor.constraint(equalTo: upcomingContainer.centerYAnchor),
            upcomingIconView.widthAnchor.constraint(equalToConstant: 20),
            upcomingIconView.heightAnchor.constraint(equalToConstant: 20),

            // Title
            upcomingHeaderLabel.topAnchor.constraint(equalTo: upcomingContainer.topAnchor, constant: 23),
            upcomingHeaderLabel.leadingAnchor.constraint(equalTo: upcomingIconView.trailingAnchor, constant: 8),

            // Subtitle
            upcomingSubtitleLabel.topAnchor.constraint(equalTo: upcomingHeaderLabel.bottomAnchor, constant: 4),
            upcomingSubtitleLabel.leadingAnchor.constraint(equalTo: upcomingHeaderLabel.leadingAnchor),

            // Button
            reminderButton.centerYAnchor.constraint(equalTo: upcomingContainer.centerYAnchor),
            reminderButton.trailingAnchor.constraint(equalTo: upcomingContainer.trailingAnchor, constant: -16),
            reminderButton.widthAnchor.constraint(equalToConstant: 130),
            reminderButton.heightAnchor.constraint(equalToConstant: 34)
        ])


        // Breakdown
        NSLayoutConstraint.activate([
            breakdownTitle.topAnchor.constraint(equalTo: upcomingContainer.bottomAnchor, constant: 22),
            breakdownTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            pieChartView.topAnchor.constraint(equalTo: breakdownTitle.bottomAnchor, constant: 12),
            pieChartView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pieChartView.widthAnchor.constraint(equalToConstant: 200),
            pieChartView.heightAnchor.constraint(equalToConstant: 200),

            itemsSoldLabel.centerXAnchor.constraint(equalTo: pieChartView.centerXAnchor),
            itemsSoldLabel.centerYAnchor.constraint(equalTo: pieChartView.centerYAnchor),

            legendStack.topAnchor.constraint(equalTo: pieChartView.bottomAnchor, constant: 12),
            legendStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        // Orders
        NSLayoutConstraint.activate([
            ordersStack.topAnchor.constraint(equalTo: legendStack.bottomAnchor, constant: 22),
            ordersStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ordersStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ordersStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -36)
        ])
    }

    private func configureData() {
        // profile
        nameLabel.text = "Nishtha"
        emailLabel.text = "ng7389@srmist.edu.in"
        salesAmountLabel.text = "₹124.72 / ₹500.00"
        salesProgressView.progress = Float(124.72 / 500.0)

        // pie chart data (hostel 7, fashion 2, sports 1, gadgets 2)
        pieChartView.configure(segments: [
            (.systemGreen, 8),   // Hostel Essentials
                (.systemBlue, 7),    // Fashion
                (.systemYellow, 12), // Sports
                (.systemRed, 10)
        ])

        // orders
        for order in demoOrders {
            let card = SellerOrderCardView(order: order)
            ordersStack.addArrangedSubview(card)
        }
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }
}
