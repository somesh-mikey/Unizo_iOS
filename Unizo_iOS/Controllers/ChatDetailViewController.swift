//
//  ChatDetailViewController.swift
//  Unizo_iOS
//
//  Created by Soham Bhattacharya on 26/11/25.
//

import UIKit

class ChatDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Inputs from previous screen
    var chatTitle: String = ""
    var isSeller: Bool = true

    // MARK: - Fake messages for now
    private var messages: [(Bool, String, String)] = [
        (false, "Hi! Thanks for your interest in the Under Armour Cap. It's in excellent condition and comes with the original box.", "2:30 PM"),
        (true, "That sounds great! Can you send me more photos?", "2:32 PM")
    ]

    // MARK: - UI ELEMENTS

    // BACK BUTTON
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .white
        b.layer.cornerRadius = 22
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .black
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // PROFILE ICON
    private let profileCircle: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.90, alpha: 1)
        v.layer.cornerRadius = 26
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let profileIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.fill"))
        iv.tintColor = .gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor.gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // TABLEVIEW
    private let tableView: UITableView = {
        let t = UITableView()
        t.separatorStyle = .none
        t.backgroundColor = UIColor(white: 0.97, alpha: 1)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.showsVerticalScrollIndicator = false
        t.allowsSelection = false
        return t
    }()

    // INPUT BAR
    private let inputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.98, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "plus"), for: .normal)
        b.tintColor = .gray
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let inputField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type a message..."
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 20
        tf.setLeftPadding(16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let emojiButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        b.tintColor = .gray
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let sendButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = UIColor(red: 0.0, green: 0.27, blue: 0.40, alpha: 1)
        b.layer.cornerRadius = 22
        b.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.97, alpha: 1)

        setupHeader()
        setupTable()
        setupInputBar()
        
        // remove nav bar completely
        navigationController?.setNavigationBarHidden(true, animated: false)

        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        titleLabel.text = chatTitle
        roleLabel.text = isSeller ? "Seller" : "Buyer"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }


    // MARK: - HEADER
    private func setupHeader() {

        view.addSubview(backButton)
        view.addSubview(profileCircle)
        profileCircle.addSubview(profileIcon)
        view.addSubview(roleLabel)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            profileCircle.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            profileCircle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            profileCircle.widthAnchor.constraint(equalToConstant: 52),
            profileCircle.heightAnchor.constraint(equalToConstant: 52),

            profileIcon.centerXAnchor.constraint(equalTo: profileCircle.centerXAnchor),
            profileIcon.centerYAnchor.constraint(equalTo: profileCircle.centerYAnchor),
            profileIcon.widthAnchor.constraint(equalToConstant: 28),
            profileIcon.heightAnchor.constraint(equalToConstant: 28),

            roleLabel.leadingAnchor.constraint(equalTo: profileCircle.trailingAnchor, constant: 8),
            roleLabel.topAnchor.constraint(equalTo: profileCircle.topAnchor, constant: 4),

            titleLabel.leadingAnchor.constraint(equalTo: roleLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 2)
        ])
    }

    // MARK: - TABLE
    private func setupTable() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: "ChatBubbleCell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: profileCircle.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }

    // MARK: - INPUT BAR
    private func setupInputBar() {
        view.addSubview(inputContainer)
        inputContainer.addSubview(addButton)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(emojiButton)
        inputContainer.addSubview(sendButton)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 60),

            addButton.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            addButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.heightAnchor.constraint(equalToConstant: 44),

            emojiButton.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            emojiButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            emojiButton.widthAnchor.constraint(equalToConstant: 24),
            emojiButton.heightAnchor.constraint(equalToConstant: 24),

            inputField.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 12),
            inputField.trailingAnchor.constraint(equalTo: emojiButton.leadingAnchor, constant: -12),
            inputField.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBubbleCell", for: indexPath) as! ChatBubbleCell
        let msg = messages[indexPath.row]

        cell.configure(isMine: msg.0, text: msg.1, time: msg.2)
        return cell
    }

    // MARK: - Back Button
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
}



// ---------------------------------------------------------
// MARK: - CHAT BUBBLE CELL
// ---------------------------------------------------------

final class ChatBubbleCell: UITableViewCell {

    private let bubble = UIView()
    private let label = UILabel()
    private let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        bubble.layer.cornerRadius = 18
        bubble.translatesAutoresizingMaskIntoConstraints = false

        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.font = UIFont.systemFont(ofSize: 11)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(bubble)
        contentView.addSubview(timeLabel)
        bubble.addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError("") }

    func configure(isMine: Bool, text: String, time: String) {

        bubble.backgroundColor = isMine
            ? UIColor(red: 0.02, green: 0.34, blue: 0.46, alpha: 1)
            : UIColor(white: 0.94, alpha: 1)

        label.textColor = isMine ? .white : .black
        label.text = text
        timeLabel.text = time

        // Remove old constraints before applying new
        bubble.removeConstraints(bubble.constraints)
        timeLabel.removeConstraints(timeLabel.constraints)

        bubble.removeFromSuperview()
        timeLabel.removeFromSuperview()
        contentView.addSubview(bubble)
        contentView.addSubview(timeLabel)
        bubble.addSubview(label)

        let horizontalPadding: CGFloat = 70

        if isMine {
            NSLayoutConstraint.activate([
                bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                bubble.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: horizontalPadding),
                bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

                label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -12),

                timeLabel.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 4),
                timeLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])

        } else {
            NSLayoutConstraint.activate([
                bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                bubble.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -horizontalPadding),
                bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

                label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -12),

                timeLabel.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 4),
                timeLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor),
                timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        }
    }
}



// ---------------------------------------------------------
// MARK: - UITextField Padding Helper
// ---------------------------------------------------------

extension UITextField {
    func setLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
