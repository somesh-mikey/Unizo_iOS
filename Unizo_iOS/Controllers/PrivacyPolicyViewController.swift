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
        title = "Privacy Policy".localized
        setupTextView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        // Required to restore floating pill shape when returning
        if let mainTab = tabBarController as? MainTabBarController {
        }
        self.tabBarController?.tabBar.isHidden = false
    }


    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.textAlignment = .left
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.backgroundColor = .clear
        
        // Apply rich text formatting
        textView.attributedText = getFormattedPrivacyText()
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func getFormattedPrivacyText() -> NSAttributedString {
        let content = """
        1. Introduction
        Welcome to Unizo ("we," "our," or "us"). Unizo is a peer-to-peer campus marketplace application designed exclusively for students to buy, sell, and exchange items within their college or university community.
        This Privacy Policy explains how Unizo collects, uses, stores, shares, and protects your personal information when you access or use the Unizo mobile application ("App") on any supported device. It also describes your rights in relation to your data and how you can exercise them.
        By downloading, registering for, or using the App, you acknowledge that you have read and understood this Privacy Policy and agree to the collection and use of your information as described herein. If you do not agree, please discontinue use of the App immediately.
        This Policy applies to:

        All registered users of the Unizo App
        Guest users browsing the App without a registered account
        Sellers listing items on the platform
        Buyers placing orders or initiating deals
        Any person who communicates through the in-app chat system


        2. Information We Collect
        2.1 Personal Identification Data
        When you create an account or update your profile, we collect:

        Full name
        Campus email address and/or personal email address
        Profile photograph
        College or university name, year of study, and academic program
        Mobile number, when provided voluntarily for communication or order coordination
        Student roll number or unique institutional identifier, where required for campus verification

        2.2 Account and Authentication Data

        Username and encrypted password credentials
        Authentication tokens and session identifiers
        Date and time of account creation
        Login history, active session logs, and device association records
        Account status (active, suspended, deactivated)

        2.3 Listing and Product Data
        When you post an item for sale or browse listings, we collect:

        Item title, description, condition, pricing, and category
        Product photographs uploaded by the seller
        Listing status (available, sold, removed)
        Edit history of listings
        Search queries you enter, filters you apply, and categories you browse
        Items you add to your Wishlist or mark as favourites

        2.4 Transaction and Order Data
        When a deal is initiated or an order is placed, we collect:

        Order details including item, quantity, agreed price, and negotiation records
        Delivery hotspot or meetup address selected by the buyer
        Order status history (pending, confirmed, accepted, rejected, completed)
        Deal request records between buyers and sellers
        Payment method selected (currently cash-based; no financial credentials are stored)
        Order ratings and feedback submitted post-transaction

        2.5 Communication Data

        In-app chat messages exchanged between buyers and sellers
        Message timestamps and read receipts
        Chat notifications and in-app notification records
        All messages are encrypted in transit and at rest using industry-standard encryption protocols

        2.6 Device and Technical Data
        We automatically collect the following when you use the App:

        Device type, manufacturer, and model
        Operating system version and App version
        Internet connection type (Wi-Fi, cellular) and connectivity status
        IP address and approximate network location
        Unique device identifiers
        App crash logs, error reports, and performance diagnostics
        Session duration, feature usage patterns, and interaction logs

        2.7 Location Data

        Approximate campus-level location, used solely to suggest safe meetup hotspots for order delivery
        Precise GPS location is only accessed if you explicitly grant location permission
        Location data is never shared with third parties for advertising or profiling purposes

        2.8 User-Generated Content

        Reviews and ratings submitted for sellers or transactions
        Feedback responses submitted through the in-app feedback system
        Reports submitted against listings or users for policy violations
        Any content you voluntarily submit through Contact Us or support channels


        3. How We Collect Your Information
        We collect information through the following methods:
        Directly from you, when you:

        Register and set up your account
        Create, edit, or delete a listing
        Place or manage an order
        Send or receive messages in the chat system
        Submit feedback, ratings, or support requests
        Update your profile or preferences

        Automatically, as you use the App:

        Through device sensors, connectivity monitoring, and usage tracking
        Through crash reporting and performance monitoring tools
        Through in-app analytics that record feature interactions in anonymised form

        From third-party services, including:

        Supabase (our backend infrastructure provider) for authentication and data storage
        Affiliated campus databases, strictly for student identity verification, subject to your explicit consent
        Push notification delivery services for order and chat alerts


        4. How We Use Your Information
        4.1 Core Platform Functionality

        To create, verify, and maintain your Unizo account
        To allow you to post, browse, search, and manage item listings
        To facilitate order placement, deal negotiation, and transaction completion
        To enable real-time in-app messaging between buyers and sellers
        To send push notifications for orders, chats, deal requests, and platform updates
        To display seller profiles, product details, and order histories accurately

        4.2 Personalisation and Discovery

        To surface relevant product recommendations based on your browsing and purchase history
        To suggest campus events relevant to your interests
        To remember your language preferences, saved addresses, and Wishlist items
        To improve search relevance and category filtering accuracy

        4.3 Safety, Trust, and Security

        To verify that all users are genuine members of a registered campus community
        To detect, investigate, and prevent fraudulent listings, suspicious transactions, or account misuse
        To enforce our prohibited items policy and community guidelines
        To process user reports and take action against policy-violating content or accounts
        To protect the integrity of the peer-to-peer marketplace ecosystem

        4.4 Platform Improvement

        To analyse aggregated, anonymised usage data to identify bugs and improve features
        To conduct internal research on user behaviour to guide product decisions
        To test new features, UI improvements, and accessibility enhancements
        To monitor app performance, reduce crash rates, and improve reliability

        4.5 Legal and Compliance Obligations

        To comply with applicable laws, regulations, and institutional requirements
        To respond to lawful requests from campus authorities, law enforcement, or regulatory bodies
        To resolve disputes between users, including order disagreements or conduct complaints
        To maintain audit trails for accountability and platform governance


        5. Data Sharing and Disclosure
        5.1 With Other Unizo Users
        The following limited information may be visible to other users in connection with your listings and transactions:

        First name and profile photograph
        Campus or institution name
        Verified student badge status
        Seller rating and review history
        Active listings and their details

        The following information is never displayed to other users:

        Email address
        Mobile number
        Academic roll number or institutional ID
        Full delivery address beyond the selected hotspot
        Payment or financial information

        5.2 With Our Service Providers
        We work with trusted third-party providers who process data strictly on our behalf, under confidentiality agreements, and only for the purposes described in this Policy. These include:

        Supabase — backend database, authentication, and real-time data infrastructure
        Cloud storage providers — for secure hosting of product images and user media
        Push notification services — for delivery of order and chat notifications
        Analytics providers — for anonymised, aggregated usage analysis

        No service provider is permitted to use your data for their own purposes or share it with any other party.
        5.3 With Campus Authorities
        Where required for student verification or in response to a formal institutional request, limited account data may be shared with authorised campus administrators or IT personnel. You will be informed of such disclosures wherever legally permissible.
        5.4 With Legal Authorities
        We will disclose personal data to law enforcement, regulatory agencies, or judicial bodies only when:

        Required to do so by applicable law or valid legal process
        Necessary to protect the safety of our users or the public
        Required to enforce our Terms of Service or protect Unizo's legal rights

        We will notify affected users of such disclosures unless prohibited by law.
        5.5 What We Will Never Do

        We will never sell, rent, lease, or trade your personal data to any third party
        We will never share your data with advertisers or marketing networks
        We will never use your chat messages for advertising profiling
        We will never disclose your precise location to other users


        6. Data Retention
        We retain your personal data for as long as your account remains active or as necessary to provide our services. Specifically:

        Account data is retained for the duration of your active account
        Listing and transaction data is retained for 24 months after the transaction date for dispute resolution purposes
        Chat messages are retained for 12 months from the date of the conversation
        Crash logs and diagnostics are retained for 90 days
        Anonymised analytics data may be retained indefinitely as it cannot be linked back to any individual

        Upon account deletion, we will permanently delete or anonymise your personal data within 30 days, except where retention is required by law or for legitimate dispute resolution.

        7. Data Security
        We take the security of your personal information seriously. Our security measures include:

        Encryption in transit — all data transmitted between the App and our servers is encrypted using TLS
        Encryption at rest — sensitive data stored on our servers is encrypted using industry-standard algorithms
        Message encryption — all in-app chat messages are encrypted end-to-end
        Authentication security — passwords are hashed and never stored in plain text; session tokens are short-lived and rotated regularly
        Access controls — internal access to user data is restricted to authorised personnel only, on a need-to-know basis
        Vulnerability monitoring — we conduct regular security assessments and apply patches promptly

        Despite these measures, no system is completely immune to security risks. We encourage you to use a strong, unique password and to report any suspicious activity to us immediately.

        8. Your Rights and Choices
        As a Unizo user, you have the following rights regarding your personal data:

        Access — You may request a copy of the personal data we hold about you
        Correction — You may update or correct inaccurate information directly in the App or by contacting us
        Deletion — You may request deletion of your account and associated personal data
        Portability — You may request your data in a structured, machine-readable format
        Restriction — You may request that we limit processing of your data in certain circumstances
        Objection — You may object to processing of your data for analytics or personalisation purposes
        Withdraw Consent — Where processing is based on consent (e.g. location access), you may withdraw it at any time through your device settings

        To exercise any of these rights, please contact us using the details in Section 11. We will respond to all verified requests within 30 days.

        9. Children's Privacy
        Unizo is intended for use by college and university students and is not directed at children under the age of 13. We do not knowingly collect personal information from anyone under 13. If we become aware that a user under 13 has provided us with personal data, we will delete it immediately. If you believe a minor has registered on our platform, please contact us promptly.

        10. Changes to This Privacy Policy
        We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or platform features. When we do:

        The "Last Updated" date at the top of this Policy will be revised
        For material changes, we will notify you through a prominent in-app notice or push notification
        Continued use of the App after the effective date of any update constitutes your acceptance of the revised Policy

        We encourage you to review this Policy periodically to stay informed about how we protect your information.

        11. Contact Us
        If you have any questions, concerns, or requests regarding this Privacy Policy or your personal data, please reach out to us:
        Unizo Support Team
        📧 Email: privacy@unizo.app
        📍 Platform: Use the "Contact Us" section within the Unizo App
        🕐 Response time: Within 2–3 business days
        """

        let attributedString = NSMutableAttributedString(string: content)
        let fullRange = NSRange(location: 0, length: attributedString.length)
        
        // Base attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: fullRange)
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
//done