# Unizo iOS — Source Root

> For full project documentation, see the [root README](../README.md).

This directory contains all Swift source files for the Unizo iOS app.

## Quick Reference

| Group | What lives here |
|---|---|
| `Controllers/` | UIKit view controllers — one file per screen |
| `Managers/` | App-wide singletons: `AuthManager`, `NotificationManager`, `ChatManager`, `OrderRealtimeManager`, `AppLanguageManager`, `FeedbackManager` |
| `Data/Models/` | `Codable` DTOs and UI models |
| `Data/Repositories/` | Supabase query layer — one repository per domain |
| `Mappers/` | DTO → UIModel converters |
| `Core/` | Shared constants, extensions, utilities |
