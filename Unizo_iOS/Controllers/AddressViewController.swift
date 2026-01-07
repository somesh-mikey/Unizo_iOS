//
//  AddressViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 18/11/25.
//

import UIKit

enum AddressFlowSource {
    case fromAccount
    case fromCart
}

class AddressViewController: UIViewController {
    
    var flowSource: AddressFlowSource = .fromCart
    var isBuyNowFlow: Bool = false

    // MARK: - Colors
    private let bgColor     = UIColor(red: 0.96, green: 0.97, blue: 1.0, alpha: 1.0)
    private let primaryTeal = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1.0)
    private let accentTeal  = UIColor(red: 0.00, green: 0.62, blue: 0.71, alpha: 1.0)
    private let lightGray   = UIColor(white: 0.8, alpha: 1.0)

    // MARK: - Top bar
    private let navBar = UIView()
    private let backButton = UIButton(type: .system)
    private let heartButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // MARK: - Step indicator
    private let stepContainer = UIView()
    private let stepStack = UIStackView()

    // MARK: - Scroll + content
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let addressesStack = UIStackView()
    private let addNewAddressButton = UIButton(type: .system)
    private let continueButton = UIButton(type: .system)

    // Radio selection
    private var addressCards: [UIView] = []
    private var radioViews: [UIView] = []
    private var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = bgColor

        setupNavBar()
        setupStepIndicator()
        setupScrollAndContent()
        setupAddressCards()
        setupAddNewAddressButton()
        setupContinueButton()
        updateSelectionUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - NAV BAR
    private func setupNavBar() {
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = bgColor
        view.addSubview(navBar)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 56)
        ])

        // Back
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        // Heart
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .black
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.text = "Select Address"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        navBar.addSubview(backButton)
        navBar.addSubview(heartButton)
        navBar.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            heartButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 28),
            heartButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navBar.centerYAnchor)
        ])
    }

    // UPDATED: Back navigation -> pop to CartViewController if present, else pop/dismiss
    @objc private func backTapped() {
        // If part of a navigation controller, try to pop to CartViewController if it exists
        if let nav = navigationController {
            if let cartVC = nav.viewControllers.first(where: { $0 is CartViewController }) {
                nav.popToViewController(cartVC, animated: true)
                return
            }
            // fallback: normal pop
            nav.popViewController(animated: true)
            return
        }

        // If presented modally, dismiss
        dismiss(animated: true)
    }

    // MARK: - STEP INDICATOR
    private func setupStepIndicator() {
        stepContainer.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.backgroundColor = bgColor
        view.addSubview(stepContainer)

        NSLayoutConstraint.activate([
            stepContainer.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            stepContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stepContainer.heightAnchor.constraint(equalToConstant: 44)
        ])

        stepStack.axis = .horizontal
        stepStack.alignment = .center
        stepStack.spacing = 40      // big gap so "Confirm Order" shifts to the right
        stepStack.translatesAutoresizingMaskIntoConstraints = false
        stepContainer.addSubview(stepStack)

        NSLayoutConstraint.activate([
            stepStack.leadingAnchor.constraint(equalTo: stepContainer.leadingAnchor, constant: 20),
            stepStack.centerYAnchor.constraint(equalTo: stepContainer.centerYAnchor)
        ])

        // STEP 1
        let step1Circle = UIView()
        step1Circle.backgroundColor = accentTeal
        step1Circle.layer.cornerRadius = 10
        step1Circle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            step1Circle.widthAnchor.constraint(equalToConstant: 20),
            step1Circle.heightAnchor.constraint(equalToConstant: 20)
        ])

        let step1LabelNumber = UILabel()
        step1LabelNumber.text = "1"
        step1LabelNumber.textColor = .white
        step1LabelNumber.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        step1LabelNumber.textAlignment = .center
        step1LabelNumber.translatesAutoresizingMaskIntoConstraints = false
        step1Circle.addSubview(step1LabelNumber)
        NSLayoutConstraint.activate([
            step1LabelNumber.centerXAnchor.constraint(equalTo: step1Circle.centerXAnchor),
            step1LabelNumber.centerYAnchor.constraint(equalTo: step1Circle.centerYAnchor)
        ])

        let step1Text = UILabel()
        step1Text.text = "Set Address"
        step1Text.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        step1Text.textColor = .black

        let step1Stack = UIStackView(arrangedSubviews: [step1Circle, step1Text])
        step1Stack.axis = .horizontal
        step1Stack.spacing = 6

        // Arrow
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.textColor = .gray
        arrowLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        // STEP 2
        let step2Circle = UIView()
        step2Circle.backgroundColor = lightGray
        step2Circle.layer.cornerRadius = 10
        step2Circle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            step2Circle.widthAnchor.constraint(equalToConstant: 20),
            step2Circle.heightAnchor.constraint(equalToConstant: 20)
        ])

        let step2Number = UILabel()
        step2Number.text = "2"
        step2Number.textColor = .white
        step2Number.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        step2Number.textAlignment = .center
        step2Number.translatesAutoresizingMaskIntoConstraints = false
        step2Circle.addSubview(step2Number)
        NSLayoutConstraint.activate([
            step2Number.centerXAnchor.constraint(equalTo: step2Circle.centerXAnchor),
            step2Number.centerYAnchor.constraint(equalTo: step2Circle.centerYAnchor)
        ])

        let step2Text = UILabel()
        step2Text.text = "Confirm Order"
        step2Text.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        step2Text.textColor = .gray

        let step2Stack = UIStackView(arrangedSubviews: [step2Circle, step2Text])
        step2Stack.axis = .horizontal
        step2Stack.spacing = 6

        stepStack.addArrangedSubview(step1Stack)
        stepStack.addArrangedSubview(arrowLabel)
        stepStack.addArrangedSubview(step2Stack)
    }

    // MARK: - SCROLL + CONTENT
    private func setupScrollAndContent() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stepContainer.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90), // leave space for Continue button

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        addressesStack.axis = .vertical
        addressesStack.spacing = 12
        addressesStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addressesStack)

        NSLayoutConstraint.activate([
            addressesStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            addressesStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - ADDRESS CARDS
    private func setupAddressCards() {
        let addresses: [(String, String)] = [
            ("Jonathan   (+91) 90078 91599",
             "4517 Washington Ave,\nManchester, Kentucky 39495"),
            ("Bryan   (+91) 80045 67543",
             "3891 Colonial Dr,\nSavannah, Georgia 31401"),
            ("Jane   (+91) 70023 56190",
             "1901 Thornridge Cir,\nShiloh, Hawaii 81063")
        ]

        for (index, info) in addresses.enumerated() {
            let card = makeAddressCard(
                index: index,
                nameLine: info.0,
                addressText: info.1
            )
            addressesStack.addArrangedSubview(card)
            addressCards.append(card)
        }

        // so scroll content has some bottom padding (before Add New Address)
        addressesStack.setContentHuggingPriority(.required, for: .vertical)
    }

    private func makeAddressCard(index: Int, nameLine: String, addressText: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.tag = index

        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true

        // Radio circle
        let radio = UIView()
        radio.layer.cornerRadius = 7
        radio.layer.borderWidth = 2
        radio.layer.borderColor = accentTeal.cgColor
        radio.backgroundColor = .clear
        radio.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(radio)

        NSLayoutConstraint.activate([
            radio.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            radio.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            radio.widthAnchor.constraint(equalToConstant: 14),
            radio.heightAnchor.constraint(equalToConstant: 14)
        ])

        radioViews.append(radio)

        // Name line
        let nameLabel = UILabel()
        nameLabel.text = nameLine
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)

        // Address text
        let addressLabel = UILabel()
        addressLabel.text = addressText
        addressLabel.font = UIFont.systemFont(ofSize: 12)
        addressLabel.textColor = .darkGray
        addressLabel.numberOfLines = 2
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(addressLabel)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: radio.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            addressLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])


        // EDIT (pencil) icon
        let editIcon = UIImageView(image: UIImage(systemName: "pencil"))
        editIcon.tintColor = .gray
        editIcon.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(editIcon)

        // BIN (trash) icon
        let deleteIcon = UIImageView(image: UIImage(systemName: "trash"))
        deleteIcon.tintColor = .gray
        deleteIcon.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(deleteIcon)

        // Constraints for icons
        NSLayoutConstraint.activate([
            editIcon.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            editIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -45),
            editIcon.widthAnchor.constraint(equalToConstant: 18),
            editIcon.heightAnchor.constraint(equalToConstant: 18),

            deleteIcon.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            deleteIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            deleteIcon.widthAnchor.constraint(equalToConstant: 18),
            deleteIcon.heightAnchor.constraint(equalToConstant: 18)
        ])


        return card
    }

    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let card = gesture.view else { return }
        selectedIndex = card.tag
        updateSelectionUI()
    }

    private func updateSelectionUI() {
        for (idx, radio) in radioViews.enumerated() {
            radio.subviews.forEach { $0.removeFromSuperview() }

            if idx == selectedIndex {
                // filled circle
                let dot = UIView()
                dot.backgroundColor = accentTeal
                dot.layer.cornerRadius = 4
                dot.translatesAutoresizingMaskIntoConstraints = false
                radio.addSubview(dot)

                NSLayoutConstraint.activate([
                    dot.centerXAnchor.constraint(equalTo: radio.centerXAnchor),
                    dot.centerYAnchor.constraint(equalTo: radio.centerYAnchor),
                    dot.widthAnchor.constraint(equalToConstant: 8),
                    dot.heightAnchor.constraint(equalToConstant: 8)
                ])

                addressCards[idx].layer.borderWidth = 2
                addressCards[idx].layer.borderColor = accentTeal.cgColor
            } else {
                addressCards[idx].layer.borderWidth = 0
                addressCards[idx].layer.borderColor = UIColor.clear.cgColor
            }
        }
    }

    // MARK: - ADD NEW ADDRESS BUTTON
    private func setupAddNewAddressButton() {
        addNewAddressButton.setTitle("Add New Address", for: .normal)
        addNewAddressButton.setTitleColor(primaryTeal, for: .normal)
        addNewAddressButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        addNewAddressButton.backgroundColor = .white
        addNewAddressButton.layer.cornerRadius = 18
        addNewAddressButton.layer.borderWidth = 1.5
        addNewAddressButton.layer.borderColor = primaryTeal.cgColor
        addNewAddressButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        addNewAddressButton.translatesAutoresizingMaskIntoConstraints = false
        addNewAddressButton.addTarget(self, action: #selector(addAddressTapped), for: .touchUpInside)

        contentView.addSubview(addNewAddressButton)

        NSLayoutConstraint.activate([
            addNewAddressButton.topAnchor.constraint(equalTo: addressesStack.bottomAnchor, constant: 18),
            addNewAddressButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addNewAddressButton.heightAnchor.constraint(equalToConstant: 36),
            addNewAddressButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    // UPDATED: navigate to AddNewAddressViewController (push or modal)
    @objc private func addAddressTapped() {
        let newVC = AddNewAddressViewController()
        if let nav = navigationController {
            nav.pushViewController(newVC, animated: true)
        } else {
            newVC.modalPresentationStyle = .fullScreen
            present(newVC, animated: true)
        }
    }

    // MARK: - CONTINUE BUTTON
    private func setupContinueButton() {
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = primaryTeal
        continueButton.layer.cornerRadius = 24
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    @objc func continueTapped() {

        switch flowSource {

        case .fromAccount:
            // Go BACK to Account screen
            if navigationController != nil {
                navigationController?.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }

        case .fromCart:
            // Move to Confirm Order screen
            let vc = ConfirmOrderViewController()
            vc.modalPresentationStyle = .fullScreen

            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                present(vc, animated: true)
            }
        }
    }
}
