import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let splashVC = SplashViewController()
        window.rootViewController = splashVC   // no navigation controller here

        self.window = window
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()

        // Full-screen "No Internet" overlay – blocks the entire app when offline.
        // Replaces the old pill banner. The overlay has a "Try Again" button.
        NetworkMonitor.shared.startObserving { [weak self] isConnected in
            DispatchQueue.main.async { [weak self] in
                guard let window = self?.window else { return }
                if !isConnected {
                    NoInternetOverlayView.show(in: window)
                } else {
                    NoInternetOverlayView.hide(from: window)
                }
            }
        }
    }
//new comment
    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Validate session before starting realtime listeners.
        // If the token is expired or corrupt, skip listeners — the auth flow
        // (SplashViewController → WelcomeViewController) handles re-authentication.
        Task {
            let sessionValid = await AuthManager.shared.validateSession()
            if sessionValid {
                await NotificationManager.shared.startListening()
                await ChatManager.shared.startListening()
            } else {
                print("⚠️ [SceneDelegate] Session invalid — skipping notification/chat listeners")
            }
        }

        // TASK-02: Show feedback popup if enough time has passed
        if AuthManager.shared.isLoggedInSync {
            if let topVC = self.window?.rootViewController {
                FeedbackManager.shared.presentFeedbackIfNeeded(from: topVC)
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
