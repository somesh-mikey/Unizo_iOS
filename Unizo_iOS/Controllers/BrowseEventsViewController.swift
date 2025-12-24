//
//  BrowseEventsViewController.swift
//  Unizo_iOS
//
//  Created by Somesh on 25/11/25.
//

import UIKit

class BrowseEventsViewController: UIViewController {

    // MARK: - Event Model

    struct EventModel {
        let imageName: String
        let title: String
        let venue: String
        let time: String
        let date: String
        let price: String
        let buttonTitle: String
    }

    // MARK: - Events List

    private let events: [EventModel] = [
        EventModel(
            imageName: "banner1",
            title: "Unity 2024",
            venue: "Main Auditorium",
            time: "7:00 PM",
            date: "Dec 15",
            price: "₹500",
            buttonTitle: "Book Now"
        ),
        EventModel(
            imageName: "banner2",
            title: "Sports Showdown",
            venue: "Dental College Ground",
            time: "7:00 PM",
            date: "Dec 23",
            price: "Free",
            buttonTitle: "Book Now"
        ),
        EventModel(
            imageName: "sportshowdown",
            title: "Basketball Championship",
            venue: "Sports Complex",
            time: "6:00 PM",
            date: "Dec 18",
            price: "₹200",
            buttonTitle: "Book Now"
        ),
        EventModel(
            imageName: "techinnovation",
            title: "Tech Innovation Summit",
            venue: "Conference Hall 2",
            time: "9:00 AM",
            date: "Dec 20",
            price: "Free",
            buttonTitle: "Register"
        ),
        EventModel(
            imageName: "banner3",
            title: "Innovate & Code",
            venue: "Mini Hall 1",
            time: "8:00 AM",
            date: "Dec 18",
            price: "₹100",
            buttonTitle: "Book Now"
        )
    ]


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
        lbl.text = "Featured Events"
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
        loadEventCards()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }


    // MARK: - Navigation Bar

    private func setupNavBar() {
        title = "Browse Events"
        navigationController?.navigationBar.prefersLargeTitles = false
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


    // MARK: - Load Event Card Views

    private func loadEventCards() {
        for event in events {

            let card = EventCardView(
                image: UIImage(named: event.imageName),
                title: event.title,
                venue: event.venue,
                time: event.time,
                date: event.date,
                price: event.price,
                buttonTitle: event.buttonTitle
            )

            contentStack.addArrangedSubview(card)
        }
    }
}
