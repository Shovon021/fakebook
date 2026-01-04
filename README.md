# Fakebook

![Flutter](https://img.shields.io/badge/Flutter-3.10.4-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Cloudinary](https://img.shields.io/badge/Cloudinary-Media%20Storage-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Fakebook** is a production-grade, high-fidelity clone of the Facebook mobile application, built with Flutter. It mimics the core functionality and design aesthetics of the original platform, offering a seamless user experience across Android and iOS. This project serves as a comprehensive demonstration of advanced Flutter UI development, state management, and cloud integration.

---

## 🏗 System Architecture

The application is built using a scalable architecture separating UI, Business Logic, and Data layers.

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore Database)
- **Media Storage**: Cloudinary (Image & Video hosting)
- **External APIs**: Pexels API (Stock video content for Reels)

---

## 🚀 Key Features

### 1. Authentication & User Management
- **Secure Login/Register**: Powered by Firebase Authentication.
- **Persistent Sessions**: Users remain logged in across app restarts.
- **Account Management**: Full capability to delete account, including all personal data (posts, stories, messages) via the Profile settings.

### 2. News Feed
- **Infinite Scrolling**: Optimized list view for endless content consumption.
- **Rich Post Types**: Support for Text, Photo, Video, and Background Color posts.
- **Interactive Reactions**: Animated reaction buttons (Like, Love, Care, Haha, Wow, Sad, Angry) using custom SVGs.
- **Comments & Shares**: Fully functional comment threads and sharing capabilities.

### 3. Short Videos (Reels) & Watch
- **Immersive Player**: Full-screen, vertical swipe video feed (TikTok-style).
- **Pexels API Integration**: Fetches high-quality, random popular videos for endless entertainment.
- **Video Upload**: Users can upload their own videos which appear in the main feed.
- **Playback Controls**: Auto-play, tap-to-pause, and volume toggle.

### 4. Stories
- **Ephemeral Content**: Users can post photo stories that expire after 24 hours.
- **Story Viewer**: Interactive viewer with progress bars and manual navigation.
- **Privacy**: Visibility limited to friends (simulated).

### 5. Profile & Social Graph
- **Customizable Profile**: Edit Profile Picture and Cover Photo with instant preview and auto-post generation.
- **Friend Management**: Send, Accept, and Reject friend requests.
- **Timeline**: View user-specific posts and life events.
- **Profile Actions**: Message, Block, and Report functionality.

### 6. Marketplace
- **Product Listing**: Browse items for sale with infinite scrolling.
- **Filtering**: Sort/Filter items by category (Vehicles, Electronics, etc.) with client-side optimization.
- **Item Details**: View detailed product information and seller profiles.

### 7. Core Experience
- **Dark Mode**: Fully supported system-wide dark theme.
- **Notifications**: Real-time alerts for interactions.
- **Search**: Functional search for users and posts.
- **Responsive Design**: Adapts to various screen densities and sizes.

---

## 🛠 Tech Stack & Services

| Service | Usage | Description |
| :--- | :--- | :--- |
| **Flutter** | Frontend Framework | Cross-platform mobile development SDK. |
| **Firebase Auth** | Authentication | Secure user identity management. |
| **Cloud Firestore** | Database | NoSQL cloud database for real-time data syncing. |
| **Cloudinary** | Media Storage | Optimized hosting for user-uploaded images and videos. |
| **Pexels API** | External API | Provider of royalty-free stock videos for the "Watch/Reels" feature. |
| **Provider** | State Management | Dependency injection and state management solution. |

---

## 📦 Installation

To run this project locally, follow these steps:

**1. Prerequisites**
- Flutter SDK installed (v3.10.0 or higher)
- Android Studio / VS Code
- A Firebase Project
- A Cloudinary Account

**2. Clone Repository**
```bash
git clone https://github.com/Shovon021/fakebook.git
cd fakebook
```

**3. Install Dependencies**
```bash
flutter pub get
```

**4. Configuration**
- **Firebase**: Replace `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) with your own.
- **Cloudinary**: Update credentials in `lib/services/storage_service.dart`.
- **Pexels API**: Add your key to `lib/services/video_service.dart`.

**5. Run Application**
```bash
flutter run
```

---

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
