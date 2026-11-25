# JatraNova — Phase 0/2 Conflict-Resolution & Decision Log

**Document Status:** `Database Baseline Approved` *(User Confirmed Master E-Ticket & Unified 20-Table Database Architecture; remaining non-DDL behavioral/UI items await confirmation)*  
**Scope:** JatraNova Passenger App (Local Offline Demo)  
**Date:** 2026-11-25 (Phase 2 Consolidated Database & Specification Alignment)  
**Authority References:**
- `AGENTS.md` (Aligned with approved database, C-08, and exchange-split baseline)
- `JatraNova_Project_Flow_Updated.md` (v1.0 + v1.1 Product Behaviour)
- `JatraNova_Database_Design.md` (v1.2 Aligned 20-Table SQLite Schema)
- `JatraNova_Technical_Requirements.md` (v1.1 Aligned Persistence & Domain Rules)

> **Status Note:** **Master E-Ticket (`UC-01`)** and the **Unified 20-Table SQLite Architecture** (Guest Identity, Payment Failure/Cancellation `bookings` statuses, Refund Lifecycle, Partial Refund statuses, Missed Boarding & `missed_at`, Master Ticket terminal statuses `used`/`partially_used`/`expired`, Point-to-Point Trips, `trip_seats` mutually exclusive hold ownership, Exchange Holder Snapshot, `passenger_group_index` `1..4` & `R-07` FKs, `ticket_cancellations` `0/75/100` tiers, approved defaults, `C-08` poisha/UTC epoch ms, and 30/50/20 floor-rounding exchange split) are **`User Confirmed` / `Approved`**. Remaining behavioral/UI items and minor schema clarifications are explicitly tracked in Section 9.1.

---

## 1. Locked Baseline, User Confirmed & Proposed Decisions

### 1.1 Baseline Requirements Consistent Across Specifications
*(These items already agree across the four source documents and establish the project baseline.)*

| ID | Area | Baseline Requirement | Source |
| :--- | :--- | :--- | :--- |
| **L-01** | Product Scope | Passenger mobile app only; offline-first local demo (`sqflite`). No backend, REST API, Firebase, real payments, OTP, push notifications, live GPS, or operator/admin/driver apps. | All 4 docs |
| **L-02** | Architecture | Feature-first Clean Architecture (`presentation -> domain <- data`) with strict feature ownership; no global `lib/bloc/`, `lib/usecases/`, etc. | `AGENTS.md`, `Tech Req` |
| **L-03** | State Management | `flutter_bloc` with **`Bloc` only** (`<name>_bloc.dart`, `_event.dart`, `_state.dart`, `Equatable`). No `Cubit`, `Provider`, `ChangeNotifier` (feature logic), `Riverpod`, or `GetX`. | `AGENTS.md`, `Tech Req` |
| **L-04** | DI & Result Types | `get_it` + `injectable` (`@injectable`, `@singleton`, `@module`) + `dartz` (`Either<Failure, T>`) + hand-written `fromMap`/`toMap` models (no `freezed`/`json_serializable`). | `AGENTS.md`, `Tech Req` |
| **L-05** | Guest Lookup Privacy | Guest **Find My Ticket** accepts exact unique, non-sequential `ticket_number` only and displays only that matching ticket; never exposes ticket history or lists. | `Project Flow v1.1`, `DB Design`, `Tech Req` |
| **L-06** | Passenger Mapping (v1.1) | Signed-in Passenger 1 autofills from account profile (booking-time edits do not overwrite saved profile). Each extra seat requires a distinct Saved Friend/Family profile. Guests enter each passenger manually. Connecting journeys collect passenger identity once and map to both legs. | `Project Flow v1.1`, `DB Design`, `Tech Req` |
| **L-07** | QR & Ticket Security | QR encodes **only** an opaque random/UUID token (zero PII). Only one active QR token per ticket. Old QR is revoked atomically on Ticket Exchange or Cancellation. | All 4 docs |
| **L-08** | Connecting Journey Invariants | Exactly 2 legs, **same operator**, matching transfer hub, wait within `[min_buffer, max_wait]`, sufficient free seats on both legs, 1 Master Booking + 2 Booking Legs + 1 Demo Payment + 1 Master E-Ticket per passenger. Direct trips always separated from connecting trips. | All 4 docs + `UC-01` |
| **L-09** | Bus Cards & Demo Labels | Bus cards display **Available Seats** (never ratings) and only dataset-backed facilities. Demo Payment, Demo Operator Approval, Demo Refunds, and Demo Journey Tracking must be clearly labelled as Demo. | `Project Flow`, `Tech Req` |

### 1.2 User Confirmed Product Decisions

| ID | Decision Topic | Confirmed Requirement | Status |
| :--- | :--- | :--- | :--- |
| **UC-01** | **Master E-Ticket for Connecting Journeys** | **A Connecting Journey must use one Master E-Ticket per passenger, not separate tickets for each leg.**<br>1. Each passenger receives one Master E-Ticket covering the complete Connecting Journey (both legs and both seats).<br>2. Each passenger has one QR code (one active opaque non-guessable token, zero PII) associated with their Master E-Ticket.<br>3. The same QR code is used for boarding validation on either leg using current leg context.<br>4. Each leg maintains independent boarding/validation status (`ticket_legs`).<br>5. A passenger validated on Leg 1 remains eligible for validation on Leg 2.<br>6. Duplicate validation on the same leg is prevented atomically.<br>7. Revoked, exchanged (`revoked_exchanged`), cancelled, fully `used`, or otherwise invalid tickets cannot pass validation.<br>8. Works uniformly for both direct (1 leg) and connecting (2 legs) journeys without duplicate ticket records, and remains compatible with passenger-ticket-level Ticket Exchange. | **`User Confirmed`** |

### 1.3 Proposed Decisions (All `Proposed — Awaiting Approval`)

#### A. Proposed Product Decisions
| ID | Decision Topic | Proposed Value | Status |
| :--- | :--- | :--- | :--- |
| **PD-P01** | Default first-launch language | **English** is the default application language (Bangla selectable on first launch and in Settings) | `Proposed — Awaiting Approval` |
| **PD-P02** | Guest booking permission | Guest users **can** complete the entire demo booking process without registration | `Proposed — Awaiting Approval` |
| **PD-P03** | Returning launch routing | Returning users without an authenticated session enter **Guest Home** directly (not Welcome Choice) | `Proposed — Awaiting Approval` |
| **PD-P04** | Bottom navigation tabs | **Home, Search, My Tickets, Profile** (4 tabs) | `Proposed — Awaiting Approval` |
| **PD-P05** | Scope exclusions | Preserve agreed exclusions: exclude **Filter & Sort, Forgot Password, Dark Theme, Promo Codes, Discounts, Service Charges** from initial scope | `Proposed — Awaiting Approval` |
| **PD-P06** | Operator approval UI | Use a manually controlled **Demo Operator Approval** screen under **Settings** | `Proposed — Awaiting Approval` |
| **PD-P07** | User-facing exchange term | Use **"Ticket Exchange"** in all user-facing terminology | `Proposed — Awaiting Approval` |
| **PD-P08** | Internal folder convention | Keep **`features/handover/`** as the internal feature folder name | `Proposed — Awaiting Approval` |
| **PD-P09** | Money storage unit | Store monetary values as integer **poisha** (`*_minor INTEGER`, 100 poisha = ৳1) | `User Confirmed` |
| **PD-P10** | Timestamp storage format | Store SQLite timestamps as **UTC epoch milliseconds** (`INTEGER`); Domain uses Dart `DateTime` | `User Confirmed` |
| **PD-P11** | Ticket Exchange revenue split | Fixed split: **Bus Operator 30%, Ticket Exchanger 50%, JatraNova Platform 20%**, calculated strictly from **Original Ticket Price** (not exchange price) | `User Confirmed` |

#### B. Business Decisions
| ID | Business Rule | Value | Status |
| :--- | :--- | :--- | :--- |
| **PD-B01** | Ticket Exchange cutoff | **2 hours** (`120` min default in `bus_operators.exchange_cutoff_minutes DEFAULT 120`) before departure | `User Confirmed` |
| **PD-B02** | Connecting ticket exchangeability | Connecting Journey tickets **cannot be exchanged** in the initial version | `Proposed — Awaiting Approval` |
| **PD-B03** | Receiver payment on exchange | Informational only; no real payment or settlement | `Proposed — Awaiting Approval` |
| **PD-B04** | Max passengers per booking | **4** passengers maximum per booking (`CHECK(passenger_group_index BETWEEN 1 AND 4)`) | `User Confirmed` |
| **PD-B05** | Seat hold duration | **5 minutes** (`300,000 ms`, lazy DB expiry) | `Proposed — Awaiting Approval` |
| **PD-B06** | Connecting Journey buffer limits | Minimum **30 minutes**, maximum **240 minutes** (`min_buffer_minutes DEFAULT 30`, `max_buffer_minutes DEFAULT 240`) | `User Confirmed` |
| **PD-B07** | Connecting booking cancellation | Cancellation of a connecting booking applies to **all legs together** (entire Master Booking) | `Proposed — Awaiting Approval` |
| **PD-B08** | Post-registration flow | Successful registration **automatically logs the user in** (opens Home) | `Proposed — Awaiting Approval` |
| **PD-B09** | Profile image handling | Use **preset avatars or initials** only (`users.avatar_key DEFAULT 'initials'`) | `User Confirmed` |
| **PD-B10** | Demo Payment outcomes | Demo Payment supports **Success**, **Failed**, and **Cancelled** outcomes | `Explicitly Defined` |
| **PD-B11** | Journey Tracking (Demo) | Journey tracking uses **manually simulated progress** | `Proposed — Awaiting Approval` |
| **PD-B12** | Demo cancellation policy & exact boundaries | Based on `delta = departure_at - now` at cancellation time:<br>• `delta >= 24 hours`: **100%** demo refund<br>• `6 hours <= delta < 24 hours`: **75%** demo refund<br>• `0 < delta < 6 hours`: **0%** demo refund<br>• `delta <= 0`: **Not Eligible** (`CHECK(refund_percentage IN (0, 75, 100))`) | `User Confirmed` |

#### C. Proposed Technical Decisions
| ID | Technical Area | Proposed Value | Status |
| :--- | :--- | :--- | :--- |
| **PD-T01** | Responsive UI scaling | Propose **`flutter_screenutil`**, subject to Flutter/Dart SDK compatibility verification | `Proposed — Awaiting Approval` |
| **PD-T02** | Design reference dimensions | **`375 x 812`** (`Size(375, 812)` in `ScreenUtilInit`) | `Proposed — Awaiting Approval` |
| **PD-T03** | Download Ticket format | Local **PDF** containing complete ticket details and QR code | `Proposed — Awaiting Approval` |
| **PD-T04** | Share Ticket behaviour | **Local file sharing** only (sharing the generated local PDF) | `Proposed — Awaiting Approval` |
| **PD-T05** | Export / share packages | Propose **`pdf`**, **`path_provider`**, **`share_plus`**, subject to SDK compatibility verification | `Proposed — Awaiting Approval` |
| **PD-T06** | Credential storage | Local demo authentication using salted SHA-256 via **`crypto`** in SQLite `users.credential_hash`. **Explicit Security Notice:** Salted SHA-256 is suitable **only** for this offline local demonstration and is **not** production-grade password security (production requires adaptive KDFs such as Argon2id/bcrypt/PBKDF2 and server-side auth). | `Proposed — Awaiting Approval` |
| **PD-T07** | Session & preferences truth | Use **`shared_preferences`** as the sole source of truth for preferences and session state (no duplicate SQLite `app_preferences` table) | `User Confirmed` |

---

## 2. Resolutions for Questions Q-01 to Q-10

| ID | Question | Resolution | Status |
| :--- | :--- | :--- | :--- |
| **Q-01** | `Remember Me` checkbox behaviour on Login | **Checked** = persistent login across app restarts (`session_user_id` stored in `shared_preferences`). **Unchecked** = session-only login held in memory (cleared on app close/restart, returning to Guest Home next launch). | `User Confirmed` *(Phase 1)* |
| **Q-02** | Single source of truth for preferences & session | Use **`shared_preferences`** as the sole preference and session storage mechanism (`onboarding_completed`, `selected_language`, `bangla_numerals_enabled`, `session_user_id`, `remember_me`). **Do not create a duplicate `app_preferences` database table.** | `User Confirmed` |
| **Q-03** | `core/` sub-folder names & `saved_passengers` placement | Use **`core/error`** for error components, **`core/route`** for routing, **`lib/l10n`** for localization resources, and keep **Saved Passengers** as an independent feature (**`features/saved_passengers/`**). | `User Confirmed` *(Phase 1)* |
| **Q-04** | Normalized `stops`/`routes` & `trip_seats` PK | Preserve normalized **`stops`** and **`routes`** tables (no `route_stops`), and use **`trip_seats.id`** as the primary key (with `UNIQUE(trip_id, seat_number)`). | `User Confirmed` |
| **Q-05** | Old ticket status & receiver info on Ticket Exchange | Original ticket receives status **`revoked_exchanged`**. The newly issued ticket displays the **new ticket holder's information** (`holder_name`, `holder_mobile`, `holder_email`) while preserving the original `booking_passengers` snapshot intact. | `User Confirmed` |
| **Q-06** | Single-device receiver demonstration UX | For single-device testing of Ticket Exchange receiver acceptance, the original user **logs out** and the receiver **logs in on the same device** (e.g., seeded accounts Rahim and Karim), accessing the approved request via Notifications or Exchange History. | `Proposed — Awaiting Approval` |
| **Q-07** | Demo Payment failure/cancelled controls | Provide explicit Demo Payment controls for **Success**, **Failed**, and **Cancelled** outcomes (clearly labelled Demo Simulation). | `Proposed — Awaiting Approval` |
| **Q-08** | Cancellation demo refund lifecycle & labels | Refund starts as `refund_pending_demo` on `ticket_cancellations` and transitions to `refund_completed_demo` on successful demo refund (reconciled with Refund Lifecycle Approach B; `0%` tier uses `no_refund_applicable`). | `User Confirmed` *(reconciled via Refund Lifecycle)* |
| **Q-09** | Optional Bangla numerals toggle | Optional **Bangla Numerals** setting in Settings (persisted in `shared_preferences`). | `Explicitly Defined` / `User Confirmed` |
| **Q-10** | Integer rounding remainder in 30/50/20 split | Calculate **Operator (30%)** and **Platform (20%)** shares using **floor rounding** (`(price * 30) ~/ 100`, `(price * 20) ~/ 100`). Assign the **remaining amount** (`price - operatorShare - platformShare`) to the **Exchanger** so all three shares always sum exactly to `Original Ticket Price`. | `User Confirmed` |

---

## 3. Conflict-by-Conflict Resolution Table

| Conflict ID | Conflicting Documents | Exact Conflicting Requirements | Technical / Product Impact | Proposed Resolution | Source Files Eventually Requiring Updates | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **C-01** | `AGENTS.md` vs `Project Flow` (v1.0/v1.1), `DB Design`, `Tech Req` | `AGENTS.md` states *"Bangla is the default locale"*. The other 3 docs state **English** is default on first launch. | Determines initial `LocaleBloc` state and default Language Selection card. | Set **English** as default first-launch language (PD-P01); Bangla remains selectable. | `AGENTS.md` | `Proposed — Awaiting Approval` |
| **C-02** | `AGENTS.md` & `Project Flow v1.0` vs `Project Flow v1.1` & `Tech Req` | `AGENTS.md` says *"Redirect unauthenticated users to login"* and v1.0 table requires login for booking; v1.1 mandates Guest Home on returning launch and full Guest booking. | Controls `AppRoute` redirect guard, nullable `user_id` on `bookings`/`tickets`, and guest seat holds. | Adopt **Project Flow v1.1**: Guest booking allowed (PD-P02), returning unauthenticated launch enters Guest Home (PD-P03); restrict auth guard to account-only routes. | `AGENTS.md`, `JatraNova_Project_Flow_Updated.md` (v1.0 table cross-reference) | `Proposed — Awaiting Approval` |
| **C-03** | `AGENTS.md` vs `Project Flow` (Sec 1.2 & #6) | `AGENTS.md` lists `(Home, Tickets, Track, Profile)`. `Project Flow` lists `(Home, Search, My Tickets, Profile)`. | Defines the 4 tabs in `app_bottom_nav` and shell branches. | Use **`Home, Search, My Tickets, Profile`** (PD-P04); reach Journey Tracking (Demo) from E-Ticket & Home/Active Journey shortcut. | `AGENTS.md` | `Proposed — Awaiting Approval` |
| **C-04** | `AGENTS.md` vs `Project Flow` (v1.0) | `Project Flow` v1.0 includes Filter & Sort (#12), Forgot Password (#5b), Light & Dark Theme (#8), and conditional Discounts/Service Charge (#16). `AGENTS.md` excludes them. | Prevents scope creep and clarifies screen inventory for Phase 1–9. | Enforce agreed exclusions: **exclude** Filter & Sort, Forgot Password, Dark Theme, Promo Codes, Discounts, and Service Charges from initial scope (PD-P05). | `JatraNova_Project_Flow_Updated.md` (scope note) | `Proposed — Awaiting Approval` |
| **C-05** | `AGENTS.md` vs `Project Flow` (#27) | `AGENTS.md` requires a manual **Demo Operator** screen under `settings`; `Project Flow` describes a rule-based local approval engine. | Determines how Pending exchange requests become Approved/Rejected. | Use a **manually controlled Demo Operator** screen under Settings (PD-P06). | `JatraNova_Project_Flow_Updated.md` (Sec 6 #27 note) | `Proposed — Awaiting Approval` |
| **C-06** | `AGENTS.md` vs `Tech Req` & `DB Design` | `AGENTS.md` uses `features/handover/`, `core/error/`, `core/route/`, `lib/l10n/`, "Ticket Handover", and 12 features. `Tech Req` uses `ticket_exchange`, `core/errors/`, `core/routing/`, `core/localization/`, adds `saved_passengers`/`profile`, and mandates **"Ticket Exchange"** in UI. | Affects directory structure, localization keys, and UI copy. | Use **"Ticket Exchange"** in all user-facing text (PD-P07); keep **`features/handover/`**, **`core/error/`**, **`core/route/`**, **`lib/l10n/`**; add **`features/saved_passengers/`** as an independent feature (PD-P08, Q-03). | `AGENTS.md` (add `saved_passengers`), `JatraNova_Technical_Requirements.md` (folder tree note) | `Proposed — Awaiting Approval` |
| **C-07** | `AGENTS.md` vs `DB Design` | `AGENTS.md` listed 13 tables; `DB Design` v1.1 listed 16 tables without `stops`/`routes`/`connection_rules`/`ticket_legs`/`ticket_cancellations` and included `app_preferences`. | Unified SQLite schema creation. | **Approved 20-table unified architecture** (Section 5); no `app_preferences`, no `route_stops`, no `handover_requests`, no `passenger_assignment_id`. | `AGENTS.md`, `JatraNova_Database_Design.md` *(Aligned)* | `User Confirmed` |
| **C-08** | `AGENTS.md` vs `DB Design` | `AGENTS.md`: whole BDT `INTEGER` & UTC epoch ms `INTEGER`. `DB Design`: `*_minor INTEGER` (poisha) & ISO-8601 `TEXT`. | Financial columns, timestamps, formatters, and calculators. | Store money as **integer poisha** (`*_minor INTEGER`, PD-P09) and SQLite timestamps as **UTC epoch milliseconds** (`INTEGER`, PD-P10); Domain uses Dart `DateTime`. | `AGENTS.md`, `JatraNova_Database_Design.md` *(Aligned)* | `User Confirmed` |
| **C-09** | `AGENTS.md` vs `Project Flow` / `DB Design` / `Tech Req` | `AGENTS.md` mentioned 50% refund + variable `handover_commission_pct` without JatraNova 20%. The other 3 docs fix **30% Operator / 50% Exchanger / 20% JatraNova**. | Determines `handover_calculator.dart` and `ticket_revenue_splits`. | Fixed **30% / 50% / 20%** split on Original Ticket Price with floor rounding for Operator & Platform and remainder to Exchanger (PD-P11, Q-10). | `AGENTS.md` *(Aligned)* | `User Confirmed` |
| **C-10** | `AGENTS.md` vs `Tech Req` | `Tech Req` mandates `flutter_screenutil` and PDF/export for Download Ticket; `AGENTS.md` forbids unapproved packages. | `pubspec.yaml` dependencies. | `flutter_screenutil` (`375x812`) added in Phase 1; PDF/share packages deferred to Phase 7. | `AGENTS.md` (`flutter_screenutil` note pending) | `Partially Approved` (`flutter_screenutil` Phase 1; PDF deferred) |
| **C-11** | `AGENTS.md` vs `Tech Req` & `DB Design` | `AGENTS.md` uses `crypto` SHA-256 + `user_id` in `shared_preferences`. `DB Design` v1.1 added `app_preferences` table. `Tech Req` restricted `shared_preferences` to non-sensitive prefs. | Preference & session store. | Use **`shared_preferences`** as sole preference/session store (`session_user_id`, `remember_me`, prefs; no passwords/hashes); drop `app_preferences` table (PD-T07, Q-01, Q-02). Salted SHA-256 (`PD-T06`) remains pending Phase 3 review. | `JatraNova_Database_Design.md`, `JatraNova_Technical_Requirements.md` *(Aligned)* | `User Confirmed` *(storage)* / `Proposed` (`PD-T06`) |

---

## 4. Technical Review Findings (`R-01`–`R-07`) & Master E-Ticket Architecture

### 4.1 Technical Review Items (`R-01`–`R-07`)

#### R-01: Payment Idempotency & Failed/Cancelled Booking Status (`User Confirmed` / `Approved`, except abandoned draft expiry)
- **Approved Resolution (`User Confirmed`):**
  1. **One Booking Draft & Separate Attempt Status:** Keep `bookings.booking_status` and `bookings.payment_status` distinct from individual `demo_payments.status` attempts (`pending`, `success`, `failed`, `cancelled`).
  2. **Guest Identity (`Approach A` — `User Confirmed`):** `bookings.user_id` is nullable; guest bookings do **not** require `guest_session_id` and are identified by the unique `bookings.id` UUID.
  3. **Payment Failure / Cancellation (`Approach B` — `User Confirmed`):**
     - Failed payment sets `bookings.booking_status = 'payment_failed'`.
     - Cancelled payment sets `bookings.booking_status = 'payment_cancelled'`.
     - Retrying may transition `bookings.booking_status` back to `'pending_payment'`, keeps `bookings.payment_status = 'pending'`, records a separate `demo_payments` row with a **new `idempotency_key`**, and issues zero tickets unless `demo_payments.status == 'success'`.
  4. **Idempotency Key & Request Fingerprint Validation:**
     - Repeated submission of the exact same request reuses the same `idempotency_key` and replays the stored attempt outcome without creating duplicate records/tickets.
     - Fingerprint compares `booking_id`, `amount_minor`, `method`, `booking_type`, and `user_id` (`NULL` for guest bookings). Mismatched request rejects with `FailureType.CONFLICT`.
     - `uidx_demo_payments_success_booking` enforces at most one `'success'` attempt per booking.
- **Affected Tables & Constraints:**
  - `demo_payments`: `idempotency_key TEXT NOT NULL UNIQUE`, `booking_id`, `method`, `amount_minor`, `uidx_demo_payments_success_booking`.
  - `bookings`: `user_id NULL` (no `guest_session_id`), `booking_status IN ('pending_payment', 'payment_failed', 'payment_cancelled', 'confirmed', 'cancelled', 'partially_cancelled')`, `payment_status IN ('pending', 'paid', 'partially_refunded_demo', 'refunded_demo')`.
- **Remaining Unresolved Rule (`Unresolved — Requires Clarification`, non-DDL):** Confirm whether an abandoned `pending_payment` / `payment_failed` / `payment_cancelled` booking draft expires automatically once its 5-minute seat hold expires (seats return to `'available'` via lazy expiry, and retrying after hold expiry returns `FailureType.HOLD_EXPIRED` if lost).

#### R-02: Multiple Ticket Cancellation Records & Refund Lifecycle (`User Confirmed` / `Approved` DDL, remaining UX rules `Unresolved`)
- **Approved Resolution (`User Confirmed`):**
  1. Dedicated **`ticket_cancellations`** table (`UNIQUE(ticket_id)`) with composite **`FOREIGN KEY (ticket_id, booking_id) REFERENCES tickets(id, booking_id) ON DELETE CASCADE`**.
  2. **Refund Lifecycle (`Approach B` — `User Confirmed`):** Refunds begin as `'refund_pending_demo'` in `ticket_cancellations.refund_status` and transition to `'refund_completed_demo'` on successful demo refund (`'no_refund_applicable'` for `< 6h` `0%` tier).
  3. **Partial Refund (`Approach B` — `User Confirmed`):** Pending refund state lives on `ticket_cancellations.refund_status`; `bookings.payment_status` supports `'pending'`, `'paid'`, `'partially_refunded_demo'`, and `'refunded_demo'` (never `'refund_pending_demo'`/`'refund_completed_demo'`). `bookings.booking_status` uses `'partially_cancelled'` or `'cancelled'`.
- **Remaining Unresolved Rules (`Unresolved — Requires Clarification`, non-DDL):**
  1. Multi-seat direct cancellation UX (cancel one ticket at a time vs optional "Cancel All My Tickets").
  2. Exact demo trigger/action that transitions `ticket_cancellations.refund_status` from `'refund_pending_demo'` to `'refund_completed_demo'`, and what `bookings.payment_status` stays at when all cancelled tickets fall in the `0%` (`no_refund_applicable`) tier or while a refund is `refund_pending_demo`.

#### R-03: Seat Hold Integrity (`User Confirmed` / `Approved` DDL, back-nav timer `Unresolved`)
- **Approved Resolution (`User Confirmed`):**
  - SQLite is the sole source of truth for seat availability and hold expiry.
  - `trip_seats` includes `hold_user_id`, `hold_session_id`, `hold_expiry`, and four supported `status` values (`'available'`, `'held'`, `'booked'`, `'blocked'` — where `'blocked'` is a seat not available for passenger booking):
    - **`available`**: no hold owner (`hold_user_id IS NULL AND hold_session_id IS NULL`), no `hold_expiry`, no `booking_id`.
    - **`held`**: **exactly one** owner identity (`hold_user_id` for signed-in OR `hold_session_id` for guest; **`hold_user_id` and `hold_session_id` cannot both be populated**), non-null `hold_expiry`, and `booking_id IS NULL`.
    - **`booked`**: non-null `booking_id`, no hold owner (`hold_user_id IS NULL AND hold_session_id IS NULL`), no `hold_expiry`.
    - **`blocked`**: seat not available for passenger booking; no hold owner (`hold_user_id IS NULL AND hold_session_id IS NULL`), no `hold_expiry`, no `booking_id`.
- **Remaining Unresolved Rule (`Unresolved — Requires Clarification`, non-DDL):** When navigating backward from Booking Review / Demo Payment to Seat Selection within the hold window, confirm whether the hold timer keeps its remaining countdown (recommended) or resets.

#### R-04: Ticket Lookup After Exchange (`Proposed — Awaiting Approval` / `Unresolved`)
- **Proposed Resolution:** Filter `My Tickets` active view to non-revoked tickets (`status IN ('issued', 'used', 'partially_used', 'expired')`), show `revoked_exchanged` in historical exchange views without receiver PII/QR, validate QR strictly on `ticket_qr_tokens.status = 'active' AND tickets.status = 'issued'`.
- **Unresolved Rule (`Unresolved — Requires Clarification`, non-DDL):** Confirm whether `Find My Ticket` lookup of a `revoked_exchanged` `ticket_number` displays `"This ticket was exchanged and is no longer valid"` (no receiver PII — recommended) or `"Ticket not found"`.

#### R-05: Trip & Route Consistency (`User Confirmed`)
- **Approved Resolution (`User Confirmed` — `Trip Structure Approach A`):**
  1. Every trip is strictly **point-to-point** (one origin stop, one destination stop, no intermediate boarding/drop-off stops, **no `route_stops` table**).
  2. Normalized **`stops`** and **`routes`** (`UNIQUE(id, origin_stop_id, destination_stop_id)`), composite FK on `trips`, `CHECK(arrival_at > departure_at)`, `CHECK(origin_stop_id != destination_stop_id)`.
  3. `available_seats` is derived dynamically from `trip_seats` (no redundant column on `trips`).

#### R-06: Guest Ticket Cancellation (`Unresolved — Requires Clarification`, non-DDL)
- **Unresolved Options:** **Option A (Signed-in only, recommended)** vs **Option B (Guest cancellation from `Find My Ticket` with `holder_mobile` verification)**. (`ticket_cancellations.cancelled_by_user_id` is nullable, so DDL is unaffected.)

#### R-07: Master E-Ticket Relational Integrity (`User Confirmed`)
- **Approved Resolution (`User Confirmed`):**
  1. One Master E-Ticket per passenger per booking (`passenger_group_index` `1..4`, `CHECK(passenger_group_index BETWEEN 1 AND 4)`). Do **not** use `passenger_assignment_id`.
  2. Composite FKs across `booking_legs`, `booking_passengers`, `trip_seats`, `tickets`, and `ticket_legs` structurally enforce booking/leg/trip/seat/passenger consistency inside SQLite (`PRAGMA foreign_keys = ON`).

---

### 4.2 How Master E-Ticket & Per-Leg QR Validation Work (`User Confirmed` Behaviour + `Proposed` Schema Mechanics)

#### A. Master E-Ticket Structure (Direct & Connecting)
- **Direct Booking (`N` passengers, 1 leg):** Creates `1` `bookings`, `1` `booking_legs`, `N` `booking_passengers`, `N` `tickets`, `N` active `ticket_qr_tokens`, and `N` `ticket_legs` (`leg_order = 1`).
- **Connecting Booking (`N` passengers, 2 legs):** Creates `1` Master `bookings`, `2` `booking_legs` (`leg_order = 1`, `leg_order = 2`), `2 × N` `booking_passengers` (`passenger_group_index` `1..N` across both legs), **`N` Master E-Tickets** (`tickets`, one per passenger), **`N` active QR tokens** (`ticket_qr_tokens`, one per Master E-Ticket), and **`2 × N` `ticket_legs` rows** (`leg_order = 1` and `leg_order = 2` for each Master E-Ticket).
- **UI & PDF Presentation:** E-Ticket / Combined E-Ticket displays the single `ticket_number`, single QR code, current `tickets.holder_*` name/mobile, and joins `ticket_legs → booking_legs → trips` & `booking_passengers` to show both legs' distinct bus/departure/arrival/transfer/seat details without creating duplicate tickets.

#### B. Per-Leg QR Validation & Duplicate-Boarding Prevention (`db.transaction`)
1. **Inputs:** Opaque QR token string `rawToken` (contains **zero** PII) + current leg validation context (`targetTripId` or `targetBookingLegId` from demo boarding/validation context).
2. **Step 1 — Token & Ticket Verification:**
   - Compute `tokenHash = SHA-256(rawToken)`.
   - Look up `ticket_qr_tokens` + `tickets` where `token_hash = ?`.
   - Reject if not found, `ticket_qr_tokens.status != 'active'`, or `tickets.status != 'issued'` (blocks `revoked_exchanged`, `cancelled`, `used`, `invalidated`).
3. **Step 2 — Leg Context Resolution:**
   - Query `ticket_legs` joined with `booking_legs` for `ticket_id = ticket.id` matching `booking_legs.trip_id = targetTripId` (or `booking_leg_id = targetBookingLegId`).
   - Reject if no matching leg exists on this Master E-Ticket (prevents validating a Leg 1 bus with a ticket for an unrelated trip).
4. **Step 3 — Atomic Duplicate-Boarding Prevention:**
   - Check `ticket_legs.boarding_status`:
     - If `'boarded'` → reject as **Already Validated / Boarded on This Leg** (`FailureType.CONFLICT`).
     - If `'cancelled'`, `'invalidated'`, or `'missed'` → reject (`FailureType.NOT_ELIGIBLE`).
   - Execute guarded update: `UPDATE ticket_legs SET boarding_status = 'boarded', validated_at = ?, validated_by_demo_context = ? WHERE id = ? AND boarding_status = 'pending'`. Require `affectedRows == 1`.
5. **Step 4 — Sequential Leg Eligibility & Master Ticket Completion:**
   - Query remaining `ticket_legs` for `ticket_id`:
     - If **Leg 1** was just boarded on a 2-leg ticket, **Leg 2** remains `boarding_status = 'pending'` and `tickets.status` stays `'issued'`, so the same QR code remains eligible when boarding Leg 2.
     - Once **all** `ticket_legs` for `ticket_id` have `boarding_status = 'boarded'`, update `tickets.status = 'used'` (and see Section 4.2D regarding `ticket_qr_tokens` revocation on terminal completion).

#### C. Master E-Ticket Compatibility with Ticket Exchange
- Ownership transfer operates at the **`tickets` (passenger-ticket) level**:
  - Old `tickets` row → `status = 'revoked_exchanged'`.
  - Old `ticket_qr_tokens` → `status = 'revoked'`.
  - Old `ticket_legs` rows → `boarding_status = 'invalidated'`.
  - New `tickets` row issued to `receiver_user_id` (`holder_*` from receiver's `users` profile), linked to the same `booking_id` & `passenger_group_index`, with a **new** `ticket_number`, **new** active `ticket_qr_tokens`, and **new** `ticket_legs` row(s) (`boarding_status = 'pending'`) pointing to the preserved `booking_id`, `booking_leg_id`, `leg_order`, and `booking_passenger_id` (original `booking_passengers` snapshot untouched).
  - Under `PD-B02`, Connecting Journey tickets are non-exchangeable in the initial version; however, this `ticket_legs` model supports both direct (1 leg) and future connecting (2 legs) exchanges cleanly without schema rework.

#### D. Missed Boarding & Master Ticket Final Status (`User Confirmed`)
- **Approved Missed Boarding Policy (`Approach A` — `User Confirmed`):**
  1. Boarding status is **independent per journey leg** (`ticket_legs`).
  2. Missing an earlier leg (e.g., Leg 1 = `'missed'`) does **not** automatically invalidate a later leg (Leg 2 remains `'pending'` and boardable under its own rules).
  3. Missed boarding is recorded per `ticket_legs` row via **`missed_at INTEGER NULL`** (UTC epoch ms `INTEGER`), remaining `NULL` unless `boarding_status == 'missed'`.
- **Approved Master Ticket Final Status (`User Confirmed`):**
  - All `ticket_legs` `'boarded'` -> `tickets.status = 'used'`
  - Some legs `'boarded'` and some `'missed'` (zero `'pending'`) -> `tickets.status = 'partially_used'`
  - All `ticket_legs` `'missed'` -> `tickets.status = 'expired'`
  - Preserve `'revoked_exchanged'`, `'cancelled'`, and `'invalidated'` for their respective cases.
- **Remaining Behavioral Confirmations (`Proposed — Awaiting Approval`, non-DDL):**
  - Confirm `'missed'` irreversibility (once `'missed'`, cannot revert to `'pending'`/`'boarded'`).
  - Confirm atomic `ticket_qr_tokens` revocation (`status = 'revoked'`) whenever `tickets.status` enters a terminal state (`'used'`, `'partially_used'`, `'expired'`, `'cancelled'`, `'revoked_exchanged'`, `'invalidated'`).

---

## 5. Approved Unified Database Schema (20 Tables — `User Confirmed`)

This unified SQLite schema (`sqflite`, not Drift) incorporates `UC-01` (Master E-Ticket), `R-01`–`R-07`, `Q-02` (no `app_preferences` table), `Q-04` (normalized `stops`, `routes`, `trip_seats.id`, no `route_stops`), `C-08` (integer poisha `*_minor INTEGER` and UTC epoch ms `INTEGER`; Domain uses Dart `DateTime`), and all Phase 2 approved defaults & `CHECK` constraints.

### 5.0 Mandatory SQLite Foreign-Key Enforcement Requirement
- **Technical Requirement:** Every SQLite database connection **must** enable foreign-key enforcement using:
  `PRAGMA foreign_keys = ON`
- **Flutter `sqflite` Configuration:** In the future `sqflite` implementation, `PRAGMA foreign_keys = ON` must be executed for **every** opened database connection (for example, inside the database `onConfigure` callback in `AppDatabase`).
- **Why Mandatory:** SQLite disables foreign-key constraint checking by default on each connection. Therefore, **none** of the single or composite foreign-key constraints defined in Section 5.1 (`trips -> routes`, `booking_passengers -> booking_legs`, `booking_passengers -> trip_seats`, `ticket_legs -> tickets`, `ticket_legs -> booking_legs`, `ticket_legs -> booking_passengers`, etc.) can be relied upon unless `PRAGMA foreign_keys = ON` is enabled on every connection.

### 5.1 Table Specifications

#### 1. `users`
- **Purpose:** Local signed-in user accounts and demo credentials.
- **Columns:** `id TEXT`, `full_name TEXT NOT NULL`, `mobile TEXT NOT NULL`, `email TEXT NULL`, `credential_hash TEXT NOT NULL`, `avatar_key TEXT NOT NULL DEFAULT 'initials'`, `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **Unique:** `UNIQUE(mobile)`, `UNIQUE(email)` | **Indexes:** `mobile`, `email` (unique auto-indexes).

#### 2. `saved_passengers`
- **Purpose:** Friends & Family passenger profiles owned by a signed-in user (`features/saved_passengers/`). Never login accounts.
- **Columns:** `id TEXT`, `user_id TEXT NOT NULL`, `display_name TEXT NOT NULL`, `full_name TEXT NOT NULL`, `mobile TEXT NOT NULL`, `email TEXT NULL`, `relationship_label TEXT NULL`, `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `user_id -> users(id) ON DELETE CASCADE` | **Indexes:** `idx_saved_passengers_user ON saved_passengers(user_id)`.

#### 3. `bus_operators` *(replaces `operators` in `AGENTS.md`)*
- **Purpose:** Demo bus operators, bilingual names, exchange & cancellation policy metadata.
- **Columns:** `id TEXT`, `name_en TEXT NOT NULL`, `name_bn TEXT NOT NULL`, `logo_path TEXT NULL`, `is_verified INTEGER NOT NULL DEFAULT 1`, `allows_exchange INTEGER NOT NULL DEFAULT 1`, `exchange_cutoff_minutes INTEGER NOT NULL DEFAULT 120`, `cancellation_policy_json TEXT NOT NULL`, `created_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **Check:** `CHECK(is_verified IN (0, 1))`, `CHECK(allows_exchange IN (0, 1))`, `CHECK(exchange_cutoff_minutes >= 0)`.

#### 4. `stops` *(preserved normalized table; `Q-04`)*
- **Purpose:** Bilingual cities and transfer hubs.
- **Columns:** `id TEXT`, `city_code TEXT NOT NULL`, `name_en TEXT NOT NULL`, `name_bn TEXT NOT NULL`, `is_popular INTEGER NOT NULL DEFAULT 0`, `is_transfer_hub INTEGER NOT NULL DEFAULT 0`.
- **PK:** `PRIMARY KEY (id)` | **Unique:** `UNIQUE(city_code)` | **Check:** `CHECK(is_popular IN (0, 1))`, `CHECK(is_transfer_hub IN (0, 1))`.

#### 5. `routes` *(preserved normalized table; `Q-04`, `R-05`)*
- **Purpose:** Normalized origin-to-destination route definitions and Popular Routes.
- **Columns:** `id TEXT`, `origin_stop_id TEXT NOT NULL`, `destination_stop_id TEXT NOT NULL`, `name_en TEXT NOT NULL`, `name_bn TEXT NOT NULL`, `is_popular INTEGER NOT NULL DEFAULT 0`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `origin_stop_id -> stops(id)`, `destination_stop_id -> stops(id)`.
- **Unique:** `UNIQUE(origin_stop_id, destination_stop_id)`, `UNIQUE(id, origin_stop_id, destination_stop_id)` *(supports `R-05` composite FK)*.
- **Check:** `CHECK(origin_stop_id != destination_stop_id)`, `CHECK(is_popular IN (0, 1))`.

#### 6. `trips` *(enhanced with `R-05` composite FK)*
- **Purpose:** Scheduled bus trips, bilingual boarding/drop-off points, dataset-only facilities, and fare.
- **Columns:** `id TEXT`, `operator_id TEXT NOT NULL`, `route_id TEXT NOT NULL`, `origin_stop_id TEXT NOT NULL`, `destination_stop_id TEXT NOT NULL`, `bus_name_en TEXT NOT NULL`, `bus_name_bn TEXT NOT NULL`, `bus_type TEXT NOT NULL`, `departure_at INTEGER NOT NULL`, `arrival_at INTEGER NOT NULL`, `boarding_point_en TEXT NOT NULL`, `boarding_point_bn TEXT NOT NULL`, `drop_off_point_en TEXT NOT NULL`, `drop_off_point_bn TEXT NOT NULL`, `facilities_json TEXT NULL`, `fare_minor INTEGER NOT NULL`, `total_seats INTEGER NOT NULL`, `is_popular INTEGER NOT NULL DEFAULT 0`, `is_active INTEGER NOT NULL DEFAULT 1`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `operator_id -> bus_operators(id)`, `(route_id, origin_stop_id, destination_stop_id) -> routes(id, origin_stop_id, destination_stop_id)` (`R-05`).
- **Check:** `CHECK(arrival_at > departure_at)`, `CHECK(fare_minor >= 0)`, `CHECK(total_seats > 0)`, `CHECK(bus_type IN ('ac_business', 'ac_sleeper', 'non_ac'))`, `CHECK(is_popular IN (0, 1))`, `CHECK(is_active IN (0, 1))`.
- **Indexes:** `idx_trips_search ON trips(origin_stop_id, destination_stop_id, departure_at, is_active)`.

#### 7. `connection_rules`
- **Purpose:** Minimum/maximum transfer wait limits and bilingual transfer instructions at hubs.
- **Columns:** `id TEXT`, `hub_stop_id TEXT NOT NULL`, `operator_id TEXT NULL`, `min_buffer_minutes INTEGER NOT NULL DEFAULT 30`, `max_buffer_minutes INTEGER NOT NULL DEFAULT 240`, `transfer_instructions_en TEXT NOT NULL`, `transfer_instructions_bn TEXT NOT NULL`, `is_active INTEGER NOT NULL DEFAULT 1`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `hub_stop_id -> stops(id)`, `operator_id -> bus_operators(id)`.
- **Check:** `CHECK(min_buffer_minutes >= 0)`, `CHECK(max_buffer_minutes >= min_buffer_minutes)`, `CHECK(is_active IN (0, 1))`.

#### 8. `trip_seats` *(uses `id` PK per `Q-04` + mutually exclusive hold ownership)*
- **Purpose:** Per-trip seat inventory and lazy-expiring seat holds. SQLite is the source of truth.
- **Columns:** `id TEXT`, `trip_id TEXT NOT NULL`, `seat_number TEXT NOT NULL`, `seat_class TEXT NULL`, `status TEXT NOT NULL`, `hold_user_id TEXT NULL` *(signed-in holder; `NULL` for guests)*, `hold_session_id TEXT NULL` *(guest checkout session UUID; `NULL` when signed in)*, `hold_expiry INTEGER NULL` *(UTC epoch ms)*, `booking_id TEXT NULL` *(populated only when `status = 'booked'`)*.
- **PK:** `PRIMARY KEY (id)` | **FK:** `trip_id -> trips(id) ON DELETE CASCADE`, `hold_user_id -> users(id)`, `booking_id -> bookings(id)`.
- **Unique:** `UNIQUE(trip_id, seat_number)`, `UNIQUE(id, trip_id)` *(supports `booking_passengers` composite FK)*.
- **Check:**
  - `CHECK(status IN ('available', 'held', 'booked', 'blocked'))` *(`'blocked'` = seat not available for passenger booking; `User Confirmed`)*
  - `CHECK(NOT (hold_user_id IS NOT NULL AND hold_session_id IS NOT NULL))` *(`hold_user_id` and `hold_session_id` cannot both be populated)*
  - `CHECK((status != 'available') OR (hold_user_id IS NULL AND hold_session_id IS NULL AND hold_expiry IS NULL AND booking_id IS NULL))`
  - `CHECK((status != 'held') OR (((hold_user_id IS NOT NULL AND hold_session_id IS NULL) OR (hold_user_id IS NULL AND hold_session_id IS NOT NULL)) AND hold_expiry IS NOT NULL AND booking_id IS NULL))`
  - `CHECK((status != 'booked') OR (booking_id IS NOT NULL AND hold_user_id IS NULL AND hold_session_id IS NULL AND hold_expiry IS NULL))`
  - `CHECK((status != 'blocked') OR (hold_user_id IS NULL AND hold_session_id IS NULL AND hold_expiry IS NULL AND booking_id IS NULL))`
- **Indexes:** `idx_trip_seats_trip_status ON trip_seats(trip_id, status, hold_expiry)`.

#### 9. `bookings` *(aligned `booking_status` and `payment_status` CHECKs)*
- **Purpose:** Master booking header for direct (1-leg) and connecting (2-leg) purchases, supporting guest (`user_id NULL`, no `guest_session_id`) and signed-in bookings.
- **Columns:** `id TEXT`, `booking_number TEXT NOT NULL`, `user_id TEXT NULL`, `booking_type TEXT NOT NULL`, `booking_status TEXT NOT NULL`, `payment_status TEXT NOT NULL`, `total_amount_minor INTEGER NOT NULL`, `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `user_id -> users(id)` | **Unique:** `UNIQUE(booking_number)`.
- **Check:** `CHECK(booking_type IN ('direct', 'connecting'))`, `CHECK(booking_status IN ('pending_payment', 'payment_failed', 'payment_cancelled', 'confirmed', 'cancelled', 'partially_cancelled'))`, `CHECK(payment_status IN ('pending', 'paid', 'partially_refunded_demo', 'refunded_demo'))`, `CHECK(total_amount_minor >= 0)`.
- **Indexes:** `idx_bookings_user_created ON bookings(user_id, created_at DESC)`.

#### 10. `booking_legs` *(enhanced with parent composite `UNIQUE` keys for Master E-Ticket integrity)*
- **Purpose:** Links a Master Booking to 1 trip (direct) or 2 trips (connecting), plus simulated journey tracking state.
- **Columns:** `id TEXT`, `booking_id TEXT NOT NULL`, `trip_id TEXT NOT NULL`, `leg_order INTEGER NOT NULL`, `transfer_point_en TEXT NULL`, `transfer_point_bn TEXT NULL`, `buffer_minutes INTEGER NULL`, `demo_tracking_stage TEXT NULL`, `demo_delay_minutes INTEGER NOT NULL DEFAULT 0`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `booking_id -> bookings(id) ON DELETE CASCADE`, `trip_id -> trips(id)`.
- **Unique:** `UNIQUE(booking_id, leg_order)`, `UNIQUE(id, booking_id, leg_order)` *(for `ticket_legs` FK)*, `UNIQUE(id, booking_id, trip_id)` *(for `booking_passengers` FK)*.
- **Check:** `CHECK(leg_order IN (1, 2))`, `CHECK(demo_delay_minutes >= 0)`.

#### 11. `booking_passengers` *(Immutable original checkout passenger snapshot; composite FK enforces seat-belongs-to-leg-trip)*
- **Purpose:** Preserves exact original passenger-to-seat assignment per booking leg; **never** overwritten by profile edits or Ticket Exchange.
- **Columns:** `id TEXT`, `booking_id TEXT NOT NULL`, `booking_leg_id TEXT NOT NULL`, `trip_id TEXT NOT NULL`, `saved_passenger_id TEXT NULL`, `passenger_group_index INTEGER NOT NULL`, `passenger_name TEXT NOT NULL`, `passenger_mobile TEXT NOT NULL`, `passenger_email TEXT NULL`, `seat_id TEXT NOT NULL`, `seat_number_snapshot TEXT NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:**
  - `booking_id -> bookings(id) ON DELETE CASCADE`
  - `FOREIGN KEY (booking_leg_id, booking_id, trip_id) REFERENCES booking_legs(id, booking_id, trip_id) ON DELETE CASCADE` *(enforces same booking & same trip as leg)*
  - `FOREIGN KEY (seat_id, trip_id) REFERENCES trip_seats(id, trip_id)` *(enforces assigned seat belongs to that leg's trip)*
  - `saved_passenger_id -> saved_passengers(id) ON DELETE SET NULL`
- **Unique:** `UNIQUE(booking_leg_id, seat_id)`, `UNIQUE(booking_leg_id, passenger_group_index)`, `UNIQUE(id, booking_id, booking_leg_id, passenger_group_index)` *(for `ticket_legs` FK)*.
- **Check:** `CHECK(passenger_group_index BETWEEN 1 AND 4)`.

#### 12. `demo_payments` *(revised per `R-01`)*
- **Purpose:** Records local demo payment attempts and idempotency guarantees.
- **Columns:** `id TEXT`, `booking_id TEXT NOT NULL`, `idempotency_key TEXT NOT NULL`, `method TEXT NOT NULL`, `status TEXT NOT NULL`, `amount_minor INTEGER NOT NULL`, `created_at INTEGER NOT NULL`, `completed_at INTEGER NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `booking_id -> bookings(id) ON DELETE CASCADE` | **Unique:** `UNIQUE(idempotency_key)`.
- **Check:** `CHECK(method IN ('mobile_banking', 'card', 'cash_demo'))`, `CHECK(status IN ('pending', 'success', 'failed', 'cancelled'))`, `CHECK(amount_minor >= 0)`.
- **Indexes:** `uidx_demo_payments_success_booking ON demo_payments(booking_id) WHERE status = 'success'` *(at most 1 successful payment per booking)*.

#### 13. `tickets` *(revised per `UC-01` Master E-Ticket & `R-07`)*
- **Purpose:** Issued E-Ticket / Master E-Ticket (one per passenger across all legs of a booking) tracking current ticket holder info and lifecycle status.
- **Columns:** `id TEXT`, `ticket_number TEXT NOT NULL`, `booking_id TEXT NOT NULL`, `passenger_group_index INTEGER NOT NULL`, `owner_user_id TEXT NULL`, `holder_name TEXT NOT NULL`, `holder_mobile TEXT NOT NULL`, `holder_email TEXT NULL`, `original_ticket_price_minor INTEGER NOT NULL`, `status TEXT NOT NULL`, `issued_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `booking_id -> bookings(id) ON DELETE CASCADE`, `owner_user_id -> users(id)`.
- **Unique:** `UNIQUE(ticket_number)`, `UNIQUE(id, booking_id)` *(for `ticket_cancellations` composite FK)*, `UNIQUE(id, booking_id, passenger_group_index)` *(for `ticket_legs` composite FK)*.
- **Check:** `CHECK(passenger_group_index BETWEEN 1 AND 4)`, `CHECK(original_ticket_price_minor >= 0)`, `CHECK(status IN ('issued', 'used', 'partially_used', 'expired', 'revoked_exchanged', 'cancelled', 'invalidated'))`.
- **Indexes:** `idx_tickets_number ON tickets(ticket_number)`, `idx_tickets_owner_issued ON tickets(owner_user_id, issued_at DESC)`, `uidx_active_ticket_per_booking_passenger ON tickets(booking_id, passenger_group_index) WHERE status IN ('issued', 'used', 'partially_used', 'expired')` *(`User Confirmed`: prevents duplicate active or finalized tickets for the same booking passenger while excluding `'revoked_exchanged'`, `'cancelled'`, and `'invalidated'` so a replacement ticket can be issued after revocation or cancellation)*.

#### 14. `ticket_legs` *(New table per `UC-01` & `R-07`; composite FKs enforce full relational integrity)*
- **Purpose:** Links one Master E-Ticket (`tickets`) to each applicable `booking_legs` and `booking_passengers` seat assignment, and stores independent per-leg boarding validation status and audit timestamps (`validated_at`, proposed `missed_at`) to prevent duplicate boarding while supporting Leg 1 → Leg 2 sequential travel.
- **Columns:** `id TEXT`, `ticket_id TEXT NOT NULL`, `booking_id TEXT NOT NULL`, `booking_leg_id TEXT NOT NULL`, `leg_order INTEGER NOT NULL`, `booking_passenger_id TEXT NOT NULL`, `passenger_group_index INTEGER NOT NULL`, `boarding_status TEXT NOT NULL DEFAULT 'pending'`, `validated_at INTEGER NULL` *(UTC epoch ms when `'boarded'`)*, `missed_at INTEGER NULL` *(proposed audit timestamp, UTC epoch ms when `'missed'`; `NULL` otherwise; preserved for audit)*, `validated_by_demo_context TEXT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK (Composite Relational Enforcement):**
  - `FOREIGN KEY (ticket_id, booking_id, passenger_group_index) REFERENCES tickets(id, booking_id, passenger_group_index) ON DELETE CASCADE` *(enforces same booking & same `passenger_group_index` as ticket)*
  - `FOREIGN KEY (booking_leg_id, booking_id, leg_order) REFERENCES booking_legs(id, booking_id, leg_order) ON DELETE CASCADE` *(enforces `booking_leg` belongs to same booking & `leg_order` matches)*
  - `FOREIGN KEY (booking_passenger_id, booking_id, booking_leg_id, passenger_group_index) REFERENCES booking_passengers(id, booking_id, booking_leg_id, passenger_group_index) ON DELETE CASCADE` *(enforces passenger belongs to same booking, same leg, and same `passenger_group_index`)*
- **Unique:** `UNIQUE(ticket_id, booking_leg_id)`, `UNIQUE(ticket_id, leg_order)` | **Check:** `CHECK(leg_order IN (1, 2))`, `CHECK(passenger_group_index BETWEEN 1 AND 4)`, `CHECK(boarding_status IN ('pending', 'boarded', 'missed', 'cancelled', 'invalidated'))`, `CHECK((boarding_status != 'boarded') OR (validated_at IS NOT NULL))`, `CHECK((boarding_status != 'missed') OR (missed_at IS NOT NULL))`, `CHECK((boarding_status == 'missed') OR (missed_at IS NULL))`.
- **Indexes:** `idx_ticket_legs_ticket ON ticket_legs(ticket_id, leg_order)`, `idx_ticket_legs_leg_status ON ticket_legs(booking_leg_id, boarding_status)`, `uidx_active_ticket_leg_passenger ON ticket_legs(booking_leg_id, booking_passenger_id) WHERE boarding_status != 'invalidated'`.

#### 15. `ticket_qr_tokens`
- **Purpose:** Tracks opaque random QR token hashes (zero PII) and active/revoked lifecycle.
- **Columns:** `id TEXT`, `ticket_id TEXT NOT NULL`, `token_hash TEXT NOT NULL`, `status TEXT NOT NULL`, `created_at INTEGER NOT NULL`, `revoked_at INTEGER NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `ticket_id -> tickets(id) ON DELETE CASCADE` | **Unique:** `UNIQUE(token_hash)`.
- **Check:** `CHECK(status IN ('active', 'revoked'))` | **Indexes:** `uidx_active_qr_per_ticket ON ticket_qr_tokens(ticket_id) WHERE status = 'active'`.

#### 16. `ticket_cancellations` *(New table per `R-02`; composite FK enforces ticket belongs to booking)*
- **Purpose:** Stores per-ticket cancellation records, reasons, and demo refund audit details without overwriting booking-wide state when multi-seat bookings cancel partially or individually.
- **Columns:** `id TEXT`, `booking_id TEXT NOT NULL`, `ticket_id TEXT NOT NULL`, `cancelled_by_user_id TEXT NULL`, `reason TEXT NULL`, `refund_percentage INTEGER NOT NULL`, `refund_amount_minor INTEGER NOT NULL`, `refund_status TEXT NOT NULL`, `cancelled_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:**
  - `booking_id -> bookings(id) ON DELETE CASCADE`
  - `FOREIGN KEY (ticket_id, booking_id) REFERENCES tickets(id, booking_id) ON DELETE CASCADE` *(enforces `tickets.booking_id == ticket_cancellations.booking_id`)*
  - `cancelled_by_user_id -> users(id)`
- **Unique:** `UNIQUE(ticket_id)` | **Check:** `CHECK(refund_percentage IN (0, 75, 100))`, `CHECK(refund_amount_minor >= 0)`, `CHECK(refund_status IN ('refund_pending_demo', 'refund_completed_demo', 'no_refund_applicable'))` *(adds `'refund_pending_demo'` for `Project Flow` #22 alignment; transition behavior pending approval)*.
- **Indexes:** `idx_ticket_cancellations_booking ON ticket_cancellations(booking_id, cancelled_at DESC)`.

#### 17. `ticket_exchange_requests` *(replaces `handover_requests` in `AGENTS.md`)*
- **Purpose:** Tracks Ticket Exchange request submission, Demo Operator approval/rejection, and receiver decision.
- **Columns:** `id TEXT`, `ticket_id TEXT NOT NULL`, `sender_user_id TEXT NOT NULL`, `receiver_user_id TEXT NOT NULL`, `receiver_name_snapshot TEXT NOT NULL`, `receiver_mobile_snapshot TEXT NOT NULL`, `optional_message TEXT NULL`, `status TEXT NOT NULL`, `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `ticket_id -> tickets(id)`, `sender_user_id -> users(id)`, `receiver_user_id -> users(id)`.
- **Check:** `CHECK(sender_user_id != receiver_user_id)`, `CHECK(status IN ('pending', 'approved', 'rejected', 'cancelled', 'declined', 'completed'))`.
- **Indexes:** `uidx_active_exchange_per_ticket ON ticket_exchange_requests(ticket_id) WHERE status IN ('pending', 'approved')`.

#### 18. `ticket_exchange_history`
- **Purpose:** Immutable audit log of completed Ticket Exchange ownership transfers.
- **Columns:** `id TEXT`, `request_id TEXT NOT NULL`, `old_ticket_id TEXT NOT NULL`, `new_ticket_id TEXT NOT NULL`, `previous_owner_id TEXT NOT NULL`, `new_owner_id TEXT NOT NULL`, `completed_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `request_id -> ticket_exchange_requests(id)`, `old_ticket_id -> tickets(id)`, `new_ticket_id -> tickets(id)`, `previous_owner_id -> users(id)`, `new_owner_id -> users(id)`.
- **Unique:** `UNIQUE(request_id)`, `UNIQUE(old_ticket_id)`, `UNIQUE(new_ticket_id)`.

#### 19. `ticket_revenue_splits`
- **Purpose:** Local demo 30% / 50% / 20% revenue allocation computed strictly from `Original Ticket Price`.
- **Columns:** `id TEXT`, `request_id TEXT NOT NULL`, `original_ticket_price_minor INTEGER NOT NULL`, `operator_share_minor INTEGER NOT NULL`, `exchanger_share_minor INTEGER NOT NULL`, `platform_share_minor INTEGER NOT NULL`, `created_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `request_id -> ticket_exchange_requests(id)` | **Unique:** `UNIQUE(request_id)`.
- **Check:** `CHECK(original_ticket_price_minor >= 0)`, `CHECK(operator_share_minor >= 0)`, `CHECK(exchanger_share_minor >= 0)`, `CHECK(platform_share_minor >= 0)`, `CHECK(operator_share_minor + exchanger_share_minor + platform_share_minor = original_ticket_price_minor)`.

#### 20. `notifications`
- **Purpose:** Local bilingual in-app notifications for signed-in users.
- **Columns:** `id TEXT`, `user_id TEXT NOT NULL`, `title_en TEXT NOT NULL`, `title_bn TEXT NOT NULL`, `message_en TEXT NOT NULL`, `message_bn TEXT NOT NULL`, `category TEXT NOT NULL`, `is_read INTEGER NOT NULL DEFAULT 0`, `related_record_type TEXT NULL`, `related_record_id TEXT NULL`, `created_at INTEGER NOT NULL`.
- **PK:** `PRIMARY KEY (id)` | **FK:** `user_id -> users(id) ON DELETE CASCADE`.
- **Check:** `CHECK(category IN ('booking', 'payment', 'reminder', 'delay', 'cancellation', 'exchange'))`, `CHECK(is_read IN (0, 1))`.
- **Indexes:** `idx_notifications_user_read_created ON notifications(user_id, is_read, created_at DESC)`.

*(Table count change: revised from 18 tables to **20 tables** by adding **`ticket_legs`** for Master E-Ticket per-leg validation and **`ticket_cancellations`** for multi-ticket cancellation records.)*

### 5.2 Revised Relationships Diagram
```text
users 1 ── N saved_passengers
users 1 ── N bookings (user_id NULL for guest)
users 1 ── N notifications
bus_operators 1 ── N trips
stops 1 ── N routes (origin / destination)
routes 1 ── N trips (composite FK on route_id, origin_stop_id, destination_stop_id)
stops 1 ── N connection_rules
trips 1 ── N trip_seats (UNIQUE(id, trip_id))
bookings 1 ── N booking_legs (1 for direct, 2 for connecting; UNIQUE(id, booking_id, leg_order), UNIQUE(id, booking_id, trip_id))
booking_legs N ── 1 trips
bookings 1 ── N booking_passengers
booking_legs 1 ── N booking_passengers (composite FK on booking_leg_id, booking_id, trip_id)
saved_passengers 1 ── N booking_passengers (optional)
trip_seats 1 ── N booking_passengers (composite FK on seat_id, trip_id)
bookings 1 ── N demo_payments (at most 1 with status = 'success')
bookings 1 ── N tickets (1 Master E-Ticket per passenger_group_index; UNIQUE(id, booking_id, passenger_group_index))
tickets 1 ── N ticket_legs (composite FK on ticket_id, booking_id, passenger_group_index)
booking_legs 1 ── N ticket_legs (composite FK on booking_leg_id, booking_id, leg_order)
booking_passengers 1 ── N ticket_legs (composite FK on booking_passenger_id, booking_id, booking_leg_id, passenger_group_index; max 1 non-invalidated)
tickets 1 ── N ticket_qr_tokens (at most 1 with status = 'active')
tickets 1 ── 0..1 ticket_cancellations (composite FK on ticket_id, booking_id)
bookings 1 ── N ticket_cancellations
tickets 1 ── N ticket_exchange_requests (at most 1 in 'pending' / 'approved')
ticket_exchange_requests 1 ── 0..1 ticket_exchange_history
ticket_exchange_requests 1 ── 0..1 ticket_revenue_splits
```

### 5.3 Atomic Transaction Summary
1. **Seat Hold / Release (`db.transaction`, `R-03`):** Clear expired holds (`status = 'held' AND hold_expiry < now` → `status = 'available'`, all hold fields `NULL`) → verify seats are `'available'` or held by the matching caller owner (`hold_user_id` for signed-in OR `hold_session_id` for guest, with `hold_expiry >= now`) → update `status = 'held'`, set **exactly one** owner (`hold_user_id` OR `hold_session_id`, never both), and set `hold_expiry = now + 300,000` (`booking_id = NULL`).
2. **Booking & Demo Payment (`db.transaction`, `UC-01`, `R-01`, `R-05`, `R-07`):** Inside `db.transaction`, branch immediately on whether the supplied `idempotency_key` already exists in `demo_payments`:
   - **Branch A — Existing Idempotency Key:**
     1. Find the existing `demo_payments` attempt using the supplied `idempotency_key`.
     2. Validate its immutable request fingerprint against the incoming request (`booking_id`, `amount_minor`, `method`, `booking_type`, and `user_id` [`NULL` for guest bookings; no `guest_session_id`]).
     3. **Exact fingerprint match:** return the previously stored payment attempt outcome immediately (a replay of a previously successful payment returns that stored success result without creating duplicate tickets; a replay of a previous `failed` or `cancelled` attempt returns that recorded outcome—a new retry requires a new `idempotency_key`).
     4. Do **not** run new-attempt checks (`booking_status` not confirmed, no prior successful payment, or seat availability checks).
     5. Do **not** create another `demo_payments` attempt or issue duplicate `tickets` / `ticket_legs` / `ticket_qr_tokens`.
     6. **Mismatched fingerprint:** reject immediately with `FailureType.CONFLICT`.
   - **Branch B — New Idempotency Key:**
     1. Revalidate `bookings.booking_status` (must permit payment: `'pending_payment'`, or retry transitioning `'payment_failed'`/`'payment_cancelled'` back to `'pending_payment'`).
     2. Verify that no `'success'` payment already exists for the booking (`NOT EXISTS` in `demo_payments` with `status = 'success'`, backed by `uidx_demo_payments_success_booking`).
     3. Clear expired holds (`hold_expiry < now`), revalidate seat availability and hold ownership/expiry (`'available'` or held by matching caller owner `hold_user_id`/`hold_session_id` with `hold_expiry >= now`), and validate Section 5.4 invariants.
     4. Execute all checks above atomically inside `db.transaction`.
     5. Process and record the new `demo_payments` attempt (`'success'`, `'failed'`, or `'cancelled'`).
     6. **Create tickets only when the new payment succeeds (`status == 'success'`):** transition `bookings.booking_status = 'confirmed'`, `bookings.payment_status = 'paid'`, mark `trip_seats` `'booked'` (`booking_id = bookings.id`, clearing hold fields to `NULL`), create `N` Master E-Tickets (`tickets`) + `N` active `ticket_qr_tokens` + `N × legCount` `ticket_legs` (`pending`), and insert `notifications` (if signed-in). If `'failed'`, set `bookings.booking_status = 'payment_failed'`; if `'cancelled'`, set `bookings.booking_status = 'payment_cancelled'`; keep `bookings.payment_status = 'pending'`, create zero tickets, and retain the attempt for retry with a new `idempotency_key`.
3. **Per-Leg QR Validation & Missed Marking (`db.transaction`, `UC-01`, `R-04`, `Sec 4.2D`):** Resolve active `ticket_qr_tokens` + `issued` `tickets` → match `ticket_legs` for current leg context → atomically update `boarding_status = 'pending' -> 'boarded'` (`rowsAffected == 1`). Missing a leg records `boarding_status = 'missed'` and `missed_at = now` independently without invalidating later legs. When zero `'pending'` legs remain on a ticket: all `'boarded'` → `tickets.status = 'used'`; mixed `'boarded'`/`'missed'` → `'partially_used'`; all `'missed'` → `'expired'`.
4. **Ticket Cancellation (`db.transaction`, `R-02`, `R-06`):** Verify `tickets.status == 'issued'`, `tickets.booking_id == targetBookingId`, ownership (`actingUser` or guest policy per `R-06`), no active exchange request, and `delta > 0` → calculate tier (`PD-B12`: 100% / 75% / 0%) → cancel targeted ticket(s) (all tickets on Master Booking if connecting per `PD-B07`) → insert `ticket_cancellations` (`'refund_pending_demo'` for eligible >6h tiers transitioning to `'refund_completed_demo'`, or `'no_refund_applicable'` for `< 6h`) → revoke active QR tokens & set `ticket_legs` `'cancelled'` → free released `trip_seats` (`status = 'available'`, `booking_id = NULL`, hold fields `NULL`) → update `bookings.booking_status` (`partially_cancelled` or `cancelled`) and `bookings.payment_status` (`paid`, `partially_refunded_demo`, `refunded_demo`) → notify active holder(s).
5. **Atomic Ticket Exchange (`db.transaction`, `UC-01`, `R-04`, `R-07`):** Revalidate `approved` request, `issued` direct ticket, cutoff (`PD-B01`), operator `allows_exchange`, and sender ownership → keep `booking_passengers` untouched → revoke old QR token, mark old ticket `revoked_exchanged`, mark old `ticket_legs` `'invalidated'` → insert new `tickets` (`holder_*` from receiver) + new active `ticket_qr_tokens` + new `ticket_legs` (`pending`) → update request `completed`, insert `ticket_exchange_history` & `ticket_revenue_splits` (`Q-10` floor rounding), and notify both users.

### 5.4 Database-Enforced Rules vs. Application-Level Transactional Validation
*(Nothing is claimed as DB-enforced unless backed by an explicit SQLite constraint above, and all SQLite FK constraints depend on `PRAGMA foreign_keys = ON` per Section 5.0.)*

| Invariant / Rule | Enforcement Mechanism | Exact Constraint or Transaction Rule |
| :--- | :--- | :--- |
| Ticket & `ticket_legs` belong to the same booking & `passenger_group_index` | **SQLite Composite FK** | `ticket_legs(ticket_id, booking_id, passenger_group_index) -> tickets(id, booking_id, passenger_group_index)` |
| `ticket_legs` belongs to the same booking & `leg_order` as `booking_legs` | **SQLite Composite FK** | `ticket_legs(booking_leg_id, booking_id, leg_order) -> booking_legs(id, booking_id, leg_order)` |
| `ticket_legs` passenger belongs to the same booking, leg, & `passenger_group_index` | **SQLite Composite FK** | `ticket_legs(booking_passenger_id, booking_id, booking_leg_id, passenger_group_index) -> booking_passengers(id, booking_id, booking_leg_id, passenger_group_index)` |
| `booking_passengers` assigned seat belongs to that leg's `trip_id` | **SQLite Composite FK** | `booking_passengers(booking_leg_id, booking_id, trip_id) -> booking_legs` + `booking_passengers(seat_id, trip_id) -> trip_seats(id, trip_id)` |
| `trips` stops match `routes` stops | **SQLite Composite FK** | `trips(route_id, origin_stop_id, destination_stop_id) -> routes(id, origin_stop_id, destination_stop_id)` |
| `ticket_cancellations` ticket belongs to the referenced booking | **SQLite Composite FK** | `ticket_cancellations(ticket_id, booking_id) -> tickets(id, booking_id)` (plus transactional check before insert) |
| Seat status & mutually exclusive hold/booking fields | **SQLite `CHECK` Constraints** | `trip_seats` mutual-exclusivity and status-specific `CHECK` clauses (Section 5.1 #8) |
| At most 1 `success` payment per booking & unique `idempotency_key` | **SQLite Unique & Partial Index** | `UNIQUE(idempotency_key)` + `uidx_demo_payments_success_booking` |
| Idempotency request fingerprint match (`booking_id`, `amount_minor`, `method`, `booking_type`, `user_id`) | **Transactional App Validation** | On existing `idempotency_key` (Branch A), verified against stored `demo_payments` and `bookings` context inside `db.transaction`: exact match immediately returns the stored payment outcome without running Branch B checks or creating duplicate payments/tickets; mismatch rejects with `FailureType.CONFLICT` |
| `trip_seats.booking_id` equals `booking_passengers.booking_id` when booked | **Transactional App Validation** | Cannot use composite FK because `trip_seats.booking_id` is `NULL` when `available`/`held`; verified inside booking & cancellation `db.transaction` |
| Minimum child cardinality (`direct` = 1 leg, `connecting` = 2 legs, every connecting Master E-Ticket has both `ticket_legs` rows) | **Transactional App Validation** | SQLite FKs validate row existence, not minimum child counts; enforced before commit in booking `db.transaction` |
| Same-operator, hub-match, and `[30, 240]` min buffer across Leg 1 & Leg 2 | **Transactional App Validation** | Verified across `trips` & `connection_rules` inside search & booking `db.transaction` |
| Cross-leg passenger identity parity & distinct `saved_passenger_id` for extra seats | **Transactional App Validation** | Verified across `passenger_group_index` pairs on Leg 1 & Leg 2 inside booking `db.transaction` |
| Seed seat count matches `trips.total_seats` | **Pending Seed / Test Validation** | Planned for Phase 2 verification via executable seed logic and `sqflite_common_ffi` schema tests (not yet run) |

### 5.5 Design-Level Consistency Review *(Actual SQLite Validation Pending)*
> **Validation Status Notice:** This section documents a **design-level consistency review** of the proposed schema only. **No SQLite migration scripts have been generated or executed, and no SQL execution, foreign-key tests, or database tests have been performed.** Actual SQLite validation remains pending until Phase 2, when executable migration scripts and `sqflite_common_ffi` schema/integrity tests will be run.

- **Foreign Keys & Parent Unique Keys (Design-Level Review):** Every proposed composite FK (`trips -> routes`, `booking_passengers -> booking_legs`, `booking_passengers -> trip_seats`, `ticket_legs -> tickets`, `ticket_legs -> booking_legs`, `ticket_legs -> booking_passengers`, `ticket_cancellations -> tickets`) is designed to target an explicit parent `UNIQUE` or `PRIMARY KEY` with matching column types (`TEXT` or `INTEGER`), contingent on `PRAGMA foreign_keys = ON` (Section 5.0).
- **PK vs. Unique Non-Contradiction (Design-Level Review):** Single-column `id TEXT PRIMARY KEY` coexists cleanly on paper with composite `UNIQUE(id, ...)` targets and natural unique indexes (`UNIQUE(trip_id, seat_number)`, `UNIQUE(booking_id, leg_order)`).
- **Direct & Connecting Parity (Design-Level Review):** Direct journeys map to `1` `booking_legs` + `1` `ticket_legs` per ticket; connecting journeys map to `2` `booking_legs` + `2` `ticket_legs` per ticket; multi-passenger connecting bookings produce `N` Master E-Tickets (`passenger_group_index` `1..N`), each mapped to both legs.
- **Exchange & Cancellation Compatibility (Design-Level Review):** `uidx_active_ticket_per_booking_passenger` and `uidx_active_ticket_leg_passenger` exclude `revoked_exchanged`/`cancelled`/`invalidated` rows so replacement tickets do not collide with historical rows; `ticket_cancellations` enforces `UNIQUE(ticket_id)` per ticket.
- **No Obsolete Fields or Extra Tables (Design-Level Review):** Zero active schema references remain to removed `original_passenger_assignment_id`, booking-level `cancellation_reason`/`refund_amount_minor`/`cancelled_at`, or `app_preferences`. Table count remains **20** (with `missed_at` added to `ticket_legs`).
- **Pending Executable Verification (Phase 2 Required):** Executable `migration_v1.dart` DDL compilation in SQLite, `PRAGMA foreign_keys = ON` rejection tests, composite FK violation tests, `trip_seats` `CHECK` constraint tests, partial unique index tests, and atomic transaction rollback tests remain **pending**.

---

## 6. Final Package Approval List

### 6.1 Baseline Packages (`AGENTS.md`)
- **Runtime:** `flutter_bloc`, `equatable`, `get_it`, `injectable`, `dartz`, `go_router`, `sqflite`, `path`, `intl`, `flutter_localizations` (SDK), `qr_flutter`, `crypto`, `shared_preferences`, `uuid`
- **Dev / Test:** `injectable_generator`, `build_runner`, `bloc_test`, `mocktail`, `sqflite_common_ffi`, `flutter_lints`

### 6.2 Proposed Additional Packages (`Proposed — Awaiting Approval`, Subject to SDK Compatibility Check)
| Package | Purpose | Reason Required | Status |
| :--- | :--- | :--- | :--- |
| `flutter_screenutil` | Responsive scaling (`.w`, `.h`, `.sp`, `.r`) with `designSize: Size(375, 812)` | Mandated by `Tech Req` Sec 3 & 13; absent from `AGENTS.md` | `Proposed — Awaiting Approval` |
| `pdf` | Generate local PDF E-Ticket containing complete ticket details + QR code | Mandated by `Tech Req` Sec 9 (no QR-only download) | `Proposed — Awaiting Approval` |
| `path_provider` | Resolve local device directory to save generated PDF offline | Required for offline local PDF storage | `Proposed — Awaiting Approval` |
| `share_plus` | Local OS file sharing for generated PDF ticket | Required by `Project Flow` #20 & #36 Share action | `Proposed — Awaiting Approval` |

*(No packages have been installed and `pubspec.yaml` has not been created or modified.)*

---

## 7. Complete Phase 1 Design System Scope *(Values Not in Specs Marked `Unresolved — Requires Clarification`)*

The Phase 1 design system (`lib/core/theme/` and `lib/core/widgets/`) must cover all 17 categories below consistently across all features, using **Light Theme only** (per `PD-P05`):

| # | Category | Required Scope & Specification Alignment | Defined vs. Pending Design Values |
| :--- | :--- | :--- | :--- |
| **1** | **Color Palette & Semantic Colors** | `AppColors` constants (no inline `Color(0x...)` literals in widgets): Primary, Secondary, Accent, Success, Warning, Error, Handover/Exchange accent, Connecting Journey accent, Scaffold/Surface/Card backgrounds, Borders/Dividers, Text Primary/Secondary/Muted, Disabled states. | **Defined (`AGENTS.md`):** Primary `#123B70`, Secondary `#1976D2`, Accent `#14BBA6`, Success `#22C55E`, Warning `#F59E0B`, Error `#EF4444`.<br>**`Unresolved — Requires Clarification`:** Exact hex values for Handover/Exchange orange, Connecting Journey violet, light scaffold/surface/border/text-neutral tokens. |
| **2** | **Typography Scale** | `AppTextStyles`: Display, Headline, Title (Large/Medium/Small), Body (Large/Medium/Small), Label, Caption/Helper, Numeric/Fare emphasis (`tabularFigures` for fares & timers). | **`Unresolved — Requires Clarification`:** Exact font sizes (`.sp`), weights, and line-height multipliers for each scale step. |
| **3** | **English & Bengali Typography** | Bundled font assets: **`Inter`** for English (`en`), **`Noto Sans Bengali`** for Bengali (`bn`). Locale-aware theme switching via `LocaleBloc`; extra vertical line-height headroom for Bengali vowel signs (*kar*/matra). | **Defined:** `Inter` + `Noto Sans Bengali` bundled assets.<br>**`Unresolved — Requires Clarification`:** Exact Bengali line-height adjustment factor and fallback font weights available in asset bundle. |
| **4** | **Spacing System** | Standardized spacing tokens (`xs`, `sm`, `md`, `lg`, `xl`, `xxl`) applied via `.w` / `.h` for screen horizontal padding, card internal padding, vertical section gaps, and form field spacing. | **`Unresolved — Requires Clarification`:** Exact pixel/dp values on the `375x812` grid (e.g. `4/8/12/16/24/32` scale). |
| **5** | **Border Radius** | Standardized radius tokens (`sm`, `md`, `lg`, `pill`) via `.r` for inputs, buttons, cards, badges/chips, seat tiles, and bottom sheets. | **`Unresolved — Requires Clarification`:** Exact corner radii per component tier. |
| **6** | **Elevation & Shadows** | Light-theme surface elevation rules: subtle card elevation or 1dp border separation, sticky bottom summary/CTA bar elevation, modal/sheet elevation. | **`Unresolved — Requires Clarification`:** Exact shadow color/opacity, blur radius, and elevation dp values. |
| **7** | **Buttons & States** | Reusable `AppButton` supporting Primary, Secondary/Outlined, Destructive, and Text variants; minimum touch target height; explicit `enabled`, `disabled`, and `loading` (inline spinner, double-tap guarded) states. | **Defined:** Min tap target ≥ 48dp; disabled until valid.<br>**`Unresolved — Requires Clarification`:** Exact button heights and disabled opacity/color tokens. |
| **8** | **Text Fields & Validation States** | Reusable `AppTextField` supporting label, hint, prefix/suffix (including password toggle), and explicit `empty`, `focused`, `filled`, `invalid` (inline localized error message), and `readOnly` (prefilled/locked) states. | **`Unresolved — Requires Clarification`:** Exact field height, border stroke width, and focused/error border colors beyond `AppColors.error`. |
| **9** | **Cards** | Reusable `AppCard` + specialized cards: Bus Card (Available Seats, **no ratings**), 2-Leg Connecting Card (`2-Leg Journey` badge, legs, transfer hub, wait time), Ticket Card / Master E-Ticket Card, Exchange Card, Popular Route Card. States: `default`, `selected`, `disabled`, `unavailable`. | **Defined:** No ratings on bus cards; clear visual hierarchy.<br>**`Unresolved — Requires Clarification`:** Exact card padding, border stroke, and selected-card highlight styling. |
| **10** | **Dialogs & Bottom Sheets** | Reusable `AppModal`, `ConfirmationDialog` (logout, cancellation, declining exchange), `LoginRequiredDialog` (explains reason, preserves search/booking context, Login & Create Account actions), Date/Passenger/Location Picker sheets. | **`Unresolved — Requires Clarification`:** Sheet max-height ratio, drag-handle dimensions, and dialog padding/max-width. |
| **11** | **Loading Indicators** | Reusable `LoadingView` for full-screen/list loading states + inline button loading indicator; never block UI silently on DB queries. | **`Unresolved — Requires Clarification`:** Indicator size, stroke width, and optional skeleton card spec. |
| **12** | **Empty States** | Reusable `EmptyView`: illustrative icon, localized title & short explanation, and contextual next-step CTA (e.g., Clear/Change Search, Explore Trips). | **`Unresolved — Requires Clarification`:** Icon/illustration sizing and vertical spacing. |
| **13** | **Error States** | Reusable `ErrorView`: branches strictly on `FailureType` enum (never raw error strings), displays localized explanation + `Retry` action. | **`Unresolved — Requires Clarification`:** Error card/banner vs full-screen layout thresholds. |
| **14** | **Navigation & Icon Guidelines** | `app_bottom_nav` (4 tabs: `Home`, `Search`, `My Tickets`, `Profile`), secondary screen AppBar (clear title + back action), consistent icon family, and `StatusBadge` (always pairs text label + semantic color, never color alone). | **Defined:** 4 tabs (`PD-P04`), text+color badges (`Project Flow` Sec 10).<br>**`Unresolved — Requires Clarification`:** Exact bottom nav height, active/inactive icon style (filled vs outlined), and badge pill padding. |
| **15** | **Responsive Layout Rules** | `ScreenUtilInit(designSize: Size(375, 812))` + `.w`, `.h`, `.sp`, `.r` paired with `LayoutBuilder`, `MediaQuery.sizeOf`, `SafeArea`, `Expanded`/`Flexible`, and `ConstrainedBox(maxWidth: ...)` for tablet/large screens; never lock orientation or branch on device type. | **Defined:** `375x812` reference size (`PD-T02`), adaptive `LayoutBuilder` rules.<br>**`Unresolved — Requires Clarification`:** Tablet/large-screen `maxWidth` breakpoint. |
| **16** | **Bengali & English Text Expansion** | Prevent `RenderFlex` overflow when switching English ↔ Bengali: use `Expanded`/`Flexible`, `softWrap: true`, `TextOverflow.ellipsis` where bounded, avoid fixed-width/height text boxes, and verify all cards/buttons in both locales. | **Defined:** Zero overflow in EN & BN (`Tech Req` Sec 13). |
| **17** | **Accessibility & System Font Scaling** | Minimum 48×48dp interactive hit areas, semantic labels on icon buttons/seat tiles, keyboard-safe scrollable forms (`resizeToAvoidBottomInset` + `SingleChildScrollView`), WCAG AA text contrast, and layout verification under enlarged system `TextScaler` / font scale. | **`Unresolved — Requires Clarification`:** Maximum supported `TextScaler` clamp policy (if any) vs unconstrained scaling. |

---

## 8. `AGENTS.md` Alignment Status

The database, `C-08` (integer poisha & UTC epoch ms), `C-09` (30/50/20 split), `Q-02` (`shared_preferences` sole store), `UC-01` (Master E-Ticket), `trip_seats` hold mutual exclusivity, `bookings` status sets, and `ticket_exchange_requests` updates in `AGENTS.md` (items #2, #5, #6) have now been **applied**. Remaining non-database `AGENTS.md` clauses (e.g., #1 default locale wording, #3 `flutter_screenutil`/PDF packages, #4 `saved_passengers/` folder tree, #7 navigation guard, #8 bottom nav tabs) remain tracked for their respective phases/approvals.

---

## 9. Remaining Unresolved Clarifications (Post-Phase 2 Alignment)

### 9.1 Remaining `Unresolved — Requires Clarification` Items *(Non-DDL)*
1. **Guest Ticket Cancellation (`R-06`, non-DDL):** Confirm whether Cancellation is **Signed-in only** (recommended) or permitted for Guests via `Find My Ticket` with `holder_mobile` verification.
2. **Abandoned Draft Expiry (`R-01`, non-DDL):** Confirm whether abandoned `pending_payment` / `payment_failed` / `payment_cancelled` drafts stay as audit rows without holding seats after the 5-minute hold expires lazily.
3. **Multi-Seat Cancellation UX & Refund Completion Trigger (`R-02`, non-DDL):**
   - Confirm whether signed-in users cancel **individual tickets** or also "Cancel All My Tickets in Booking".
   - Clarify the exact demo trigger/action that moves `ticket_cancellations.refund_status` from `'refund_pending_demo'` to `'refund_completed_demo'`, and confirm `bookings.payment_status` (`'paid'`) when all cancelled tickets fall in the `0%` (`no_refund_applicable`) tier or while a refund is `refund_pending_demo`.
4. **Back-Navigation Seat Hold Timer (`R-03`, non-DDL):** Confirm whether navigating back from Booking Review / Payment to Seat Selection keeps the remaining 5-minute countdown (recommended) or resets it.
5. **Revoked Ticket Lookup Display (`R-04`, non-DDL):** Confirm whether `Find My Ticket` on a `revoked_exchanged` `ticket_number` shows a neutral `"Exchanged / No Longer Valid"` state without receiver PII (recommended) or `"Ticket not found"`.
6. **Missed Boarding Behavioral Confirmations (`Section 4.2D`, non-DDL):** Confirm `'missed'` irreversibility and atomic `ticket_qr_tokens` revocation whenever `tickets.status` enters a terminal state (`'used'`, `'partially_used'`, `'expired'`, `'cancelled'`, `'revoked_exchanged'`, `'invalidated'`).
7. **Post-Exchange Receiver Ticket Cancellation (`Project Flow` #22 vs `R-02`, non-DDL):** Clarify whether a receiver's replacement `'issued'` ticket (from a completed Ticket Exchange) can use normal cancellation or is blocked.
8. **Design System Visual Tokens (`Section 7`):** Supply approved UI Design specs + bundled `Inter` / `Noto Sans Bengali` font files, or authorize proposing concrete Phase 1 tokens.
9. **Remaining Non-DB `Proposed` Items:** Confirm `PD-P04`–`PD-P08`, `PD-B02`, `PD-B03`, `PD-B05`, `PD-B07`, `PD-B08`, `PD-B11`, `PD-T03`–`PD-T06`, `Q-06`, `Q-07`, `C-01`–`C-06` UI/nav alignments prior to their respective implementation phases.

### 9.2 Phase 2 Implementation Gate
1. **Schema Baseline Locked & Ready for SQLite Implementation:** Zero DDL blockers remain. All 20 tables, PKs, composite FKs, unique/partial indexes (`uidx_active_ticket_per_booking_passenger`), `trip_seats.status` (`available`, `held`, `booked`, `blocked`) and mutual-exclusivity `CHECK` constraints, integer poisha (`*_minor`), UTC epoch ms (`INTEGER`), and defaults are locked and aligned across `AGENTS.md`, `JatraNova_Database_Design.md`, `JatraNova_Technical_Requirements.md`, and `JatraNova_Decision_Log.md`.
2. **Phase 2 Execution Prerequisites:** Add `sqflite_common_ffi` to `pubspec.yaml` `dev_dependencies`, build `AppDatabase` (`onConfigure: PRAGMA foreign_keys = ON`), `migration_v1.dart`, and `seed_data.dart`, and verify with `sqflite_common_ffi` in-memory schema/FK/constraint/rollback tests.
