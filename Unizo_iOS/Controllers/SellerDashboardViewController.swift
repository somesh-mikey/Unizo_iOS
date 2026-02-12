//
//  SellerDashboardViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 25/11/25.
//

import UIKit

// Local Order struct for UI display (maps from SellerOrder)
struct DashboardOrder {
    let category: String
    let title: String
    let statusText: String
    let priceText: String
    let imageUrl: String?
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

    init(order: DashboardOrder) {
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

        // Load image from URL or use placeholder
        if let imageUrl = order.imageUrl, !imageUrl.isEmpty {
            if imageUrl.hasPrefix("http") {
                productImageView.loadImage(from: imageUrl)
            } else {
                productImageView.image = UIImage(named: imageUrl)
            }
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

    // MARK: - Repository
    private let repository = SellerDashboardRepository()

    // MARK: - Data
    private var sellerOrders: [SellerOrder] = []
    private var statistics: SellerStatistics?
    private var userProfile: UserDTO?

    // MARK: - Loading
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Navbar
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowRadius = 8
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
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

    // MARK: - Breakdown
    private let breakdownTitle = UILabel()
    private let pieChartView = SimplePieChartView()
    private let itemsSoldLabel = UILabel()
    private let legendStack = UIStackView()

    // MARK: - Orders List
    private let ordersStack = UIStackView()

    // MARK: - Empty State
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No orders yet"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupConstraints()
        setupLoadingIndicator()
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Load real data from backend
        loadDashboardData()
    }

    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadDashboardData() {
        loadingIndicator.startAnimating()
        scrollView.alpha = 0.3

        Task {
            do {
                // Fetch all data in parallel
                async let profileTask = repository.fetchSellerProfile()
                async let ordersTask = repository.fetchSellerOrders()
                async let statsTask = repository.fetchSellerStatistics()

                let (profile, orders, stats) = try await (profileTask, ordersTask, statsTask)

                self.userProfile = profile
                self.sellerOrders = orders
                self.statistics = stats

                await MainActor.run {
                    self.configureData()
                    self.loadingIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.3) {
                        self.scrollView.alpha = 1.0
                    }
                }
            } catch {
                print("❌ Failed to load dashboard data: \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.scrollView.alpha = 1.0
                    self.showErrorState(message: "Failed to load dashboard data")
                }
            }
        }
    }

    private func showErrorState(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadDashboardData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true

        // Correct way to hide the floating tab bar
        (tabBarController as? MainTabBarController)?.hideFloatingTabBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false

        // Correct way to restore it
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
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
        legendStack.spacing = 16
        contentView.addSubview(legendStack)
        // Legend items will be added dynamically in configureData()

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
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

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

        // Breakdown
        NSLayoutConstraint.activate([
            breakdownTitle.topAnchor.constraint(equalTo: profileContainer.bottomAnchor, constant: 22),
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
        // Profile
        if let user = userProfile {
            nameLabel.text = user.displayName
            emailLabel.text = user.email ?? ""
        } else {
            nameLabel.text = "Seller"
            emailLabel.text = ""
        }

        // Sales statistics
        if let stats = statistics {
            let totalSales = stats.totalSales
            let salesGoal = stats.salesGoal
            salesAmountLabel.text = "₹\(String(format: "%.2f", totalSales)) / ₹\(String(format: "%.0f", salesGoal))"
            salesProgressView.progress = Float(min(totalSales / salesGoal, 1.0))

            // Items sold in pie chart center
            itemsSoldLabel.text = "\(stats.itemsSold)"

            // Pie chart data from category breakdown
            let segments = stats.categoryBreakdown.map { category -> (UIColor, CGFloat) in
                let color = colorForCategory(category.color)
                return (color, CGFloat(category.count))
            }

            if segments.isEmpty {
                // Show placeholder if no data
                pieChartView.configure(segments: [(.systemGray4, 1)])
            } else {
                pieChartView.configure(segments: segments)
            }

            // Update legend
            updateLegend(with: stats.categoryBreakdown)
        } else {
            salesAmountLabel.text = "₹0.00 / ₹5000.00"
            salesProgressView.progress = 0
            itemsSoldLabel.text = "0"
            pieChartView.configure(segments: [(.systemGray4, 1)])
        }

        // Clear existing order cards
        ordersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add order cards from real data
        if sellerOrders.isEmpty {
            emptyStateLabel.isHidden = false
            ordersStack.addArrangedSubview(emptyStateLabel)
        } else {
            emptyStateLabel.isHidden = true
            for order in sellerOrders {
                let dashboardOrder = DashboardOrder(
                    category: order.category,
                    title: order.title,
                    statusText: order.statusText,
                    priceText: order.priceText,
                    imageUrl: order.imageUrl
                )
                let card = SellerOrderCardView(order: dashboardOrder)
                ordersStack.addArrangedSubview(card)
            }
        }
    }

    private func colorForCategory(_ colorName: String) -> UIColor {
        switch colorName {
        case "systemGreen": return .systemGreen
        case "systemBlue": return .systemBlue
        case "systemYellow": return .systemYellow
        case "systemRed": return .systemRed
        case "systemPurple": return .systemPurple
        case "systemOrange": return .systemOrange
        default: return .systemGray
        }
    }

    private func updateLegend(with categories: [CategorySales]) {
        // Clear existing legend items
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Create rows for legend (2 items per row)
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

        // Add category items to rows
        for (index, category) in categories.prefix(4).enumerated() {
            let color = colorForCategory(category.color)
            let legendItem = LegendItemView(color: color, text: "\(category.category) \(category.count)")

            if index < 2 {
                row1.addArrangedSubview(legendItem)
            } else {
                row2.addArrangedSubview(legendItem)
            }
        }

        // If no categories, show placeholder
        if categories.isEmpty {
            let placeholder = LegendItemView(color: .systemGray4, text: "No sales yet")
            row1.addArrangedSubview(placeholder)
        }
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }
}
