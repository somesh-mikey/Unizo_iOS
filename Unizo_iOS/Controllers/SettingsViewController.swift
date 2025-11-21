//
//  SettingsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 20/11/25.
//

import UIKit

class SettingsViewController: UIViewController {

    // Scroll View
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)

        setupNavBar()
        setupScroll()
        setupSections()
    }

    // MARK: - NAV BAR
    private func setupNavBar() {
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backPressed)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: nil,
            action: nil
        )
    }

    @objc private func backPressed() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - SCROLL SETUP
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

    // MARK: - MAIN SECTION LAYOUT
    private func setupSections() {

        var lastBottom: NSLayoutYAxisAnchor = contentView.topAnchor
        let sectionSpacing: CGFloat = 28

        // PREFERENCES SECTION
        let prefLabel = makeHeader("Preferences")
        contentView.addSubview(prefLabel)
        NSLayoutConstraint.activate([
            prefLabel.topAnchor.constraint(equalTo: lastBottom, constant: 25),
            prefLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        lastBottom = prefLabel.bottomAnchor

        let preferencesCard = makePreferencesCard()
        contentView.addSubview(preferencesCard)
        NSLayoutConstraint.activate([
            preferencesCard.topAnchor.constraint(equalTo: lastBottom, constant: 10),
            preferencesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            preferencesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastBottom = preferencesCard.bottomAnchor

        // SUPPORT SECTION
        let supportLabel = makeHeader("Support")
        contentView.addSubview(supportLabel)
        NSLayoutConstraint.activate([
            supportLabel.topAnchor.constraint(equalTo: lastBottom, constant: sectionSpacing),
            supportLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        lastBottom = supportLabel.bottomAnchor

        let supportCard = makeSupportCard()
        contentView.addSubview(supportCard)
        NSLayoutConstraint.activate([
            supportCard.topAnchor.constraint(equalTo: lastBottom, constant: 10),
            supportCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            supportCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastBottom = supportCard.bottomAnchor

        // SECURITY SECTION
        let securityLabel = makeHeader("Security")
        contentView.addSubview(securityLabel)
        NSLayoutConstraint.activate([
            securityLabel.topAnchor.constraint(equalTo: lastBottom, constant: sectionSpacing),
            securityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        lastBottom = securityLabel.bottomAnchor

        let securityCard = makeSecurityCard()
        contentView.addSubview(securityCard)
        NSLayoutConstraint.activate([
            securityCard.topAnchor.constraint(equalTo: lastBottom, constant: 10),
            securityCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            securityCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        lastBottom = securityCard.bottomAnchor

        // ACCOUNT ACTIONS SECTION
        let accountLabel = makeHeader("Account Actions")
        contentView.addSubview(accountLabel)
        NSLayoutConstraint.activate([
            accountLabel.topAnchor.constraint(equalTo: lastBottom, constant: sectionSpacing),
            accountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        lastBottom = accountLabel.bottomAnchor

        let accountCard = makeAccountCard()
        contentView.addSubview(accountCard)
        NSLayoutConstraint.activate([
            accountCard.topAnchor.constraint(equalTo: lastBottom, constant: 10),
            accountCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            accountCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            accountCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - SECTION HEADER LABEL
    private func makeHeader(_ title: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = title
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    // MARK: - CARDS (white rounded blocks)

    // Preferences card (Push notifications + Email + Language + Currency)
    private func makePreferencesCard() -> UIView {
        let card = buildCard()

        let item1 = makeSwitchRow(icon: "bell", title: "Push Notifications", selector: #selector(togglePush))
        let item2 = makeSwitchRow(icon: "envelope", title: "Email Marketing", selector: #selector(toggleEmail))
        let item3 = makeArrowRow(icon: "globe", title: "Language")
        let item4 = makeArrowRow(icon: "dollarsign.circle", title: "Currency")

        stackRows(card, rows: [item1, item2, item3, item4])
        return card
    }

    private func makeSupportCard() -> UIView {
        let card = buildCard()

        let row1 = makeArrowRow(icon: "questionmark.circle", title: "Help Center")
        let row2 = makeArrowRow(icon: "phone", title: "Contact Us")
        let row3 = makeArrowRow(icon: "star", title: "Rate Our App")

        stackRows(card, rows: [row1, row2, row3])
        return card
    }

    private func makeSecurityCard() -> UIView {
        let card = buildCard()

        let row1 = makeArrowRow(icon: "key", title: "Change Password")
        let row2 = makeSwitchRow(icon: "touchid", title: "Biometric Login", selector: #selector(toggleBiometric))

        stackRows(card, rows: [row1, row2])
        return card
    }

    private func makeAccountCard() -> UIView {
        let card = buildCard()

        let row1 = makeArrowRow(icon: "arrow.right.square", title: "Sign Out")
        let row2 = makeArrowRow(icon: "trash", title: "Delete Account")

        stackRows(card, rows: [row1, row2])
        return card
    }

    // MARK: - CARD UI TEMPLATE
    private func buildCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    // MARK: - ROW STYLES
    private func makeArrowRow(icon: String, title: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImageView(image: UIImage(systemName: icon))
        image.tintColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        image.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .gray
        arrow.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(image)
        row.addSubview(label)
        row.addSubview(arrow)

        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            image.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 24),
            image.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            arrow.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            arrow.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            row.heightAnchor.constraint(equalToConstant: 55)
        ])

        return row
    }

    private func makeSwitchRow(icon: String, title: String, selector: Selector) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImageView(image: UIImage(systemName: icon))
        image.tintColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        image.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        let sw = UISwitch()
        sw.onTintColor = UIColor(red: 0.07, green: 0.33, blue: 0.42, alpha: 1)
        sw.addTarget(self, action: selector, for: .valueChanged)
        sw.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(image)
        row.addSubview(label)
        row.addSubview(sw)

        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            image.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 24),
            image.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            sw.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            sw.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            row.heightAnchor.constraint(equalToConstant: 55)
        ])

        return row
    }

    private func stackRows(_ card: UIView, rows: [UIView]) {
        var previous: UIView? = nil

        for row in rows {
            card.addSubview(row)

            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: card.trailingAnchor)
            ])

            if let prev = previous {
                row.topAnchor.constraint(equalTo: prev.bottomAnchor).isActive = true
            } else {
                row.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
            }

            previous = row
        }

        previous?.bottomAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
    }

    // MARK: - SWITCH ACTIONS
    @objc private func togglePush(_ sender: UISwitch) {
        print("Push Notifications:", sender.isOn)
    }

    @objc private func toggleEmail(_ sender: UISwitch) {
        print("Email Marketing:", sender.isOn)
    }

    @objc private func toggleBiometric(_ sender: UISwitch) {
        print("Biometric Login:", sender.isOn)
    }
}
