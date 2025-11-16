//
//  SearchViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 13/11/25.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - UI Elements
    private let topContainerView = UIView()
    private let searchBarBackground = UIView()
    private let searchIcon = UIImageView()
    private let searchTextField = UITextField()
    private let closeButton = UIButton(type: .system)
    private let recentSearchesLabel = UILabel()
    private let whiteCardView = UIView()
    private let tableView = UITableView()
    
    // MARK: - Data
    private let recentSearches = ["cap", "headphones", "chair", "sports"]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 33/255, green: 97/255, blue: 114/255, alpha: 1.0) // teal
        
        // --- Top Container (Teal Background) ---
        view.addSubview(topContainerView)
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // --- Search Bar Background ---
        topContainerView.addSubview(searchBarBackground)
        searchBarBackground.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        searchBarBackground.layer.cornerRadius = 20
        searchBarBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarBackground.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16),
            searchBarBackground.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -60),
            searchBarBackground.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            searchBarBackground.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // --- Search Icon ---
        searchIcon.image = UIImage(systemName: "magnifyingglass")
        searchIcon.tintColor = .gray
        searchBarBackground.addSubview(searchIcon)
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchIcon.leadingAnchor.constraint(equalTo: searchBarBackground.leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: searchBarBackground.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 18),
            searchIcon.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        // --- Search TextField ---
        searchBarBackground.addSubview(searchTextField)
        searchTextField.placeholder = "Search"
        searchTextField.font = UIFont.systemFont(ofSize: 16)
        searchTextField.textColor = .black
        searchTextField.delegate = self
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchBarBackground.trailingAnchor, constant: -8),
            searchTextField.centerYAnchor.constraint(equalTo: searchBarBackground.centerYAnchor)
        ])
        
        // --- Close Button (X) ---
        topContainerView.addSubview(closeButton)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 20
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: searchBarBackground.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        // --- White Card View ---
        view.addSubview(whiteCardView)
        whiteCardView.backgroundColor = .white
        whiteCardView.layer.cornerRadius = 30
        whiteCardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        whiteCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            whiteCardView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: 20),
            whiteCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            whiteCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            whiteCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // --- Recent Searches Label ---
        whiteCardView.addSubview(recentSearchesLabel)
        recentSearchesLabel.text = "Recent Searches"
        recentSearchesLabel.font = UIFont.boldSystemFont(ofSize: 16)
        recentSearchesLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recentSearchesLabel.topAnchor.constraint(equalTo: whiteCardView.topAnchor, constant: 20),
            recentSearchesLabel.leadingAnchor.constraint(equalTo: whiteCardView.leadingAnchor, constant: 16)
        ])
        
        // --- Table View ---
        whiteCardView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: recentSearchesLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: whiteCardView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: whiteCardView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: whiteCardView.bottomAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "SearchCell")
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
        cell.configure(with: recentSearches[indexPath.row])
        return cell
    }
}

// MARK: - Custom Cell for Proper Alignment
class SearchTableViewCell: UITableViewCell {
    private let iconView = UIImageView()
    private let searchLabel = UILabel()
    private let stack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 20
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        iconView.image = UIImage(systemName: "magnifyingglass")
        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        searchLabel.font = UIFont.systemFont(ofSize: 16)
        searchLabel.textColor = .black
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(searchLabel)
    }
    
    func configure(with text: String) {
        searchLabel.text = text
    }
}
