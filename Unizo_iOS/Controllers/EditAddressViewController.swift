//
//  EditAddressViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 19/11/25.
//

import UIKit

class EditAddressViewController: UIViewController {

    // MARK: - Nav Bar Elements
    private let navBar = UIView()
    private let backButton = UIButton()
    private let heartButton = UIButton()
    private let titleLabel = UILabel()

    // MARK: - Scroll + Content
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Section
    private let sectionLabel = UILabel()
    private let whiteContainer = UIView()

    // MARK: - Address Rows (Labels + Values)
    private func makeRow(title: String, value: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        valueLabel.textColor = UIColor.gray
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .gray
        arrow.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(titleLabel)
        row.addSubview(valueLabel)
        row.addSubview(arrow)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            arrow.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            arrow.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 15),

            valueLabel.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        row.heightAnchor.constraint(equalToConstant: 48).isActive = true

        return row
    }

    // MARK: - Save Button
    private let saveButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1, alpha: 1)

        setupNavBar()
        setupScroll()
        setupSection()
        setupWhiteContainer()
        setupRows()
        setupSaveButton()
    }

    // MARK: - Custom Nav Bar
    private func setupNavBar() {
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = .clear
        view.addSubview(navBar)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Back button
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .black
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navBar.addSubview(backButton)

        // Heart button
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .black
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(heartButton)

        // Title
        titleLabel.text = "Edit Address"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),

            heartButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -20),
            heartButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: navBar.centerYAnchor)
        ])
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Scroll Setup
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 5),
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

    // MARK: - Section Label
    private func setupSection() {
        sectionLabel.text = "Current Address"
        sectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(sectionLabel)

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }

    // MARK: - White Rounded Container
    private func setupWhiteContainer() {
        whiteContainer.backgroundColor = .white
        whiteContainer.layer.cornerRadius = 20
        whiteContainer.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(whiteContainer)

        NSLayoutConstraint.activate([
            whiteContainer.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            whiteContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            whiteContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }

    // MARK: - Rows
    private func setupRows() {
        let rows = [
            makeRow(title: "Name", value: "Jonathan"),
            makeRow(title: "Phone Number", value: "+91 90078 91599"),
            makeRow(title: "Address Line 1", value: "4517 Washington Ave"),
            makeRow(title: "Address Line 2 (Optional)", value: ""),
            makeRow(title: "City", value: "Manchester"),
            makeRow(title: "State", value: "Kentucky"),
            makeRow(title: "Pincode", value: "39495")
        ]

        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = 1      // spacing = divider thickness
        stack.translatesAutoresizingMaskIntoConstraints = false

        whiteContainer.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: whiteContainer.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: whiteContainer.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: whiteContainer.trailingAnchor, constant: -15),
            stack.bottomAnchor.constraint(equalTo: whiteContainer.bottomAnchor, constant: -10)
        ])

        // Add light dividers (Figma style)
        for row in rows {
            let divider = UIView()
            divider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            divider.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(divider)

            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                divider.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                divider.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                divider.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }

    // MARK: - Save Button
    private func setupSaveButton() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)
        saveButton.layer.cornerRadius = 25
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)

        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: whiteContainer.bottomAnchor, constant: 60),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
}

    @objc private func savePressed() {
        let alert = UIAlertController(title: "Success", message: "Address Updated!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
