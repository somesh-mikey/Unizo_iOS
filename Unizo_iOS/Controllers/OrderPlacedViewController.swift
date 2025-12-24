import UIKit

class OrderPlacedViewController: UIViewController {

    // MARK: - Outlets from XIB
    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var suggestedTitleContainer: UIView!
    @IBOutlet weak var productsContainer: UIView!

    // MARK: Colors
    private let bgColor      = UIColor(red: 0.96, green: 0.97, blue: 1.00, alpha: 1)
    private let primaryTeal  = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)

    // ScrollView
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = bgColor

        removeUglyWhiteBackgrounds()
        setupScrollView()
        layoutContainers()

        setupTopBar()
        setupIconSection()
        setupTitleSection()
        setupButtons()
        setupSuggestedTitle()
        setupProductsSection()
    }

    // ===========================================================
    // REMOVE WHITE CONTAINER BACKGROUNDS (IMPORTANT)
    // ===========================================================
    private func removeUglyWhiteBackgrounds() {
        [
            topBarContainer,
            iconContainer,
            titleContainer,
            buttonContainer,
            suggestedTitleContainer,
            productsContainer
        ].forEach { $0?.backgroundColor = .clear }
    }

    // ===========================================================
    // SCROLL VIEW SETUP
    // ===========================================================
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

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
    }

    // ===========================================================
    // LAYOUT OUTLET CONTAINERS
    // ===========================================================
    private func layoutContainers() {
        let sections = [
            topBarContainer,
            iconContainer,
            titleContainer,
            buttonContainer,
            suggestedTitleContainer,
            productsContainer
        ]

        sections.forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0!)
        }

        NSLayoutConstraint.activate([

            topBarContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            topBarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topBarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 60),

            iconContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: 20),
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            iconContainer.heightAnchor.constraint(equalToConstant: 170),

            titleContainer.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 10),
            titleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 85),

            buttonContainer.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 15),
            buttonContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: 130),

            suggestedTitleContainer.topAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: 15),
            suggestedTitleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            suggestedTitleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            suggestedTitleContainer.heightAnchor.constraint(equalToConstant: 40),

            productsContainer.topAnchor.constraint(equalTo: suggestedTitleContainer.bottomAnchor, constant: 12),
            productsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    // ===========================================================
    // TOP BAR
    // ===========================================================
    private func setupTopBar() {
        let circle = UIView()
        circle.backgroundColor = .white
        circle.layer.cornerRadius = 20
        circle.translatesAutoresizingMaskIntoConstraints = false

        let backBtn = UIButton(type: .system)
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.translatesAutoresizingMaskIntoConstraints = false

        circle.addSubview(backBtn)
        topBarContainer.addSubview(circle)

        NSLayoutConstraint.activate([
            circle.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 20),
            circle.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 40),
            circle.heightAnchor.constraint(equalToConstant: 40),

            backBtn.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            backBtn.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
    }

    // ===========================================================
    // ICON SECTION
    // ===========================================================
    private func setupIconSection() {
        let circle = UIView()
        circle.backgroundColor = UIColor(red: 0.87, green: 0.94, blue: 0.98, alpha: 1)
        circle.layer.cornerRadius = 70
        circle.translatesAutoresizingMaskIntoConstraints = false

        let bag = UIImageView(image: UIImage(systemName: "bag"))
        bag.tintColor = primaryTeal
        bag.translatesAutoresizingMaskIntoConstraints = false

        circle.addSubview(bag)
        iconContainer.addSubview(circle)

        NSLayoutConstraint.activate([
            circle.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 140),
            circle.heightAnchor.constraint(equalToConstant: 140),

            bag.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            bag.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            bag.widthAnchor.constraint(equalToConstant: 52),
            bag.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // ===========================================================
    // TITLE + SUBTITLE
    // ===========================================================
    private func setupTitleSection() {
        let title = UILabel()
        title.text = "Order Placed!"
        title.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = UILabel()
        subtitle.text = "Your order has been successfully processed and its on its way to you soon"
        subtitle.font = UIFont.systemFont(ofSize: 14)
        subtitle.textColor = .gray
        subtitle.numberOfLines = 2
        subtitle.textAlignment = .center
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        titleContainer.addSubview(title)
        titleContainer.addSubview(subtitle)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            title.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            subtitle.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 40),
            subtitle.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -40)
        ])
    }

    // ===========================================================
    // BUTTONS
    // ===========================================================
    private func setupButtons() {
        let primary = UIButton(type: .system)
        primary.backgroundColor = primaryTeal
        primary.layer.cornerRadius = 25
        primary.setTitle("My Order Detail", for: .normal)
        primary.setTitleColor(.white, for: .normal)
        primary.translatesAutoresizingMaskIntoConstraints = false

        let secondary = UIButton(type: .system)
        secondary.setTitle("Continue Shopping", for: .normal)
        secondary.setTitleColor(primaryTeal, for: .normal)
        secondary.layer.borderWidth = 2
        secondary.layer.cornerRadius = 25
        secondary.layer.borderColor = primaryTeal.cgColor
        secondary.translatesAutoresizingMaskIntoConstraints = false

        buttonContainer.addSubview(primary)
        buttonContainer.addSubview(secondary)

        NSLayoutConstraint.activate([
            primary.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 30),
            primary.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -30),
            primary.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            primary.heightAnchor.constraint(equalToConstant: 52),

            secondary.leadingAnchor.constraint(equalTo: primary.leadingAnchor),
            secondary.trailingAnchor.constraint(equalTo: primary.trailingAnchor),
            secondary.topAnchor.constraint(equalTo: primary.bottomAnchor, constant: 14),
            secondary.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // ===========================================================
    // SECTION TITLE
    // ===========================================================
    private func setupSuggestedTitle() {
        let label = UILabel()
        label.text = "Products You Might Like"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        suggestedTitleContainer.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: suggestedTitleContainer.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: suggestedTitleContainer.centerYAnchor)
        ])
    }

    // ===========================================================
    // PRODUCTS GRID — NOW ALL 4 CARDS HAVE LABELS
    // ===========================================================
    private func setupProductsSection() {

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 22
        container.translatesAutoresizingMaskIntoConstraints = false

        productsContainer.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: productsContainer.topAnchor),
            container.leadingAnchor.constraint(equalTo: productsContainer.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: productsContainer.trailingAnchor, constant: -20),
            container.bottomAnchor.constraint(equalTo: productsContainer.bottomAnchor)
        ])

        // ROW 1
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = 16

        row1.addArrangedSubview(makeFullProductCard("Kettle", "Prestige Electric Kettle", "4.9", "Non - Negotiable", "₹649"))
        row1.addArrangedSubview(makeFullProductCard("Lamp", "Table Lamp", "4.2", "Negotiable", "₹500"))

        container.addArrangedSubview(row1)

        // ROW 2 (NOW FULL DETAILS ADDED)
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 16

        row2.addArrangedSubview(makeFullProductCard("NoiseHeadphone", "pTron Headphones", "4.2", "Negotiable", "₹1,000"))
        row2.addArrangedSubview(makeFullProductCard("Rackets", "Tennis Rackets", "3.9", "Negotiable", "₹2,300"))

        container.addArrangedSubview(row2)
    }

    // ===========================================================
    // PRODUCT CARD WITH LABELS (USED FOR ALL 4 NOW)
    // ===========================================================
    private func makeFullProductCard(
        _ imageName: String,
        _ title: String,
        _ rating: String,
        _ negotiable: String,
        _ price: String
    ) -> UIView {

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowOpacity = 0.12
        card.layer.shadowRadius = 4
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false

        let img = UIImageView()
        img.image = UIImage(named: imageName)
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.cornerRadius = 12
        img.translatesAutoresizingMaskIntoConstraints = false

        let name = UILabel()
        name.text = title
        name.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        name.numberOfLines = 2
        name.translatesAutoresizingMaskIntoConstraints = false

        let details = UILabel()
        details.text = "★ \(rating)  |  \(negotiable)"
        details.font = UIFont.systemFont(ofSize: 11)
        details.textColor = UIColor(red: 0, green: 0.55, blue: 0.75, alpha: 1)
        details.translatesAutoresizingMaskIntoConstraints = false

        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(img)
        card.addSubview(name)
        card.addSubview(details)
        card.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            img.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            img.widthAnchor.constraint(equalToConstant: 92),
            img.heightAnchor.constraint(equalToConstant: 119),

            name.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 8),
            name.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            name.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),

            details.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4),
            details.leadingAnchor.constraint(equalTo: name.leadingAnchor),

            priceLabel.topAnchor.constraint(equalTo: details.bottomAnchor, constant: 6),
            priceLabel.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        return card
    }
}
