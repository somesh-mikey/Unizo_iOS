Unizo iOS Application - Updated README
Overview
Unizo is a fully native iOS application built with UIKit that provides a comprehensive campus marketplace experience. The app enables users to browse products, manage orders, handle authentication, post items as sellers, interact via real-time chat, and receive push notifications. Built with modern Swift concurrency patterns and integrated with Supabase backend.
Total Swift Files: 90
Platform: iOS 15+
Architecture: MVC with Repository Pattern
Backend: Supabase (PostgreSQL + Real-time API + Storage)

Features
Marketplace & Browsing

Product listings with images, prices, ratings, and seller information
Product detail screen with descriptions, features, specifications
Paginated fetching (20 items per page)
Full-text search across titles, descriptions, and categories
Category filtering: Electronics, Clothing, Furniture, Sports, Hostel Essentials
Popular products sorting (by views_count)
Negotiable products filter
SF Symbol-based rating icons and modern UI sections

Seller Features

Post Item: Create listings with image upload, negotiable toggle, full product details
Seller Dashboard: View pending orders and sales statistics
Confirm Order: Accept/reject incoming buyer orders with notifications
Listings Management: View, edit, and delete active listings
Product status tracking: Available, Pending, Sold
Inventory management with quantity tracking

Buyer Features

Shopping Cart: Add/remove items with quantity management and validation
Cart Validation: Checks product availability before checkout
Wishlist: Save products for later
Orders: Place orders with address selection and payment method
My Orders: View order history with status tracking
Order Details: Full timeline with status progression

Order System

Order Status Flow: Pending → Confirmed → Shipped → Delivered
Order Timeline: Visual timeline of order status changes
Multi-seller Orders: Automatic grouping by seller
Seller Notifications: Automatic notifications when buyers place orders
Declined Flow: Separate UI for rejected orders

Real-time Notifications

Real-time notifications using Supabase Realtime V2
Notification Types: NewOrder, OrderAccepted, OrderRejected, OrderShipped, OrderDelivered
In-app toast banner with auto-dismiss
Deeplink navigation to relevant order screens
Unread count tracking with live badge updates
Notification center with read/unread status

Chat System

Tabbed interface showing seller and buyer conversations
Private messaging between buyer and seller
Unread message badges
Role indicators distinguishing seller vs buyer

Authentication

Supabase Auth with email/password
Modal-based login/signup flows
Session management with JWT tokens
Password reset functionality
Account management and preferences

Events

Browse campus events with scrollable cards
Event details: image, venue, date, price, action buttons
Custom EventCardView component

Additional Features

Address management (add, edit, save multiple addresses)
User profile editing
Settings: Change password, notification preferences, language
Privacy Policy and Terms & Conditions screens
Blocked users filtering


Technology Stack

Language: Swift 5+
UI Framework: UIKit (Hybrid: Programmatic + XIB)
Concurrency: Swift async/await
Layout: Auto Layout
Icons: SF Symbols
Backend: Supabase

PostgreSQL database
Real-time subscriptions
Authentication
Storage (image uploads)


Package Manager: Swift Package Manager (SPM)


Project Structure
Unizo_iOS/
├── Controllers/              # 48 ViewControllers
│   ├── Authentication/       # Login, Signup, Password Reset
│   ├── Marketplace/          # Landing, ItemDetails, Category, Search
│   ├── Seller/               # PostItem, Dashboard, Listings, ConfirmOrder
│   ├── Buyer/                # Cart, Payments, Orders, Wishlist
│   ├── Chat/                 # ChatVC, ChatDetailVC
│   ├── Notifications/        # NotificationsVC
│   ├── Account/              # Profile, Settings, Address
│   └── Navigation/           # MainTabBarController
│
├── Data/
│   ├── Models/               # DTOs and UI Models
│   │   ├── ProductDTO.swift
│   │   ├── OrderDTO.swift
│   │   ├── OrderItemDTO.swift
│   │   ├── NotificationDTO.swift
│   │   ├── UserDTO.swift
│   │   ├── AddressDTO.swift
│   │   └── CartItem.swift
│   ├── Repositories/         # 7 Data Access Repositories
│   │   ├── ProductRepository.swift
│   │   ├── OrderRepository.swift
│   │   ├── NotificationRepository.swift
│   │   ├── AddressRepository.swift
│   │   ├── UserRepository.swift
│   │   ├── WishlistRepository.swift
│   │   └── EventRepository.swift
│   └── Store/                # In-memory stores
│
├── Managers/                 # 4 Singleton Managers
│   ├── AuthManager.swift
│   ├── CartManager.swift
│   ├── NotificationManager.swift
│   └── SupabaseManager.swift
│
├── Mappers/
│   ├── ProductMapper.swift
│   └── AddressMapper.swift
│
├── Core/
│   ├── Session/
│   ├── Storage/
│   ├── Constants/
│   ├── Extensions/
│   └── Utilities/
│
├── Views/                    # 40+ Custom Views
│   ├── XIB Files/
│   ├── InAppNotificationBanner.swift
│   ├── EventCardView.swift
│   ├── OrderCardView.swift
│   ├── ProductCell.swift
│   ├── ListingCell.swift
│   └── ...
│
├── Assets.xcassets/          # Images, Colors, App Icons
└── Supporting Files/

Architecture
Design Patterns

Singleton: Managers (AuthManager, CartManager, NotificationManager, SupabaseManager)
Repository Pattern: All data access through dedicated repositories
DTO Pattern: Data transfer between backend and UI layers
Mapper Pattern: Converting DTOs to UI models
MVC: View Controllers + Models + Custom Views
Delegate Pattern: For navigation and notifications
Observer Pattern: NotificationCenter for cross-app communication
Async/Await: Modern Swift concurrency throughout

Data Layer
DTO (Backend) → Mapper → UIModel (Frontend)
     ↑
Repository (Supabase Client)
Key Managers

AuthManager: Session state, user ID, sign-in/out
CartManager: Shopping cart state, validation, totals
NotificationManager: Real-time subscriptions, unread counts, banners
SupabaseManager: Centralized Supabase client


Installation and Setup

Clone the repository:

bash   git clone https://github.com/<your-username>/Unizo_iOS.git
   cd Unizo_iOS

Open the project:

bash   open Unizo_iOS.xcodeproj

Configure Supabase (if needed):

Update Supabase URL and anon key in configuration
Ensure database tables and RLS policies are set up


Build and run:

Select iOS Simulator (iPhone 14 or later recommended)
Build and run (⌘+R)



Dependencies are managed via SPM and will resolve automatically.

Database Schema
Core Tables

users: User profiles (name, email, phone, preferences)
products: Product listings with inventory
orders: Order records with status tracking
order_items: Line items for each order
addresses: User delivery addresses
notifications: Order notifications with deeplink payloads
banners: Marketing banners
wishlist: User's saved products

Key Relationships

Orders → OrderItems → Products
Orders → Addresses
Products → Users (seller)
Notifications → Orders


Security

Supabase RLS: Row Level Security filters data per user
Event Key Idempotency: Prevents duplicate notifications
Status Validation: Products must be active with quantity > 0
Authentication Checks: All mutations require auth verification
Blocked Users: Local filtering of products from blocked sellers


Code Style

UIKit-first design with strict separation of concerns
Reusable components for cards, buttons, labels
Consistent navigation logic for push vs modal screens
Tab bar visibility handled explicitly per screen
Debug logging throughout for development
Consistent error handling with custom error types


Recent Updates

Fixed Listing screen navigation and UI
Added Chat tab with real-time messaging
Added Deal flow features
Implemented order timeline with 3 states
Added seller accept/reject notification flow
Fixed banner auto-scroll with manual scroll support
Added gender picker in profile
Cart delete button functionality
Notification unread dot repositioning


Future Enhancements

Push notifications via APNs
Real-time chat with WebSockets
Advanced product filtering and sorting
Payment gateway integration
Image gallery for products
In-app reviews and ratings
Seller verification system


Contributing

Fork the repository
Create a feature branch:

bash   git checkout -b feature/my-feature

Commit your changes and create a pull request


License
This project is released under the MIT License.

Statistics

Total Swift Files: 90
View Controllers: 48
Repositories: 7
Data Models: 14+ DTOs/Models
Managers: 4 Singleton Managers
Custom Views: 40+ UIView Components
Lines of Code: ~15,000+
