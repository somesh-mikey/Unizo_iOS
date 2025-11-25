//
//  MainTabBarController.swift
//  Unizo_iOS
//
//  Created by Soham Bhattacharya on 21/11/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
    }

    private func setupTabs() {

        let homeVC = UINavigationController(rootViewController: LandingScreenViewController())
        let chatVC = UINavigationController(rootViewController: ChatViewController())
//        let postVC = UINavigationController(rootViewController: PostViewController())
//        let listingsVC = UINavigationController(rootViewController: ListingsViewController())
//        let profileVC = UINavigationController(rootViewController: ProfileViewController())

        homeVC.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(systemName: "house.fill"), tag: 0)

        chatVC.tabBarItem = UITabBarItem(title: "Chat",
                                         image: UIImage(systemName: "message.fill"), tag: 1)

//        postVC.tabBarItem = UITabBarItem(title: "Post",
//                                         image: UIImage(systemName: "square.and.arrow.up.fill"), tag: 2)
//
//        listingsVC.tabBarItem = UITabBarItem(title: "Listings",
//                                             image: UIImage(systemName: "rectangle.grid.2x2.fill"), tag: 3)
//
//        profileVC.tabBarItem = UITabBarItem(title: "Profile",
//                                            image: UIImage(systemName: "person.crop.circle.fill"), tag: 4)

        viewControllers = [homeVC, chatVC]
    }

    private func styleTabBar() {
        tabBar.tintColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        tabBar.unselectedItemTintColor = .darkGray
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowRadius = 5
    }
}
