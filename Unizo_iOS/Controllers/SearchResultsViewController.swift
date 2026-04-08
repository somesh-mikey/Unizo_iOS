import UIKit

final class SearchResultsViewController: UIViewController {

    // MARK: - Data
    private let productRepository = ProductRepository()
    private var results: [ProductUIModel] = []
    private var recentSearches: [String] = []
    private let keyword: String
    private let shouldAutoFocusSearchBar: Bool
    private var didAutoFocusSearchBar = false
    private var predictiveSuggestions: [String] = []

    // Debounce
    private var searchTask: Task<Void, Never>?
    private let debounceDelay: UInt64 = 300_000_000 // 300ms
    private var suggestionsTask: Task<Void, Never>?
    private let suggestionsDebounceDelay: UInt64 = 180_000_000 // 180ms

    private enum SearchDropdownMode {
        case hidden
        case recent
        case suggestions
    }
    private var dropdownMode: SearchDropdownMode = .hidden

    // MARK: - UI
    private let searchBar = UISearchBar()

    private let recentSearchesView = UIView()
    private let recentSearchesHeader = UIView()
    private let recentSearchesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent Searches".localized
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let clearRecentSearchesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let recentSearchesTableView = UITableView(frame: .zero, style: .plain)
    private var recentSearchesHeightConstraint: NSLayoutConstraint?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let collectionView: UICollectionView
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    // Loading indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // Empty State
    private let emptyStateLabel = UILabel()

    // MARK: - Init
    init(keyword: String, shouldAutoFocus: Bool = false) {
        self.keyword = keyword
        self.shouldAutoFocusSearchBar = shouldAutoFocus || keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        configureNavigationBar()
        setupScrollView()
        setupCollectionView()
        setupRecentSearchesView()
        setupEmptyState()
        setupLoadingIndicator()
        loadRecentSearches()
        setupKeyboardHandling()

        searchBar.text = keyword
        if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updateRecentSearchesVisibility(for: keyword)
        } else {
            fetchPredictiveSuggestionsDebounced(keyword)
            performSearchDebounced(keyword)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProductDeleted(_:)),
            name: .productDeleted,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBlockedUsersDidChange(_:)),
            name: .blockedUsersDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        (tabBarController as? MainTabBarController)?.hideFloatingTabBar()
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard shouldAutoFocusSearchBar, !didAutoFocusSearchBar else { return }
        didAutoFocusSearchBar = true

        DispatchQueue.main.async { [weak self] in
            self?.searchBar.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTask?.cancel()
        suggestionsTask?.cancel()
        navigationController?.setNavigationBarHidden(false, animated: false)
        (tabBarController as? MainTabBarController)?.showFloatingTabBar()
        tabBarController?.tabBar.isHidden = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleProductDeleted(_ notification: Notification) {
        guard let productId = notification.userInfo?["productId"] as? String else { return }
        results.removeAll { $0.id == productId }
        collectionView.reloadData()
        updateCollectionHeight()
        emptyStateLabel.isHidden = !results.isEmpty
    }

    @objc private func handleBlockedUsersDidChange(_ notification: Notification) {
        let blockedSellerId = notification.userInfo?["blockedSellerId"] as? String
        let shouldRefreshData = notification.userInfo?["refreshData"] as? Bool ?? false
        let blockedSellerSet = BlockedUsersStore.all()

        let beforeCount = results.count
        results.removeAll { product in
            guard let sellerId = product.sellerId else { return false }
            if let blockedSellerId {
                return sellerId == blockedSellerId
            }
            return blockedSellerSet.contains(sellerId)
        }

        let removedCount = max(0, beforeCount - results.count)
        if removedCount > 0 {
            print("🚫 [Moderation] Search results removed \(removedCount) blocked-seller products")
            collectionView.reloadData()
            updateCollectionHeight()
            emptyStateLabel.isHidden = !results.isEmpty
            return
        }

        if shouldRefreshData {
            let query = searchBar.text ?? keyword
            print("🔄 [Moderation] Search refreshing after unblock query='\(query)'")
            performSearchDebounced(query)
        }
    }

    // MARK: - Search (Debounced)
    private func performSearchDebounced(_ text: String) {
        searchTask?.cancel()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        updateRecentSearchesVisibility(for: trimmed)
        guard !trimmed.isEmpty else { return }

        searchTask = Task { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: self.debounceDelay)
            guard !Task.isCancelled else { return }
            await self.performSearch(trimmed)
        }
    }

    private func fetchPredictiveSuggestionsDebounced(_ text: String) {
        suggestionsTask?.cancel()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            predictiveSuggestions.removeAll()
            updateRecentSearchesVisibility(for: trimmed)
            return
        }

        suggestionsTask = Task { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: self.suggestionsDebounceDelay)
            guard !Task.isCancelled else { return }
            await self.fetchPredictiveSuggestions(trimmed)
        }
    }

    @MainActor
    private func fetchPredictiveSuggestions(_ query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            predictiveSuggestions = []
            updateRecentSearchesVisibility(for: "")
            return
        }

        do {
            let dtos = try await productRepository.searchProducts(keyword: trimmed)
            let latestInput = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard latestInput.caseInsensitiveCompare(trimmed) == .orderedSame else { return }

            predictiveSuggestions = buildPredictiveSuggestions(from: dtos, query: trimmed)
            updateRecentSearchesVisibility(for: trimmed)
        } catch {
            predictiveSuggestions = []
            updateRecentSearchesVisibility(for: trimmed)
        }
    }

    private func buildPredictiveSuggestions(from products: [ProductDTO], query: String) -> [String] {
        let normalized = query.lowercased()
        var seen = Set<String>()
        var suggestions: [String] = []

        // Prioritize matched recent searches so users can quickly re-run familiar intent.
        for recent in recentSearches {
            let trimmedRecent = recent.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedRecent.isEmpty else { continue }
            let lowerRecent = trimmedRecent.lowercased()
            guard lowerRecent.contains(normalized) else { continue }
            if seen.insert(lowerRecent).inserted {
                suggestions.append(trimmedRecent)
            }
            if suggestions.count >= 8 { return suggestions }
        }

        for product in products {
            let candidates = [
                product.title,
                product.category ?? "",
                product.condition ?? "",
                product.colour ?? "",
                product.size ?? ""
            ]

            for candidate in candidates {
                let trimmedCandidate = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedCandidate.isEmpty else { continue }
                let lowerCandidate = trimmedCandidate.lowercased()
                guard lowerCandidate.contains(normalized) else { continue }

                if seen.insert(lowerCandidate).inserted {
                    suggestions.append(trimmedCandidate)
                }

                if suggestions.count >= 8 {
                    return suggestions
                }
            }
        }

        return suggestions
    }

    @MainActor
    private func performSearch(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            results = []
            collectionView.reloadData()
            loadingIndicator.stopAnimating()
            emptyStateLabel.isHidden = true
            updateCollectionHeight()
            updateRecentSearchesVisibility(for: trimmed)
            return
        }

        loadingIndicator.startAnimating()
        emptyStateLabel.isHidden = true

        do {
            let dtos = try await productRepository.searchProducts(keyword: trimmed)
            results = dtos.map(ProductMapper.toUIModel)

            loadingIndicator.stopAnimating()
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            updateCollectionHeight()
            emptyStateLabel.isHidden = !results.isEmpty

            print("🔍 Search results:", results.count)
        } catch {
            print("❌ Search failed:", error)
            loadingIndicator.stopAnimating()
            emptyStateLabel.isHidden = false
        }
    }

    // MARK: - NavBar
    private func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonDisplayMode = .minimal

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        navigationController?.navigationBar.tintColor = .label

        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search".localized
        searchBar.delegate = self
        searchBar.text = keyword

        let titleContainer = UIView(frame: CGRect(x: 0, y: 0, width: max(220, view.bounds.width - 140), height: 44))
        searchBar.frame = titleContainer.bounds
        searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleContainer.addSubview(searchBar)
        navigationItem.titleView = titleContainer

        let wishlistItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(openWishlist)
        )
        wishlistItem.accessibilityLabel = "Wishlist".localized
        wishlistItem.accessibilityHint = "View your saved items".localized
        navigationItem.rightBarButtonItem = wishlistItem

        // Accessibility
        searchBar.accessibilityLabel = "Search products".localized
        loadingIndicator.accessibilityLabel = "Searching".localized
    }

    @objc private func openWishlist() {
        let vc = WishlistViewController()

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }

        print("✅ [SearchResults] Opened wishlist from nav bar")
    }

    // MARK: - ScrollView
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white
        scrollView.keyboardDismissMode = .interactive

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - CollectionView
    private func setupCollectionView() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(
            ProductCell.self,
            forCellWithReuseIdentifier: ProductCell.reuseIdentifier
        )

        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        collectionViewHeightConstraint =
            collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint?.isActive = true
    }

    private func updateCollectionHeight() {
        collectionViewHeightConstraint?.constant =
            collectionView.collectionViewLayout.collectionViewContentSize.height
    }

    // MARK: - Loading Indicator
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 60)
        ])
    }

    // MARK: - Empty State
    private func setupEmptyState() {
        emptyStateLabel.text = "No results found".localized
        emptyStateLabel.font = UIFont.boldSystemFont(ofSize: 20)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .darkGray
        emptyStateLabel.isHidden = true

        contentView.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60)
        ])
    }

    private func setupRecentSearchesView() {
        recentSearchesView.translatesAutoresizingMaskIntoConstraints = false
        recentSearchesView.backgroundColor = .white
        recentSearchesView.isHidden = true
        view.addSubview(recentSearchesView)

        NSLayoutConstraint.activate([
            recentSearchesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            recentSearchesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recentSearchesView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        recentSearchesHeightConstraint = recentSearchesView.heightAnchor.constraint(equalToConstant: 0)
        recentSearchesHeightConstraint?.isActive = true

        recentSearchesHeader.translatesAutoresizingMaskIntoConstraints = false
        recentSearchesHeader.backgroundColor = .white
        recentSearchesView.addSubview(recentSearchesHeader)

        recentSearchesHeader.addSubview(recentSearchesTitleLabel)
        recentSearchesHeader.addSubview(clearRecentSearchesButton)

        clearRecentSearchesButton.addTarget(self, action: #selector(clearRecentSearchesTapped), for: .touchUpInside)

        recentSearchesTableView.translatesAutoresizingMaskIntoConstraints = false
        recentSearchesTableView.dataSource = self
        recentSearchesTableView.delegate = self
        recentSearchesTableView.backgroundColor = .white
        recentSearchesTableView.separatorInset = UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 16)
        recentSearchesTableView.tableFooterView = UIView()
        recentSearchesTableView.isScrollEnabled = true
        recentSearchesTableView.showsVerticalScrollIndicator = false
        recentSearchesTableView.keyboardDismissMode = .onDrag
        recentSearchesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecentSearchCell")
        recentSearchesView.addSubview(recentSearchesTableView)

        NSLayoutConstraint.activate([
            recentSearchesHeader.topAnchor.constraint(equalTo: recentSearchesView.topAnchor),
            recentSearchesHeader.leadingAnchor.constraint(equalTo: recentSearchesView.leadingAnchor),
            recentSearchesHeader.trailingAnchor.constraint(equalTo: recentSearchesView.trailingAnchor),
            recentSearchesHeader.heightAnchor.constraint(equalToConstant: 44),

            recentSearchesTitleLabel.leadingAnchor.constraint(equalTo: recentSearchesHeader.leadingAnchor, constant: 16),
            recentSearchesTitleLabel.centerYAnchor.constraint(equalTo: recentSearchesHeader.centerYAnchor),

            clearRecentSearchesButton.trailingAnchor.constraint(equalTo: recentSearchesHeader.trailingAnchor, constant: -16),
            clearRecentSearchesButton.centerYAnchor.constraint(equalTo: recentSearchesHeader.centerYAnchor),

            recentSearchesTableView.topAnchor.constraint(equalTo: recentSearchesHeader.bottomAnchor),
            recentSearchesTableView.leadingAnchor.constraint(equalTo: recentSearchesView.leadingAnchor),
            recentSearchesTableView.trailingAnchor.constraint(equalTo: recentSearchesView.trailingAnchor),
            recentSearchesTableView.bottomAnchor.constraint(equalTo: recentSearchesView.bottomAnchor)
        ])
    }

    private func loadRecentSearches() {
        recentSearches = SearchHistoryStore.all()
        recentSearchesTableView.reloadData()
    }

    private func saveRecentSearch(_ query: String) {
        SearchHistoryStore.add(query)
        loadRecentSearches()
    }

    private func updateRecentSearchesVisibility(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShowRecents = searchBar.isFirstResponder && trimmed.isEmpty && !recentSearches.isEmpty
        let shouldShowSuggestions = searchBar.isFirstResponder && !trimmed.isEmpty && !predictiveSuggestions.isEmpty

        if shouldShowRecents {
            dropdownMode = .recent
            recentSearchesTitleLabel.text = "Recent Searches".localized
            clearRecentSearchesButton.isHidden = false
            recentSearchesTableView.reloadData()
            recentSearchesView.isHidden = false
            scrollView.isHidden = true
            emptyStateLabel.isHidden = true
            let tableAreaHeight = min(CGFloat(recentSearches.count) * 52.0, 312.0)
            recentSearchesHeightConstraint?.constant = 44 + tableAreaHeight
            return
        }

        if shouldShowSuggestions {
            dropdownMode = .suggestions
            recentSearchesTitleLabel.text = "Suggestions".localized
            clearRecentSearchesButton.isHidden = true
            recentSearchesTableView.reloadData()
            recentSearchesView.isHidden = false
            scrollView.isHidden = true
            emptyStateLabel.isHidden = true
            let tableAreaHeight = min(CGFloat(predictiveSuggestions.count) * 52.0, 312.0)
            recentSearchesHeightConstraint?.constant = 44 + tableAreaHeight
            return
        }

        dropdownMode = .hidden
        clearRecentSearchesButton.isHidden = true
        recentSearchesView.isHidden = true
        scrollView.isHidden = false
        recentSearchesHeightConstraint?.constant = 0
    }

    @objc private func clearRecentSearchesTapped() {
        SearchHistoryStore.clear()
        loadRecentSearches()
        updateRecentSearchesVisibility(for: searchBar.text ?? "")
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        applyKeyboardInset(0, notification: notification)
    }

    @objc private func handleKeyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }

        let endFrame = endFrameValue.cgRectValue
        let keyboardFrame = view.convert(endFrame, from: view.window)
        let overlap = max(0, view.bounds.maxY - keyboardFrame.minY)
        let bottomInset = max(0, overlap - view.safeAreaInsets.bottom)

        applyKeyboardInset(bottomInset, notification: notification)
    }

    private func applyKeyboardInset(_ inset: CGFloat, notification: Notification) {
        let userInfo = notification.userInfo
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curveFallback = UInt(UIView.AnimationCurve.easeInOut.rawValue)
        let curveRaw = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? curveFallback
        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)

        UIView.animate(withDuration: duration, delay: 0, options: [curve, .beginFromCurrentState]) {
            self.scrollView.contentInset.bottom = inset
            self.scrollView.verticalScrollIndicatorInsets.bottom = inset
            self.recentSearchesTableView.contentInset.bottom = inset
            self.recentSearchesTableView.verticalScrollIndicatorInsets.bottom = inset
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let currentText = searchBar.text ?? ""
        fetchPredictiveSuggestionsDebounced(currentText)
        updateRecentSearchesVisibility(for: currentText)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchPredictiveSuggestionsDebounced(searchText)
        performSearchDebounced(searchText)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let trimmed = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            saveRecentSearch(trimmed)
        }
        updateRecentSearchesVisibility(for: trimmed)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let trimmed = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchBar.resignFirstResponder()
            updateRecentSearchesVisibility(for: "")
            return
        }

        saveRecentSearch(trimmed)
        searchTask?.cancel()
        suggestionsTask?.cancel()
        predictiveSuggestions.removeAll()

        Task { [weak self] in
            await self?.performSearch(trimmed)
        }

        searchBar.resignFirstResponder()
        updateRecentSearchesVisibility(for: trimmed)
    }
}

// MARK: - CollectionView
extension SearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        results.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as! ProductCell

        cell.configure(with: results[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = floor((collectionView.bounds.width - 30) / 2)
        return CGSize(width: width, height: ProductCell.preferredHeight(for: traitCollection))
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let selected = results[indexPath.item]

        let vc = ItemDetailsViewController(
            nibName: "ItemDetailsViewController",
            bundle: nil
        )
        vc.product = selected

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dropdownMode {
        case .recent:
            return recentSearches.count
        case .suggestions:
            return predictiveSuggestions.count
        case .hidden:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath)

        let term: String
        let iconName: String
        switch dropdownMode {
        case .recent:
            term = recentSearches[indexPath.row]
            iconName = "clock"
        case .suggestions:
            term = predictiveSuggestions[indexPath.row]
            iconName = "magnifyingglass"
        case .hidden:
            term = ""
            iconName = "magnifyingglass"
        }

        var content = cell.defaultContentConfiguration()
        content.text = term
        content.textProperties.color = .label
        content.image = UIImage(systemName: iconName)
        content.imageProperties.tintColor = .secondaryLabel
        content.imageToTextPadding = 12

        cell.contentConfiguration = content
        cell.backgroundColor = .white
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let term: String
        switch dropdownMode {
        case .recent:
            term = recentSearches[indexPath.row]
        case .suggestions:
            term = predictiveSuggestions[indexPath.row]
        case .hidden:
            return
        }

        searchBar.text = term
        saveRecentSearch(term)
        updateRecentSearchesVisibility(for: term)

        searchTask?.cancel()
        suggestionsTask?.cancel()
        Task { [weak self] in
            await self?.performSearch(term)
        }

        searchBar.resignFirstResponder()
    }
}
