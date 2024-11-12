# Firebase Project Setup Script for Flutter

This script automates the setup of a Firebase project, tailored primarily for Flutter projects, but it can be  compatible with individual Android or iOS projects for simple touches. It handles Firebase project creation, Android and iOS app linking, and configuration file generation—reducing manual effort and ensuring consistent setup across different environments.

## Features and Benefits

- **Automated Firebase Project Creation**: Initializes a new Firebase project or links to an existing one if already set up.
- **Platform-Specific App Setup**: Adds Android and iOS apps to the Firebase project, ensuring they’re configured with Firebase SDK files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS).
- **Compatibility**: Built for Flutter but easily adaptable for single-platform (Android or iOS) projects.
- **Ease of Use**: Requires only a single command to set up Firebase, ideal for developers aiming for quick, reliable project initialization.

## Prerequisites

1. **Firebase CLI**: Ensure [Firebase CLI](https://firebase.google.com/docs/cli) is installed and authenticated.
2. **jq**: This script uses `jq` for JSON parsing. Install it via:
   ```bash
   sudo apt-get install jq   # For Debian/Ubuntu
   brew install jq           # For macOS
   ```

## firebase_config.env

firebase_config.env: A .env file containing project-specific configurations in the same directory as the script. Example file content:
   ```bash
    PROJECT_NAME="My New Application"  # Firebase Project Name 
    PROJECT_ID="my-new-application"     # Project Id to create in firebase (Google GCP)
    ANDROID_PACKAGE_NAME="com.example.newapplication" # Android package name
    IOS_BUNDLE_ID="com.example.newapplication"  # iOS Bundle Id
    APP_DISPLAY_NAME="My New Application"   # Display name of the applciation
   ```

## firebase_config.env
Clone or download this repository.
Configure the firebase_config.env file as shown above with your project details.
Make the script executable (if necessary):
   ```bash
chmod +x setup_firebase.sh
   ```
Run the script:
   ```bash
      ./setup_firebase.sh
```

## Usage Script Overview

⋅⋅*Environment Variables: Loads configurations from firebase_config.env.
⋅⋅*Project Check and Initialization: Creates a new Firebase project or links to an existing one.
⋅⋅*Platform Setup: Adds and configures Android and iOS apps within the Firebase project.
⋅⋅*SDK Configuration: Downloads the necessary SDK files and saves them in the appropriate directories for Flutter.
⋅⋅*Note: For best compatibility, this script assumes a Flutter project structure, but can be modified for standalone Android or iOS projects.

## Troubleshooting
If you encounter errors related to missing Firebase CLI or jq, double-check the prerequisites and ensure these dependencies are correctly installed and accessible.