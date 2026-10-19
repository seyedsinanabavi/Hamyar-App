# Hamyar — Flutter App

**Local mutual aid mobile client** for the Hamyar platform.

Neighbors post **offers** and **requests** (power, water, medicine, tools, transport, food, and more), chat about a specific listing, rate each other, and report abuse. Trust badges and help counters make local cooperation safer.

> Hamyar is a connection layer only — not a payment intermediary or transaction guarantor.

---

## Features

- Phone OTP login (Iranian mobile format)
- Home feed with category and type filters (offer / request)
- Create listing
- Listing detail: start chat, report listing or user
- Conversations list and chat UI
- Report user from chat
- Profile: help stats, verification request, logout
- Trust badges: **Verified** (admin) / **Trusted** (behavior-based)
- Safety disclaimer on login, create listing, and profile
- RTL Persian UI and secure token storage

---

## Stack

| Layer | Choice |
|--------|--------|
| Framework | Flutter 3.x |
| State | Riverpod |
| HTTP | Dio |
| Routing | GoRouter |
| Storage | FlutterSecureStorage |
| UI | Material 3 + themed Persian typography |

---

## Project structure

```
lib/
├── main.dart
├── core/
│   ├── constants/api_constants.dart
│   ├── network/          # Dio client, ApiException
│   ├── security/         # Secure storage, sanitization
│   ├── theme/app_theme.dart
│   └── router/app_router.dart
├── features/
│   ├── auth/             # login, OTP, repository, provider
│   ├── home/             # feed, listing card, category chips
│   ├── listing/          # create, detail
│   ├── chat/             # conversations, chat screen
│   ├── profile/
│   └── report/           # report sheet + repository
└── shared/
    ├── models/           # User, Listing
    └── widgets/          # shell, trust badge, safety disclaimer
```

---

## Setup

### Requirements

- Flutter SDK `>= 3.2`
- A running **Hamyar Laravel API**

### Install and run

```bash
cd hamyar_flutter
flutter pub get
flutter run
```

### API base URL

Edit `lib/core/constants/api_constants.dart`:

```dart
// Android emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// iOS simulator
// static const String baseUrl = 'http://localhost:8000/api';

// Physical device (same Wi-Fi as your machine)
// static const String baseUrl = 'http://192.168.x.x:8000/api';
```

---

## Main screens

| Screen | Purpose |
|--------|---------|
| Login | Phone number entry |
| OTP | 6-digit verification |
| Home | Nearby listings feed |
| Create listing | New offer or request |
| Listing detail | Detail, chat, report |
| Conversations | Thread list |
| Chat | Messages + report user |
| Profile | Stats, verify request, logout |

---

## Trust UI

| Badge | Meaning |
|-------|---------|
| Verified | Identity approved by Hamyar admins |
| Trusted | Automatic: enough ratings and completed helps |

Profile shows **helps given**, **helps received**, and rating. Users can request **identity verification** from the profile (national ID not required in the app). Admins approve or reject in the backend panel.

---

## Security (client)

- Auth token stored with `FlutterSecureStorage`
- Token sent via Dio interceptor; cleared on HTTP 401
- Phone and text sanitization before requests
- Tokens and OTP codes are not logged in production builds

---

## Build release

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

Estimated install size: about **15–25 MB** depending on ABI splits and assets.

---

## Configuration checklist

- [ ] Backend API reachable from the device or emulator
- [ ] `api_constants.dart` points to the correct host
- [ ] Debug network/cleartext HTTP allowed if using `http://` locally
- [ ] Backend migrations and seeders applied (categories, etc.)

---

## Disclaimer

Hamyar does not process payments, hold funds, or guarantee delivery of goods or services. Users interact at their own judgment within their neighborhood.

---

## License

Private / project use unless otherwise specified by the owner.
