//
//  TermsAndConditionsViewController.swift
//  Unizo_iOS
//
//  Created by Nishtha on 12/11/25.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {

    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // ✅ Navigation Bar Title
        self.title = "Terms and Conditions"

        setupTextView()
        setupConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        // If using a custom floating tab bar in MainTabBarController
        if let tab = tabBarController as? MainTabBarController {
        }
        self.tabBarController?.tabBar.isHidden = false
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.backgroundColor = .white
        textView.attributedText = getFormattedText()
        view.addSubview(textView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func getFormattedText() -> NSAttributedString {
        let fullText = """
        1. Acceptance of Terms
        By downloading, installing, registering, accessing, or using the Student Marketplace App, you agree to be bound by these Terms and Conditions and all applicable laws, regulations, and policies. If you do not accept or agree with these Terms, you may not access or use the App. Your continued use of the App following the publication of updated Terms constitutes your acceptance of those changes.

        2. Description of Service
        The App is a secure, hyper-local online marketplace designed exclusively for current college and university students to buy, sell, exchange, or give away pre-owned goods and campus-specific items within their verified institution ecosystem. The App provides a platform to facilitate communication and transactions between students; it does not directly participate in or guarantee user transactions and does not own or hold any inventory.

        3. Eligibility
        • You must be at least 18 years old and an active student currently enrolled in an accredited college or university in India.
        • Registration requires a valid, official institutional email address (e.g., ending with .edu.in or recognized campus domain), which will be verified by the App.
        • You agree to provide accurate, current, and complete information during registration and to update such information as necessary to keep it accurate.
        • The App reserves the right to suspend or terminate the account of any user found ineligible or providing false or misleading information at any time without notice.

        4. Account Security and Responsibility
        • You are solely responsible for maintaining the security and confidentiality of your account credentials.
        • All activity and transactions occurring under your account will be deemed to have been authorized by you.
        • You must notify us immediately of any unauthorized access to your account or breach of security.
        • The App shall not be liable for any loss or damage arising from your failure to comply with these security obligations.

        5. Permitted and Prohibited Use of Platform
        • The App must not be used for any unlawful purpose or in a manner that violates any local, state, or national laws, regulations, or institutional policies.
        • Only pre-owned goods or services appropriate to student communities — such as textbooks, electronics, furniture, bicycles, clothing, and hostel items — may be listed.
        • You agree not to upload, post, or share any prohibited items which include, but are not limited to: weapons, stolen property, illicit drugs, counterfeit goods, hazardous or unsafe items, personal identification documents, restricted electronics, or anything else that is prohibited under law or institutional policy.
        • Activities such as money laundering, promoting scams or ponzi schemes, pyramid or multi-level marketing, or selling for non-student third-parties are strictly forbidden.
        • Campus-specific listings must remain exclusive to users of the corresponding campus unless authorized for cross-campus access by the administration.

        6. Listing and Content Policies
        • All product listings must contain truthful, accurate, and complete information, including clear product photographs, honest descriptions, actual condition, original price (where applicable), and asking price.
        • You agree not to misrepresent the nature, condition, ownership, or availability of your items.
        • No listing may contain false, misleading, or inappropriate information, spam, malware, offensive material, third-party intellectual property, or external promotional content.
        • The App reserves the right to review, modify, or remove any listing, photo, or post at its sole discretion for violations of these Terms, policies, or for protecting user safety.

        7. User Conduct and Community Standards
        • All users must act with honesty, courtesy, and respect at all times.
        • You may not harass, threaten, defame, impersonate, or abuse any user or staff.
        • Unsolicited promotions, repeated spam, posting irrelevant messages, or attempting to direct users off-platform is prohibited.
        • Any attempts at fraud, scam, or misrepresentation – including misusing the chat system for inappropriate messaging – may result in immediate suspension or report to your institution or authorities.
        • Any abusive, discriminatory, or illegal behavior will not be tolerated.

        8. Transactions, Safety, and Payments
        • All buying, selling, and exchanges must be initiated and negotiated through the in-app chat and must remain within your campus network.
        • The App recommends meeting in safe, publicly visible locations as approved by your institution (such as hostels, libraries, or student centers). The App does not take responsibility for personal safety, lost items, or disputes but may cooperate with campus security or authorities in the event of a complaint or incident.
        • Payments and exchanges are the sole responsibility of the users involved. The App does not handle escrow, direct payments, or guarantees.
        • Listings that are marked as sold must be promptly updated by the seller.

        9. Fees, Promotions, and Premium Services
        • Standard use of the App, including basic listings and messaging, is free of charge.
        • Premium listing, promotional features, priority search, and additional services may incur extra fees as detailed within the App.
        • The App reserves the right to introduce, modify, or withdraw fees for premium features with prior notice to users.
        • All fees charged are final, non-refundable, and inclusive of applicable taxes, unless specified otherwise or required by law.

        10. Violations, Suspension, and Termination
        • The App reserves the right, without prior notice, to suspend, terminate, or restrict your account or access to the App if you violate any Terms, engage in fraudulent, illegal, or unsafe activities, or act in any manner that harms other users or the reputation of the community.
        • Suspension, deletion, or restriction of accounts may be temporary or permanent depending on the severity and frequency of infractions.

        11. Reporting, Takedown, and Disputes
        • Users may report inappropriate, fraudulent, or suspicious listings and behavior via in-app reporting tools or the provided contact email.
        • The App will review all complaints and may take down violating listings or suspend accounts as necessary.
        • The App is not a party to user transactions or disputes and will not mediate financial or product-related disagreements; however, reported safety issues will be escalated as per institutional or legal protocols.

        12. Intellectual Property
        • All content uploaded to the App (photos, descriptions, chat, reviews) remains the property of the original user. By posting content, you grant the App a perpetual, worldwide, royalty-free license to use, reproduce, display, adapt, and distribute such content for operation, promotion, or improvement of the App.
        • You must not post copyrighted, trademarked, or proprietary material without authorization.

        13. Platform Changes and Service Availability
        • The App reserves the right to modify, discontinue, or suspend any aspect or feature of the App at any time with or without notice.
        • While best efforts are made to maintain platform uptime and protection against data loss, the App cannot guarantee continuous, error-free service and will not be liable for any downtime, loss of data, or interruption.

        14. Limitation of Liability and Disclaimer
        • The App is an intermediary platform and does not control, verify, or warrant user listings, products, or transactions. All risks arising from the use of the App or interactions with other users are borne solely by you.
        • Under no circumstances shall the App or its operators be liable for any indirect, incidental, consequential, or punitive damages arising from your use of or inability to use the App, whether based on warranty, contract, tort, or any other legal theory.
        • All listings and user-provided data are the user’s responsibility; the App makes no guarantees regarding availability, accuracy, completeness, or legality.

        15. Amendments to Terms
        • The App may modify, update, or replace these Terms at any time. Users will be notified of material changes via in-app communication or registered email. Continued use after changes implies acceptance.

        16. Governing Law and Jurisdiction
        • These Terms are governed by the laws of India and the jurisdiction corresponding to your registered institution’s location. Any disputes will be subject to the exclusive jurisdiction of the courts nearest your institution.

        17. Contact and Grievance Redressal
        • For grievances, complaints, or queries regarding these Terms, please contact:
        ◦ Email: [unizo.grievances@gmail.com]
        ◦ Designated Grievance Officer: [Soham Bhattacharya]

        18. Severability and Waiver
        • If any provision of these Terms is found invalid or unenforceable, it will not affect the validity of the remaining provisions. No waiver of any term shall be deemed a further or continuing waiver of such term or any other.
        """

        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = NSRange(location: 0, length: attributedString.length)
        
        // Base attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: fullRange)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)

        // Make section numbers bold
        let boldTitles = [
            "1. Acceptance of Terms", "2. Description of Service", "3. Eligibility",
            "4. Account Security and Responsibility", "5. Permitted and Prohibited Use of Platform",
            "6. Listing and Content Policies", "7. User Conduct and Community Standards",
            "8. Transactions, Safety, and Payments", "9. Fees, Promotions, and Premium Services",
            "10. Violations, Suspension, and Termination", "11. Reporting, Takedown, and Disputes",
            "12. Intellectual Property", "13. Platform Changes and Service Availability",
            "14. Limitation of Liability and Disclaimer", "15. Amendments to Terms",
            "16. Governing Law and Jurisdiction", "17. Contact and Grievance Redressal",
            "18. Severability and Waiver"
        ]
        
        for title in boldTitles {
            if let range = attributedString.string.range(of: title) {
                let nsRange = NSRange(range, in: attributedString.string)
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: nsRange)
            }
        }

        return attributedString
    }
}
