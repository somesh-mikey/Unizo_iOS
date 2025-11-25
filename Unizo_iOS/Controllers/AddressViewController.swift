//
//  AddressViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 18/11/25.
//

import UIKit

class AddressViewController: UIViewController {
   
    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet weak var stepIndicatorContainer: UIView!
    
    @IBOutlet weak var address1Container: UIView!
    @IBOutlet weak var address2Container: UIView!
    @IBOutlet weak var address3Container: UIView!
    
    @IBOutlet weak var addNewAddressButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Colors (ADDED)
    private let teal74E7DA = UIColor(red: 0x74/255, green: 0xE7/255, blue: 0xDA/255, alpha: 1) // 1 & 2
    private let blue189AB4 = UIColor(red: 0x18/255, green: 0x9A/255, blue: 0xB4/255, alpha: 1) // Add new address
    
    // MARK: - state
    private var selectedAddressIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBarContainer.translatesAutoresizingMaskIntoConstraints = false
        stepIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        address1Container.translatesAutoresizingMaskIntoConstraints = false
        address2Container.translatesAutoresizingMaskIntoConstraints = false
        address3Container.translatesAutoresizingMaskIntoConstraints = false
        addNewAddressButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        addNewAddressButton.addTarget(self, action: #selector(openAddNewAddress), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        setupBaseAppearance()
        buildTopBar()
        buildStepIndicator()
        buildAddressCards()
        styleButtons()
        applyConstraints()
        
        updateSelectionUI()
    }
    
    private func setupBaseAppearance() {
        view.backgroundColor = UIColor(red: 246/255, green: 247/255, blue: 251/255, alpha: 1)
        
        [address1Container, address2Container, address3Container].forEach { c in
            guard let c = c else { return }
            c.backgroundColor = .white
            c.layer.cornerRadius = 14
            c.layer.shadowColor = UIColor.black.cgColor
            c.layer.shadowOpacity = 0.06
            c.layer.shadowOffset = CGSize(width: 0, height: 2)
            c.layer.shadowRadius = 6
        }
    }
    
    private func buildTopBar() {
        topBarContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let back = circleButton(systemName: "chevron.left")
        back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let heart = circleButton(systemName: "heart")
        let title = UILabel()
        title.text = "Address"
        title.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        topBarContainer.addSubview(back)
        topBarContainer.addSubview(title)
        topBarContainer.addSubview(heart)
        
        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 6),
            back.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 40),
            back.heightAnchor.constraint(equalToConstant: 40),
            
            heart.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor, constant: -6),
            heart.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            heart.widthAnchor.constraint(equalToConstant: 40),
            heart.heightAnchor.constraint(equalToConstant: 40),
            
            title.centerXAnchor.constraint(equalTo: topBarContainer.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor)
        ])
    }
    
    private func circleButton(systemName: String) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: systemName), for: .normal)
        b.tintColor = .black
        b.backgroundColor = .white
        b.layer.cornerRadius = 20
        return b
    }
    
    private func buildStepIndicator() {
        stepIndicatorContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let leftStack = UIStackView()
        leftStack.axis = .horizontal
        leftStack.spacing = 8
        leftStack.alignment = .center
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        
        let step1 = smallStepBubble(number: "1", label: "Set Address", highlighted: true)
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .lightGray
        arrow.translatesAutoresizingMaskIntoConstraints = false
        
        leftStack.addArrangedSubview(step1)
        leftStack.addArrangedSubview(arrow)
        
        let step2 = smallStepBubble(number: "2", label: "Confirm Order", highlighted: false)
        step2.translatesAutoresizingMaskIntoConstraints = false
        
        stepIndicatorContainer.addSubview(leftStack)
        stepIndicatorContainer.addSubview(step2)
        
        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: stepIndicatorContainer.leadingAnchor, constant: 14),
            leftStack.centerYAnchor.constraint(equalTo: stepIndicatorContainer.centerYAnchor),
            
            step2.centerYAnchor.constraint(equalTo: stepIndicatorContainer.centerYAnchor),
            step2.trailingAnchor.constraint(equalTo: stepIndicatorContainer.trailingAnchor, constant: -40)
        ])
    }
    
    private func smallStepBubble(number: String, label: String, highlighted: Bool) -> UIView {
        let h = UIStackView()
        h.axis = .horizontal
        h.spacing = 8
        h.alignment = .center
        h.translatesAutoresizingMaskIntoConstraints = false
        
        let bubble = UIView()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.widthAnchor.constraint(equalToConstant: 26).isActive = true
        bubble.heightAnchor.constraint(equalToConstant: 26).isActive = true
        bubble.layer.cornerRadius = 13
        
        // UPDATED COLOR
        bubble.backgroundColor = highlighted ? teal74E7DA : UIColor(white: 0.92, alpha: 1)
        
        let n = UILabel()
        n.text = number
        n.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        n.textColor = .white
        n.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(n)
        
        NSLayoutConstraint.activate([
            n.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            n.centerYAnchor.constraint(equalTo: bubble.centerYAnchor)
        ])
        
        let lbl = UILabel()
        lbl.text = label
        lbl.font = UIFont.systemFont(ofSize: 14, weight: highlighted ? .semibold : .regular)
        lbl.textColor = highlighted ? .black : .lightGray
        
        h.addArrangedSubview(bubble)
        h.addArrangedSubview(lbl)
        return h
    }
    
    private func buildAddressCards() {
        addAddressCard(into: address1Container, tag: 1,
                       name: "Jonathan", phone: "(+91) 90078 91599",
                       address: "4517 Washington Ave,\nManchester, Kentucky 39495")
        
        addAddressCard(into: address2Container, tag: 2,
                       name: "Bryan", phone: "(+91) 98303 85601",
                       address: "1901 Thornridge Cir, Shiloh,\nHawaii 81603")
        
        addAddressCard(into: address3Container, tag: 3,
                       name: "Jane", phone: "(+91) 75877 87910",
                       address: "8502 Preston Rd, Inglewood,\nMaine 98380")
    }
    
    private func addAddressCard(into container: UIView?, tag: Int, name: String, phone: String, address: String) {
        guard let container = container else { return }
        container.subviews.forEach { $0.removeFromSuperview() }
        container.tag = tag
        
        let radioOuter = UIView()
        radioOuter.translatesAutoresizingMaskIntoConstraints = false
        radioOuter.layer.cornerRadius = 16
        radioOuter.layer.borderWidth = 2
        
        // UPDATED DEFAULT BORDER COLOR
        radioOuter.layer.borderColor = UIColor.lightGray.cgColor
        
        let radioInner = UIView()
        radioInner.translatesAutoresizingMaskIntoConstraints = false
        radioInner.layer.cornerRadius = 10
        radioInner.backgroundColor = .clear
        radioOuter.addSubview(radioInner)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        let phoneLabel = UILabel()
        phoneLabel.text = "  \(phone)"
        phoneLabel.font = UIFont.systemFont(ofSize: 13)
        phoneLabel.textColor = .gray
        
        let namePhone = UIStackView(arrangedSubviews: [nameLabel, phoneLabel])
        namePhone.axis = .horizontal
        namePhone.spacing = 6
        namePhone.translatesAutoresizingMaskIntoConstraints = false
        
        let addr = UILabel()
        addr.text = address
        addr.numberOfLines = 0
        addr.font = UIFont.systemFont(ofSize: 13)
        addr.textColor = .gray
        addr.translatesAutoresizingMaskIntoConstraints = false
        
        let edit = UIButton(type: .system)
        edit.setImage(UIImage(systemName: "pencil"), for: .normal)
        edit.tintColor = .gray
        edit.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        container.addGestureRecognizer(tap)
        
        container.addSubview(radioOuter)
        container.addSubview(namePhone)
        container.addSubview(addr)
        container.addSubview(edit)
        
        NSLayoutConstraint.activate([
            radioOuter.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            radioOuter.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            radioOuter.widthAnchor.constraint(equalToConstant: 32),
            radioOuter.heightAnchor.constraint(equalToConstant: 32),
            
            radioInner.centerXAnchor.constraint(equalTo: radioOuter.centerXAnchor),
            radioInner.centerYAnchor.constraint(equalTo: radioOuter.centerYAnchor),
            radioInner.widthAnchor.constraint(equalToConstant: 18),
            radioInner.heightAnchor.constraint(equalToConstant: 18),
            
            edit.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            edit.centerYAnchor.constraint(equalTo: radioOuter.centerYAnchor),
            edit.widthAnchor.constraint(equalToConstant: 22),
            edit.heightAnchor.constraint(equalToConstant: 22),
            
            namePhone.leadingAnchor.constraint(equalTo: radioOuter.trailingAnchor, constant: 12),
            namePhone.trailingAnchor.constraint(lessThanOrEqualTo: edit.leadingAnchor, constant: -8),
            namePhone.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            
            addr.leadingAnchor.constraint(equalTo: namePhone.leadingAnchor),
            addr.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            addr.topAnchor.constraint(equalTo: namePhone.bottomAnchor, constant: 6),
            addr.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        if let t = gesture.view?.tag {
            selectedAddressIndex = t
            updateSelectionUI()
        }
    }
    
    private func updateSelectionUI() {
        let cards = [address1Container, address2Container, address3Container]
        
        for (index, card) in cards.enumerated() {
            guard let card = card else { continue }
            let selected = (index + 1) == selectedAddressIndex
            
            if let radioOuter = card.subviews.first(where: { $0.layer.cornerRadius == 16 }) {
                
                // UPDATED SELECTED COLOR
                radioOuter.layer.borderColor = selected ? teal74E7DA.cgColor : UIColor.lightGray.cgColor
                
                if let inner = radioOuter.subviews.first {
                    inner.backgroundColor = selected ? teal74E7DA : .clear
                }
            }
        }
    }
    
    private func styleButtons() {
        
        addNewAddressButton.setTitle("Add New Address", for: .normal)
        addNewAddressButton.setTitleColor(blue189AB4, for: .normal)  // UPDATED
        addNewAddressButton.layer.borderWidth = 1.5
        addNewAddressButton.layer.borderColor = blue189AB4.cgColor   // UPDATED
        addNewAddressButton.layer.cornerRadius = 20
        addNewAddressButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        addNewAddressButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = UIColor(red: 0/255, green: 60/255, blue: 78/255, alpha: 1)
        continueButton.layer.cornerRadius = 26
    }
    
    private func applyConstraints() {
        guard let safe = view?.safeAreaLayoutGuide else { return }
        
        NSLayoutConstraint.activate([
            topBarContainer.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            topBarContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 10),
            topBarContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -10),
            topBarContainer.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        NSLayoutConstraint.activate([
            stepIndicatorContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: 8),
            stepIndicatorContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            stepIndicatorContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            stepIndicatorContainer.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            address1Container.topAnchor.constraint(equalTo: stepIndicatorContainer.bottomAnchor, constant: 8),
            address1Container.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 14),
            address1Container.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -14),
            address1Container.heightAnchor.constraint(greaterThanOrEqualToConstant: 92),
            
            address2Container.topAnchor.constraint(equalTo: address1Container.bottomAnchor, constant: 14),
            address2Container.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 14),
            address2Container.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -14),
            address2Container.heightAnchor.constraint(greaterThanOrEqualToConstant: 88),
            
            address3Container.topAnchor.constraint(equalTo: address2Container.bottomAnchor, constant: 14),
            address3Container.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 14),
            address3Container.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -14),
            address3Container.heightAnchor.constraint(greaterThanOrEqualToConstant: 88),
            
            addNewAddressButton.topAnchor.constraint(equalTo: address3Container.bottomAnchor, constant: 18),
            addNewAddressButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 14),
            addNewAddressButton.heightAnchor.constraint(equalToConstant: 42),
            addNewAddressButton.widthAnchor.constraint(equalToConstant: 170),
            
            continueButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 18),
            continueButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -18),
            continueButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -18),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func openAddNewAddress() {
        let vc = AddNewAddressViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    @objc private func continuePressed() {
        let vc = ConfirmOrderViewController(nibName: "ConfirmOrderViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    @objc private func goBack() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)   // Pop to previous VC (Cart)
        } else {
            self.dismiss(animated: true)            // In case it was presented
        }
    }
}
