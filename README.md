# 🪃 Boomerang

**Boomerang** is a clean, minimal, and intuitive debt management app built with Flutter. It helps you keep track of money you've borrowed or lent to friends, ensuring that what goes around, always comes back!

## ✨ Features

- **Track Debts & Loans:** Easily record who owes you money and who you owe money to.
- **Partial Payments:** Add incremental payments to a debt until the remaining balance is settled.
- **Automated Reminders:** Never forget a due date! Boomerang automatically schedules exact-time local notifications to remind you on the expected return date.
- **Multi-Currency Support:** Traveling? No problem. Record debts in various global currencies.
- **Data Export & Import:** Securely export your data to CSV or JSON formats, and import it back whenever you switch devices.
- **Dark & Light Mode:** Beautiful UI that respects your system's theme preferences.

## 🚀 Getting Started

To build and run this project locally, you will need to have [Flutter](https://flutter.dev/docs/get-started/install) installed on your system.

### Prerequisites
- Flutter SDK (>=3.12.2)
- Android Studio / VS Code

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/imanitrajput/boomerang.git
   ```
2. Navigate to the project directory:
   ```bash
   cd boomerang
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 🛠️ Building for Release

To generate an APK for Android, run:
```bash
flutter build apk --release
```
To generate an App Bundle (for Google Play), run:
```bash
flutter build appbundle
```

*(Note: Don't forget to configure your keystore in `key.properties` before generating a release build!)*

## 📦 Tech Stack

- **Framework:** Flutter / Dart
- **State Management:** Provider
- **Local Storage:** SharedPreferences
- **Notifications:** flutter_local_notifications

---
*Made with ❤️ using Flutter.*
