# Unizo iOS

Unizo is a native iOS marketplace app built with UIKit and Supabase for authentication, data storage, real-time updates, and media handling.

## Project Snapshot

| Metric | Value |
|---|---|
| Platform | iOS 15+ |
| Language | Swift 5+ |
| Architecture | MVC + Repository Pattern |
| UI | UIKit (Programmatic + XIB) |
| Backend | Supabase (PostgreSQL + Realtime + Storage) |
| Swift Files | ~90 |

## Architecture

### Core Layers

- **Controllers**: Screen-level UI and interaction handling
- **Views (XIB + UIKit Views)**: Layout and reusable UI
- **Managers**: Centralized domain services (auth, chat, notifications, realtime, language)
- **Data/Models**: DTOs and feature data contracts
- **Data/Repositories**: Data access and business operations
- **Mappers**: DTO to UI model transformation
- **Core**: Shared constants, enums, extensions, utilities, error types

### Main Design Patterns

- MVC for screen composition and navigation
- Repository Pattern for data access abstraction
- DTO ↔ UI mapping via dedicated mappers
- Singleton managers for session/realtime cross-cutting concerns
- Delegate usage for callback-driven feature flows

## High-Level Structure

```text
Unizo_iOS/
├── Controllers/
│   ├── Authentication/
│   ├── Marketplace/
│   ├── Seller/
│   ├── Buyer/
│   ├── Chat/
│   ├── Account/
│   └── UIExtensions/
├── Views/
├── Managers/
├── Data/
│   ├── Models/
│   └── Repositories/
├── Mappers/
├── Core/
└── Assets.xcassets/
```

## Key Managers

- `SupabaseManager.swift`: Shared Supabase client bootstrap
- `AuthManager.swift`: Session state, password reset/change, sign-out
- `NotificationManager.swift`: Realtime notification subscriptions + unread state
- `ChatManager.swift`: Conversation/message realtime lifecycle + unread state
- `OrderRealtimeManager.swift`: Order-level status subscriptions
- `AppLanguageManager.swift`: Runtime language switching and localization lookup

## Feature Coverage

### Authentication

- Email/password auth with Supabase Auth
- JWT session lifecycle through centralized auth manager
- Password reset via email link flow

### Marketplace

- Product browsing with pagination (20 items/page)
- Search across title/description/category
- Category filtering and popularity sorting by view count
- Product details with ratings, metadata, and negotiable indicators

### Seller

- Post listings with multi-image upload (up to 5)
- Seller dashboard metrics and pending orders
- Listing management (view/edit/delete)
- Order confirmation flow (accept/reject)

### Buyer

- Cart and checkout flow
- Address management and selection
- Wishlist support
- Orders list and order detail timeline

### Realtime Chat & Notifications

- Supabase Realtime V2-based listeners
- Buyer/seller conversation segmentation
- Unread badge tracking
- In-app notification banners and deep-link payload navigation

### Localization

- Runtime language switching with persistence
- Supported: English, Hindi, Spanish, French, German

## Data Layer Overview

### Representative Models

- `UserDTO`, `ProductDTO`, `OrderDTO`, `AddressDTO`
- `MessageDTO`, `ConversationDTO`, `NotificationDTO`
- Feature UI models such as `BannerUIModel`

### Representative Repositories

- `OrderRepository`: create/fetch/update order lifecycle
- `ChatRepository`: conversations, messages, send operations
- `AddressRepository`: address CRUD
- `WishlistRepository`: add/remove/fetch
- `SellerDashboardRepository`: profile/products/orders/statistics
- `NotificationRepository`: fetch/create/mark-as-read

## Database Schema (Supabase)

Core domain tables:

- `users`
- `products`
- `orders`
- `order_items`
- `addresses`
- `conversations`
- `messages`
- `notifications`

Reference SQL scripts:

- `Database/chat_tables.sql`

## Setup

### Prerequisites

- Xcode 15+
- iOS Deployment Target 15.0+
- Swift 5.5+

### Open and Run

```bash
open Unizo_iOS.xcodeproj
```

Build and run from Xcode using an iOS 15+ simulator/device.

### Dependencies

- Supabase Swift SDK via Swift Package Manager
- UIKit, Foundation, PhotosUI (plus Combine where reactive state is used)

### Supabase Configuration

Supabase client is initialized in:

- `Unizo_iOS/Managers/SupabaseManager.swift`

Keep credentials and keys scoped appropriately for environment/security requirements.

## Security Notes

- JWT-backed authentication session handling
- User-scoped querying with Supabase Row-Level Security
- Password reset via Supabase email workflow
- Realtime payload deep-links should be validated before navigation

## Screen Flow (Summary)

- Welcome → Authentication
- Landing/Marketplace → Product Details
- Search/Category → Browse
- Seller Post Item → Product Posted
- Cart → Checkout → Order Placed
- My Orders → Order Details timeline
- Chat → Buyer/Seller conversations
- Settings → Profile, Address, Language, Security

---

Last updated: February 2026