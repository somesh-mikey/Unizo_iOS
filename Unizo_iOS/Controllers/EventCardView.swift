//
//  EventCardView.swift
//  Unizo_iOS
//
//  Created by Somesh on 25/11/25.
//

import UIKit

final class EventCardView: UIView {

    // MARK: - UI Components

    private let eventImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let venueLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = UIColor.systemTeal
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let bookButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Book Now".localized, for: .normal)

        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        // 🔵 UPDATED BUTTON COLOR (04445F)
        btn.backgroundColor = UIColor(
            red: 4/255,
            green: 68/255,
            blue: 95/255,
            alpha: 1
        )

        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Tap Handler
    var onBookTapped: (() -> Void)?


    // MARK: - Initializer

    init(
        image: UIImage?,
        title: String,
        venue: String,
        time: String,
        date: String,
        price: String,
        buttonTitle: String
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        eventImageView.image = image
        titleLabel.text = title
        venueLabel.text = "\(venue) • \(time)"
        dateLabel.text = date
        priceLabel.text = price
        bookButton.setTitle(buttonTitle, for: .normal)

        setupUI()
        setupConstraints()
    }

    // Convenience initializer for URL-based images
    init(
        imageURL: String?,
        title: String,
        venue: String,
        time: String,
        date: String,
        price: String,
        buttonTitle: String
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        venueLabel.text = "\(venue) • \(time)"
        dateLabel.text = date
        priceLabel.text = price
        bookButton.setTitle(buttonTitle, for: .normal)

        setupUI()
        setupConstraints()

        // Load image from URL
        if let urlString = imageURL, !urlString.isEmpty {
            eventImageView.loadImage(from: urlString)
        } else {
            eventImageView.image = UIImage(systemName: "calendar")
            eventImageView.tintColor = .systemGray3
            eventImageView.contentMode = .scaleAspectFit
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Setup UI

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

        addSubview(eventImageView)
        addSubview(titleLabel)
        addSubview(venueLabel)
        addSubview(dateLabel)
        addSubview(priceLabel)
        addSubview(bookButton)

        // Add tap action for book button
        bookButton.addTarget(self, action: #selector(bookButtonTapped), for: .touchUpInside)
    }

    @objc private func bookButtonTapped() {
        onBookTapped?()
    }


    // MARK: - Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // Top Image
            eventImageView.topAnchor.constraint(equalTo: topAnchor),
            eventImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            eventImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            eventImageView.heightAnchor.constraint(equalToConstant: 150),

            // Title
            titleLabel.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            // Date (right side)
            dateLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            // Venue + Time
            venueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            venueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            // Price
            priceLabel.topAnchor.constraint(equalTo: venueLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            // Book Button
            bookButton.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            bookButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            bookButton.widthAnchor.constraint(equalToConstant: 110),
            bookButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
