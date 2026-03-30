# Unizo iOS

A native iOS marketplace app where users can buy and sell second-hand items and discover local events.

Built with UIKit + Supabase, targeting iOS 15+.

---

## Tech Stack

| Concern | Technology |
|---|---|
| Platform | iOS 15+ |
| Language | Swift 5.5+ |
| UI | UIKit (Programmatic + XIB) |
| Backend | Supabase (PostgreSQL + Realtime + Storage) |
| Auth | Supabase Auth (JWT) |
| Architecture | MVC + Repository Pattern |
| SPM Packages | [supabase-swift](https://github.com/supabase-community/supabase-swift) |

---

## Getting Started

### Prerequisites

- Xcode 15 or later
- iOS 15+ simulator or device
- A Supabase project (free tier works)

### Setup

1. Clone the repo and open the project:

   ```bash
   git clone <repo-url>
   open Unizo_iOS.xcodeproj
   ```

2. Set your Supabase credentials in `Unizo_iOS/Managers/SupabaseManager.swift`:

   ```swift
   let supabaseURL = URL(string: "https://<your-project>.supabase.co")!
   let supabaseKey = "<your-anon-key>"
   ```

3. Run the SQL migration in `Database/chat_tables.sql` against your Supabase project
   to create the required tables.

4. Build and run in Xcode (`⌘R`).

> **Note:** Row-Level Security (RLS) is enabled on all tables. Ensure your Supabase
> policies match the query patterns in the repository layer before testing in production.

---

## Project Structure

```
Unizo_iOS/
├── AppDelegate.swift
├── SceneDelegate.swift
│
├── Controllers/           # UIKit view controllers (one per screen)
│   ├── Auth/              # Welcome, SignUp, Login, Reset/ChangePassword
│   ├── Marketplace/       # Landing, Category, Search, ItemDetails
│   ├── Seller/            # Post, Edit, Listings, SellerDashboard
│   ├── Orders/            # Confirm, OrderDetails, MyOrders, Rating
│   ├── Chat/              # ChatList, ChatDetail, banners
│   └── Account/           # Profile, Settings, Address, Wishlist, Notifications
│
├── Managers/              # Singletons for cross-cutting concerns
│   ├── SupabaseManager    # Shared SupabaseClient instance
│   ├── AuthManager        # Session state, password ops, account deletion
│   ├── NotificationManager # Realtime notification subscription + badge count
│   ├── ChatManager        # Realtime conversation/message subscription
│   ├── OrderRealtimeManager # Per-order status subscriptions
│   ├── AppLanguageManager # Runtime language switching
│   └── FeedbackManager    # Timed in-app feedback prompts
│
├── Data/
│   ├── Models/            # Codable DTOs matching Supabase table columns
│   │   ├── *DTO.swift     # Raw API shapes (never passed to UI directly)
│   │   └── *UIModel.swift # Transformed models safe for display
│   ├── Repositories/      # One repository per domain (Product, Order, Chat…)
│   └── Store/             # ProductStore — in-memory cache across screens
│
├── Mappers/               # DTO → UIModel transformations
├── Core/
│   ├── AppConstants.swift
│   ├── Constants/Spacing.swift     # 8pt-grid layout constants
│   ├── Extensions/
│   │   ├── UIColor+Brand.swift     # Brand + semantic color palette
│   │   └── UIView+Animations.swift # Reusable animation helpers
│   ├── Session/Session.swift       # Lightweight current-user state
│   ├── Storage/BlockedUsersStore.swift
│   └── Utilities/
│       ├── HapticFeedback.swift
│       ├── MessageEncryptionService.swift  # AES-GCM chat encryption
│       ├── NetworkMonitor.swift
│       └── NoInternetBannerView.swift
│
└── Database/
    └── chat_tables.sql    # Reference schema for Supabase migrations
```

---

## Architecture

### MVC + Repository

View controllers own UI state and user interaction. Business logic and data access live in repositories; controllers are kept thin by injecting repository dependencies. There is no separate ViewModel layer — controllers call repositories directly and update views on `@MainActor`.

### Data Flow

```
ViewController
    └─ calls ──▶  Repository  (async/throws)
                    └─ queries ──▶  Supabase (PostgreSQL / Realtime / Storage)
                    └─ maps ─────▶  DTO  ──▶  UIModel  (via Mapper)
    └─ renders ──▶  UIKit views
```

### Realtime

Three singletons manage Supabase Realtime V2 channels:

| Manager | Scope | Post login / logout |
|---|---|---|
| `NotificationManager` | All notifications for current user | `startListening()` / `stopListening()` |
| `ChatManager` | All conversations for current user | `startListening()` / `stopListening()` |
| `OrderRealtimeManager` | Per-order channels, on-demand | `subscribeToOrder()` / `unsubscribeAll()` |

Modules communicate via `NotificationCenter` names defined next to each manager (e.g. `.orderStatusDidChange`, `.newNotificationReceived`).

---

## Key Features

### Authentication
- Email/password sign-in and sign-up via Supabase Auth
- Password reset by email link and in-session password change
- Guest browsing with a login prompt on protected actions

### Marketplace
- Paginated product feed (20/page), excluding sold items and the user's own listings
- Popularity feed sorted by `views_count`
- Full-text search across title, description, and category
- Category-filtered browsing
- Negotiable price indicator and deal-request flow

### Seller
- Multi-image listing creation (up to 5 images via Supabase Storage)
- Listing management — edit title, price, quantity, images
- Seller dashboard with order counts and revenue metrics
- Order accept/reject flow with push notification to buyer

### Buyer
- Wishlist with realtime add/remove
- Address management (CRUD, default flag)
- Checkout flow: address selection → payment method → confirm
- Order timeline with live status updates via Realtime
- Handoff code verification for in-person delivery

### Chat
- Buyer ↔ Seller conversations with realtime messages
- AES-GCM encryption for message content (`MessageEncryptionService`)
- Unread badge tracked across the session

### Notifications
- Realtime in-app notification banners
- Deep-link payload for direct navigation (e.g. `confirm_order_seller`)
- Unread count persisted across sessions

### Localization
- Runtime language switching without restart
- Supported: English (default), Hindi, Spanish, French, German

---

## Data Layer Reference

### DTOs vs UIModels

| Suffix | Purpose | Where used |
|---|---|---|
| `DTO` | Mirrors the Supabase table schema exactly. `Codable`. | Repositories only |
| `InsertDTO` | Subset of fields for INSERT operations | Repositories only |
| `UpdateDTO` | Subset of fields for UPDATE operations | Repositories only |
| `UIModel` | Presentation-ready shape (formatted strings, computed props) | Controllers and cells |

### Core Tables (Supabase)

| Table | Description |
|---|---|
| `users` | Profile data; `average_rating` / `total_ratings` are denormalised and updated by a DB trigger |
| `products` | Listings; `status` is `available` or `sold`; `is_active = false` soft-deletes |
| `orders` | Buyer orders; status flow: `pending → confirmed → shipped → delivered` |
| `order_items` | Line items per order |
| `addresses` | User delivery addresses |
| `conversations` | Buyer–seller chat threads |
| `messages` | Individual chat messages |
| `notifications` | In-app notification log with `deeplink_payload` JSON |
| `order_ratings` | Post-delivery ratings; triggers update `users.average_rating` |

---

## Design Tokens

Shared design constants live in `Core/` and should be used instead of hardcoded values:

- **Colors** — `UIColor.brandPrimary`, `UIColor.statusSuccess`, `UIColor.cardBackground`, etc. → `UIColor+Brand.swift`
- **Spacing** — `Spacing.lg`, `Spacing.cardPadding`, `Spacing.buttonHeight`, etc. → `Constants/Spacing.swift`
- **Animations** — `view.animateBounce()`, `view.shake()`, `view.startShimmer()`, etc. → `UIView+Animations.swift`
- **Haptics** — `HapticFeedback.placeOrder()`, `HapticFeedback.errorOccurred()`, etc. → `HapticFeedback.swift`

---

## Security Notes

- Supabase RLS policies enforce user-scoped access on every sensitive table
- The anon key is safe to ship in the client; never use the `service_role` key
- Chat messages are encrypted end-to-end with AES-GCM before being stored
- Password reset flows through Supabase's email link mechanism (no custom token handling)
- Deep-link payloads from push notifications are validated before navigation

---

## Screen Flow

```
Splash
 └─ Welcome ──▶ SignUp / Login / Guest
                  └─ Landing (Marketplace)
                       ├─ Search / Category ──▶ ItemDetails ──▶ Checkout ──▶ OrderPlaced
                       ├─ Wishlist
                       ├─ Chat ──▶ ChatDetail
                       ├─ Notifications
                       └─ Account ──▶ Profile / Settings / Address / Orders
                                          └─ OrderDetails (realtime status)
                                          └─ Seller Dashboard ──▶ Listings / PostItem
```

---

Last updated: March 2026
