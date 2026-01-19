//
//  LanguageViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 24/12/25.
//

import UIKit

class LanguageViewController: UIViewController {

    // MARK: - Data
    private let languages = ["English", "Hindi", "Spanish", "French", "German"]
    private var selectedLanguages: Set<String> = ["English"]

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Labels
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let youSelectedLabel = UILabel()
    private let allLanguagesLabel = UILabel()

    // MARK: - Cards
    private let selectedCard = UIView()
    private let allLanguagesCard = UIView()

    // MARK: - Colors
    private let tickColor = UIColor(red: 0.12, green: 0.28, blue: 0.35, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        refreshSelectedCard()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        navigationItem.title = "Language"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        titleLabel.text = "Choose the language"
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)

        subtitleLabel.text = "Select your preferred language below. This helps us serve you better."
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        youSelectedLabel.text = "You Selected"
        youSelectedLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        youSelectedLabel.textColor = .label

        allLanguagesLabel.text = "All Languages"
        allLanguagesLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        allLanguagesLabel.textColor = .label

        configureCard(selectedCard)
        configureCard(allLanguagesCard)

        [
            titleLabel,
            subtitleLabel,
            youSelectedLabel,
            selectedCard,
            allLanguagesLabel,
            allLanguagesCard
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        buildAllLanguagesCard()
    }

    private func configureCard(_ card: UIView) {
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
    }

    // MARK: - Selected Card
    private func refreshSelectedCard() {
        selectedCard.subviews.forEach { $0.removeFromSuperview() }

        var previous: UIView?

        for (index, lang) in selectedLanguages.enumerated() {
            let row = languageRow(
                title: lang,
                selected: true,
                showSeparator: index != selectedLanguages.count - 1
            )
            selectedCard.addSubview(row)

            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: selectedCard.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: selectedCard.trailingAnchor),
                row.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? selectedCard.topAnchor,
                                         constant: index == 0 ? 8 : 0)
            ])

            previous = row
        }

        previous?.bottomAnchor.constraint(equalTo: selectedCard.bottomAnchor, constant: -8).isActive = true
    }

    // MARK: - All Languages Card
    private func buildAllLanguagesCard() {
        allLanguagesCard.subviews.forEach { $0.removeFromSuperview() }

        var previous: UIView?

        for (index, lang) in languages.enumerated() {
            let row = languageRow(
                title: lang,
                selected: selectedLanguages.contains(lang),
                showSeparator: index != languages.count - 1
            )
            row.tag = index
            row.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(languageTapped(_:))
            ))
            allLanguagesCard.addSubview(row)

            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: allLanguagesCard.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: allLanguagesCard.trailingAnchor),
                row.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? allLanguagesCard.topAnchor,
                                         constant: index == 0 ? 8 : 0)
            ])

            previous = row
        }

        previous?.bottomAnchor.constraint(equalTo: allLanguagesCard.bottomAnchor, constant: -8).isActive = true
    }

    // MARK: - Row
    private func languageRow(title: String, selected: Bool, showSeparator: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let checkbox = UIView()
        checkbox.layer.cornerRadius = 11
        checkbox.layer.borderWidth = selected ? 0 : 1.5
        checkbox.layer.borderColor = UIColor.systemGray4.cgColor
        checkbox.backgroundColor = selected ? tickColor : .clear

        let tick = UIImageView(image: UIImage(systemName: "checkmark"))
        tick.tintColor = .white
        tick.isHidden = !selected

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)

        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.isHidden = !showSeparator

        [checkbox, tick, label, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }

        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            checkbox.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 22),
            checkbox.heightAnchor.constraint(equalToConstant: 22),

            tick.centerXAnchor.constraint(equalTo: checkbox.centerXAnchor),
            tick.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            separator.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        return container
    }

    // MARK: - Actions
    @objc private func languageTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        let lang = languages[index]

        if selectedLanguages.contains(lang) {
            selectedLanguages.remove(lang)
        } else {
            selectedLanguages.insert(lang)
        }

        buildAllLanguagesCard()
        refreshSelectedCard()
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            youSelectedLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            youSelectedLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            selectedCard.topAnchor.constraint(equalTo: youSelectedLabel.bottomAnchor, constant: 8),
            selectedCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            selectedCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            allLanguagesLabel.topAnchor.constraint(equalTo: selectedCard.bottomAnchor, constant: 24),
            allLanguagesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            allLanguagesCard.topAnchor.constraint(equalTo: allLanguagesLabel.bottomAnchor, constant: 8),
            allLanguagesCard.leadingAnchor.constraint(equalTo: selectedCard.leadingAnchor),
            allLanguagesCard.trailingAnchor.constraint(equalTo: selectedCard.trailingAnchor),
            allLanguagesCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
}
