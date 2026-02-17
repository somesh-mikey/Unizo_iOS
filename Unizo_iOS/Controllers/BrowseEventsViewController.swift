//
//  BrowseEventsViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 25/11/25.
//

import UIKit

class BrowseEventsViewController: UIViewController {

    // MARK: - Dependencies
    private let eventRepository = EventRepository()

    // MARK: - Data
    private var events: [EventDTO] = []


    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let sectionTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Featured Events".localized
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()


    // MARK: - Lifecycle

    override func loadView() {
        let nib = UINib(nibName: "BrowseEventsViewController", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        self.view = objects.first as? UIView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupLayout()
        fetchEvents()
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
        title = "Browse Events".localized
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


    // MARK: - Layout Setup

    private func setupLayout() {

        // Add ScrollView → inside XIB root view
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add Stack inside ScrollView
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // Ensures vertical scrolling works properly
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // Section title
        contentStack.addArrangedSubview(sectionTitleLabel)
    }


    // MARK: - Fetch Events from Backend

    private func fetchEvents() {
        Task {
            do {
                let fetchedEvents = try await eventRepository.fetchFeaturedEvents()
                await MainActor.run {
                    self.events = fetchedEvents
                    self.loadEventCards()
                }
            } catch {
                print("❌ Failed to fetch events:", error)
                // Show empty state or error message
                await MainActor.run {
                    self.showEmptyState()
                }
            }
        }
    }

    // MARK: - Load Event Card Views

    private func loadEventCards() {
        // Clear existing cards (except section title)
        contentStack.arrangedSubviews.dropFirst().forEach { $0.removeFromSuperview() }

        for event in events {
            let card = EventCardView(
                imageURL: event.image_url,
                title: event.title,
                venue: event.venue,
                time: event.event_time,
                date: event.formattedDate,
                price: event.priceDisplay,
                buttonTitle: event.is_free ? "Register".localized : "Book Now".localized
            )

            // Set tap handler to navigate to event details
            card.onBookTapped = { [weak self] in
                self?.navigateToEventDetails(event: event)
            }

            contentStack.addArrangedSubview(card)
        }
    }

    // MARK: - Navigation

    private func navigateToEventDetails(event: EventDTO) {
        let vc = EventDetailsViewController()
        vc.event = event
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Empty State

    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No events available at the moment".localized
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        contentStack.addArrangedSubview(emptyLabel)
    }
}
