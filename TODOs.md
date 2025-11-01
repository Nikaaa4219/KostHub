Project TODOs (generated)

This file consolidates actionable TODOs found in the codebase and indicates the recommended priority and next steps.

How to use
- Each entry shows file path, short description, and suggested action.
- Once you implement an item, update or remove it from this file.

High priority
- lib/services/auth_service.dart: replace simulated logout/login with real API calls (AuthService).
  Suggested: implement network client, token storage (secure_storage), and error handling.

- lib/providers/auth_provider.dart: integrate with real auth flow (setUser on login, persist session).
  Status: implemented — `AuthProvider` now persists non-sensitive profile to
  SharedPreferences and token to secure storage. Use `AuthProvider.loadSavedAuth()`
  at startup to restore auth before UI is built.

- lib/services/user_service.dart: implement `updateProfile` to call backend and handle validation and image upload.
  Status: partially implemented — `updateProfile` supports an optional `updateEndpoint`.
  When empty the service falls back to a local stub. Configure an endpoint to enable real updates.

- lib/services/room_service.dart: replace stub with real API-based search and fetchNearby.
  Status: stubbed implementation present. Replace with HTTP client and pagination when backend is available.

- lib/services/room_service.dart: replace stub with real API-based search and fetchNearby.
  Suggested: implement pagination, caching, and error handling.

Medium priority
- lib/screens/search_screen.dart: implement location lookup and permission handling (use `location` or `geolocator` package).
- lib/screens/edit_profile_screen.dart: replace image picker stub with `image_picker` integration and upload flow.
- lib/screens/profile_screen.dart: update UI/provider when EditProfileScreen returns updated profile (currently shows snackbar only).

Low priority / housekeeping
- Replace remaining inline TODO comments with tracked issues in this file. (This consolidation happened automatically.)
- Address deprecation warnings about RadioListTile -> consider migrating to new RadioGroup API when upgrading Flutter SDK.
- Update `lib/widgets/safe_asset_image.dart` to use super parameters for `key` (minor lint).

Notes
- Many TODOs are stubs indicating where backend integration is required. They are intentionally left as comments in code to mark where to integrate.
- If you'd like, I can implement specific TODOs (for example: image picker + upload, or real RoomService using a mock HTTP client). Tell me which ones to prioritize next.
