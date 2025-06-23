# Overview - The Memory Scrapbook

The Memory Scrapbook is a mobile application designed for users to be able to create a daily visual Scrapbook, or diary. It allows people to capture and cherish special memories by adding photos, a caption/title, a feeling, and an optional place to add a detailed description of the memory. All memories are stored locally on the user's mobile device. This allows the app to work effectively even when offline.

**How to Use the App:**

1. On opening the app the user will be greeted with the "Memory Log" homee screen which displays a chronological list of all saved memories, newest first (this will have none the first time).
2. To add a new memory, just tap the + add photo button at the bottom right of the screen. This will navigate you to the "Create New Memory" screen.
3. On the new screen, you will have the following options on creating a new memory:
    - Adding a photo from your existing gallery, taking a new photo, or not adding a photo.
    - Adding a brief title or caption for the photo
    - Selecting a "feeling" that reflects how you felt in this moment.
    - Adding more details to the "Additional Thoughts" section.
    - Tap "Save Memory" to store locally and be returned to the home page of the app with the full list of all stored memories.
4. On the Memory log screen you can tap a memory which will bring a modal of it up to read and view
5. On the Memory log screen you can also tap the delete icon to remove the memory (with confirmation)

**Purpose for Creating the App**

The main reason I wrote this app was really to get my feet wet in the world of app development. I've never actually built an app before, so I considered many of the recommended ideas, and recommendations online of others, and kind of made an amalgamation of many other ideas into this one, a memory scrapbook. It seems fun, and it seems like something I would actually use. In addition, I really wanted to begin learning some of the mobile app design best practices. I learned how to implement persissions, access certain features of the phone, and it really was a lot easier than I thought it was going to be. I look forward to eventually deploying a cross-platform kind of app, and Flutter/Dart seems like a great way to go.

[Software Demo Video](http://youtube.link.goes.here)

# Local Data Storage (Database)

This app utilizes **Hive**. This is a fast NoSQL key-value database for local data storage on the user's device. Hive was chosen for its simplicity, performance, and excellent integration with Flutter (and the fact it was widely recommended in every online tutorial I found).

The database consists of a single "box" (essentially a table) named `memories`. Each entry in this box is an instance of a `MemoryEntry` object, with the structure:

*   **`date`**: (DateTime, required) - The timestamp when the memory was created.
*   **`imagePath`**: (String, optional) - The local file system path to the image.
*   **`caption`**: (String, required) - A short description of the memory, like a title or picture caption..
*   **`feeling`**: (String, required) - The feeling associated with the memory - emoji infused ("😊 Happy", "✨ Cozy")!
*   **`textEntry`**: (String, optional) - A more detailed text journal entry for the memory.

# Development Environment

*   **Flutter SDK**: The UI toolkit from Google to build natively compiled apps cross-platoform with a single codebase.
*   **Dart**: Main language used by the Flutter SDK.
*   **Android Studio**: Android Virtual Device for testing (Pixel 8, API 35 - Android 15)
*   **Android SDK**: Software Development Kit for Android.
*   **Git & GitHub**: For version control and source code management.
*   **Physical Android Device**: Samsung S25+ for real-world testing (my personal cell phone).
*   **Visual Studio Code (VSC)**: My main dev environment.

**Key Flutter Packages & Libraries Used:**

*   **`flutter/material.dart`**: The core Material Design widget library for Flutter.
*   **`hive` & `hive_flutter`**: For local NoSQL database storage.
*   **`path_provider`**: Used to find the commonly used file locations for local storage.
*   **`image_picker`**: To allow users to pick images from the gallery or camera.
*   **`permission_handler`**: To request and check device permissions (camera, photos).
*   **`intl`**: For internationalization and date/time formatting.
*   **`path`**: Utility used to manipulate file system paths.
*   **`build_runner` & `hive_generator`** (dev_dependencies): For code generation, specifically for Hive type adapters.

# Useful Websites

* [Flutter Documentation](https://docs.flutter.dev/) - Official documentation for Flutter.
* [Pub.dev](https://pub.dev/) - For understanding all official packages for Dart and Flutter (like image_picker and path and so on).
* [Stack Overflow](https://stackoverflow.com/) - Lots of troubleshooting help on Flutter and Dart
* [Getting Started with Flutter in 2025: A Developer's Roadmap](https://medium.com/@shouravnahid/getting-started-with-flutter-in-2025-a-developers-roadmap-2cb10b4bce49) - Great crash course
* [Building a Cross-Platform App with Flutter in 2025](https://getsetbuild.com/building-a-cross-platform-app-with-flutter-in-2025/) - Another great crash course on starting.

# Future Work

* Implement a way to add audio recordings or the entries, with transcribing
* In addition to the audio recordings, I'd like to add an audio button on the keyboard to enable voice to text too.
* Add search to the memories - right now it is only in date order descending with most recent showing.
* Expand the "feelings" choices to full range omojis to custom ones too.
* Add cloud integration as backup to your locally stored files
* This would thus require creating an account.
* Better UI/UX

