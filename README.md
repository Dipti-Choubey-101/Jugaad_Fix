# 🔧 Jugaad Fix

> **Roz ke problems, desi style ke solutions**

Jugaad Fix is a community-powered Indian life hacks app. It brings together 125+ desi solutions for everyday problems — from power cuts to monsoon season, kitchen jugaads to exam tips — all in Hinglish!

---

## 📱 App Preview

| Splash Screen | Home Screen | Explore Screen |
|---|---|---|
| Indian themed splash | 125+ jugaads feed | 25 category grid |

| Detail Screen | Profile Screen | Submit Screen |
|---|---|---|
| Star ratings + upvote | Liked, Saved, Posted | Community submissions |

---

## ✨ Features

- 🔍 **Smart Search** — Semantic keyword search with category suggestions
- 📦 **25 Categories** — Power cut, Kitchen, Travel, Money, Health, Exam and more
- 🔖 **Bookmarks** — Save your favourite jugaads
- ❤️ **Upvotes** — Like jugaads that actually work
- ⭐ **Star Ratings** — Rate jugaads 1-5 stars
- ✍️ **Community Submissions** — Share your own jugaad
- ✅ **Verified Badge** — Jugaads verified after 5 community upvotes
- ⏳ **Pending Badge** — New jugaads shown as pending review
- 🗑️ **Owner Delete** — Only the submitter can delete their own jugaad
- 🔔 **Daily Notifications** — One jugaad every morning at 9 AM IST
- 🌙 **Dark & Light Mode** — Saffron Indian theme in both modes
- 🔐 **Firebase Auth** — Secure email/password login and signup
- ☁️ **Cloud Sync** — Likes, bookmarks and submissions synced via Firestore
- 📱 **Offline First** — Works without internet using local storage

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| Flutter 3.x | Mobile app framework |
| Dart | Programming language |
| Firebase Authentication | User login and signup |
| Cloud Firestore | Real-time cloud database |
| SharedPreferences | Offline local storage |
| flutter_local_notifications | Daily scheduled notifications |
| Google Fonts | Baloo Bhai 2 and Poppins |
| share_plus | Share jugaads with friends |
| flutter_staggered_animations | List animations |

---

## 📂 Project Structure
```
jugaad_fix/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   └── sample_data.dart
│   ├── models/
│   │   └── jugaad_model.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── explore_screen.dart
│   │   ├── bookmarks_screen.dart
│   │   ├── detail_screen.dart
│   │   └── submit_screen.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   ├── firestore_service.dart
│   │   └── notification_service.dart
│   └── widgets/
│       └── jugaad_card.dart
└── assets/
    └── images/
        ├── splash.png
        └── app_icon.png
```

---

## 🔐 Security

The following files are excluded from this repository:

| File | Reason |
|---|---|
| `google-services.json` | Firebase project config |
| `firebase_options.dart` | Firebase API keys |
| `key.properties` | Keystore passwords |
| `*.jks` | APK signing keystore |

---

## 📊 Stats

| | |
|---|---|
| Total Jugaads | 125+ |
| Categories | 25 |
| Language | Hinglish |
| Min Android SDK | 21 |
| Architecture | Offline-first + Firestore sync |

---

## 🗺️ Roadmap

- [ ] Admin moderation panel
- [ ] Google Sign In
- [ ] Share jugaad as image card
- [ ] Comments on jugaads
- [ ] Play Store release

---

## ⚖️ Copyright
```
Copyright © 2026 Dipti Choubey. All Rights Reserved.

This project and its source code are the intellectual property of Dipti Choubey.
Unauthorized copying, modification, distribution or use of this code
is strictly prohibited without explicit written permission from the author.

Shared for educational and portfolio purposes only.
```

---

<div align="center">

**Dipti Choubey**

B.Tech — Computer Science and Business Systems

</div>
