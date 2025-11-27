//
//  MainTabBarController.swift
//  Unizo_iOS
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
            super.viewDidLoad()
            setupTabs()
            styleTabBar()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            fixFloatingBar()   // <— Apply only here
        }

    private func fixFloatingBar() {
        DispatchQueue.main.async {
            guard !self.tabBar.isHidden else { return }

            let height: CGFloat = 70
            var frame = self.tabBar.frame
            frame.size.height = height
            frame.origin.y = self.view.frame.height - height - 20
            self.tabBar.frame = frame
        }
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

        viewControllers = [
            homeVC,
            chatVC,
            postVC,
            listingsVC,
            accountVC
        ]

        // Adjust icon + title for floating style
        for item in tabBar.items ?? [] {
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
            item.imageInsets = UIEdgeInsets(top: -4, left: 0, bottom: 4, right: 0)
        }
    }


    // MARK: - Floating Tab Bar Styling
    private func styleTabBar() {

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        tabBar.isTranslucent = true
        tabBar.clipsToBounds = false

        tabBar.tintColor = UIColor(red: 0.10, green: 0.45, blue: 0.72, alpha: 1)   // Active blue
        tabBar.unselectedItemTintColor = .darkGray

        // Remove default background view
        if let bg = tabBar.subviews.first(where: {
            String(describing: type(of: $0)) == "_UITabBarBackgroundView"
        }) {
            bg.removeFromSuperview()
        }
    }


    // MARK: - Public API for Hiding / Showing (for child VCs)
    func hideFloatingTabBar() {
        tabBar.isHidden = true
    }


    func showFloatingTabBar() {
        tabBar.isHidden = false
        fixFloatingBar()
    }
    }
