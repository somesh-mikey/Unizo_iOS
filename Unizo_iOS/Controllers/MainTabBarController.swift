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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height: CGFloat = 70  // pill height
        var tabFrame = tabBar.frame
        tabFrame.size.height = height
        tabFrame.origin.y = view.frame.height - height - 20  // floating 20pts above bottom
        tabBar.frame = tabFrame
    }
    
    private func setupTabs() {
        
        let homeVC = UINavigationController(rootViewController: LandingScreenViewController())
        let chatVC = UINavigationController(rootViewController: ChatViewController())
        let accountVC = UINavigationController(rootViewController: AccountViewController())
        //        let postVC = UINavigationController(rootViewController: PostViewController())
        //        let listingsVC = UINavigationController(rootViewController: ListingsViewController())
        //        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        
        homeVC.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(systemName: "house.fill"), tag: 0)
        
        chatVC.tabBarItem = UITabBarItem(title: "Chat",
                                         image: UIImage(systemName: "message.fill"), tag: 1)
        accountVC.tabBarItem = UITabBarItem(
            title: "Account",
            image: UIImage(systemName: "person.crop.circle.fill"),
            tag: 4
        )
        
        
        //        postVC.tabBarItem = UITabBarItem(title: "Post",
        //                                         image: UIImage(systemName: "square.and.arrow.up.fill"), tag: 2)
        //
        //        listingsVC.tabBarItem = UITabBarItem(title: "Listings",
        //                                             image: UIImage(systemName: "rectangle.grid.2x2.fill"), tag: 3)
        //
        //        profileVC.tabBarItem = UITabBarItem(title: "Profile",
        //                                            image: UIImage(systemName: "person.crop.circle.fill"), tag: 4)
        
        viewControllers = [homeVC, chatVC,accountVC ]
    }
    
    private func styleTabBar() {
        
        // 1. Make system appearance fully transparent
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // 2. Remove ALL built-in backgrounds
        tabBar.backgroundColor = .clear
        tabBar.isTranslucent = true
        tabBar.clipsToBounds = false
        
        // 🚨 Critical — remove _UITabBarBackgroundView
        if let bgView = tabBar.subviews.first(where: { String(describing: type(of: $0)) == "_UITabBarBackgroundView" }) {
            bgView.removeFromSuperview()
        }
        
        // 3. Keep tab bar fully transparent (no custom pill)
        tabBar.backgroundImage = UIImage()
        
        // 4. Colors
        tabBar.tintColor = UIColor(red: 0.239, green: 0.486, blue: 0.596, alpha: 1)
        tabBar.unselectedItemTintColor = .darkGray
    }
}

