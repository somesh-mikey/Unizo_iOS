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
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
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
        At Unizo, we value your privacy and are committed to protecting your personal information with high standards of security and transparency.

        Last Updated: April 9, 2025
        Version: 1.0
        Applies to: Unizo iOS App

        This Privacy Policy describes how Unizo ("we", "us", or "our") collects, uses, and shares information about you when you use our mobile application and related services. By using Unizo, you agree to the practices described in this policy.

        1. Information We Collect

        1.1 Information You Provide to Us
        When you register and use Unizo, we collect information you provide directly, including:
        - Account Information: Your name, email address, phone number, and password when you create an account.
        - Profile Information: Your profile photo, display name, bio, and any other details you choose to add.
        - Listing Information: Product details, descriptions, prices, images, and other content you submit when creating a listing.
        - Transaction Information: Details of purchases, sales, payment method, shipping addresses, and order history.
        - Communications: Messages exchanged with other users through in-app chat, and any feedback or support requests you submit.

        1.2 Information We Collect Automatically
        When you use our app, we automatically collect certain information, including:
        - Device Information: Device model, operating system, unique device identifiers, and mobile network information.
        - Usage Data: Pages you visit, features you use, search queries, time spent in the app, and interactions with listings.
        - Location Data: Approximate location based on IP address, and precise location if you grant permission.
        - Log Data: IP address, access times, app crashes, and diagnostic data.

        1.3 Information from Third Parties
        If you sign in using a third-party service (for example, Google Sign-In), we may receive basic profile information such as your name and email address as permitted by that service. We may also receive information from payment processors to verify transactions.

        2. How We Use Your Data
        We use the information we collect to:
        - Provide and improve our services: Create and manage your account, process orders, facilitate transactions, and improve app performance.
        - Personalize your experience: Recommend products, show relevant listings, and tailor features to your preferences.
        - Communicate with you: Send order confirmations, account alerts, push notifications, and promotional messages (where permitted).
        - Ensure safety and security: Detect and prevent fraud, abuse, and unauthorized access.
        - Comply with legal obligations: Meet applicable laws, regulations, and lawful requests.
        - Analytics and research: Understand usage patterns, improve features, and fix bugs.

        Note: We do not sell your personal data to third-party advertisers. Any sharing is limited to what is necessary to operate and improve our services.

        3. Cookies and Tracking Technologies
        We and our third-party partners use cookies, SDKs, and similar technologies to collect usage data and improve our service, including:
        - Analytics tools (for example, Firebase Analytics)
        - Authentication tokens to keep you signed in securely
        - Crash reporting tools (for example, Firebase Crashlytics)

        You can control tracking preferences through your device settings. Disabling certain technologies may affect app functionality.

        4. Sharing Your Data
        We do not sell, rent, or trade your personal information. We may share data only in the following cases:
        - With other users: Limited profile/listing information needed to facilitate transactions.
        - With service providers: Trusted vendors (for example, Firebase, payment partners) that process data on our behalf under confidentiality obligations.
        - For legal reasons: If required by law, court order, or to protect rights, property, or safety.
        - Business transfers: In a merger, acquisition, or sale of assets, with advance notice where required.

        5. Links to Other Sites
        Our app may include links to third-party sites or services not operated by Unizo. We strongly encourage you to review their privacy policies. We are not responsible for their content, privacy practices, or terms.

        6. Security
        We use technical and organizational measures to protect your personal information, including:
        - Encryption in transit (HTTPS/TLS) and at rest
        - Firebase Security Rules for controlled database access
        - Secure authentication (including OAuth-supported sign-in flows)
        - Access controls and periodic security reviews

        No method of transmission or storage is completely secure. Please use a strong password and keep credentials confidential.

        7. Your Choices and Opt-Out
        You can control your data and preferences in several ways:
        - Update account/profile information in app settings
        - Enable/disable push notifications in device settings
        - Unsubscribe from marketing emails via unsubscribe links
        - Revoke location permissions in iOS Settings
        - Request account deletion by contacting support

        8. Children's Privacy
        Unizo is not intended for individuals under 18. We do not knowingly collect personal information from children. If we learn that such data was collected, we will delete it as quickly as possible.

        9. Data Retention
        We retain personal information for as long as needed to provide services and satisfy legal obligations. In general:
        - Account data is retained while your account is active and for a reasonable period afterward where required.
        - Transaction records may be retained for up to 7 years for accounting and legal compliance.
        - Chat messages may be retained while accounts remain active.
        - Analytics data may be retained in aggregated or anonymized form for product improvement.

        Upon account deletion, we delete or anonymize personal data unless retention is required by law.

        10. Your Rights
        Depending on your location and applicable law, you may have rights such as:
        - Access
        - Rectification
        - Erasure
        - Restriction
        - Data Portability
        - Objection to specific processing (including direct marketing)

        To exercise your rights, contact us at the address below. We respond to verified requests within applicable legal timelines.

        11. Changes to This Policy
        We may update this Privacy Policy from time to time. For significant changes, we will:
        - Update the Last Updated date
        - Provide in-app notice or push notification
        - Obtain consent where required by law

        Continued use of Unizo after updates become effective constitutes acceptance of the revised policy.

        12. Contact Us
        If you have questions, concerns, or requests regarding this Privacy Policy, contact:

        Unizo Privacy Team
        Email: unizoapp00@gmail.com
        App: Unizo - Buy and Sell Marketplace
        Platform: iOS

        We are committed to resolving privacy-related queries promptly.
        """

        let attributedString = NSMutableAttributedString(string: content)
        let fullRange = NSRange(location: 0, length: attributedString.length)
        
        // Base attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: fullRange)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)

        // Bold section titles (supports 1. and 1.1 style headings)
        let boldFont = UIFont.boldSystemFont(ofSize: 16)
        let regex = try! NSRegularExpression(pattern: #"(\d+(?:\.\d+)*\.\s?[A-Z].*|\d+\.\s[A-Z].*)"#, options: [])
        let matches = regex.matches(in: content, range: fullRange)
        for match in matches {
            attributedString.addAttribute(.font, value: boldFont, range: match.range)
        }

        return attributedString
    }
}
//done