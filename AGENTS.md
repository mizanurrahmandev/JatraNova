# AGENTS.md

This file provides guidance to AI coding agents (Antigravity, Claude Code, Cursor, Copilot, Codex, etc.) when working in this repository. Nothing here is tool-specific. Treat it as the boundary of your task: if something is not allowed here, ask the user instead of deciding on your own.

## Rules for agents working in this repo

**Do:**
- Follow the feature-first folder structure exactly (`lib/features/<feature>/{data,domain,presentation}`, plus `lib/core` for shared code) for any new feature or file — see Architecture below. Keep each feature's Bloc, events, states, usecases, repository interface and repository implementation inside that feature. Put new files where an equivalent existing feature already lives.
- Follow the existing data flow for every new operation: data source method (sqflite) → repository method (implements an `I`-prefixed abstract repository from the domain layer, returns `Either<Failure, T>`) → usecase (also `I`-prefixed interface + impl, `@injectable`) → bloc event/state → `result.fold(...)` in the bloc. Never call the database from a bloc, widget or usecase directly.
- Use the localization system (`AppLocalizations.of(context)!.<key>`) for every user-facing string. Add every new key to **both** `lib/l10n/intl_en.arb` and `lib/l10n/intl_bn.arb` (snake_case keys). Bangla is the default locale.
- Use `flutter_bloc` with **Bloc only** for all feature and app-wide state. Every Bloc must have separate `<name>_bloc.dart`, `<name>_event.dart` and `<name>_state.dart` files, with `Equatable` events and states. Do not create or use Cubit anywhere in this project.
- Register new injectable classes (`@injectable` / `@singleton` / `@Injectable(as: ...)` / `@module`) and rerun build_runner instead of hand-writing DI wiring.
- Run every multi-step database change (booking, seat hold, payment, handover) inside `db.transaction(...)` so it either fully succeeds or fully rolls back.
- Keep all money as integer poisha (`*_minor INTEGER`, 100 poisha = ৳1) and all SQLite timestamps as UTC epoch milliseconds (`INTEGER`); the Domain Layer uses Dart `DateTime`. Never store money as `double` or SQLite `REAL`.
- Write or update a test when you change core logic: seat hold and expiry, booking transaction, connecting-journey query, handover transaction, refund/commission calculation (see Testing).
- Match the naming and style conventions in this file over anything written in a proposal or doc when the two disagree. The code is ground truth; if the proposal and the code disagree, ask the user.

**Don't:**
- Don't run, build or launch the app (`flutter run`, `flutter build`, emulators/devices) unless the user explicitly asks. Static analysis (`flutter analyze`) and tests (`flutter test`) are fine to run proactively to verify a change.
- Don't add any networking: no REST API, no `http`, no `dio`, no Firebase, no sockets, no remote config. This is an offline demo app; all data lives in the local sqflite database. If a feature seems to need a server, ask the user first.
- Don't use Cubit or introduce a second state-management approach (`Riverpod`, `Provider`, `GetX`, `setState`-heavy screens) for feature logic. Use Bloc for app-wide and feature state. Local `StatefulWidget` state is fine only for purely visual things (text controllers, animations, tab index).
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

1. **Ticket Exchange (internal `handover` feature)** — a passenger who cannot travel can hand an eligible direct ticket to another passenger. The operator approves, and on completion the revenue split is calculated strictly from the Original Ticket Price: **30% bus operator, 50% ticket exchanger, 20% JatraNova platform** (integer floor rounding for operator and platform, remainder to exchanger), and the seat is not wasted.
2. **Same-Operator Connecting Journey** — when no direct trip exists, the app joins two point-to-point trips of the **same operator** at a transfer hub into one journey with **one master booking, two booking legs, one demo payment, and one Master E-Ticket per passenger**.

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

Inside every feature, follow this structure. Keep the same pattern for small and large features; do not move feature files into global `src/data`, `src/domain` or `src/presentation` folders.

```
<feature>/
├─ data/
│  ├─ datasources/              # Local sqflite data sources
│  ├─ models/                   # Hand-written fromMap/toMap models
│  └─ repositories/             # Repository implementations
│     └─ <name>_repository_impl.dart
├─ domain/
│  ├─ entities/
│  ├─ repositories/             # Abstract contracts only
│  │  └─ i_<name>_repository.dart
│  └─ usecases/
│     ├─ i_<action>_usecase.dart # Usecase contract
│     └─ <action>_usecase_impl.dart
└─ presentation/
   ├─ bloc/
   │  ├─ <name>_bloc.dart
   │  ├─ <name>_event.dart
   │  └─ <name>_state.dart
   ├─ pages/
   └─ widgets/
```

Naming and dependency rules:
- Repository contract: `I<Name>Repository` in `domain/repositories/`; implementation: `<Name>RepositoryImpl` in `data/repositories/`.
- Usecase contract: `I<Action>Usecase` in `domain/usecases/`; implementation: `<Action>UsecaseImpl` in `domain/usecases/`.
- Each Bloc has its own event and state files. Use `Bloc`, not `Cubit`.
- **Strict feature ownership:** a feature's files must stay inside that same feature. For example, Home Bloc files belong in `lib/features/home/presentation/bloc/`; Auth Bloc files belong in `lib/features/auth/presentation/bloc/`. Apply this rule to every feature (Search files in `search/`, Booking files in `booking/`, Tickets files in `tickets/`, and so on).
- Do not create a central `lib/bloc/`, `lib/events/`, `lib/states/`, `lib/usecases/` or `lib/repositories/` folder for feature-specific code. Do not put Home/Auth or other feature-specific Bloc files in another feature's folder.
- A feature's data layer implements its domain repository contract. The domain layer must not import the data or presentation layer.
- Keep feature-specific files inside their owning feature. Put only genuinely shared infrastructure and reusable components in `lib/core/`.

Data flow uses `dartz`'s `Either<Failure, T>` end to end instead of throwing: the data source throws or returns raw rows → the repository catches exceptions and maps them to `Failure` → the usecase passes the result through (or adds business rules) → the bloc folds it into a state → the page renders with `BlocConsumer`/`BlocBuilder`. Entities in `domain` are plain Dart and know nothing about sqflite or Flutter. Models in `data` extend or map to entities.

### State management

- **flutter_bloc** for all feature logic. Blocs are `@injectable`. Each page that needs a bloc gets it via `BlocProvider(create: (_) => getIt<...>())`.
- App-wide state (current session user and locale) must also use Blocs only (for example, `SessionBloc` and `LocaleBloc`) provided once in `lib/app.dart`. Do not use `SessionCubit`, `LocaleCubit`, or any other Cubit. The chosen locale is persisted in `shared_preferences`.
- DI is **get_it + injectable**. `lib/core/di/injection.dart` calls the generated `getIt.init()`. `service_module.dart` (`@module`) provides external singletons: the opened `Database` (`@preResolve`) and `SharedPreferences` (`@preResolve`). After adding or changing any annotated class, rerun build_runner.

### Local database (sqflite)

- One database, opened by `AppDatabase` in `lib/core/database/app_database.dart` (singleton). Enable foreign keys in `onConfigure` (`PRAGMA foreign_keys = ON`). Create tables in `onCreate`, then seed demo data in the same transaction. Schema changes go in a new numbered file under `migrations/` and a version bump — never edit an old migration.
- Table and column names are constants in `db_tables.dart`. Don't repeat string literals for table or column names in data sources.
- Main tables (20-table unified schema): `users`, `saved_passengers`, `bus_operators`, `stops`, `routes`, `trips`, `connection_rules`, `trip_seats`, `bookings`, `booking_legs`, `booking_passengers`, `demo_payments`, `tickets`, `ticket_legs`, `ticket_qr_tokens`, `ticket_cancellations`, `ticket_exchange_requests`, `ticket_exchange_history`, `ticket_revenue_splits`, `notifications`. Primary keys are `TEXT` UUIDs. There is no `app_preferences` table (`shared_preferences` is the sole preference/session store) and no `route_stops` table (trips are strictly point-to-point).
- Data sources are the **only** place that touches `Database`. They return raw rows or models, never entities with business rules applied.
- Seed data: demo operators (`bus_operators`, with `exchange_cutoff_minutes DEFAULT 120`), normalized `stops` and point-to-point `routes` including Dhaka → Rajshahi/Sylhet/Chattogram and a connecting pair Dhaka → Rangpur → Bogura on the same operator, `trips` for the next 7 days generated relative to the first launch (with `trip_seats` generated per trip; `available_seats` is derived from `trip_seats`), two demo users (for example Rahim and Karim, `avatar_key DEFAULT 'initials'`), and `connection_rules` (`min_buffer_minutes DEFAULT 30`, `max_buffer_minutes DEFAULT 240`). Keep seed code in `core/database/seed/` only.

### Seat holds and booking

- A seat hold on `trip_seats` supports four statuses (`available`, `held`, `booked`, `blocked` — where `blocked` is a seat unavailable for passenger booking). Holds set `status = 'held'`, `hold_expiry` (UTC epoch ms `INTEGER`), and **exactly one** owner identity (`hold_user_id` for signed-in users OR `hold_session_id` for guests; `hold_user_id` and `hold_session_id` cannot both be populated). `available`, `booked`, and `blocked` seats have no hold owner or expiry (`available` and `blocked` also have no `booking_id`). There is no background server, so expiry is **lazy**: in the same transaction that reads or books seats, treat rows with `hold_expiry < now` as free and clear them first. The countdown timer in the UI is only visual; the database is the source of truth.
- Booking is one transaction: re-check that every seat is still free or held by this caller → create `bookings` (`booking_status`: `pending_payment`, `payment_failed`, `payment_cancelled`, `confirmed`, `cancelled`, `partially_cancelled`; `payment_status`: `pending`, `paid`, `partially_refunded_demo`, `refunded_demo`; `user_id` nullable for guests with no `guest_session_id`), `booking_legs`, and immutable `booking_passengers` (`passenger_group_index` 1..4) → record `demo_payments` attempt (`idempotency_key`; retries use a new key) → on `success`, mark seats `booked` (clearing hold fields) and create one Master E-Ticket (`tickets`) per passenger (`ticket_legs` per leg) with one active `ticket_qr_tokens` hash. If any step fails, roll back and return `FailureType.CONFLICT` (seat taken) or `FailureType.HOLD_EXPIRED`.
- Payment is a demo adapter inside the `payment` feature. It must be labelled "Demo Payment" in the UI and must never claim real settlement.

### Innovation logic

- **Ticket Handover / Ticket Exchange** (`features/handover`). One atomic `db.transaction`: check eligibility (direct ticket is `issued`, unused, not cancelled, not expired, not handed over before, within `exchange_cutoff_minutes` [default 120], operator allows exchange) → create/advance `ticket_exchange_requests` → on operator approval and acceptance by the new passenger: keep `booking_passengers` immutable, set the old ticket to `revoked_exchanged`, revoke the old `ticket_qr_tokens` row, mark old `ticket_legs` `invalidated`, and create a new `tickets` row (`holder_name`, `holder_mobile`, `holder_email` from receiver) with a new `ticket_qr_tokens` hash and new `ticket_legs` → record `ticket_exchange_history` and `ticket_revenue_splits` (30% operator, 50% exchanger, 20% platform on Original Ticket Price; integer floor rounding for operator/platform, remainder to exchanger in integer poisha) → write `notifications` for both users. Any failure rolls everything back. Rounding lives in one pure function (`handover_calculator.dart`) and is unit-tested.
- **Demo Operator approval:** the Demo Operator screen in `settings` lists pending requests and lets the user Approve or Reject. It only changes `ticket_exchange_requests.status`; it is not an operator app.
- **Connecting Journey** (`features/connecting_journey`). Offer a connection only when a single query/usecase confirms **all four**: (1) both point-to-point trips belong to the same operator, (2) trip 1 ends at the hub and trip 2 starts at the same hub, (3) the wait between arrival and departure is between `min_buffer_minutes` (default 30) and `max_buffer_minutes` (default 240) from `connection_rules`, (4) both legs have enough free seats. Direct trips are always shown first. Booking creates one master booking with two `booking_legs`, one demo payment, and one Master E-Ticket per passenger (`ticket_legs` tracks independent per-leg boarding status: `pending`, `boarded`, `missed` with `missed_at`, `cancelled`, `invalidated`; missing an earlier leg does not automatically invalidate a later leg; Master ticket becomes `used` when all legs are boarded, `partially_used` when some boarded and some missed, `expired` when all legs missed). Never label a connection "guaranteed" before both legs are confirmed.

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
