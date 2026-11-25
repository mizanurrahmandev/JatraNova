# JatraNova --- Technical Requirements Specification

**Passenger Mobile Application · Local Demo · Version 1.1 · 24 November
2026**

## 1\. Purpose and Authority

This document defines technical implementation requirements for
JatraNova Passenger App. The updated **Project Flow** is the product
behaviour source; the separate **Database Design** file defines the
proposed SQLite schema. Do not modify the AGENTS/Agent Role file as part
of this document.

## 2\. Scope

### Included

* Passenger mobile app only.
* Flutter/Dart, offline-first local demo.
* SQLite through `sqflite`.
* BLoC only; feature-first Clean Architecture.
* English and Bangla localization; English default on first launch.
* Guest and signed-in flows.
* Bus search, direct booking, same-operator two-leg connecting
booking.
* Local demo payment, E-Ticket QR and Download Ticket.
* Guest exact Ticket Number lookup; signed-in My Tickets.
* Saved Friends/Family profiles for signed-in multi-passenger booking.
* Ticket Exchange demo, local notifications, profile/settings.
* Simulated journey progress from local data.

### Excluded

* Operator/admin/driver apps.
* Backend/API/Firebase/cloud database.
* Real payment gateway, money transfer or refund.
* OTP, SMS/email verification or real recovery service.
* Push notifications, live GPS or dispatch integration.
* Real operator approval or settlement.
* Unapproved features outside the Project Flow.

## 3\. Approved Technology Direction

\---

Concern                             Requirement

\---

Framework/language                  Flutter / Dart

State management                    `flutter\_bloc` with `Bloc`; no
Cubit

Equality                            `equatable`

Architecture                        Feature-first Clean Architecture

Database                            `sqflite` + `path`

DI                                  `get\_it`;
`injectable`/`build\_runner` where
approved

Result handling                     `dartz` where already adopted

Navigation                          Choose `go\_router` or Navigator and
use consistently

Localization                        `flutter\_localizations` + `intl`

Responsive UI                       `flutter\_screenutil`

QR                                  `qr\_flutter`

IDs                                 `uuid`

Preferences                         `shared\_preferences` for
non-sensitive preferences only

Tests                               `flutter\_test`, `bloc\_test`,
`mocktail`, `sqflite\_common\_ffi`

## Lints                               `flutter\_lints`

Do not add packages outside the approved dependency list without
explaining the need and obtaining approval. A PDF/export dependency for
Download Ticket requires approval if not already approved. Check package
compatibility with the installed Flutter/Dart SDK; do not hardcode
arbitrary versions.

## 4\. Mandatory Feature-First Folder Ownership

Feature-specific files must stay inside their own feature. Do not create
global feature-specific folders such as `lib/bloc/`, `lib/events/`,
`lib/states/`, `lib/usecases/`, or `lib/repositories/`.

``` text
lib/
  core/
    database/
    di/
    errors/
    localization/
    routing/
    theme/
    utils/
    widgets/
  features/
    home/
      data/datasources/
      data/models/
      data/repositories/
      domain/entities/
      domain/repositories/
      domain/usecases/
      presentation/bloc/
      presentation/pages/
      presentation/widgets/
    auth/
    search/
    booking/
    tickets/
    ticket\_exchange/
    profile/
    saved\_passengers/
    settings/
```

Each feature owns its BLoC, Event, State, pages, widgets, use cases,
repository interface/implementation, models and data sources. `core/` is
only for shared infrastructure and genuinely reusable components.

### Naming

* Interface: `IAuthRepository`
* Implementation: `AuthRepositoryImpl`
* Use case interface: `ILoginUsecase`
* Implementation: `LoginUsecaseImpl`
* Separate BLoC files: `<feature>\_bloc.dart`, `<feature>\_event.dart`,
`<feature>\_state.dart`
* Use `Equatable` for events/states where appropriate.
* Use `Bloc` classes only; never introduce Cubit.

## 5\. Startup and Session

### First launch

1. Initialize Flutter and dependency injection.
2. Initialize/migrate SQLite and safely seed reference demo data.
3. Read local preferences.
4. Show Splash.
5. Show Onboarding and Language Selection only if
`onboarding\_completed` is false.
6. English is selected by default; Bangla remains selectable.
7. Show Welcome Choice: Login, Create Account or Continue as Guest.
8. Persist onboarding completion and selected language.

### Second and later launches

* Open Home directly; do not automatically show Onboarding, Language
Selection or Welcome Choice again.
* Restore a valid local signed-in session and show signed-in Home.
* Without a signed-in session, show Guest Home directly.
* Apply saved language automatically.
* Keep Login/Create Account accessible through account actions and
protected-feature prompts.

## 6\. Authentication and Access

* Authentication is local demo behaviour only.
* Never store plaintext passwords.
* Do not silently convert a guest into a registered user.
* Protected features show Login Required with Login and Create
Account.
* Preserve search/booking context when prompting login for an
account-only feature.
* Do not force login during an otherwise permitted guest ticket
purchase.

## 7\. Permission Matrix

Capability                                         Guest   Signed-in

\---

Home, search, results and bus details                Yes         Yes
Seat selection                                       Yes         Yes
Buy ticket with demo payment                         Yes         Yes
Enter passenger details manually                     Yes         Yes
Purchase confirmation                                Yes         Yes
Exact Ticket Number lookup                           Yes         Yes
My Tickets list/history                               No         Yes
Profile management                                    No         Yes
Saved Friends/Family                                  No         Yes
Ticket Exchange                                       No         Yes
Account notification inbox                            No         Yes
Other account-only features               Login required         Yes

Guest lookup must return only the exact matching ticket, never a
browsable ticket list or complete history.

## 8\. Booking and Passenger Rules

### Signed-in

* Prefill Passenger 1 with the signed-in user's profile.
* Editing booking-time passenger details must not silently update the
saved profile.
* One account holder is one passenger by default.
* Each additional seat requires a separate saved Friend/Family
passenger profile.
* Each seat maps to exactly one passenger and that passenger's own
details.
* Never duplicate the account holder's profile into additional
passenger records.

### Guest

* Guest can purchase without login or account creation.
* Guest enters details manually for each selected seat.
* After successful demo payment, show ticket and unique Ticket Number;
explain Find My Ticket.

### Connecting journey

* One Master Booking (`bookings`) and exactly two Booking Legs (`booking_legs`).
* Trips are strictly point-to-point (one origin and one destination; no intermediate stops and no `route_stops` table).
* Apply same-operator, transfer point and approved buffer rules (`min_buffer_minutes DEFAULT 30`, `max_buffer_minutes DEFAULT 240`).
* Collect passenger identity once (`passenger_group_index` 1..4) and map that passenger to the appropriate seat on both legs.
* Issue one Master E-Ticket (`tickets`) per passenger mapped to both legs through `ticket_legs` (no `passenger_assignment_id`), with one active opaque QR token per passenger Master E-Ticket.
* Maintain independent per-leg `boarding_status` in `ticket_legs` (with `missed_at` UTC epoch ms when missed); missing an earlier leg does not automatically invalidate a later leg.
* Master ticket status transitions: all legs boarded → `used`; some boarded and some missed → `partially_used`; all legs missed → `expired`.
* One combined review and one demo payment.
* Keep each leg's trip, seat, departure and arrival details distinct.

## 9\. Ticket, QR and Download

* Generate a unique Ticket Number per passenger ticket.
* QR contains an opaque collision-resistant token only; never
passenger PII.
* Display relevant passenger, route, leg, seat, schedule, booking
reference and ticket status.
* Provide a visible **Download Ticket** action.
* Downloaded file must contain both QR code and ticket details; no
QR-only download as the sole option.
* Keep download local to the device.
* Obtain approval before adding an unapproved PDF/export package.
* Ticket Exchange must revoke the old QR and issue a new token
atomically.

## 10\. Ticket Exchange

* User-facing label: **Ticket Exchange** (table: `ticket_exchange_requests`; `handover_requests` is retired).
* Preserve eligibility, request, approval, receiver response and completion rules from Project Flow, with `bus_operators.exchange_cutoff_minutes DEFAULT 120`.
* Preserve original passenger snapshots in `booking_passengers`; store current holder info (`holder_name`, `holder_mobile`, `holder_email`) on `tickets`; mark exchanged old ticket `revoked_exchanged`.
* Execute exchange and QR replacement in one transaction.
* Revenue split is based on Original Ticket Price: Operator 30%, exchanger 50%, JatraNova 20% (integer poisha, floor rounding for operator and platform, remainder to exchanger).
* Store the split locally in `ticket_revenue_splits` for demo only; never imply real settlement or operator approval.

## 11\. BLoC and Clean Architecture

* Widgets must not execute SQL or contain business rules.
* BLoC receives events, invokes feature-owned use cases and emits
immutable states.
* Use cases validate business rules and coordinate repositories.
* Repository interfaces live in feature domain; implementations live
in feature data.
* Data sources own SQL and model mapping.
* Keep feature-specific BLoC/Event/State within the feature.
* Provide explicit loading, success, empty and failure states where
relevant.

## 12\. Persistence and Database

* SQLite (`sqflite`, not Drift) is the source of truth for local business records, following the approved 20-table schema in `JatraNova_Database_Design.md` and `JatraNova_Decision_Log.md`.
* Use versioned schema and sequential migrations; enable `PRAGMA foreign_keys = ON` on every connection.
* Store all monetary values as integer poisha (`*_minor INTEGER`, 100 poisha = ৳1) and all SQLite timestamps as UTC epoch milliseconds (`INTEGER`); the Domain Layer uses Dart `DateTime`.
* Use parameterized queries and `db.transaction` for seat holds, booking confirmation, demo payment, per-leg validation, cancellation, and Ticket Exchange.
* `bookings.booking_status` (`pending_payment`, `payment_failed`, `payment_cancelled`, `confirmed`, `cancelled`, `partially_cancelled`) and `bookings.payment_status` (`pending`, `paid`, `partially_refunded_demo`, `refunded_demo`) remain separate from `demo_payments.status` (`pending`, `success`, `failed`, `cancelled`) and `ticket_cancellations.refund_status` (`refund_pending_demo`, `refund_completed_demo`, `no_refund_applicable`).
* Never reseed over user-created bookings, tickets, saved passengers or preferences.
* `shared_preferences` is the sole store for preferences (`onboarding_completed`, `selected_language`, `bangla_numerals_enabled`) and demo session pointers (`session_user_id`, `remember_me`), never passwords/credential hashes; do not create an `app_preferences` SQLite table.

## 13\. Localization and UI

* Use `flutter_screenutil` for responsive UI dimension scaling. Initialize `ScreenUtilInit` at the application root and use `.w`, `.h`, `.sp` and `.r` consistently for appropriate dimensions, spacing, typography and radii.
* Confirm the design reference dimensions from the approved UI design; if they are not specified, ask for approval instead of assuming a design size.
* Use Flutter adaptive layout tools such as `LayoutBuilder`, `MediaQuery` and `SafeArea` where needed; ScreenUtil does not replace adaptive layout decisions. Verify layouts on compact, standard and large screens, with English and Bangla text, larger system text settings and keyboard visibility. Fix overflow, clipping and inaccessible controls.
* English default on first launch; Bangla selectable and persisted.
* All UI strings use localization resources.
* Format BDT consistently.
* Bus cards show available seats, never ratings.
* Show only facilities present in demo data.
* Clearly label demo payment, simulated tracking, local approval and
simulated notifications.
* Follow approved UI design for layout, typography, spacing, colours
and navigation.

## 14\. Error Handling and Security

* Validate inputs at presentation and domain boundaries.
* Convert database exceptions into user-friendly failures.
* Prevent duplicate booking/payment confirmation.
* Revalidate seats transactionally to prevent double allocation.
* Enforce ownership checks for saved passengers, profile, tickets and
notifications.
* Guest ticket lookup is exact-match only.
* Never log or encode passenger PII in QR payloads.
* Do not present local demo authentication as production security.

## 15\. Performance and Reliability

* Avoid expensive database operations in UI build paths.
* Limit or paginate long local lists when appropriate.
* Avoid unnecessary full-table queries.
* Dispose controllers/subscriptions correctly.
* Home and core workflows must work offline.
* Preserve user-created data through app restarts and schema
migrations.

## 16\. Testing Requirements

### Unit

* Use-case validation and business rules.
* Guest/signed-in access.
* Profile autofill and multi-passenger mapping.
* Connecting journey invariants.
* Ticket Number generation and exact lookup.
* Ticket Exchange transitions and revenue split.

### BLoC

* Loading/success/empty/error transitions.
* Session restore and Guest Home routing.
* Booking and demo payment outcomes.
* Guest ticket lookup.
* Saved passenger selection.
* Ticket Exchange flow.

### Database

* Schema and migrations; foreign keys and unique indexes.
* Seat collision and transaction rollback.
* Ticket/QR creation and old-token revocation.
* Exact Ticket Number lookup.
* Guest cannot browse ticket history.
* Saved passenger ownership constraints.

### Widget/integration

* First launch versus returning launch.
* Guest purchase without login.
* Guest can retrieve only the matching ticket.
* Signed-in passenger autofill.
* Additional seats require distinct Friend/Family records.
* Downloaded ticket includes QR and ticket details.
* Connecting journey creates one master booking and two legs.

## 17\. Antigravity Workflow

1. Read approved UI Design, updated Project Flow, Agent Role, Database
Design and this Technical Requirements document completely.
2. Do not code immediately. Produce a requirement audit, architecture
confirmation, database relationship review, conflict list and
pending-decision list.
3. Wait for explicit user approval before implementation.
4. Implement one small feature/phase at a time.
5. Before each phase, list prerequisites, planned files and acceptance
checks.
6. After each phase, report changed files, behaviours, tests/results,
known issues and next phase.
7. Do not mark a phase complete unless acceptance checks pass.
8. If requirements conflict or are ambiguous, stop and ask; do not
invent policy values.
9. Keep Passenger App and local-demo boundaries unchanged.
10. Do not modify AGENTS/Agent Role as part of these specifications.

## 18\. Remaining Unresolved Decisions --- Do Not Guess

* Credential-storage hashing implementation details (`PD-T06`, e.g., salted SHA-256 confirmation for Phase 3 Auth).
* Abandoned `pending_payment` / `payment_failed` / `payment_cancelled` draft expiry handling (`R-01`), multi-seat cancellation UX & demo refund completion trigger (`R-02`), `bookings.payment_status` behavior on `0%` (`no_refund_applicable`) cancellation, back-navigation hold timer (`R-03`), `Find My Ticket` display for `revoked_exchanged` (`R-04`), guest cancellation (`R-06`), and post-exchange receiver ticket cancellation eligibility.
* PDF/export package deferral (`pdf`, `path_provider`, `share_plus`) until Phase 7.

