# Unizo iOS Application

Unizo is a fully native iOS application built using UIKit. The app provides a complete campus marketplace experience, allowing users to browse products, manage orders, book events, chat with sellers, and handle authentication flows. The project is a hybrid of programmatic UIKit and XIB-based UI, optimized for modularity, scalability, and clean code organization.

## Features

### Marketplace
- Product listings with images, prices, and ratings.
- Product detail screen with descriptions, features, specifications, and seller information.
- Add to Cart, Buy Now, and Wishlist integration.
- SF Symbol-based rating icons and modern UI sections.

### Orders
- Order Details screen with timeline, item cards, price summary, delivery information, and action buttons.
- Order Placed confirmation screen.
- Navigation logic that maintains correct tab bar and navigation bar visibility.

### Events
- Browse Events section with scrollable event cards.
- Custom EventCardView built programmatically.
- Event details include image, venue, date, price, and action buttons.

### Authentication
- Login Modal with a bottom-sheet design.
- Password visibility toggle using SF Symbols.
- Forgot Password modal presented over current context.
- Successful login updates the root controller and opens the Landing screen with the tab bar.

### Navigation
- Custom navigation architecture ensuring consistent behavior across:
  - Tab Bar transitions
  - Modal presentations
  - Full-screen flows
  - XIB + programmatic screens
- MainTabBarController as the app’s primary navigation root.

### Cart and Wishlist
- Add-to-cart confirmation alerts.
- Wishlist screen for saving preferred items.
- Cart management with checkout flow.

## Technology Stack

- Swift 5+
- UIKit (Hybrid: Programmatic + XIB)
- Auto Layout
- SF Symbols
- MVC-based structure with modular controllers
- Minimal dependencies and strong focus on native frameworks

## Project Structure

Unizo_iOS
│
├── Models
├── Views
│   ├── XIB Files
│   ├── Custom UIView Components (EventCardView, SellerCard, ItemCards, etc.)
│
├── ViewControllers
│   ├── Landing
│   ├── Items
│   ├── Cart
│   ├── Orders
│   ├── Events
│   ├── Authentication
│   ├── Profile
│
├── Navigation
│   ├── MainTabBarController
│   ├── Navigation Helpers
│
├── Resources
│   ├── Assets (Images, Colors)
│   ├── App Icons
│
└── Utilities
    ├── Extensions
    ├── UI Helpers
    └── Formatting Helpers

## Installation and Setup

1. Clone the repository:
   git clone https://github.com/<your-username>/<repo-name>.git

2. Open the project:
   cd Unizo_iOS
   open Unizo_iOS.xcodeproj

3. Build and run the project in Xcode on any iOS Simulator (iPhone 14 or later recommended).

No external frameworks or package managers are required.

## Code Style and Architecture

- UIKit-first design.
- Strict separation between UI building, layout, and logic.
- Reusable components for cards, buttons, labels, and layouts.
- Consistent navigation logic for push vs modal screens.
- Tab Bar visibility is handled explicitly in each screen for consistent transitions.

## Future Enhancements

- API integration for products, authentication, and orders.
- Real-time seller chat using WebSockets or Firebase.
- Push notifications for order updates and event reminders.
- Dynamic item filtering and search.
- Payment gateway integration.

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository.
2. Create a new branch:
   git checkout -b feature/my-feature
3. Commit your changes and create a pull request.

## License

This project is released under the MIT License.
