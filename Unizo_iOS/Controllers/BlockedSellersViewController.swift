import UIKit
import FirebaseFirestore

final class BlockedSellersViewController: UIViewController {

    private struct BlockedSellerItem {
        let id: String
        let name: String
        let email: String?
    }

    private let db = Firestore.firestore()
    private var blockedSellers: [BlockedSellerItem] = []

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "You have not blocked any sellers yet.".localized
        label.isHidden = true
        return label
    }()

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
        title = "Blocked Sellers".localized
        navigationItem.largeTitleDisplayMode = .never

        setupTableView()
        setupEmptyState()

        Task {
            await loadBlockedSellers()
        }
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BlockedSellerCell")
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    @objc private func handleRefresh() {
        Task {
            await loadBlockedSellers()
            await MainActor.run {
                self.refreshControl.endRefreshing()
            }
        }
    }

    @MainActor
    private func loadBlockedSellers() async {
        guard let userId = await AuthManager.shared.currentUserId else {
            print("❌ [Moderation] Blocked sellers load failed: no authenticated user")
            blockedSellers = []
            tableView.reloadData()
            updateEmptyState()
            return
        }

        print("🛡️ [Moderation] Loading blocked sellers for userId=\(userId)")

        do {
            let snapshot = try await db.collection("blocked_users")
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()

            let backendIds = Set(snapshot.documents.compactMap { doc in
                doc.data()["blocked_user_id"] as? String
            })
            let mergedIds = backendIds.union(BlockedUsersStore.all())
            BlockedUsersStore.replaceAll(with: mergedIds)

            if mergedIds.isEmpty {
                blockedSellers = []
                tableView.reloadData()
                updateEmptyState()
                print("ℹ️ [Moderation] Blocked sellers list is empty")
                return
            }

            let profileMap = try await fetchSellerProfiles(ids: Array(mergedIds))
            let items: [BlockedSellerItem] = mergedIds
                .map { sellerId -> BlockedSellerItem in
                    let user = profileMap[sellerId]
                    let name = user?.displayName ?? String(format: "Seller %@".localized, String(sellerId.prefix(6)))
                    return BlockedSellerItem(id: sellerId, name: name, email: user?.email)
                }
                .sorted(by: { (lhs: BlockedSellerItem, rhs: BlockedSellerItem) -> Bool in
                    lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                })

            blockedSellers = items
            tableView.reloadData()
            updateEmptyState()

            print("✅ [Moderation] Loaded blocked sellers count=\(blockedSellers.count)")
        } catch {
            print("❌ [Moderation] Failed to load blocked sellers: \(error)")
            blockedSellers = []
            tableView.reloadData()
            updateEmptyState()
            showAlert(title: "Error".localized, message: "Couldn't load blocked sellers. Please try again.".localized)
        }
    }

    private func fetchSellerProfiles(ids: [String]) async throws -> [String: UserDTO] {
        guard !ids.isEmpty else { return [:] }

        var usersById: [String: UserDTO] = [:]
        for chunk in ids.chunked(into: 10) {
            let snapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()

            for doc in snapshot.documents {
                if let user = try? doc.data(as: UserDTO.self) {
                    usersById[doc.documentID] = user
                }
            }
        }

        return usersById
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !blockedSellers.isEmpty
        tableView.isHidden = blockedSellers.isEmpty
    }

    private func confirmUnblock(seller: BlockedSellerItem) {
        let alert = UIAlertController(
            title: "Unblock Seller".localized,
            message: String(format: "You will start seeing listings from %@ again.".localized, seller.name),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "Unblock".localized, style: .destructive) { [weak self] _ in
            self?.performUnblock(seller: seller)
        })

        present(alert, animated: true)
    }

    private func performUnblock(seller: BlockedSellerItem) {
        Task {
            guard let userId = await AuthManager.shared.currentUserId else {
                print("❌ [Moderation] performUnblock aborted: no authenticated user")
                await MainActor.run {
                    self.showAlert(title: "Error".localized, message: "Please sign in to continue.".localized)
                }
                return
            }

            let documentId = "\(userId)_\(seller.id)"
            print("🛡️ [Moderation] performUnblock started userId=\(userId), sellerId=\(seller.id)")

            do {
                try await db.collection("blocked_users").document(documentId).delete()
                BlockedUsersStore.remove(seller.id)

                await MainActor.run {
                    self.blockedSellers.removeAll { $0.id == seller.id }
                    self.tableView.reloadData()
                    self.updateEmptyState()

                    NotificationCenter.default.post(
                        name: .blockedUsersDidChange,
                        object: nil,
                        userInfo: ["refreshData": true, "unblockedSellerId": seller.id]
                    )
                }

                print("✅ [Moderation] performUnblock success userId=\(userId), sellerId=\(seller.id)")
            } catch {
                print("❌ [Moderation] performUnblock failed sellerId=\(seller.id), error=\(error)")
                await MainActor.run {
                    self.showAlert(title: "Error".localized, message: "Couldn't unblock seller right now. Please try again.".localized)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(alert, animated: true)
    }
}

extension BlockedSellersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedSellers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedSellerCell", for: indexPath)
        let seller = blockedSellers[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = seller.name
        content.secondaryText = seller.email ?? seller.id
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        cell.selectionStyle = .none
        cell.backgroundColor = .white

        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let seller = blockedSellers[indexPath.row]

        let unblockAction = UIContextualAction(style: .destructive, title: "Unblock".localized) { [weak self] _, _, completion in
            self?.confirmUnblock(seller: seller)
            completion(true)
        }

        unblockAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [unblockAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let seller = blockedSellers[indexPath.row]
        confirmUnblock(seller: seller)
    }
}
