#!/bin/bash
# Check if Firebase CLI and jq are installed
command -v firebase &>/dev/null || { echo "Firebase CLI not installed. Exiting."; exit 1; }
command -v jq &>/dev/null || { echo "jq not installed. Exiting."; exit 1; }



# Load environment variables from .env file
if [ -f "firebase_config.env" ]; then
  # Source environment variables from .env file to handle spaces and special characters correctly
if [ -f "firebase_config.env" ]; then
    # Use 'source' to load variables directly
    source firebase_config.env
else
    echo "Configuration file 'firebase_config.env' not found. Exiting."
    exit 1
fi

else
    echo "Configuration file 'firebase_config.env' not found. Exiting."
    exit 1
fi

# Ensure required values are defined
if [ -z "$PROJECT_ID" ] || [ -z "$ANDROID_PACKAGE_NAME" ] || [ -z "$IOS_BUNDLE_ID" ]; then
    echo "Error: PROJECT_ID, ANDROID_PACKAGE_NAME, and IOS_BUNDLE_ID must be defined."
    exit 1
fi

# Check Variables for Firebase project setup
# echo $PROJECT_NAME  # Set your project name
# echo $PROJECT_ID  # Set your unique project ID
# echo $ANDROID_PACKAGE_NAME  # Set your Android package name
# echo $IOS_BUNDLE_ID  # Set your iOS bundle ID
# echo $APP_DISPLAY_NAME  # Set your app's display name
# exit 0;
# Directory for the new project
PROJECT_DIR="."

# Ensure Variables are Defined
if [ -z "$ANDROID_PACKAGE_NAME" ] || [ -z "$IOS_BUNDLE_ID" ]; then
    echo "Error: Package name and bundle ID must be defined."
    exit 1
fi

# Function to create a Firebase project
create_firebase_project() {
    echo "Creating Firebase project: $PROJECT_NAME with ID: $PROJECT_ID"

    # Check if project already exists
    if firebase projects:list | grep -q "$PROJECT_ID"; then
        echo "Firebase project with ID $PROJECT_ID already exists."
        cd "$PROJECT_DIR" || exit
        firebase use --add "$PROJECT_ID"
        return
    fi

    # Create the Firebase project
    firebase projects:create "$PROJECT_ID" --display-name "$PROJECT_NAME"
    if [ $? -ne 0 ]; then
        echo "Failed to create Firebase project. Exiting."
        exit 1
    fi

    # Initialize Firebase in the project directory with Extensions setup
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR" || exit

    # Create a .firebaserc file to define the project
    echo "{ \"projects\": { \"default\": \"$PROJECT_ID\" } }" > .firebaserc

    # Run firebase init with Extensions only in a non-interactive way
    firebase init extensions --non-interactive --project="$PROJECT_ID"

    # Set the active project (after initializing firebase.json)
    firebase use --add "$PROJECT_ID"
}

# Function to add an Android app to the Firebase project
# Function to add an Android app to the Firebase project
add_android_app() {
    echo "Adding Android app to Firebase project"

    # Check if the Android app already exists
    app_list_json=$(firebase apps:list --json)

    if [ $? -ne 0 ]; then
        echo "Failed to retrieve app list. Exiting."
        exit 1
    fi

    # Corrected jq syntax to check for existing app
    if echo "$app_list_json" | jq -e --arg PACKAGE_NAME "$ANDROID_PACKAGE_NAME" '.result[] | select(.namespace == $PACKAGE_NAME)' > /dev/null 2>&1; then
        echo "Android app with package name $ANDROID_PACKAGE_NAME already exists."
        return
    fi

    # Create the Android app
    firebase apps:create android "$APP_DISPLAY_NAME" --package-name="$ANDROID_PACKAGE_NAME" 
    if [ $? -ne 0 ]; then
        echo "Failed to add Android app. Exiting."
        exit 1
    fi

    echo "Android app added successfully."

    # Re-fetch the app list to ensure the latest data
    app_list_json=$(firebase apps:list --json)
    echo $app_list_json
    app_id=$(echo "$app_list_json" | jq -r --arg PACKAGE_NAME "$ANDROID_PACKAGE_NAME" '.result[] | select(.namespace == $PACKAGE_NAME).appId')
    firebase apps:sdkconfig ANDROID "$app_id" > ./android/app/google-services.json
}


# Function to add an iOS app to the Firebase project
# Function to add an iOS app to the Firebase project
add_ios_app() {
    echo "Adding iOS app to Firebase project"

    # Check if the iOS app already exists
    app_list_json=$(firebase apps:list --json)
    echo $app_list_json

    if [ $? -ne 0 ]; then
        echo "Failed to retrieve app list. Exiting."
        exit 1
    fi

    # Corrected jq syntax to check for existing iOS app
    if echo "$app_list_json" | jq -e --arg BUNDLE_ID "$IOS_BUNDLE_ID" '.result[] | select(.namespace == $BUNDLE_ID)' > /dev/null 2>&1; then
        echo "iOS app with bundle ID $IOS_BUNDLE_ID already exists."
        return
    fi

    # Create the iOS app (avoid asking for App Store ID by not providing it)
    firebase apps:create ios "$APP_DISPLAY_NAME" --bundle-id="$IOS_BUNDLE_ID" --no-store-link
    if [ $? -ne 0 ]; then
        echo "Failed to add iOS app. Exiting."
        exit 1
    fi

    echo "iOS app added successfully."

    # Re-fetch the app list to ensure the latest data
    app_list_json=$(firebase apps:list --json)
    echo $app_list_json
    app_id=$(echo "$app_list_json" | jq -r --arg BUNDLE_ID "$IOS_BUNDLE_ID" '.result[] | select(.namespace == $BUNDLE_ID).appId')
    firebase apps:sdkconfig IOS "$app_id" > ./ios/Runner/GoogleService-Info.plist
}


# Main script execution
echo "Starting Firebase project setup."

create_firebase_project
add_android_app
add_ios_app

echo "Firebase project setup completed successfully."
