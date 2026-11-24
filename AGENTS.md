# AGENTS.md

This file provides guidance to AI coding agents (Antigravity, Claude Code, Cursor, Copilot, Codex, etc.) when working in this repository. Nothing here is tool-specific. Treat it as the boundary of your task: if something is not allowed here, ask the user instead of deciding on your own.

## Rules for agents working in this repo

**Do:**
- Follow the feature-first folder structure exactly (`lib/features/<feature>/{data,domain,presentation}`, plus `lib/core` for shared code) for any new feature or file — see Architecture below. Put new files where an equivalent existing feature already lives.
- Follow the existing data flow for every new operation: data source method (sqflite) → repository method (implements an `I`-prefixed abstract repository from the domain layer, returns `Either<Failure, T>`) → usecase (also `I`-prefixed interface + impl, `@injectable`) → bloc event/state → `result.fold(...)` in the bloc. Never call the database from a bloc, widget or usecase directly.
- Use the localization system (`AppLocalizations.of(context)!.<key>`) for every user-facing string. Add every new key to **both** `lib/l10n/intl_en.arb` and `lib/l10n/intl_bn.arb` (snake_case keys). Bangla is the default locale.
- Use `flutter_bloc` for all feature state, with `Equatable` events and states and one `part`/`part of` triple per bloc (`<name>_bloc.dart`, `<name>_event.dart`, `<name>_state.dart`).
- Register new injectable classes (`@injectable` / `@singleton` / `@Injectable(as: ...)` / `@module`) and rerun build_runner instead of hand-writing DI wiring.
- Run every multi-step database change (booking, seat hold, payment, handover) inside `db.transaction(...)` so it either fully succeeds or fully rolls back.
- Keep all money as integer BDT (whole taka) and all timestamps as UTC epoch milliseconds (`INTEGER`). Never store money as `double`.
- Write or update a test when you change core logic: seat hold and expiry, booking transaction, connecting-journey query, handover transaction, refund/commission calculation (see Testing).
- Match the naming and style conventions in this file over anything written in a proposal or doc when the two disagree. The code is ground truth; if the proposal and the code disagree, ask the user.

**Don't:**
- Don't run, build or launch the app (`flutter run`, `flutter build`, emulators/devices) unless the user explicitly asks. Static analysis (`flutter analyze`) and tests (`flutter test`) are fine to run proactively to verify a change.
- Don't add any networking: no REST API, no `http`, no `dio`, no Firebase, no sockets, no remote config. This is an offline demo app; all data lives in the local sqflite database. If a feature seems to need a server, ask the user first.
- Don't introduce a second state-management approach (`Riverpod`, `Provider`, `GetX`, `setState`-heavy screens) for feature logic. Local `StatefulWidget` state is fine only for purely visual things (text controllers, animations, tab index).
- Don't hardcode user-visible strings, and don't use localized display strings for logic (comparisons, branching, asset/icon choice). Match on enums or stable keys instead.
- Don't branch on error message strings. Branch on the `FailureType` enum from `Failure`.
- Don't hand-edit generated files: `injection.config.dart`, `app_localizations*.dart`. Change the source (`@injectable` class or `.arb` file) and regenerate.
- Don't let one feature import another feature's `data` or `presentation` layer. A feature may depend on another feature's `domain` layer (entities, repository interfaces, usecases) through DI, or on `lib/core`. Nothing else.
- Don't write raw SQL strings with user input concatenated into them. Always use `?` placeholders and `whereArgs`.
- Don't use inline `Color(0x...)` literals or hardcoded font names. Use `AppColors` and the theme text styles.
- Don't add new dependencies, change dependency versions or edit `pubspec.yaml` assets/fonts without checking with the user first (see the approved list under Project).
- Don't "fix" or refactor code outside the task you were given. Don't rename, move or reformat files you were not asked to touch.

## Scope boundaries (stay inside these)

- **In scope:** the **passenger app only**, as a demo with local data. Features: splash, login, register, home, search, results (direct and connecting), bus details, seat selection, passenger details and booking summary, demo payment, e-ticket with QR, my tickets, **Ticket Handover**, **Same-Operator Connecting Journey**, notifications, settings (profile, language, Demo Operator).
- **Out of scope — do not build, stub or scaffold:** operator, admin or driver/supervisor apps or dashboards; a REST API or backend; live GPS or maps; real payments; push notifications; filters, promo codes, ratings, loyalty; forgot-password; round-trip search; any language other than Bangla and English.
- If the user asks for something that touches these items, confirm first. If a task is ambiguous, ask one short question instead of guessing.

## Project

**JatraNova** — a Flutter **passenger** app for intercity bus ticketing in Bangladesh, built as a demo with a local **sqflite** database and seeded demo data. A passenger searches a trip, picks seats, pays (demo), and gets a QR ticket. Two core innovations:

1. **Ticket Handover** — a passenger who cannot travel can hand the ticket to another passenger. The operator approves, the original owner gets **50% of the ticket price back**, the operator earns a **commission**, and the seat is not wasted.
2. **Same-Operator Connecting Journey** — when no direct trip exists, the app joins two trips of the **same operator** at a transfer hub into one journey with **one master booking and one payment**.

Because there is no backend, "operator approval" is simulated by a **Demo Operator** screen under `settings`, and "another passenger" is a second seeded demo account. All sample data (trips, fares, operators, users, bookings) is demo data and must be labelled as such in the UI.

**Approved dependencies** (anything else needs the user's OK): `flutter_bloc`, `equatable`, `get_it`, `injectable` (+ `injectable_generator`, `build_runner` as dev), `dartz`, `go_router`, `sqflite`, `path`, `intl`, `flutter_localizations` (SDK), `qr_flutter`, `crypto`, `shared_preferences`, `uuid`. Dev/test: `bloc_test`, `mocktail`, `sqflite_common_ffi`, `flutter_lints`. Fonts: Inter (English) and Noto Sans Bengali (Bangla), bundled as assets.

## Commands

```bash
# Install deps
flutter pub get

# Regenerate DI (injectable) code
flutter pub run build_runner build --delete-conflicting-outputs

# Regenerate localization (also runs on pub get / build)
flutter gen-l10n

# Run (single flavor, Android first) — only when the user asks
flutter run

# Lint
flutter analyze

# Tests
flutter test
```

Entry point is `lib/main.dart`: it initializes `WidgetsFlutterBinding`, opens/seeds the database, calls `configureInjection()`, then `runApp(MyApp())`. `lib/app.dart` builds `MaterialApp.router` with the theme, the locale from settings, and the router from `AppRoute`.

## Architecture

Clean Architecture, **feature-first**. Every feature owns its three layers under `lib/features/<feature>/`. Shared code lives in `lib/core`. Dependencies point inward: `presentation → domain ← data`.

```
lib/
├─ main.dart
├─ app.dart
├─ core/
│  ├─ database/      app_database.dart, db_tables.dart, migrations/, seed/seed_data.dart
│  ├─ error/         failure.dart (Failure, FailureType)
│  ├─ di/            injection.dart, injection.config.dart (generated), service_module.dart
│  ├─ route/         route_config.dart (AppRoute, RoutePath)
│  ├─ theme/         app_colors.dart, app_theme.dart, app_text_styles.dart
│  ├─ utils/         money_formatter.dart, date_formatter.dart, validators.dart, qr_token_generator.dart
│  └─ widgets/       app_button, app_text_field, app_card, app_bottom_nav, app_modal,
│                    app_notification_tile, loading_view, empty_view, error_view
├─ l10n/             intl_en.arb, intl_bn.arb (+ generated app_localizations*.dart)
└─ features/
   ├─ auth/                 splash, login, register, session
   ├─ home/                 home screen, popular routes
   ├─ search/               search form, results (direct and connecting lists)
   ├─ trips/                bus details
   ├─ seat_selection/       seat map, seat holds
   ├─ booking/              passenger details, booking summary, master booking
   ├─ payment/              demo payment, confirmation
   ├─ tickets/              e-ticket (QR), my tickets
   ├─ handover/             Ticket Handover (innovation 1)
   ├─ connecting_journey/   Same-Operator Connecting Journey (innovation 2)
   ├─ notifications/        notification list
   └─ settings/             profile, language, Demo Operator
```

Inside every feature:

```
<feature>/
├─ data/          models/ (hand-written fromMap/toMap), datasources/ (sqflite), repositories/ (implementations)
├─ domain/        entities/, repositories/ (I-prefixed interfaces), usecases/ (I-prefixed interface + impl)
└─ presentation/  bloc/ (bloc, event, state), pages/, widgets/
```

Data flow uses `dartz`'s `Either<Failure, T>` end to end instead of throwing: the data source throws or returns raw rows → the repository catches exceptions and maps them to `Failure` → the usecase passes the result through (or adds business rules) → the bloc folds it into a state → the page renders with `BlocConsumer`/`BlocBuilder`. Entities in `domain` are plain Dart and know nothing about sqflite or Flutter. Models in `data` extend or map to entities.

### State management

- **flutter_bloc** for all feature logic. Blocs are `@injectable`. Each page that needs a bloc gets it via `BlocProvider(create: (_) => getIt<...>())`.
- App-wide state (current session user, locale) is held by small app-level blocs/cubits (`SessionCubit`, `LocaleCubit`) provided once in `lib/app.dart`. The chosen locale is persisted in `shared_preferences`.
- DI is **get_it + injectable**. `lib/core/di/injection.dart` calls the generated `getIt.init()`. `service_module.dart` (`@module`) provides external singletons: the opened `Database` (`@preResolve`) and `SharedPreferences` (`@preResolve`). After adding or changing any annotated class, rerun build_runner.

### Local database (sqflite)

- One database, opened by `AppDatabase` in `lib/core/database/app_database.dart` (singleton). Enable foreign keys in `onConfigure` (`PRAGMA foreign_keys = ON`). Create tables in `onCreate`, then seed demo data in the same transaction. Schema changes go in a new numbered file under `migrations/` and a version bump — never edit an old migration.
- Table and column names are constants in `db_tables.dart`. Don't repeat string literals for table or column names in data sources.
- Main tables: `users`, `operators`, `routes`, `stops`, `buses`, `trips`, `seat_inventory`, `bookings`, `booking_legs`, `tickets`, `handover_requests`, `connection_rules`, `notifications`. Primary keys are `TEXT` UUIDs, except `seat_inventory` which uses a composite key `(trip_id, seat_id)`.
- Data sources are the **only** place that touches `Database`. They return raw rows or models, never entities with business rules applied.
- Seed data: demo operators (one verified, with a `handover_commission_pct`), routes including Dhaka → Rajshahi/Sylhet/Chattogram and a connecting pair Dhaka → Rangpur → Bogura on the same operator, trips for the next 7 days generated relative to the first launch, two demo users (for example Rahim and Karim), and `connection_rules` (minimum and maximum wait at the hub). Keep seed code in `core/database/seed/` only.

### Seat holds and booking

- A seat hold writes `status = held`, `hold_user_id` and `hold_expiry` (epoch ms) on `seat_inventory`. There is no background server, so expiry is **lazy**: in the same transaction that reads or books seats, treat rows with `hold_expiry < now` as free and clear them first. The countdown timer in the UI is only visual; the database is the source of truth.
- Booking is one transaction: re-check that every seat is still free or held by this user → create `bookings` and `booking_legs` → mark seats `booked` → create `tickets` with opaque `qr_token` → record payment status. If any step fails, roll back and return `FailureType.CONFLICT` (seat taken) or `FailureType.HOLD_EXPIRED`.
- Payment is a demo adapter inside the `payment` feature. It must be labelled "Demo Payment" in the UI and must never claim real settlement.

### Innovation logic

- **Ticket Handover** (`features/handover`). One atomic `db.transaction`: check eligibility (ticket is `active`, unused, not cancelled, not expired, not handed over before, before the departure cut-off, operator allows handover) → create/advance the `handover_requests` row → on operator approval and acceptance by the new passenger: set the old ticket to `revoked` **first**, then create a new ticket with a new `qr_token` owned by the new passenger → record `refund_amount` (50% of the ticket price, to the original owner) and `commission_amount` (operator percentage) → write `notifications` for both users. Any failure rolls everything back. Rounding for refund and commission lives in one pure function (`handover_calculator.dart`) and is unit-tested.
- **Demo Operator approval:** the Demo Operator screen in `settings` lists pending requests and lets the user Approve or Reject. It only changes `handover_requests.status`; it is not an operator app.
- **Connecting Journey** (`features/connecting_journey`). Offer a connection only when a single query/usecase confirms **all four**: (1) both trips belong to the same operator, (2) trip 1 ends at the hub and trip 2 starts at the same hub, (3) the wait between arrival and departure is between `min_buffer` and `max_wait` from `connection_rules`, (4) both legs have enough free seats. Direct trips are always shown first. Booking creates one master booking with two `booking_legs` and one payment. Never label a connection "guaranteed" before both legs are confirmed.

### Localization

Uses Flutter's built-in `gen-l10n` (config in `l10n.yaml`), not `easy_localization`. Sources are `lib/l10n/intl_en.arb` and `lib/l10n/intl_bn.arb`; Bangla is the default locale and the user can switch in Settings at any time (no restart). Use `intl` for date, number and BDT (`৳`) formatting so it follows the locale; Bangla digits are an optional setting. Stops, routes and operators store both `name_bn` and `name_en`; pick the right one by locale in the repository or mapper, not in widgets. Errors map to localized text through `FailureType`, never through raw messages.

### Error handling

`Failure` and `FailureType` live in `lib/core/error/failure.dart`. Types: `DATABASE`, `NOT_FOUND`, `VALIDATION`, `CONFLICT`, `HOLD_EXPIRED`, `NOT_ELIGIBLE`, `UNAUTHORIZED`, `UNKNOWN`. Repositories catch database exceptions and return `Left(Failure)`. Pages show failures through the shared `ErrorView`, empty results through `EmptyView`, and waiting through `LoadingView`. Every screen that loads data must handle loading, empty, error and success states.

### Navigation

`go_router`-based, via an injectable singleton `AppRoute` in `lib/core/route/route_config.dart` that exposes `.router`, consumed as `MaterialApp.router(routerConfig: getIt<AppRoute>().router)`. Path constants live in the `RoutePath` class at the bottom of the same file. Pass typed objects through `GoRouterState.extra` or path/query parameters. Redirect unauthenticated users to login using the session state.

### Security and demo data

- Passwords are never stored in plain text: salted SHA-256 via `crypto` (demo-grade; do not describe it as production security). The logged-in user id is kept in `shared_preferences`.
- QR tokens are random opaque values (`uuid`-based). Never put names, phone numbers or other personal data in a QR code. A ticket is valid only if its token matches an `active` ticket in the database.
- Mark demo data and demo payment clearly in the UI. Do not present sample schedules as real inventory.

### Testing

Establish and follow this pattern: repository and data source tests use `sqflite_common_ffi` with an **in-memory** database and the real schema/seed; blocs are tested with `bloc_test` and `mocktail` (mock the usecase); pure logic (`handover_calculator`, connection checks, validators) gets plain unit tests. Priority test cases: seat hold expiry, two users choosing the same seat, booking rollback on failure, connecting query (same operator, hub, buffer limits, seats on both legs), handover happy path, ineligible ticket, duplicate handover request, and both locales rendering without missing keys.

## Conventions

- Naming: `snake_case` files and folders, `PascalCase` classes, `lowerCamelCase` members. Abstract repository and usecase interfaces are `I`-prefixed (for example `IAuthRepository`, `IBookTripUsecase`) and implemented by `<Name>Impl`. Pages end with `_page.dart`, blocs with `_bloc.dart`.
- Models are hand-written `fromMap`/`toMap` classes. There is no `json_serializable` and no generated model files. Only DI uses build_runner output.
- Colors live in `AppColors` (`lib/core/theme/app_colors.dart`) as `Color` constants from the design system: primary `#123B70`, secondary `#1976D2`, accent `#14BBA6`, success `#22C55E`, warning `#F59E0B`, error `#EF4444`, handover accent orange, connecting-journey accent violet. Reuse an entry or add one; never inline a color literal.
- UI: light theme, card-based layouts with rounded corners, large tap targets, bottom navigation (Home, Tickets, Track, Profile). Shared widgets (button, text field, card, bottom nav, modal, notification tile) are built once in `lib/core/widgets` and reused by every feature.
- Debug logging uses `dart:developer`'s `log(...)`. No `print`.
- Comments explain *why*, not *what*. Keep functions small and keep business rules in usecases or pure functions, not in widgets or data sources.
