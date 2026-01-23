import UIKit

class SplashViewController: UIViewController {

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Background color (same as you used)
        view.backgroundColor = UIColor(red: 38/255, green: 99/255, blue: 121/255, alpha: 1)

        setupLogo()
        setupTitle()

        // 3-second delay before moving to the Welcome screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.goToWelcomeScreen()
        }
    }

    // MARK: - Logo Setup
    private func setupLogo() {
        logoImageView.image = UIImage(named: "Unizo")   // Add image in Assets
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            logoImageView.widthAnchor.constraint(equalToConstant: 230),
            logoImageView.heightAnchor.constraint(equalToConstant: 230)
        ])
    }

    // MARK: - Title Setup
    private func setupTitle() {
//        titleLabel.text = "unizo."
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Navigate to WelcomeViewController
    private func goToWelcomeScreen() {
        let vc = WelcomeViewController()

        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve  // Smooth fade animation

        present(vc, animated: true)
    }
}
