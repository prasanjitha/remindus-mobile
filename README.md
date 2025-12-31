# RemindUs 🌿

RemindUs is a collaborative inventory management and notification app built with Flutter and Firebase. It allows families to manage household essentials like vegetables with real-time sync and role-based permissions.

## 🚀 Key Features
- **Multi-Group Access:** Join multiple family groups and switch between them seamlessly.
- **Role-Based Permissions:** Owners can assign 'Full' (Edit/Delete) or 'Limited' (View Only) access to members.
- **Real-time Sync:** Powered by Cloud Firestore for instant updates across all family members.
- **Smart Invitations:** Invite members via email using EmailJS integration.

## 🛠️ Tech Stack
- **Framework:** Flutter
- **Backend:** Firebase (Authentication & Firestore)
- **Communication:** EmailJS API
- **State Management:** StatefulWidgets with Real-time Streams

## 📦 Installation & Setup
1. Clone the repository: `git clone https://github.com/your-username/remindus-inventory-app.git`
2. Run `flutter pub get` to install dependencies.
3. Add your own `google-services.json` to `android/app/`.
4. Add your own `GoogleService-Info.plist` to `ios/Runner/`.
5. Run the app: `flutter run`
