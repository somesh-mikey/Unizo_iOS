//
//  LanguageViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 24/12/25.
//

import UIKit

class LanguageViewController: UIViewController {

    // MARK: - Data
    private let languages = AppLanguage.allCases
    private var selectedLanguage: AppLanguage = AppLanguageManager.shared.current

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

    // MARK: - Save Button
    private let saveButton = UIButton(type: .system)

    // MARK: - Colors
    private let tickColor = UIColor(red: 0.12, green: 0.28, blue: 0.35, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        refreshSelectedCard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        navigationItem.title = "Language".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        titleLabel.text = "Choose the language".localized
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)

        subtitleLabel.text = "Select your preferred language below. This helps us serve you better.".localized
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        youSelectedLabel.text = "You Selected".localized
        youSelectedLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        youSelectedLabel.textColor = .label

        allLanguagesLabel.text = "All Languages".localized
        allLanguagesLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        allLanguagesLabel.textColor = .label

        configureCard(selectedCard)
        configureCard(allLanguagesCard)

        // Save button
        saveButton.setTitle("Save".localized, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton.backgroundColor = tickColor
        saveButton.layer.cornerRadius = 28
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        [
            titleLabel,
            subtitleLabel,
            youSelectedLabel,
            selectedCard,
            allLanguagesLabel,
            allLanguagesCard,
            saveButton
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

        let row = languageRow(
            title: selectedLanguage.rawValue,
            selected: true,
            showSeparator: false
        )
        selectedCard.addSubview(row)

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: selectedCard.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: selectedCard.trailingAnchor),
            row.topAnchor.constraint(equalTo: selectedCard.topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: selectedCard.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - All Languages Card
    private func buildAllLanguagesCard() {
        allLanguagesCard.subviews.forEach { $0.removeFromSuperview() }

        var previous: UIView?

        for (index, lang) in languages.enumerated() {
            let row = languageRow(
                title: lang.rawValue,
                selected: lang == selectedLanguage,
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

        // Radio button style (circle)
        let radio = UIView()
        radio.layer.cornerRadius = 11
        radio.layer.borderWidth = selected ? 0 : 1.5
        radio.layer.borderColor = UIColor.systemGray4.cgColor
        radio.backgroundColor = selected ? tickColor : .clear

        let tick = UIImageView(image: UIImage(systemName: "checkmark"))
        tick.tintColor = .white
        tick.isHidden = !selected

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)
        label.textColor = selected ? tickColor : .label

        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.isHidden = !showSeparator

        [radio, tick, label, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }

        NSLayoutConstraint.activate([
            radio.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            radio.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            radio.widthAnchor.constraint(equalToConstant: 22),
            radio.heightAnchor.constraint(equalToConstant: 22),

            tick.centerXAnchor.constraint(equalTo: radio.centerXAnchor),
            tick.centerYAnchor.constraint(equalTo: radio.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: radio.trailingAnchor, constant: 12),
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
        selectedLanguage = languages[index]
        buildAllLanguagesCard()
        refreshSelectedCard()
    }

    @objc private func saveTapped() {
        let previousLanguage = AppLanguageManager.shared.current

        guard selectedLanguage != previousLanguage else {
            // No change — just go back
            navigationController?.popViewController(animated: true)
            return
        }

        // Persist the language change
        AppLanguageManager.shared.setLanguage(selectedLanguage)

        // Notify all screens to refresh
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)

        // Restart the app UI from root so all screens pick up the new language
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            navigationController?.popViewController(animated: true)
            return
        }

        let tab = MainTabBarController()
        // Navigate to Account tab (index 4) → Settings will need to be re-entered
        tab.selectedIndex = 4
        window.rootViewController = tab
        window.makeKeyAndVisible()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
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

            saveButton.topAnchor.constraint(equalTo: allLanguagesCard.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
}
