# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run the app
flutter analyze          # Lint / static analysis
flutter test             # Run all tests
flutter test test/foo_test.dart  # Run a single test file
```

To force-reseed Firestore data (clear and re-seed):
```bash
SEED_FIRESTORE=force flutter run
```

To deploy Firestore security rules:
```bash
firebase deploy --only firestore:rules
```

## Architecture

**Flutter + GetX MVC + Firebase**

The app uses GetX for state management, dependency injection, and named-route navigation. The pattern is:

- **Service** → registered in `InitialBinding` or a route binding, injected via `Get.find<T>()`
- **Controller** → `GetxController` subclass, consumes services, exposes `Rx*` observables
- **View** → uses `Obx(...)` or `GetX<Controller>` to react to observable state

### Key files

| File | Purpose |
|---|---|
| `lib/main.dart` | App entry: Firebase init, Firestore seed, `GetMaterialApp` setup |
| `lib/core/bindings/initial_binding.dart` | Registers `AuthService` permanently at startup (real or stub) |
| `lib/core/routes/app_pages.dart` | All named routes + per-route bindings |
| `lib/core/routes/app_routes.dart` | Named route string constants |
| `lib/services/auth_service.dart` | `AuthService` abstract + `FirebaseAuthService` / `StubAuthService` |
| `lib/services/home_repository.dart` | Firestore reads for banners, dishes, categories, restaurants |
| `lib/services/firestore_seed_service.dart` | Seeds Firestore once on first run (idempotent via `meta/seed` doc) |
| `lib/controllers/main_controller.dart` | Central hub: bottom-nav index, home data, cart count, favorites, search |

### Firebase / stub pattern

When `firebase_options.dart` is missing or Firebase fails to init, the app falls back to `StubAuthService` (no-op) so it runs without crashing. `InitialBinding` detects `Firebase.apps.isNotEmpty` and registers the appropriate implementation. The same guard appears in route bindings for `HomeRepository`.

To enable real Firebase, run `flutterfire configure` to generate `lib/firebase_options.dart`.

For Google Sign-In, uncomment and set `AuthService.googleSignInWebClientId` in `main.dart` with the Web client ID from Firebase Console.

### Firestore data

Collections: `banners`, `popular_dishes`, `categories`, `restaurants`. All documents have an `order` field for sorting. Seed data is written once (guarded by `meta/seed` doc). Use `SEED_FIRESTORE=force` env var to clear and re-seed.

Firestore rules are in `firestore.rules` at the project root — public read for content collections, authenticated write only.

### `MainController` as shared state

`MainController` is the central data store for the post-auth shell. `ProductDetailController` and `RestaurantMenuController` both receive a reference to it via constructor injection, using it to access restaurants, dishes, favorites, and cart state.

### Platform environment

`lib/core/platform_env.dart` conditionally exports `platform_env_io.dart` (uses `dart:io` `Platform.environment`) or `platform_env_stub.dart` (returns `null`) for web/non-IO targets.
