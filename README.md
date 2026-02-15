# Delivery App

A Flutter food delivery app using **GetX** (state management, DI, navigation), **MVC** architecture, and **Firebase** (Auth, Firestore, Storage).

## Project structure

- `lib/core/` – theme, routes, bindings
- `lib/controllers/` – GetX controllers (MVC)
- `lib/views/` – screens (MVC)
- `lib/models/` – data models
- `lib/services/` – Firebase and other services

## Getting started

1. **Install dependencies**

   ```bash
   flutter pub get
   ```

2. **Configure Firebase** (required for auth and data)

   See **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** for step-by-step instructions (Firebase Console + terminal). Summary:
   - Create a project and add iOS/Android apps in [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password and **Google**), and Firestore
   - For Google Sign-In: add a **Web app** in Firebase, then set `AuthService.googleSignInWebClientId` in your app (e.g. in `main.dart`) to the Web client ID from Firebase Console.
   - Run `firebase login`, then `dart pub global activate flutterfire_cli`, then `flutterfire configure` in the project root
   - This generates `lib/firebase_options.dart`; the app will then use real Firebase instead of the stub.

3. **Run the app**

   ```bash
   flutter run
   ```

## Implemented so far

- **Splash** → redirects to Auth or Home based on login state
- **Auth** – email/password sign in and sign up
- **Home** – placeholder dashboard with Restaurants, Orders, Cart, Profile cards and sign out
- **Theme** – Material 3 light/dark with azure primary
- **Firebase Auth** – email/password and **Google Sign-In**; reactive auth state

## Next steps

- Add Firestore (restaurants, menu, orders)
- Build Restaurants list and detail screens
- Cart and checkout flow
- User profile and order history
- FCM for order updates
