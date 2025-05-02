# Pulse News App

## Introduction

Pulse News is a modern Flutter-based news aggregation application that provides users with real-time access to the latest news from multiple trusted sources. The app is designed to deliver a seamless and personalized news-reading experience, ensuring users stay informed about topics that matter to them. With its clean interface and powerful features, Pulse News is the perfect companion for staying updated in today's fast-paced world.

## Scope

The Pulse News app is intended for a diverse audience, including:

- **Casual readers** who want quick access to trending news.
- **Professionals** who need to stay informed about industry-specific updates.
- **Students and researchers** looking for reliable news sources.
- **Global audiences** seeking news from various regions and perspectives.

The app is scalable and can be enhanced with features like AI-powered recommendations, offline reading, and user preferences in future updates.

## Problem and Solution

### Problem
In the digital age, users are overwhelmed by the sheer volume of news available online. Many platforms are cluttered with ads, irrelevant content, or lack personalization, making it difficult to find trustworthy and relevant news.

### Solution
Pulse News solves these issues by:
- Aggregating news from multiple reliable sources in one place.
- Offering categorized news feeds for easy navigation.
- Providing a clean, ad-free interface for a distraction-free experience.
- Allowing users to bookmark articles for later reading.
- Including a robust search feature to quickly find specific topics.

## Tools and Technologies

The following tools and technologies were used in the development of the Pulse News app:

### Framework and Language
- **Flutter**: Framework for building cross-platform mobile applications.
- **Dart**: Programming language for Flutter development.

### Backend and Database
- **Firebase**: Backend-as-a-Service (BaaS) for authentication, database, and cloud storage.
  - **firebase_core**: Core Firebase SDK for Flutter.
  - **firebase_auth**: Firebase Authentication for user login and signup.
  - **cloud_firestore**: Firebase Firestore for database operations.

### Networking
- **http**: For making HTTP requests to fetch news articles.
- **NewsAPI.org**: Third-party API for fetching real-time news.

### State Management
- **provider**: For managing app state efficiently.

### UI and Animations
- **flutter_html**: For rendering HTML content in articles.
- **cached_network_image**: For efficient image caching and loading.
- **flutter_animate**: For adding animations to the app.

### Utilities
- **shared_preferences**: For storing user preferences locally.
- **intl**: For date formatting and localization.
- **url_launcher**: For opening URLs in the browser or external apps.
- **fluttertoast**: For displaying toast notifications.
- **package_info_plus**: For retrieving app metadata like version and build number.

### Authentication
- **google_sign_in**: For Google Sign-In functionality.

### Miscellaneous
- **country_picker**: For selecting countries in the signup process.
- **font_awesome_flutter**: For using FontAwesome icons.

### Development and Deployment
- **Firebase CLI**: For configuring Firebase services.
- **FlutterFire CLI**: For integrating Firebase with Flutter.
- **Git**: For version control and source code management.
- **Google Play Store**: For distributing the app on Android devices.
- **Apple App Store**: For distributing the app on iOS devices.

## Key Features

- **Real-Time News Updates**: Stay informed with the latest news from trusted sources.
- **Categorized News Feeds**: Browse news by categories such as Technology, Sports, Politics, and more.
- **Search Functionality**: Quickly find articles on specific topics or keywords.
- **Bookmarking**: Save articles for later reading.
- **Responsive Design**: Optimized for both mobile and tablet devices.
- **Dark Mode**: Switch between light and dark themes for a comfortable reading experience.

## Key Screens

The Pulse News app includes the following screens:

1. **Splash Screen**:
   - Displays the app logo and tagline during the app's initialization.

2. **Login Screen**:
   - Allows users to log in using email/password or Google Sign-In.

3. **Signup Screen**:
   - Enables new users to create an account.

4. **Home Screen**:
   - Displays trending news and the latest news articles.
   - Includes infinite scrolling for the latest news.

5. **Categories Screen**:
   - Allows users to browse news by categories such as Technology, Sports, and more.

6. **Bookmarks Screen**:
   - Displays articles that users have bookmarked for later reading.
   - Includes options to delete individual or all bookmarks.

7. **Article Detail Screen**:
   - Shows detailed information about a selected article.
   - Includes options to save the article to bookmarks or adjust text size.

8. **Profile Screen**:
   - Displays user information, bookmarks count, and reading history count.
   - Provides options to edit the profile, change appearance, access help, and more.

9. **Edit Profile Screen**:
   - Allows users to update their username and password.

10. **App Appearance Screen**:
    - Enables users to switch between light, dark, or system default themes.

11. **Help & Support Screen**:
    - Provides FAQs, contact support options, and a form to report issues.

12. **About Screen**:
    - Displays app information, version, and links to the privacy policy, terms of service, and open-source licenses.

13. **Privacy Policy Screen**:
    - Displays the app's privacy policy.

14. **Terms of Service Screen**:
    - Displays the app's terms of service.

15. **Open Source Licenses Screen**:
    - Lists the open-source libraries used in the app.

## Dependencies

The following dependencies are used in the Pulse News app:

### Core Dependencies
- **Flutter**: Framework for building cross-platform mobile applications.
- **Dart**: Programming language for Flutter development.

### Firebase
- **firebase_core**: Core Firebase SDK for Flutter.
- **firebase_auth**: Firebase Authentication for user login and signup.
- **cloud_firestore**: Firebase Firestore for database operations.

### Networking
- **http**: For making HTTP requests to fetch news articles.

### State Management
- **provider**: For managing app state efficiently.

### UI and Animations
- **flutter_html**: For rendering HTML content in articles.
- **cached_network_image**: For efficient image caching and loading.
- **flutter_animate**: For adding animations to the app.

### Utilities
- **shared_preferences**: For storing user preferences locally.
- **intl**: For date formatting and localization.
- **url_launcher**: For opening URLs in the browser or external apps.
- **fluttertoast**: For displaying toast notifications.
- **package_info_plus**: For retrieving app metadata like version and build number.

### Authentication
- **google_sign_in**: For Google Sign-In functionality.

### Miscellaneous
- **country_picker**: For selecting countries in the signup process.
- **font_awesome_flutter**: For using FontAwesome icons.

## Future Enhancements

- **AI-Powered Recommendations**: Suggest articles based on user preferences and reading history.
- **Offline Reading**: Download articles to read without an internet connection.
- **Push Notifications**: Notify users about breaking news and trending topics.
- **User Profiles**: Allow users to customize their experience and manage preferences.
- **Multi-Language Support**: Provide news in multiple languages to cater to a global audience.

## Installation Guide

Follow these steps to set up the Pulse News app locally:

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd pulsenews
   ```

2. **Install Flutter**:
   Ensure Flutter is installed on your system. Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install).

3. **Install Dependencies**:
   Run the following command to install the required dependencies:
   ```bash
   flutter pub get
   ```

4. **Run the App**:
   Use the following command to run the app on an emulator or connected device:
   ```bash
   flutter run
   ```

5. **Build for Production**:
   To build the app for production, use:
   ```bash
   flutter build apk
   ```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
