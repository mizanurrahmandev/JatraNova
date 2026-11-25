# JatraNova --- Database Design Specification

**Passenger Mobile Application · Local Demo · Version 1.2 (Aligned 20-Table Schema) · 25 November 2026**

## 1. Purpose and Authority

This document defines the aligned local SQLite design for JatraNova Passenger App, consolidating [JatraNova_Project_Flow_Updated.md](JatraNova_Project_Flow_Updated.md) and the user-approved database decisions in [JatraNova_Decision_Log.md](JatraNova_Decision_Log.md).

-   Flutter mobile app; local/offline demo only.
-   SQLite through `sqflite` (not Drift); no backend/API/Firebase.
-   No real payment processing or financial settlement.
-   All 20 tables below constitute the single authoritative schema baseline for Phase 2 migrations.

## 2. Design Principles

1.  SQLite is the source of truth for users, saved passengers, catalog/trips, seat inventory/holds, bookings, tickets, per-leg validation, demo payments, cancellations, Ticket Exchange, and local notifications.
2.  Use normalized tables. Never store lists of passenger IDs or seat IDs as comma-separated strings.
3.  Use UUIDs or collision-resistant identifiers (`TEXT` primary keys).
4.  Store all SQLite timestamps as **UTC epoch milliseconds (`INTEGER`)**; the Domain Layer uses Dart `DateTime` and the Data Layer converts at the boundary.
5.  Store all monetary values as integer **poisha** (`*_minor INTEGER`, 100 poisha = ৳1). Never use floating-point (`REAL` / `double`) for money.
6.  Use `db.transaction` for multi-record operations and parameterized SQL (`?` placeholders and `whereArgs`).
7.  Never store plaintext passwords.
8.  QR payloads contain only an opaque random token (zero PII).
9.  Guest ticket lookup returns only the exact ticket matching the submitted `ticket_number`.
10. Do not create an `app_preferences` SQLite table; `shared_preferences` is the sole store for preferences (`onboarding_completed`, `selected_language`, `bangla_numerals_enabled`) and demo session pointers (`session_user_id`, `remember_me`).
11. Enable `PRAGMA foreign_keys = ON` on **every** database connection (`onConfigure`).

## 3. Approved 20-Table Architecture

| # | Table | Purpose |
| :--- | :--- | :--- |
| 1 | `users` | Local signed-in accounts and profile |
| 2 | `saved_passengers` | Friends/family profiles owned by a user (never login accounts) |
| 3 | `bus_operators` | Demo bus operators, bilingual names, exchange & cancel policies |
| 4 | `stops` | Bilingual cities and transfer hubs |
| 5 | `routes` | Point-to-point origin-to-destination route definitions (`no route_stops`) |
| 6 | `trips` | Scheduled point-to-point trips, bus details, bilingual points, and fare |
| 7 | `connection_rules` | Hub transfer buffer limits and bilingual transfer instructions |
| 8 | `trip_seats` | Per-trip seat inventory and lazy-expiring seat holds |
| 9 | `bookings` | Master booking header (direct or connecting; nullable `user_id` for guests) |
| 10 | `booking_legs` | One leg (direct) or two legs (connecting) + demo tracking state |
| 11 | `booking_passengers` | Immutable checkout passenger-to-seat snapshot per leg |
| 12 | `demo_payments` | Local payment simulation attempts and `idempotency_key` tracking |
| 13 | `tickets` | Issued E-Ticket / Master E-Ticket (one per passenger across legs) |
| 14 | `ticket_legs` | Maps one Master E-Ticket to each `booking_leg` & `booking_passenger` + per-leg boarding status |
| 15 | `ticket_qr_tokens` | Opaque QR token hashes (`SHA-256`) and active/revoked lifecycle |
| 16 | `ticket_cancellations` | Per-ticket cancellation audit and demo refund lifecycle |
| 17 | `ticket_exchange_requests` | Ticket Exchange request, Demo Operator approval, and receiver action *(replaces `handover_requests`)* |
| 18 | `ticket_exchange_history` | Immutable audit log of completed Ticket Exchange transfers |
| 19 | `ticket_revenue_splits` | Local demo 30% / 50% / 20% revenue allocation on Original Ticket Price |
| 20 | `notifications` | Bilingual local in-app notifications (signed-in users only) |

*(Obsolete definitions removed: `app_preferences`, `route_stops`, `tickets.passenger_assignment_id`, `handover_requests`, `trips.available_seats`, `guest_session_id`.)*

## 4. Table-Level Logical Schema

### 1. `users`
-   `id TEXT PRIMARY KEY`
-   `full_name TEXT NOT NULL`
-   `mobile TEXT NOT NULL UNIQUE` (normalized)
-   `email TEXT NULL UNIQUE`
-   `credential_hash TEXT NOT NULL` (never plaintext)
-   `avatar_key TEXT NOT NULL DEFAULT 'initials'`
-   `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`

### 2. `saved_passengers`
-   `id TEXT PRIMARY KEY`
-   `user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE`
-   `display_name TEXT NOT NULL`, `full_name TEXT NOT NULL`, `mobile TEXT NOT NULL`, `email TEXT NULL`, `relationship_label TEXT NULL`
-   `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`
-   Index: `idx_saved_passengers_user ON saved_passengers(user_id)`. Only its owning user may manage it; extra seats in a signed-in multi-ticket booking require distinct saved passenger profiles.

### 3. `bus_operators`
-   `id TEXT PRIMARY KEY`
-   `name_en TEXT NOT NULL`, `name_bn TEXT NOT NULL`, `logo_path TEXT NULL`
-   `is_verified INTEGER NOT NULL DEFAULT 1 CHECK(is_verified IN (0, 1))`
-   `allows_exchange INTEGER NOT NULL DEFAULT 1 CHECK(allows_exchange IN (0, 1))`
-   `exchange_cutoff_minutes INTEGER NOT NULL DEFAULT 120 CHECK(exchange_cutoff_minutes >= 0)`
-   `cancellation_policy_json TEXT NOT NULL`
-   `created_at INTEGER NOT NULL`

### 4. `stops`
-   `id TEXT PRIMARY KEY`
-   `city_code TEXT NOT NULL UNIQUE`, `name_en TEXT NOT NULL`, `name_bn TEXT NOT NULL`
-   `is_popular INTEGER NOT NULL DEFAULT 0 CHECK(is_popular IN (0, 1))`
-   `is_transfer_hub INTEGER NOT NULL DEFAULT 0 CHECK(is_transfer_hub IN (0, 1))`

### 5. `routes`
-   `id TEXT PRIMARY KEY`
-   `origin_stop_id TEXT NOT NULL REFERENCES stops(id)`
-   `destination_stop_id TEXT NOT NULL REFERENCES stops(id)`
-   `name_en TEXT NOT NULL`, `name_bn TEXT NOT NULL`
-   `is_popular INTEGER NOT NULL DEFAULT 0 CHECK(is_popular IN (0, 1))`
-   Unique: `UNIQUE(origin_stop_id, destination_stop_id)`, `UNIQUE(id, origin_stop_id, destination_stop_id)`
-   Check: `CHECK(origin_stop_id != destination_stop_id)`

### 6. `trips`
-   `id TEXT PRIMARY KEY`
-   `operator_id TEXT NOT NULL REFERENCES bus_operators(id)`
-   `route_id TEXT NOT NULL`, `origin_stop_id TEXT NOT NULL`, `destination_stop_id TEXT NOT NULL`
-   Composite FK: `FOREIGN KEY (route_id, origin_stop_id, destination_stop_id) REFERENCES routes(id, origin_stop_id, destination_stop_id)`
-   `bus_name_en TEXT NOT NULL`, `bus_name_bn TEXT NOT NULL`
-   `bus_type TEXT NOT NULL CHECK(bus_type IN ('ac_business', 'ac_sleeper', 'non_ac'))`
-   `departure_at INTEGER NOT NULL`, `arrival_at INTEGER NOT NULL` (`CHECK(arrival_at > departure_at)`)
-   `boarding_point_en TEXT NOT NULL`, `boarding_point_bn TEXT NOT NULL`, `drop_off_point_en TEXT NOT NULL`, `drop_off_point_bn TEXT NOT NULL`
-   `facilities_json TEXT NULL`, `fare_minor INTEGER NOT NULL CHECK(fare_minor >= 0)`
-   `total_seats INTEGER NOT NULL CHECK(total_seats > 0)`
-   `is_popular INTEGER NOT NULL DEFAULT 0 CHECK(is_popular IN (0, 1))`, `is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0, 1))`
-   Strictly point-to-point (one origin and one destination; no intermediate boarding/drop-off stops). `available_seats` is derived dynamically from `trip_seats` (never stored redundantly on `trips`).

### 7. `connection_rules`
-   `id TEXT PRIMARY KEY`
-   `hub_stop_id TEXT NOT NULL REFERENCES stops(id)`, `operator_id TEXT NULL REFERENCES bus_operators(id)`
-   `min_buffer_minutes INTEGER NOT NULL DEFAULT 30 CHECK(min_buffer_minutes >= 0)`
-   `max_buffer_minutes INTEGER NOT NULL DEFAULT 240 CHECK(max_buffer_minutes >= min_buffer_minutes)`
-   `transfer_instructions_en TEXT NOT NULL`, `transfer_instructions_bn TEXT NOT NULL`
-   `is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0, 1))`

### 8. `trip_seats`
-   `id TEXT PRIMARY KEY`
-   `trip_id TEXT NOT NULL REFERENCES trips(id) ON DELETE CASCADE`
-   `seat_number TEXT NOT NULL`, `seat_class TEXT NULL`
-   `status TEXT NOT NULL CHECK(status IN ('available', 'held', 'booked', 'blocked'))` (`blocked` = seat not available for passenger booking)
-   `hold_user_id TEXT NULL REFERENCES users(id)`
-   `hold_session_id TEXT NULL`
-   `hold_expiry INTEGER NULL`
-   `booking_id TEXT NULL REFERENCES bookings(id)`
-   Unique: `UNIQUE(trip_id, seat_number)`, `UNIQUE(id, trip_id)`
-   Hold & ownership constraints:
    -   `CHECK(NOT (hold_user_id IS NOT NULL AND hold_session_id IS NOT NULL))` (`hold_user_id` and `hold_session_id` cannot both be populated)
    -   `CHECK((status != 'available') OR (hold_user_id IS NULL AND hold_session_id IS NULL AND hold_expiry IS NULL AND booking_id IS NULL))`
    -   `CHECK((status != 'held') OR (((hold_user_id IS NOT NULL AND hold_session_id IS NULL) OR (hold_user_id IS NULL AND hold_session_id IS NOT NULL)) AND hold_expiry IS NOT NULL AND booking_id IS NULL))`
    -   `CHECK((status != 'booked') OR (booking_id IS NOT NULL AND hold_user_id IS NULL AND hold_session_id IS NULL AND hold_expiry IS NULL))`
    -   `CHECK((status != 'blocked') OR (hold_user_id IS NULL AND hold_session_id IS NULL AND hold_expiry IS NULL AND booking_id IS NULL))`
-   Index: `idx_trip_seats_trip_status ON trip_seats(trip_id, status, hold_expiry)`. Re-check availability inside `db.transaction` before holding or confirming seats.

### 9. `bookings`
-   `id TEXT PRIMARY KEY`
-   `booking_number TEXT NOT NULL UNIQUE`
-   `user_id TEXT NULL REFERENCES users(id)` (`NULL` for guest bookings; no `guest_session_id` column — booking UUID identifies a guest booking)
-   `booking_type TEXT NOT NULL CHECK(booking_type IN ('direct', 'connecting'))`
-   `booking_status TEXT NOT NULL CHECK(booking_status IN ('pending_payment', 'payment_failed', 'payment_cancelled', 'confirmed', 'cancelled', 'partially_cancelled'))`
-   `payment_status TEXT NOT NULL CHECK(payment_status IN ('pending', 'paid', 'partially_refunded_demo', 'refunded_demo'))`
-   `total_amount_minor INTEGER NOT NULL CHECK(total_amount_minor >= 0)`
-   `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`
-   Index: `idx_bookings_user_created ON bookings(user_id, created_at DESC)`. Do not create fake user accounts for guests.

### 10. `booking_legs`
-   `id TEXT PRIMARY KEY`
-   `booking_id TEXT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE`
-   `trip_id TEXT NOT NULL REFERENCES trips(id)`
-   `leg_order INTEGER NOT NULL CHECK(leg_order IN (1, 2))`
-   `transfer_point_en TEXT NULL`, `transfer_point_bn TEXT NULL`, `buffer_minutes INTEGER NULL`
-   `demo_tracking_stage TEXT NULL`, `demo_delay_minutes INTEGER NOT NULL DEFAULT 0 CHECK(demo_delay_minutes >= 0)`
-   Unique: `UNIQUE(booking_id, leg_order)`, `UNIQUE(id, booking_id, leg_order)`, `UNIQUE(id, booking_id, trip_id)`

### 11. `booking_passengers`
-   `id TEXT PRIMARY KEY`
-   `booking_id TEXT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE`
-   `booking_leg_id TEXT NOT NULL`, `trip_id TEXT NOT NULL`
-   Composite FK: `FOREIGN KEY (booking_leg_id, booking_id, trip_id) REFERENCES booking_legs(id, booking_id, trip_id) ON DELETE CASCADE`
-   `saved_passenger_id TEXT NULL REFERENCES saved_passengers(id) ON DELETE SET NULL`
-   `passenger_group_index INTEGER NOT NULL CHECK(passenger_group_index BETWEEN 1 AND 4)`
-   `passenger_name TEXT NOT NULL`, `passenger_mobile TEXT NOT NULL`, `passenger_email TEXT NULL`
-   `seat_id TEXT NOT NULL`, `seat_number_snapshot TEXT NOT NULL`
-   Composite FK: `FOREIGN KEY (seat_id, trip_id) REFERENCES trip_seats(id, trip_id)`
-   Unique: `UNIQUE(booking_leg_id, seat_id)`, `UNIQUE(booking_leg_id, passenger_group_index)`, `UNIQUE(id, booking_id, booking_leg_id, passenger_group_index)`
-   Passenger data is snapshotted at booking time and never overwritten by profile edits or Ticket Exchange.

### 12. `demo_payments`
-   `id TEXT PRIMARY KEY`
-   `booking_id TEXT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE`
-   `idempotency_key TEXT NOT NULL UNIQUE`
-   `method TEXT NOT NULL CHECK(method IN ('mobile_banking', 'card', 'cash_demo'))`
-   `status TEXT NOT NULL CHECK(status IN ('pending', 'success', 'failed', 'cancelled'))`
-   `amount_minor INTEGER NOT NULL CHECK(amount_minor >= 0)`
-   `created_at INTEGER NOT NULL`, `completed_at INTEGER NULL`
-   Partial unique index: `uidx_demo_payments_success_booking ON demo_payments(booking_id) WHERE status = 'success'`. Each retry uses a new `idempotency_key`. Simulation only; never implies gateway settlement.

### 13. `tickets`
-   `id TEXT PRIMARY KEY`
-   `ticket_number TEXT NOT NULL UNIQUE` (unguessable, non-sequential)
-   `booking_id TEXT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE`
-   `passenger_group_index INTEGER NOT NULL CHECK(passenger_group_index BETWEEN 1 AND 4)`
-   `owner_user_id TEXT NULL REFERENCES users(id)` (`NULL` for guest-owned ticket)
-   `holder_name TEXT NOT NULL`, `holder_mobile TEXT NOT NULL`, `holder_email TEXT NULL`
-   `original_ticket_price_minor INTEGER NOT NULL CHECK(original_ticket_price_minor >= 0)`
-   `status TEXT NOT NULL CHECK(status IN ('issued', 'used', 'partially_used', 'expired', 'revoked_exchanged', 'cancelled', 'invalidated'))`
-   `issued_at INTEGER NOT NULL`
-   Unique: `UNIQUE(id, booking_id)`, `UNIQUE(id, booking_id, passenger_group_index)`
-   Indexes: `idx_tickets_number ON tickets(ticket_number)`, `idx_tickets_owner_issued ON tickets(owner_user_id, issued_at DESC)`, `uidx_active_ticket_per_booking_passenger ON tickets(booking_id, passenger_group_index) WHERE status IN ('issued', 'used', 'partially_used', 'expired')` (prevents duplicate active or finalized tickets for the same booking passenger while excluding `revoked_exchanged`, `cancelled`, and `invalidated` so a replacement ticket can be issued after revocation or cancellation).
-   One Master E-Ticket per passenger per booking; maps to 1 or 2 legs through `ticket_legs` (no `passenger_assignment_id`).

### 14. `ticket_legs`
-   `id TEXT PRIMARY KEY`
-   `ticket_id TEXT NOT NULL`, `booking_id TEXT NOT NULL`, `booking_leg_id TEXT NOT NULL`, `leg_order INTEGER NOT NULL CHECK(leg_order IN (1, 2))`
-   `booking_passenger_id TEXT NOT NULL`, `passenger_group_index INTEGER NOT NULL CHECK(passenger_group_index BETWEEN 1 AND 4)`
-   `boarding_status TEXT NOT NULL DEFAULT 'pending' CHECK(boarding_status IN ('pending', 'boarded', 'missed', 'cancelled', 'invalidated'))`
-   `validated_at INTEGER NULL`, `missed_at INTEGER NULL`, `validated_by_demo_context TEXT NULL`
-   Composite FKs:
    -   `FOREIGN KEY (ticket_id, booking_id, passenger_group_index) REFERENCES tickets(id, booking_id, passenger_group_index) ON DELETE CASCADE`
    -   `FOREIGN KEY (booking_leg_id, booking_id, leg_order) REFERENCES booking_legs(id, booking_id, leg_order) ON DELETE CASCADE`
    -   `FOREIGN KEY (booking_passenger_id, booking_id, booking_leg_id, passenger_group_index) REFERENCES booking_passengers(id, booking_id, booking_leg_id, passenger_group_index) ON DELETE CASCADE`
-   Unique: `UNIQUE(ticket_id, booking_leg_id)`, `UNIQUE(ticket_id, leg_order)`
-   Checks: `CHECK((boarding_status != 'boarded') OR (validated_at IS NOT NULL))`, `CHECK((boarding_status != 'missed') OR (missed_at IS NOT NULL))`, `CHECK((boarding_status == 'missed') OR (missed_at IS NULL))`
-   Indexes: `idx_ticket_legs_ticket ON ticket_legs(ticket_id, leg_order)`, `idx_ticket_legs_leg_status ON ticket_legs(booking_leg_id, boarding_status)`, `uidx_active_ticket_leg_passenger ON ticket_legs(booking_leg_id, booking_passenger_id) WHERE boarding_status != 'invalidated'`.

### 15. `ticket_qr_tokens`
-   `id TEXT PRIMARY KEY`
-   `ticket_id TEXT NOT NULL REFERENCES tickets(id) ON DELETE CASCADE`
-   `token_hash TEXT NOT NULL UNIQUE`
-   `status TEXT NOT NULL CHECK(status IN ('active', 'revoked'))`
-   `created_at INTEGER NOT NULL`, `revoked_at INTEGER NULL`
-   Partial unique index: `uidx_active_qr_per_ticket ON ticket_qr_tokens(ticket_id) WHERE status = 'active'`. Only one active QR token per ticket; zero PII.

### 16. `ticket_cancellations`
-   `id TEXT PRIMARY KEY`
-   `booking_id TEXT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE`
-   `ticket_id TEXT NOT NULL UNIQUE`
-   Composite FK: `FOREIGN KEY (ticket_id, booking_id) REFERENCES tickets(id, booking_id) ON DELETE CASCADE`
-   `cancelled_by_user_id TEXT NULL REFERENCES users(id)`
-   `reason TEXT NULL`
-   `refund_percentage INTEGER NOT NULL CHECK(refund_percentage IN (0, 75, 100))`
-   `refund_amount_minor INTEGER NOT NULL CHECK(refund_amount_minor >= 0)`
-   `refund_status TEXT NOT NULL CHECK(refund_status IN ('refund_pending_demo', 'refund_completed_demo', 'no_refund_applicable'))`
-   `cancelled_at INTEGER NOT NULL`
-   Index: `idx_ticket_cancellations_booking ON ticket_cancellations(booking_id, cancelled_at DESC)`. Refund policy: `>= 24h` = 100%, `6h <= delta < 24h` = 75%, `< 6h` = 0%.

### 17. `ticket_exchange_requests`
-   `id TEXT PRIMARY KEY`
-   `ticket_id TEXT NOT NULL REFERENCES tickets(id)`
-   `sender_user_id TEXT NOT NULL REFERENCES users(id)`, `receiver_user_id TEXT NOT NULL REFERENCES users(id)`
-   `receiver_name_snapshot TEXT NOT NULL`, `receiver_mobile_snapshot TEXT NOT NULL`, `optional_message TEXT NULL`
-   `status TEXT NOT NULL CHECK(status IN ('pending', 'approved', 'rejected', 'cancelled', 'declined', 'completed'))`
-   `created_at INTEGER NOT NULL`, `updated_at INTEGER NOT NULL`
-   Check: `CHECK(sender_user_id != receiver_user_id)`
-   Index: `uidx_active_exchange_per_ticket ON ticket_exchange_requests(ticket_id) WHERE status IN ('pending', 'approved')`.

### 18. `ticket_exchange_history`
-   `id TEXT PRIMARY KEY`
-   `request_id TEXT NOT NULL UNIQUE REFERENCES ticket_exchange_requests(id)`
-   `old_ticket_id TEXT NOT NULL UNIQUE REFERENCES tickets(id)`, `new_ticket_id TEXT NOT NULL UNIQUE REFERENCES tickets(id)`
-   `previous_owner_id TEXT NOT NULL REFERENCES users(id)`, `new_owner_id TEXT NOT NULL REFERENCES users(id)`
-   `completed_at INTEGER NOT NULL`

### 19. `ticket_revenue_splits`
-   `id TEXT PRIMARY KEY`
-   `request_id TEXT NOT NULL UNIQUE REFERENCES ticket_exchange_requests(id)`
-   `original_ticket_price_minor INTEGER NOT NULL CHECK(original_ticket_price_minor >= 0)`
-   `operator_share_minor INTEGER NOT NULL CHECK(operator_share_minor >= 0)`
-   `exchanger_share_minor INTEGER NOT NULL CHECK(exchanger_share_minor >= 0)`
-   `platform_share_minor INTEGER NOT NULL CHECK(platform_share_minor >= 0)`
-   `created_at INTEGER NOT NULL`
-   Check: `CHECK(operator_share_minor + exchanger_share_minor + platform_share_minor = original_ticket_price_minor)`. Fixed rule: Bus Operator 30% (floor), Platform 20% (floor), Exchanger remainder (~50%), calculated strictly from `original_ticket_price_minor` for local demo only.

### 20. `notifications`
-   `id TEXT PRIMARY KEY`
-   `user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE`
-   `title_en TEXT NOT NULL`, `title_bn TEXT NOT NULL`, `message_en TEXT NOT NULL`, `message_bn TEXT NOT NULL`
-   `category TEXT NOT NULL CHECK(category IN ('booking', 'payment', 'reminder', 'delay', 'cancellation', 'exchange'))`
-   `is_read INTEGER NOT NULL DEFAULT 0 CHECK(is_read IN (0, 1))`
-   `related_record_type TEXT NULL`, `related_record_id TEXT NULL`
-   `created_at INTEGER NOT NULL`
-   Index: `idx_notifications_user_read_created ON notifications(user_id, is_read, created_at DESC)`. Local in-app only; guest users have no account notification inbox.

## 5. Relationships

```text
users 1 ── N saved_passengers
users 1 ── N bookings (user_id NULL for guest)
users 1 ── N notifications
bus_operators 1 ── N trips
stops 1 ── N routes (origin / destination)
routes 1 ── N trips (composite FK on route_id, origin_stop_id, destination_stop_id)
stops 1 ── N connection_rules
trips 1 ── N trip_seats (UNIQUE(id, trip_id))
bookings 1 ── N booking_legs (1 direct, 2 connecting)
booking_legs N ── 1 trips
bookings 1 ── N booking_passengers
booking_legs 1 ── N booking_passengers (composite FK on booking_leg_id, booking_id, trip_id)
saved_passengers 1 ── N booking_passengers (optional)
trip_seats 1 ── N booking_passengers (composite FK on seat_id, trip_id)
bookings 1 ── N demo_payments (max 1 'success')
bookings 1 ── N tickets (1 Master E-Ticket per passenger_group_index)
tickets 1 ── N ticket_legs (composite FK on ticket_id, booking_id, passenger_group_index)
booking_legs 1 ── N ticket_legs (composite FK on booking_leg_id, booking_id, leg_order)
booking_passengers 1 ── N ticket_legs (composite FK on booking_passenger_id, booking_id, booking_leg_id, passenger_group_index)
tickets 1 ── N ticket_qr_tokens (max 1 'active')
tickets 1 ── 0..1 ticket_cancellations (composite FK on ticket_id, booking_id)
bookings 1 ── N ticket_cancellations
tickets 1 ── N ticket_exchange_requests (max 1 'pending'/'approved')
ticket_exchange_requests 1 ── 0..1 ticket_exchange_history
ticket_exchange_requests 1 ── 0..1 ticket_revenue_splits
```

## 6. Indexes and Constraints

-   Unique normalized `users.mobile`; unique `users.email` when present; unique `stops.city_code`; unique `routes(origin_stop_id, destination_stop_id)` + `UNIQUE(id, origin_stop_id, destination_stop_id)`.
-   Unique `trip_seats(trip_id, seat_number)` + `UNIQUE(id, trip_id)` + mutually exclusive hold owner `CHECK`s.
-   Unique `bookings.booking_number`; unique `demo_payments.idempotency_key`; partial unique `uidx_demo_payments_success_booking`.
-   Unique `tickets.ticket_number`, `UNIQUE(id, booking_id)`, `UNIQUE(id, booking_id, passenger_group_index)`; unique `ticket_qr_tokens.token_hash` + `uidx_active_qr_per_ticket`.
-   Composite FKs on `trips`, `booking_passengers`, `ticket_legs`, and `ticket_cancellations`.
-   Search/lookup indexes on `trips`, `trip_seats`, `bookings`, `tickets`, `ticket_legs`, `ticket_cancellations`, `notifications`.
-   `PRAGMA foreign_keys = ON` on every connection; parameterized SQL and controlled `CHECK` values.

## 7. Required Transactions

### Seat Hold / Release (`db.transaction`)
Clear expired holds (`status = 'held' AND hold_expiry < now` -> `'available'`, hold fields `NULL`) -> verify target seats are `'available'` or held by matching caller owner (`hold_user_id` or `hold_session_id`) with `hold_expiry >= now` -> write `'held'`, single owner (`hold_user_id` OR `hold_session_id`), and `hold_expiry`.

### Booking & Demo Payment Confirmation (`db.transaction`)
Branch on `idempotency_key` in `demo_payments`:
-   **Existing key:** validate immutable request fingerprint (`booking_id`, `amount_minor`, `method`, `booking_type`, `user_id`); exact match replays stored attempt outcome without creating duplicate records/tickets; mismatch fails with `FailureType.conflict`.
-   **New key:** verify `bookings.booking_status` permits payment (`pending_payment`, or retry transitioning `payment_failed`/`payment_cancelled` -> `pending_payment`), verify no prior `'success'` attempt exists, clear expired holds, revalidate seats & `UC-01`/`R-07` invariants, insert `demo_payments` attempt (`success`, `failed`, or `cancelled`).
-   **On `success`:** `bookings.booking_status = 'confirmed'`, `bookings.payment_status = 'paid'`, mark `trip_seats` `'booked'` (clearing hold fields), create `N` Master `tickets` + `N` active `ticket_qr_tokens` + `N × legCount` `ticket_legs` (`pending`), and insert `notifications` (if signed in). On `failed` / `cancelled`: set `bookings.booking_status = 'payment_failed'` / `'payment_cancelled'`, keep `bookings.payment_status = 'pending'`, issue zero tickets.

### Per-Leg Boarding & Missed Marking (`db.transaction`)
Resolve active `ticket_qr_tokens` + `'issued'` `tickets` -> match `ticket_legs` -> atomic `UPDATE ticket_legs SET boarding_status = 'boarded', validated_at = ?, validated_by_demo_context = ? WHERE id = ? AND boarding_status = 'pending'`. Missing an earlier leg records `boarding_status = 'missed'` and `missed_at = now` without invalidating later legs. When zero `'pending'` legs remain on a ticket: all boarded -> `tickets.status = 'used'`; mixed boarded & missed -> `'partially_used'`; all missed -> `'expired'`.

### Ticket Exchange (`db.transaction`)
Revalidate `'approved'` request, `'issued'` direct ticket, cutoff, operator `allows_exchange`, and sender ownership -> keep `booking_passengers` untouched -> revoke old QR, mark old ticket `'revoked_exchanged'`, mark old `ticket_legs` `'invalidated'` -> insert new `tickets` (`holder_*` from receiver) + new active `ticket_qr_tokens` + new `ticket_legs` (`pending`) -> mark request `'completed'`, insert `ticket_exchange_history` & `ticket_revenue_splits` (30/50/20 floor rounding), notify both users.

### Cancellation (`db.transaction`)
Verify `'issued'` ticket, `booking_id` match, ownership, no active exchange request, and `delta > 0` -> compute tier (`100%` / `75%` / `0%`) -> insert `ticket_cancellations` (`refund_pending_demo` or `no_refund_applicable`; later transitions to `refund_completed_demo`) -> set `tickets.status = 'cancelled'`, revoke QR, set `ticket_legs.boarding_status = 'cancelled'`, free `trip_seats` to `'available'` -> update `bookings.booking_status` (`partially_cancelled` or `cancelled`) and `bookings.payment_status` (`paid`, `partially_refunded_demo`, `refunded_demo`), notify owner(s).

## 8. Guest Lookup and Privacy

-   Accept an exact unique `ticket_number` (`bookings.user_id IS NULL` for guest bookings; identified by booking UUID without `guest_session_id`).
-   Return only that matching ticket and its display details; never expose a guest ticket list, booking history, or unrelated passenger records.
-   QR payload contains an opaque token only (zero PII).

## 9. Migrations, Seed Data and Tests

-   Versioned schema (`databaseVersion = 1`) and sequential migrations (`migration_v1.dart`, etc.).
-   Deterministic seed operators, stops, point-to-point routes, trips, `trip_seats`, `connection_rules`, and demo users; never overwrite user-created data on launch.
-   Test with `sqflite_common_ffi` (in-memory DB): migrations, `PRAGMA foreign_keys = ON`, composite FKs, mutual-exclusivity `trip_seats` `CHECK`s, partial unique indexes, rollback, seat collision, payment idempotency, Master E-Ticket per-leg validation & missed transitions, cancellation, Ticket Exchange, and exact guest lookup.

## 10. Remaining Unresolved Clarifications (Do Not Guess)

-   All DDL/schema decisions are locked and ready for SQLite implementation.
-   Remaining non-DDL runtime/UI rules: abandoned draft expiry (`R-01`), `bookings.payment_status` when all cancelled tickets fall in `0%` (`no_refund_applicable`) or while `refund_pending_demo`, demo trigger for `refund_pending_demo` -> `refund_completed_demo` & multi-seat cancel UX (`R-02`), back-nav hold timer (`R-03`), `Find My Ticket` display for `revoked_exchanged` (`R-04`), guest cancellation (`R-06`), `'missed'` irreversibility & terminal QR revocation (`4.2D`), and post-exchange receiver ticket cancellation eligibility.
