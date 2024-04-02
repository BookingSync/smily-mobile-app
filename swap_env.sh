#!/bin/bash

if [ $# -eq 0 ]; then
    # Determinar el entorno actual
    if grep -q "phoenix" ".env"; then
        current_environment="staging"
    elif grep -q "https://bookingsync.com" ".env"; then
        current_environment="production"
    else
        current_environment="Unknown"
    fi

    echo "Current environment is: $current_environment"
    exit 0
fi

if [ "$1" != "staging" ] && [ "$1" != "production" ]; then
    echo "Invalid argument. Usage: $0 <staging|production>"
    exit 1
fi

if [ ! -f ".env.$1" ]; then
    echo ".env.$1 does not exist. Creating it..."
    if [ "$1" == "production" ]; then
        echo "URL_LOGIN_FR=https://bookingsync.com/fr/users/login?type=smily" > .env.$1
        echo "URL_LOGIN_EN=https://bookingsync.com/en/users/login?type=smily" >> .env.$1
    elif [ "$1" == "staging" ]; then
        echo "URL_LOGIN_FR=https://phoenix.bookingsync.com/fr/users/login?type=smily" > .env.$1
        echo "URL_LOGIN_EN=https://phoenix.bookingsync.com/en/users/login?type=smily" >> .env.$1
    fi
    echo ".env.$1 has been created."
fi

if [ ! -f "lib/firebase_options.dart.$1" ]; then
    echo "lib/firebase_options.dart.$1 does not exist."
    echo "Generate it using: flutterfire configure"
    exit 1
fi

if [ ! -f "android/app/google-services.json.$1" ]; then
    echo "android/app/google-services.json.$1 does not exist."
    echo "Generate it using: flutterfire configure"
    exit 1
fi

if [ ! -f "ios/firebase_app_id_file.json.$1" ]; then
    echo "ios/firebase_app_id_file.json.$1 does not exist."
    echo "Generate it using: flutterfire configure"
    exit 1
fi

cp ".env.$1" .env
cp "lib/firebase_options.dart.$1" lib/firebase_options.dart
cp "android/app/google-services.json.$1" "android/app/google-services.json"
cp "ios/firebase_app_id_file.json.$1" "ios/firebase_app_id_file.json"

echo "Environment swapped to $1 successfully."
