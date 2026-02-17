//
//  EventDetailsViewController.swift
//  Unizo_iOS
//
//  Created by Claude on 17/02/26.
//

import UIKit

class EventDetailsViewController: UIViewController {

    // MARK: - Event Data
    var event: EventDTO!

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let eventImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl.textColor = .label
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let dateIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "calendar"))
        iv.tintColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let timeIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock"))
        iv.tintColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let venueIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        iv.tintColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let venueLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let descriptionHeaderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "About this Event"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let bookButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Book Now", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = UIColor(red: 4/255, green: 68/255, blue: 95/255, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
        populateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        (tabBarController as? MainTabBarController)?.hideFloatingTabBar()
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Navigation Bar

    private func setupNavBar() {
        title = "Event Details"
        navigationController?.navigationBar.prefersLargeTitles = false

        // Add back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add subviews to content view
        [eventImageView, titleLabel, dateIconView, dateLabel, timeIconView, timeLabel,
         venueIconView, venueLabel, descriptionHeaderLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }

        // Bottom bar with price and button
        view.addSubview(priceLabel)
        view.addSubview(bookButton)

        bookButton.addTarget(self, action: #selector(bookButtonTapped), for: .touchUpInside)
    }

    // MARK: - Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bookButton.topAnchor, constant: -16),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Event Image
            eventImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            eventImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            eventImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            eventImageView.heightAnchor.constraint(equalToConstant: 200),

            // Title
            titleLabel.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Date Row
            dateIconView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            dateIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateIconView.widthAnchor.constraint(equalToConstant: 24),
            dateIconView.heightAnchor.constraint(equalToConstant: 24),

            dateLabel.centerYAnchor.constraint(equalTo: dateIconView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateIconView.trailingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Time Row
            timeIconView.topAnchor.constraint(equalTo: dateIconView.bottomAnchor, constant: 16),
            timeIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeIconView.widthAnchor.constraint(equalToConstant: 24),
            timeIconView.heightAnchor.constraint(equalToConstant: 24),

            timeLabel.centerYAnchor.constraint(equalTo: timeIconView.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: timeIconView.trailingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Venue Row
            venueIconView.topAnchor.constraint(equalTo: timeIconView.bottomAnchor, constant: 16),
            venueIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            venueIconView.widthAnchor.constraint(equalToConstant: 24),
            venueIconView.heightAnchor.constraint(equalToConstant: 24),

            venueLabel.centerYAnchor.constraint(equalTo: venueIconView.centerYAnchor),
            venueLabel.leadingAnchor.constraint(equalTo: venueIconView.trailingAnchor, constant: 12),
            venueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Description Header
            descriptionHeaderLabel.topAnchor.constraint(equalTo: venueLabel.bottomAnchor, constant: 28),
            descriptionHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Description
            descriptionLabel.topAnchor.constraint(equalTo: descriptionHeaderLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Price Label
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            priceLabel.centerYAnchor.constraint(equalTo: bookButton.centerYAnchor),

            // Book Button
            bookButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bookButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bookButton.widthAnchor.constraint(equalToConstant: 160),
            bookButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Populate Data

    private func populateData() {
        guard let event = event else { return }

        titleLabel.text = event.title
        dateLabel.text = event.formattedDate
        timeLabel.text = event.event_time
        venueLabel.text = event.venue
        descriptionLabel.text = event.description ?? "No description available."
        priceLabel.text = event.priceDisplay

        // Update button title based on free/paid
        bookButton.setTitle(event.is_free ? "Register" : "Book Now", for: .normal)

        // Load image
        if let imageURL = event.image_url, !imageURL.isEmpty {
            eventImageView.loadImage(from: imageURL)
        } else {
            eventImageView.image = UIImage(systemName: "calendar")
            eventImageView.tintColor = .systemGray3
            eventImageView.contentMode = .scaleAspectFit
        }
    }

    // MARK: - Actions

    @objc private func bookButtonTapped() {
        // TODO: Implement booking/registration flow
        let alert = UIAlertController(
            title: event.is_free ? "Registration" : "Booking",
            message: event.is_free ? "You have successfully registered for this event!" : "Proceed to payment for this event.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
