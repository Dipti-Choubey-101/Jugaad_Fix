<div align="center">

# 🔧 Jugaad Fix

### *Roz ke problems, desi style ke solutions*

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

*A community-powered Indian life hacks app — 125+ desi solutions for everyday problems, all in Hinglish!*

</div>

---

## 🇮🇳 About

**Jugaad Fix** is a traditional Indian life hacks app that crowdsources desi solutions for everyday problems. From power cuts to monsoon season, kitchen jugaads to exam tips — if there's a problem, there's a jugaad for it!

The app features a community submission system where users can share their own jugaads, upvote the ones that work, and rate them with stars. Jugaads get a **✅ Verified** badge after 5 community upvotes — so only real, tested hacks make it to the top.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 Smart Search | Semantic keyword search with Hinglish support |
| 📦 25 Categories | Power cut, Kitchen, Travel, Money, Health, Exam & more |
| ⭐ Star Ratings | 1-5 star ratings synced to Firestore |
| ✅ Verified System | Community upvote-based verification |
| ✍️ Submit Jugaad | Users can contribute their own hacks |
| 🗑️ Owner Delete | Only the submitter can delete their jugaad |
| 🔖 Bookmarks | Save favourite jugaads offline |
| 🔔 Daily Notifications | One jugaad every morning at 9 AM IST |
| 🌙 Dark & Light Mode | Saffron Indian theme in both modes |
| 🔐 Firebase Auth | Secure email/password authentication |
| ☁️ Cloud Sync | Firestore sync for likes, bookmarks & submissions |
| 📱 Offline First | Works without internet via local storage |

---

## 🛠️ Tech Stack
```
Flutter 3.x          →  Mobile framework
Dart                 →  Programming language
Firebase Auth        →  Authentication
Cloud Firestore      →  Real-time database
SharedPreferences    →  Offline storage
Local Notifications  →  Daily jugaad at 9 AM
Google Fonts         →  Baloo Bhai 2 + Poppins
share_plus           →  Share jugaads
```

---

## 📂 Project Structure
```
jugaad_fix/
├── lib/
│   ├── main.dart                      # App root, routing, themes
│   ├── data/
│   │   └── sample_data.dart           # 125 jugaads + 25 categories
│   ├── models/
│   │   └── jugaad_model.dart          # Data model
│   ├── screens/
│   │   ├── splash_screen.dart         # Indian themed splash
│   │   ├── login_screen.dart          # Auth screen
│   │   ├── home_screen.dart           # Main feed
│   │   ├── explore_screen.dart        # Category explorer
│   │   ├── bookmarks_screen.dart      # Saved jugaads
│   │   ├── detail_screen.dart         # Detail + ratings
│   │   └── submit_screen.dart         # Community submission
│   ├── services/
│   │   ├── storage_service.dart       # Local storage
│   │   ├── firestore_service.dart     # Cloud operations
│   │   └── notification_service.dart  # Notifications
│   └── widgets/
│       └── jugaad_card.dart           # Card component
└── assets/
    └── images/
        ├── splash.png
        └── app_icon.png
```

---

## 📊 App Stats
```
125+  Jugaads
 25   Categories  
  4   Bottom tabs — Home, Explore, Saved, Profile
  1   Submit tab — community contributions
```

---

## 🔐 Security Notice

The following files are excluded from this repository for security:
```
android/app/google-services.json   →  Firebase config
lib/firebase_options.dart          →  Firebase keys  
android/key.properties             →  Keystore credentials
android/app/*.jks                  →  Signing keystore
```

---

## 🗺️ Roadmap
```
✅  Core jugaad feed with search and filters
✅  Firebase authentication
✅  Community submissions with verification
✅  Star ratings via Firestore
✅  Daily notifications
✅  Dark and light theme
⬜  Admin moderation panel
⬜  Google Sign In
⬜  Share jugaad as image card
⬜  Comments on jugaads
```

---

## ⚖️ Copyright
```
Copyright © 2026 Dipti Choubey. All Rights Reserved.

This project and its source code are the intellectual property of Dipti Choubey.
Unauthorized copying, modification, distribution or use of this code
is strictly prohibited without explicit written permission from the author.

Shared for portfolio and educational purposes only.
```

---

<div align="center">

**Dipti Choubey**
B.Tech — Computer Science and Business Systems

</div>
