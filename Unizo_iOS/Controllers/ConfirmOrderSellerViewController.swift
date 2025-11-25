//
//  ConfirmOrderViewSellerController.swift
//  Unizo_iOS
//
//  Created by Somesh on 21/11/25.
//

import UIKit

class ConfirmOrderSellerViewController: UIViewController {

    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Toolbar
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 22
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Confirm Order"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let heartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 22
        return btn
    }()
    private let toolbarBackground: UIView = {
        let v = UIView()
        v.backgroundColor = .white      // opaque white
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05     // subtle shadow like iOS navigation bars
        v.layer.shadowRadius = 4
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        return v
    }()

    
    
    // MARK: - Product Section
    
    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "lamp")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()
    private let categoryLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Fashion"
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .gray
        return lbl
    }()
    
    private let titleText: UILabel = {
        let lbl = UILabel()
        lbl.text = "Hostel Table Lamp"
        lbl.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        return lbl
    }()
    
    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "₹500"
        lbl.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        return lbl
    }()
    
    
    // MARK: - Product Properties (Aligned)
    
    private func makeTitleLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .gray
        return lbl
    }
    
    private func makeValueLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textAlignment = .right
        return lbl
    }
    
    private lazy var colourTitleLabel = makeTitleLabel("Colour:")
    private lazy var sizeTitleLabel = makeTitleLabel("Size:")
    private lazy var conditionTitleLabel = makeTitleLabel("Condition:")
    
    private lazy var colourValueLabel = makeValueLabel("Yellow")
    private lazy var sizeValueLabel = makeValueLabel("-")
    private lazy var conditionValueLabel = makeValueLabel("New")
    
    
    // MARK: - Buyer Card
    
    private let buyerCard: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.2)
        v.layer.cornerRadius = 12
        return v
    }()
    
    private let buyerNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Jonathan"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return lbl
    }()
    
    private let buyerAddressLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "4517 Washington Ave, Manchester, Kentucky 39495"
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .darkGray
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let qtyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Qty\n1"
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()
    
    
    // MARK: - Message Field
    private let messageField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Send a message"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 10
        tf.setLeftPaddingPoints(14)
        return tf
    }()
    
    
    // MARK: - Bottom Buttons
    private let declineButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Decline", for: .normal)
        btn.backgroundColor = .systemRed
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    private let acceptButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Accept", for: .normal)
        btn.backgroundColor = UIColor(red: 0.02, green: 0.27, blue: 0.37, alpha: 1.0) // #04445F
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}


extension ConfirmOrderSellerViewController {
    
    func setupUI() {
        view.backgroundColor = UIColor.systemGray6
        
        // MARK: - ScrollView Setup
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        view.addSubview(toolbarBackground)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(heartButton)
        toolbarBackground.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toolbarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            toolbarBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarBackground.bottomAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            heartButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            heartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            heartButton.widthAnchor.constraint(equalToConstant: 44),
            heartButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
        
        
        // MARK: - Scroll Items
        let scrollItems = [
            categoryLabel,
            productImageView,
            titleText,
            priceLabel,
        ]
        
        scrollItems.forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        // MARK: - Product Layout
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),

            categoryLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 12),
            categoryLabel.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),
            
            titleText.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 5),
            titleText.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            
            priceLabel.centerYAnchor.constraint(equalTo: titleText.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor)
        ])
        
        
        // MARK: - Property Rows
        let colourRow = UIStackView(arrangedSubviews: [colourTitleLabel, colourValueLabel])
        let sizeRow = UIStackView(arrangedSubviews: [sizeTitleLabel, sizeValueLabel])
        let conditionRow = UIStackView(arrangedSubviews: [conditionTitleLabel, conditionValueLabel])
        
        [colourRow, sizeRow, conditionRow].forEach {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
        }
        
        let detailsStack = UIStackView(arrangedSubviews: [colourRow, sizeRow, conditionRow])
        detailsStack.axis = .vertical
        detailsStack.spacing = 6
        
        contentView.addSubview(detailsStack)
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            detailsStack.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 12),
            detailsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        
        // MARK: - Buyer Card
        contentView.addSubview(buyerCard)
        buyerCard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buyerCard.topAnchor.constraint(equalTo: detailsStack.bottomAnchor, constant: 20),
            buyerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buyerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        let buyerStack = UIStackView(arrangedSubviews: [buyerNameLabel, buyerAddressLabel])
        buyerStack.axis = .vertical
        buyerStack.spacing = 4
        
        buyerCard.addSubview(buyerStack)
        buyerCard.addSubview(qtyLabel)
        
        buyerStack.translatesAutoresizingMaskIntoConstraints = false
        qtyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buyerStack.topAnchor.constraint(equalTo: buyerCard.topAnchor, constant: 16),
            buyerStack.leadingAnchor.constraint(equalTo: buyerCard.leadingAnchor, constant: 16),
            buyerStack.trailingAnchor.constraint(lessThanOrEqualTo: qtyLabel.leadingAnchor, constant: -12),
            buyerStack.bottomAnchor.constraint(equalTo: buyerCard.bottomAnchor, constant: -16),
            
            qtyLabel.centerYAnchor.constraint(equalTo: buyerCard.centerYAnchor),
            qtyLabel.trailingAnchor.constraint(equalTo: buyerCard.trailingAnchor, constant: -16),
            qtyLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        
        // MARK: - Message Field
        contentView.addSubview(messageField)
        messageField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageField.topAnchor.constraint(equalTo: buyerCard.bottomAnchor, constant: 20),
            messageField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            messageField.heightAnchor.constraint(equalToConstant: 52),
            messageField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        
        // MARK: - Bottom Buttons
        view.addSubview(declineButton)
        view.addSubview(acceptButton)
        
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            declineButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            declineButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            declineButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.42),
            declineButton.heightAnchor.constraint(equalToConstant: 60),
            
            acceptButton.bottomAnchor.constraint(equalTo: declineButton.bottomAnchor),
            acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            acceptButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.42),
            acceptButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}


// MARK: - Padding Extension
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        leftView = padding
        leftViewMode = .always
    }
}
