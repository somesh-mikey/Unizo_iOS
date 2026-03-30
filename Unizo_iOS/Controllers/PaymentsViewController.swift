//
//  PaymentsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 26/11/25.
//

import UIKit

class PaymentsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1, alpha: 1)
        setupNavBar()
        setupScroll()
        setupContent()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true

        // Correct floating tab bar hiding
        (tabBarController as? MainTabBarController)?.hideFloatingTabBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false

        // Correct floating tab bar restoring
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
    }



    // MARK: - Custom Navigation Bar
    private func setupNavBar() {
        let backBtn = UIButton(type: .system)
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.backgroundColor = .white
        backBtn.layer.cornerRadius = 22
        backBtn.layer.shadowColor = UIColor.black.cgColor
        backBtn.layer.shadowOpacity = 0.1
        backBtn.layer.shadowRadius = 8
        backBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        let title = UILabel()
        title.text = "Payments".localized
        title.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backBtn)
        view.addSubview(title)

        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backBtn.widthAnchor.constraint(equalToConstant: 44),
            backBtn.heightAnchor.constraint(equalToConstant: 44),

            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor)
        ])
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Scroll + Content
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
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

    // MARK: - Main UI
    private func setupContent() {
        // ----- "Cards" Label -----
        let cardsLabel = makeSectionTitle("Cards".localized)
        contentView.addSubview(cardsLabel)

        // ----- Card Button -----
        let cardRow = makeRow(icon: "creditcard",
                              title: "Add credit or debit cards".localized,
                              showChevron: true,
                              showDivider: false)

        contentView.addSubview(cardRow)

        // ----- UPI Label -----
        let upiLabel = makeSectionTitle("UPI".localized)
        contentView.addSubview(upiLabel)

        // ----- UPI container -----
        let upiContainer = UIView()
        upiContainer.backgroundColor = .white
        upiContainer.layer.cornerRadius = 15
        upiContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(upiContainer)

        // List items
        let google = makeUPIRow(title: "Google Pay UPI".localized, showAddButton: false)
        let phonePe = makeUPIRow(title: "PhonePe UPI".localized, showAddButton: false)
        let bhim = makeUPIRow(title: "BHIM UPI".localized, showAddButton: false)
        let addNew = makeUPIRow(title: "Add new UPI ID".localized, showAddButton: true)

        let stack = UIStackView(arrangedSubviews: [google, phonePe, bhim, addNew])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        upiContainer.addSubview(stack)

        // MARK: Constraints
        NSLayoutConstraint.activate([
            cardsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            cardRow.topAnchor.constraint(equalTo: cardsLabel.bottomAnchor, constant: 5),
            cardRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardRow.heightAnchor.constraint(equalToConstant: 60),

            upiLabel.topAnchor.constraint(equalTo: cardRow.bottomAnchor, constant: 25),
            upiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            upiContainer.topAnchor.constraint(equalTo: upiLabel.bottomAnchor, constant: 5),
            upiContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upiContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            stack.topAnchor.constraint(equalTo: upiContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: upiContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: upiContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: upiContainer.bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: 240),

            upiContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60)
        ])
    }

    // MARK: - Helper Views

    private func makeSectionTitle(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    private func makeRow(icon: String, title: String, showChevron: Bool, showDivider: Bool) -> UIView {
        let row = UIView()
        row.backgroundColor = .white
        row.layer.cornerRadius = 15
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(red: 0, green: 0.28, blue: 0.39, alpha: 1)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(iconView)
        row.addSubview(titleLabel)
        if showChevron { row.addSubview(chevron) }

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 25),
            iconView.heightAnchor.constraint(equalToConstant: 25),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -20),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        return row
    }

    private func makeUPIRow(title: String, showAddButton: Bool) -> UIView {
        let row = UIView()
        row.backgroundColor = .white
        row.translatesAutoresizingMaskIntoConstraints = false

        let leftIcon = UIImageView()
        leftIcon.translatesAutoresizingMaskIntoConstraints = false
        leftIcon.image = UIImage(systemName: "creditcard")
        leftIcon.tintColor = UIColor(red: 0, green: 0.28, blue: 0.39, alpha: 1)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(leftIcon)
        row.addSubview(titleLabel)

        // ADD button
        if showAddButton {
            let addButton = UIButton(type: .system)
            addButton.setTitle("Add".localized, for: .normal)
            addButton.setTitleColor(UIColor(red: 0, green: 0.28, blue: 0.39, alpha: 1), for: .normal)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(addButton)

            NSLayoutConstraint.activate([
                addButton.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -20),
                addButton.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            leftIcon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 15),
            leftIcon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            leftIcon.widthAnchor.constraint(equalToConstant: 25),
            leftIcon.heightAnchor.constraint(equalToConstant: 25),

            titleLabel.leadingAnchor.constraint(equalTo: leftIcon.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.9, alpha: 1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(divider)

        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 15),
            divider.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -15),
            divider.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])

        return row
    }
}
