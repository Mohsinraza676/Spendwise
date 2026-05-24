# SpendWise – Personal Finance Manager

A Flutter app built during Week 5 of my Flutter Developer Internship. The focus this week was Firebase — authentication, Firestore, and real-time data sync. I took that further and built a full personal finance manager around it, because a plain login/profile screen felt like too small a canvas for everything Firebase can do.

The app lets users track their income and expenses, see a live balance, and visualize spending by category — all backed by Firebase with data that persists across sessions and devices.

---

## What It Does

After signing up, users land on a dashboard showing their current balance, recent transactions, and a quick income vs. expense summary. They can log new transactions with a category, view an analytics breakdown by pie chart, and everything stays in sync with Firestore in real time.

Log out and log back in — your data is right there.

---

## Features

**Authentication**
- Email and password signup/login via Firebase Auth
- Forgot password flow
- Form validation with error messages
- Sessions persist so users stay logged in

**Dashboard**
- Live balance calculated from all transactions
- Income and expense summary at a glance
- Toggle to hide/show your balance

**Transactions**
- Add income or expense entries with a category
- Delete transactions
- All data syncs instantly with Cloud Firestore

**Analytics**
- Pie chart breaking down spending by category
- Built with `fl_chart`

**UI**
- Material 3 with a green fintech-inspired theme
- Animated splash screen
- Clean card layouts throughout

---

## Screenshots

| Splash | 
| <img width="1080" height="2436" alt="1000127577" src="https://github.com/user-attachments/assets/d9f46677-131f-4386-86f1-acb8f10da257" />
| Login |
| <img width="1080" height="2436" alt="1000127578" src="https://github.com/user-attachments/assets/624470b5-a948-4f8d-a551-245cb2974c65" />
| Dashboard |
| <img width="1080" height="2436" alt="1000127582" src="https://github.com/user-attachments/assets/5d9746a7-6df2-4cd0-bbcb-f04cfdb1be5a" />


| Add Transaction |

| <img width="1080" height="2436" alt="1000127580" src="https://github.com/user-attachments/assets/b6719c5d-a685-45e8-aa81-d7cd9413e5fe" />
| Analytics |
 | <img width="1080" height="2436" alt="1000127583" src="https://github.com/user-attachments/assets/684dedc7-110c-483f-850a-272e33c7eddb" />
 |

---

## Demo

https://github.com/user-attachments/assets/ed6e1da4-93cf-4df8-87ac-68e80fbea716

---

## Tech Stack

| What | Why |
|------|-----|
| Flutter + Dart | Cross-platform UI |
| Firebase Authentication | Email/password login and session management |
| Cloud Firestore | Real-time cloud database for transactions and user data |
| Provider | State management |
| `fl_chart` | Expense pie chart |
| Google Fonts | Typography |

---

## Project Structure

```
lib/
├── models/
│   └── transaction_model.dart       # Transaction data class
│
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_transaction_screen.dart
│   ├── analytics_screen.dart
│   └── profile_screen.dart
│
├── services/
│   ├── auth_service.dart            # Firebase Auth logic
│   └── database_service.dart        # Firestore read/write
│
├── widgets/
│   ├── custom_textfield.dart
│   ├── transaction_card.dart
│   └── balance_card.dart
│
├── utils/
│   └── app_theme.dart
│
└── main.dart
```

The `services/` layer keeps Firebase logic completely separate from the UI — screens just call methods and get data back. Made testing and debugging much cleaner.

---

## Firebase Setup

This app requires a Firebase project. Here's how to get it running:

### 1. Create a Firebase Project

Head to [console.firebase.google.com](https://console.firebase.google.com) and create a new project.

### 2. Enable Email/Password Authentication

In the Firebase console, go to **Authentication → Sign-in Method** and enable **Email/Password**.

### 3. Create a Firestore Database

Go to **Firestore Database → Create Database** and start in **Test Mode**.

### 4. Add Your Android App

Register your app with the package name (e.g. `com.example.spendwise`), download the `google-services.json` file, and drop it in the `android/app/` directory.

### 5. Firestore Security Rules

For development, these rules allow any authenticated user to read and write:

```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

> Before going to production, tighten these rules so users can only access their own documents.

---

## Running the App

```bash
git clone https://github.com/yourusername/spendwise.git
cd spendwise
flutter pub get
flutter run
```

Make sure `google-services.json` is in place before running, otherwise Firebase won't initialize.

---

## Dependencies

```yaml
dependencies:
  firebase_core:
  firebase_auth:
  cloud_firestore:
  provider:
  fl_chart:
  google_fonts:
```

---

## What I Learned

This was my first time integrating Firebase into a real Flutter project, and it changed how I think about app architecture. A few things that stood out:

- Setting up Firebase Auth is straightforward, but handling edge cases (wrong password, user not found, network errors) takes real thought
- Firestore's real-time listeners with `snapshots()` are genuinely powerful — the UI just updates on its own
- Provider made a lot more sense once I had actual shared state (the current user, the transaction list) that multiple screens needed
- Separating Firebase calls into a `services/` layer early on made the code much easier to work with as the app grew
- Security rules are easy to overlook but important — test mode is fine for development, not for anything real

---

## About

Built by **Syed Mohsin Raza** — Week 5 task for a Flutter Developer Internship.

---

## License

Created for educational and internship purposes.
