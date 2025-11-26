//
//  MainTabBarController.swift
//  Unizo_iOS
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Floating tab bar with pill shape
        let height: CGFloat = 70
        var frame = tabBar.frame
        frame.size.height = height
        frame.origin.y = view.frame.height - height - 20
        tabBar.frame = frame
    }

    // MARK: - Setup Tabs
    private func setupTabs() {

        let homeVC      = UINavigationController(rootViewController: LandingScreenViewController())
        let chatVC      = UINavigationController(rootViewController: ChatViewController())
        let postVC      = UINavigationController(rootViewController: PostItemViewController())
        let listingsVC  = UINavigationController(rootViewController: ListingsViewController())
        let accountVC   = UINavigationController(rootViewController: AccountViewController())

        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )

        chatVC.tabBarItem = UITabBarItem(
            title: "Chat",
            image: UIImage(systemName: "bubble.left.and.bubble.right.fill"),
            tag: 1
        )

        postVC.tabBarItem = UITabBarItem(
            title: "Post",
            image: UIImage(systemName: "square.and.arrow.up.fill"),
            tag: 2
        )

        listingsVC.tabBarItem = UITabBarItem(
            title: "Listings",
            image: UIImage(systemName: "list.bullet.rectangle.portrait"),
            tag: 3
        )

        accountVC.tabBarItem = UITabBarItem(
            title: "Account",
            image: UIImage(systemName: "person.crop.circle.fill"),
            tag: 4
        )

        // Order exactly as Figma screenshot
        viewControllers = [
            homeVC,
            chatVC,
            postVC,
            listingsVC,
            accountVC
        ]
    }

    // MARK: - Style Floating Tab Bar
    private func styleTabBar() {

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        tabBar.backgroundColor = .clear
        tabBar.isTranslucent = true
        tabBar.clipsToBounds = false

        // Remove system background view
        if let bg = tabBar.subviews.first(where: {
            String(describing: type(of: $0)) == "_UITabBarBackgroundView"
        }) {
            bg.removeFromSuperview()
        }

        // Tab item colors
        tabBar.tintColor = UIColor(red: 0.10, green: 0.45, blue: 0.72, alpha: 1)   // active blue
        tabBar.unselectedItemTintColor = .darkGray
    }
}
