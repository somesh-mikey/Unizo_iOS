//
//  PrivacyPolicyViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 12/11/25.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Privacy Policy"
        setupTextView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        // Required to restore floating pill shape when returning
        if let mainTab = tabBarController as? MainTabBarController {
        }
    }


    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.textAlignment = .left
        textView.backgroundColor = .clear
        
        // Apply rich text formatting
        textView.attributedText = getFormattedPrivacyText()
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }

    private func getFormattedPrivacyText() -> NSAttributedString {
        let content = """
        1. Introduction and Scope
        This Privacy Policy describes how Student Marketplace App collects, uses, discloses, and protects your personal information. Our priority is to ensure a transparent and secure experience for every student. This Policy applies to all users who access or use the App and covers information submitted during registration, while browsing, communicating, making transactions, and post-transaction activities within the App.

        2. Types of Information Collected
        A. Personal Identification Data
        • Full name, campus email address, profile photo, institution affiliation (college/university, year of study, program).
        • Mobile number, when provided for communication or verification.
        • Unique student identifiers or roll numbers to validate campus access.
        
        B. Account and Usage Data
        • Username, encrypted login credentials, session details.
        • Date of registration, account activity, and usage logs.

        C. Listing and Transactional Data
        • Item listings: descriptions, photos, pricing, and status updates (available/sold/given away).
        • Search queries, browsing history, applied filters, and favorites.
        • Messages and chat records between users.

        D. Device and Technical Data
        • Device type, model, operating system, app version.
        • IP address, device identifiers, crash logs, and performance diagnostics.
        • Location data (campus-based GPS, when enabled for safe meetup recommendations).

        E. Cookies and Analytics
        • Usage of cookies/local storage to maintain user sessions, remember preferences, manage login states, and gather analytics for improving services.
        • Information collected via third-party analytics tools (de-identified for analysis).

        3. Methods of Data Collection
        • Data provided directly by you during registration, profile updates, listing items, messaging, or interacting with notifications and support.
        • Data generated automatically as you use the App, including device, technical, and behavioral data.
        • Data received from affiliated campus databases for user verification (subject to explicit consent).
        • Cookies and similar technologies used for seamless login, analytics, and personalized recommendations.

        4. Use of Data
        A. Main Purposes
        • To verify user identity and restrict access strictly to genuine campus members.
        • To allow users to create, manage, and browse listings, and facilitate transactions within campus networks.
        • To enable in-app chat, communication, and safe meetup recommendations.
        • To personalize user experience, deliver AI-powered recommendations, and provide relevant category-based updates.
        • To analyze aggregated and anonymized trends for better platform performance and user safety.

        B. Safety, Security, and Compliance
        • To monitor suspicious activity, enforce prohibited item policies, and prevent fraud or misuse.
        • For required legal, regulatory, or institutional obligations, including responding to official requests from authorities.
        • To support safety initiatives, including escalation to campus authorities when necessary.

        C. Service Improvement
        • To debug, improve, and optimize platform features and user interface.
        • To solicit feedback, conduct surveys, and communicate improvements or policy changes.

        5. Sharing and Disclosure of Data
        A. With Other Users
        • Limited profile information (first name, campus, verified badge, profile image) may be displayed to other users in connection with listings and chat.
        • Detailed personal information, email address, phone number, or academic details are never disclosed to non-authorized users.

        B. With Third-Parties
        • No personal information is ever sold, rented, or shared with external advertisers or marketers.
        • Data may be shared with campus administrators, IT staff, or institutional authorities for verification or as required by regulations.
        • Third-party service providers may process data strictly for hosting, analytics, or technical support — subject to confidentiality and data security safeguards.
        • Data will be disclosed to legal authorities only in accordance with applicable law, regulation, or mandatory requests.

        C. Aggregated and Anonymized Data
        • Non-identifiable, aggregated statistics may be published for transparency and reporting (e.g., total items exchanged, sustainability impact) without revealing personal identities.
        """

        let attributedString = NSMutableAttributedString(string: content)
        let fullRange = NSRange(location: 0, length: attributedString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)

        // Bold section titles (1., 2., A., etc.)
        let boldFont = UIFont.boldSystemFont(ofSize: 16)
        let regex = try! NSRegularExpression(pattern: #"(\d+\.\s[A-Z].*|[A-Z]\.\s[A-Z].*)"#, options: [])
        let matches = regex.matches(in: content, range: fullRange)
        for match in matches {
            attributedString.addAttribute(.font, value: boldFont, range: match.range)
        }

        return attributedString
    }
}
