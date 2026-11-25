JATRANOVA

Passenger App

Complete Screen Flow, UI Components & Business Logic

A clear, step-by-step specification for design and Flutter development

DEMO APPLICATION SPECIFICATION • VERSION 1.0 • 23 NOVEMBER 2026

# Document Purpose

This document explains how the JatraNova Passenger App should look and
behave. It defines the purpose of each screen, the order of its UI
components, what happens when a user interacts with those components,
and the business rules that must be followed.

It is written in simple English so that a UI/UX designer, Flutter
developer, tester, or project reviewer can understand the same product
requirements.

# Project Scope and Important Boundaries

| Area \| Project decision \|

| --- \| --- \|

| Application \| Passenger mobile application only. \|

| Implementation type \| Local demo application. No production backend
  or API integration. \|

| State management \| BLoC. \|

| Architecture \| Feature-first Clean Architecture. \|

| Local database \| sqflite. \|

| Payment \| Demo payment selection and simulation only. No real payment
  gateway or money transfer. \|

| Authentication \| Local demo account/session behaviour. No OTP flow.
  \|

| Notifications \| Locally generated demo notifications. No real
  push-notification service. \|

| Live tracking \| Simulated bus position and journey progress. No live
  GPS or operator dispatch integration. \|

| Operator approval \| Clearly labelled local demo approval. It must not
  be presented as real operator approval. \|

Important: Every screen must clearly communicate when an action is
simulated. Do not show a successful real payment, real refund, real
operator approval, or live bus location when the application only uses
local demo data.

# How to Read Each Screen Specification

Purpose explains why the screen exists.

Recommended layout explains the top-to-bottom component order.

UI components lists the visible controls and information.

User actions explains what should happen after a tap or selection.

Business rules and validation define what is allowed and what must be
blocked.

Required UI states describe loading, empty, error, disabled, and success
conditions where relevant.

Navigation explains the next screen or return path.

# Contents

1.  Product-wide rules and navigation

2.  Onboarding and account access

3.  Home and passenger discovery

4.  Search and bus discovery

5.  Seat selection and booking

6.  Tickets, cancellation and history

7.  Ticket handover

8.  Connecting journeys

9.  Tracking and supporting screens

10. Data and business logic rules

11. Reusable UI components

12. Main user flow diagrams

13. Corrections and decisions to confirm

# 1. Product-wide Rules and Navigation

## 1.1 User types and permissions

| Feature \| Guest user \| Logged-in user \|

| --- \| --- \| --- \|

| Search buses \| Allowed \| Allowed \|

| View bus details \| Allowed \| Allowed \|

| Browse seat layout \| Allowed \| Allowed \|

| Create a booking \| Login required \| Allowed \|

| View My Tickets \| Login required \| Allowed \|

| Ticket handover \| Login required \| Allowed \|

| View personal profile \| Login required \| Allowed \|

| Browse public app information \| Allowed \| Allowed \|

When a guest opens a protected feature, show a Login Required dialog.
Explain the reason in plain language, then provide Login and Create
Account actions. Keep the guest's current search details when possible
so the user does not need to start again after signing in.

## 1.2 Main bottom navigation

| Tab \| Purpose \| Guest behaviour \|

| --- \| --- \| --- \|

| Home \| Main dashboard and quick search \| Available \|

| Search \| Search for direct and connecting buses \| Available \|

| My Tickets \| Upcoming, completed and cancelled tickets \| Show login
  gate \|

| Profile \| Account details and app settings \| Show login/register
  view \|

## 1.3 Shared interaction rules

Show a clear page title and back action on secondary screens.

Use consistent spacing, typography, button styles, field styles, icons,
and status colours.

Disable a primary action until its required fields are valid.

Show a short, understandable error message beside the relevant field or
in a clear message area.

Ask for confirmation before destructive actions such as cancellation,
logout, or declining a handover.

Never show a rating on bus result cards. Show available seat count
instead.

Only display bus facilities that exist in the local demo dataset.

Preserve form selections when moving between related steps unless the
user changes them.

# 2. Onboarding and Account Access

## 1. Splash Screen

Purpose: Show the JatraNova identity while the app starts.

Recommended layout:

Place the JatraNova logo and app name in the centre.

Place the tagline below the app name.

Show a small loading indicator near the lower area.

Show the app version at the bottom.

UI components:

JatraNova logo

App name

Tagline: "Your Journey, Connected"

Loading indicator

App version

User actions and expected behaviour:

Load saved language preference and local user session.

If this is the first launch, open Onboarding, then Language Selection,
then Welcome Choice. Mark the first-launch flow as completed after the
user finishes or skips onboarding.

On every second and subsequent app launch, open Home directly. Restore a
valid signed-in session when one exists; otherwise open Home in Guest
mode. Do not show Onboarding, Language Selection, or Welcome Choice
again automatically.

If there is no signed-in session on a subsequent launch, continue
directly to Guest Home. Login and Create Account remain available from
account/protected-feature entry points.

## 2. Onboarding Screens

Purpose: Introduce the app's main benefits before the user enters the
app.

Recommended layout:

Use a full-screen illustration for each page.

Place a short heading and one or two lines of description below the
illustration.

Place page indicators near the bottom.

Place Skip and Next actions at the bottom; replace Next with Get Started
on the final page.

UI components:

Illustration

Heading and short description

Page indicator

Skip button

Next button

Get Started button

User actions and expected behaviour:

Page 1 introduces easy bus search and booking.

Page 2 introduces digital QR tickets and journey management.

Page 3 introduces ticket handover and connecting journeys.

Next opens the next onboarding page. Skip or Get Started opens Language
Selection, followed by Welcome Choice. This onboarding sequence is shown
only on the first app launch.

## 3. Language Selection and Welcome Choice

Purpose: Let the user choose a language, then choose how to enter the
app.

Recommended layout:

First show a language selection panel with the heading "Choose Your
Language".

Show Bangla and English as two selectable cards.

Show a selected indicator on the active card and a Continue button.

After Continue, show the JatraNova logo, welcome heading, and three
clear actions.

UI components:

Bangla language card

English language card (default)

Selected language indicator

Continue button

JatraNova logo

Welcome heading

Login button

Create Account button

Continue as Guest button

Language switch

User actions and expected behaviour:

English is selected by default on the first launch.

Save the chosen language in local preferences.

Continue opens the Welcome Choice view.

Login opens Login Screen; Create Account opens Registration; Continue as
Guest opens Home in guest mode.

The language switch can reopen language selection.

Business rules and validation:

Language selection is shown only during the first-launch setup. On later
launches, use the saved language and open Home directly. The user can
change language later from Settings.

## 4. Login Screen

Purpose: Allow an existing demo user to access their account.

Recommended layout:

Show the page title and a short welcome message.

Place the email/mobile field first, then password field.

Place Remember Me and Forgot Password below the password field.

Place the primary Login button, then Create Account and Continue as
Guest links.

UI components:

Email or Bangladesh mobile number input

Password input

Password visibility toggle

Remember Me checkbox

Forgot Password link

Login button

Create Account link

Continue as Guest link

User actions and expected behaviour:

Accept either a valid email address or a valid Bangladesh mobile number
in the same identifier field.

Validate that the password is not empty.

Show a clear message when the credentials do not match a local demo
account.

On success, save the local user session and open Home.

Continue as Guest opens Home without creating a signed-in session. Guest
users may search buses, select seats, enter passenger details, complete
the local demo purchase, and view a purchased ticket by entering its
unique ticket number. All other account-based features remain
login-protected.

Business rules and validation:

Do not create an OTP screen.

Remember Me controls whether the local session remains active after the
app is closed; define this behaviour consistently.

Do not expose whether an email or phone number belongs to an account in
a way that reveals another user's private information.

## 5. Registration and Forgot Password

Purpose: Create a local demo account or simulate password recovery.

Recommended layout:

Use two separate pages: Registration and Forgot Password.

Registration: show fields in a single scrollable form with the Create
Account button at the bottom.

Forgot Password: show one identifier field, a Continue button, demo
information, and Back to Login.

UI components:

Registration: Full Name

Mobile Number

Email Address

Password

Confirm Password

Terms and Conditions checkbox

Create Account button

Already Have an Account link

Forgot Password: registered email or mobile input

Continue button

Demo recovery information

Back to Login link

User actions and expected behaviour:

Require a name and valid Bangladesh mobile number.

Require a valid email address and check that email and mobile are not
already used in the local database.

Password and Confirm Password must match.

Require acceptance of Terms and Conditions before account creation.

On successful registration, save the user locally and open Home or Login
according to the agreed experience.

Forgot Password must display a demo recovery result only.

Business rules and validation:

There is no real email/SMS recovery or server identity verification.

Never claim that an actual email or SMS has been sent.

# 3. Home and Passenger Discovery

## 6. Home Screen

Purpose: Help passengers start a bus search quickly and discover useful
routes and features.

Recommended layout:

Header: greeting and account actions.

Search card: From and To on the first row; swap control between or
beside them; date and passenger count on the next row; Search button at
the bottom.

Popular Routes: horizontal route cards.

Popular Buses: vertical cards showing operator, bus type, route,
available seats, and fare.

Feature cards: connecting journey and ticket handover.

Bottom navigation fixed at the bottom.

UI components:

Greeting and user name or Guest label

Profile icon

Notification icon

From location selector

To location selector

Swap button

Journey date

Passenger count

Search Bus button

Popular Routes cards

Popular Buses cards

Connecting Journey information card

Ticket Handover information card

Bottom navigation: Home, Search, My Tickets, Profile

User actions and expected behaviour:

Tapping Search Bus opens Search Results using the selected search
values.

Tapping a popular route pre-fills origin and destination, then opens
results or the Search screen for confirmation.

Tapping a popular bus opens Bus Details.

Notification icon opens Notifications.

Guest users cannot access the signed-in My Tickets list. Instead,
provide a separate Find My Ticket option where a guest enters the unique
ticket number to view only that matching ticket. Do not expose ticket
history or other account features.

Ticket Handover card opens the information view; starting handover
requires login.

Business rules and validation:

Use available seats, not ratings, on bus cards.

Do not show unsupported bus facilities or unverified data.

If no popular buses exist in demo data, show a useful empty state.

## 7. Notification Screen

Purpose: Show important updates about bookings, journeys, and handovers.

Recommended layout:

Place the title and Mark All as Read action in the header.

Place category filters below the header.

Show notifications as a vertical list, newest first.

UI components:

Notification list

Notification icon

Title

Description

Date and time

Read/unread indicator

Mark All as Read button

Category filter

User actions and expected behaviour:

Support booking success, payment success, journey reminder, bus delay,
ticket cancellation, handover request update, handover
approved/rejected, receiver accepted, handover completed, and connecting
journey reminder.

Tapping a notification opens the relevant ticket, booking, or handover
detail screen when applicable.

Mark All as Read updates all local notification records.

Business rules and validation:

States: Loading, Empty, Read, and Unread.

A notification must not claim that a real payment, real refund, or live
bus event occurred if it was generated by demo logic.

## 8. Profile Screen

Purpose: Show account information and shortcuts to account-related
features.

Recommended layout:

For a signed-in user, show avatar, name, email, and mobile number at the
top.

Show Edit Profile as a prominent action.

Show ticket and handover shortcuts in a grouped list.

Place language, notification settings, Help & Support, About, and Logout
below.

UI components:

Profile image or initials avatar

Full name

Email

Mobile number

Edit Profile

My Tickets shortcut

Handover History shortcut

Language

Notification Settings

Light & dark theme

Help & Support

About JatraNova

Logout

User actions and expected behaviour:

Edit Profile opens Edit Profile screen.

My Tickets and Handover History open their respective screens.

Language opens Language Settings.

Light & dark theme settings

Logout opens a confirmation dialog; confirm clears the local session and
returns to Welcome Choice or Guest Home.

For guests, show Login/Register actions and explain that profile
management, saved passengers, full ticket list/history, Ticket Exchange,
notifications and other account-based features require login. Guest
ticket lookup by unique ticket number remains available.

# 4. Search and Bus Discovery

## 9. Search Screen

Purpose: Collect the route, travel date, and passenger count needed to
find buses.

Recommended layout:

Show From and To selectors at the top with a swap button.

Show date and passenger selector beneath them.

Place Search button as the main action.

Show Recent Searches and Popular Routes below the form.

UI components:

From location selector

To location selector

Swap button

Journey date picker

Passenger selector

Search button

Recent Searches

Popular Routes

User actions and expected behaviour:

Location selector opens a searchable city list with popular cities and a
clear selection state.

Swap exchanges origin and destination.

Date and passenger selection can open a bottom sheet or full-screen
selector.

Search opens Bus Search Results using the selected values.

Business rules and validation:

Origin and destination cannot be the same.

Past dates cannot be selected.

Passenger count must be within the supported range configured for the
demo.

Show a validation message instead of silently changing invalid values.

## 10. Date and Passenger Selector

Purpose: Allow the passenger to select a valid travel date and passenger
count.

Recommended layout:

Use a calendar for date selection.

Place month navigation above the calendar and a Today marker where
relevant.

Place passenger count controls below the calendar or on a separate
tab/section.

Place Done at the bottom.

UI components:

Calendar

Previous/Next month controls

Today indicator

Selected date indicator

Disabled past dates

Adult count

Increase/decrease buttons

Total passenger count

Done button

User actions and expected behaviour:

Selecting a date updates the search form.

Increase/decrease changes the passenger count within the allowed range.

Done returns the selected date and count to the previous screen.

## 11. Bus Search Results

Purpose: Display available direct and connecting journey options.

Recommended layout:

Keep a compact search summary at the top with Change Search.

Use separate Direct Buses and Connecting Journeys tabs.

Place Filter and Sort controls near the result count.

Show each bus in a clear card; use a separate layout for two-leg journey
cards.

UI components:

Search summary header

Change Search action

Journey date

Result count

Direct Bus tab

Connecting Journey tab

Filter button

Sort button

Bus cards with operator, bus name/type, departure/arrival,
boarding/drop-off, available seats, fare, and View Seats/Details

User actions and expected behaviour:

Direct results must be clearly separate from connecting results.

Bus card tap opens Bus Details or Connection Details.

Change Search returns to the search form with existing values prefilled.

Filter and Sort update the displayed local results.

Business rules and validation:

Show Available Seats instead of Rating.

Sort options: Lowest Fare, Earliest Departure, Earliest Arrival.

Filters: AC/Non-AC, bus type, departure time, fare range, and available
seats.

Show an empty state when no matching buses exist.

## 12. Filter and Sort

Purpose: Help passengers narrow down and order search results.

Recommended layout:

Show filter groups in a scrollable page or bottom sheet.

Place Reset and Apply Filter actions at the bottom.

Sort can be a separate bottom sheet or a clearly labelled section.

UI components:

Price range slider

AC/Non-AC

Sleeper/Seater

Departure time range

Arrival time range

Operator

Boarding point

Available seat count

Reset button

Apply Filter button

User actions and expected behaviour:

Apply Filter updates search results and closes the filter view.

Reset restores default filter values.

Keep selected filter values when the user reopens the filter panel.

## 13. Bus Details

Purpose: Present all information needed before choosing seats.

Recommended layout:

Show operator image/logo and bus name at the top.

Show departure and arrival times with route and duration.

Show a route timeline and boarding/drop-off points.

Show available seats and fare prominently.

Place facilities, cancellation policy, and handover policy in separate
information sections.

Keep Select Seats as the primary bottom action.

UI components:

Bus image or operator logo

Operator name

Bus type

Departure and arrival

Journey duration

Route timeline

Boarding point

Drop-off point

Available seats

Fare information

Bus facilities

Cancellation policy

Handover policy

Select Seats button

User actions and expected behaviour:

Only display facilities available in the local dataset: AC, charging
point, Wi-Fi (if present), water, and reclining seat.

Select Seats opens Seat Selection.

Policies must be readable before the user continues.

# 5. Seat Selection and Booking

## 14. Seat Selection

Purpose: Let the passenger choose the required number of available
seats.

Recommended layout:

Show a compact trip summary at the top.

Show driver position and a visual seat layout in the centre.

Use a legend to explain seat statuses.

Show selected seat numbers and fare summary near the bottom.

Keep Continue fixed at the bottom.

UI components:

Trip summary

Driver position

Seat layout

Seat numbers

Legend: Available, Selected, Booked, Unavailable

Selected seats summary

Fare per seat

Total fare

Continue button

Demo seat-hold timer

User actions and expected behaviour:

Tap an Available seat to select it; tap a Selected seat to remove it.

Booked and Unavailable seats are disabled.

The number of selected seats cannot exceed the passenger count.

Update selected seats and total fare immediately.

Continue is enabled only when the selected seat count matches the
passenger count.

Business rules and validation:

A demo hold timer may clear the selection when it expires.

When the timer expires, clear the selected seats and show a message
asking the user to select again.

Re-check availability against the current local demo records before
continuing.

## 15. Passenger Information

Purpose: Collect the passenger details and map each passenger to a
selected seat.

Recommended layout:

For a signed-in user, show the account holder's saved profile details as
the default first passenger and prefill the form automatically. For a
guest, show an empty passenger form. The booking may include the account
holder plus additional passengers selected from the signed-in user's
Saved Passengers list.

For each selected seat, show a separate passenger section. A signed-in
user may book one ticket for themselves by default. To book additional
tickets, they must add/select each friend or family member from Saved
Passengers; each additional ticket must use that person's own saved
passenger information. Do not duplicate the account holder as multiple
passengers.

Show the seat number beside each passenger section.

Place Continue at the bottom.

UI components:

Passenger name (prefilled from signed-in profile; editable subject to
validation)

Mobile number

Optional email

Passenger details

Gender only if required by the demo data/rules

Seat-to-passenger mapping

Save Passenger to Profile / Saved Passengers (signed-in users)

Continue button

User actions and expected behaviour:

Every passenger must have their own required name and valid mobile
number. For signed-in users, prefill the account holder's own details
and allow selection of saved friends/family for additional seats. Do not
copy the account holder's details into another passenger's ticket.

Validate all required passenger fields.

Passenger count must match selected seat count.

For a connecting journey, collect passenger information once and
associate it with every journey leg.

Continue opens Booking Review.

## 16. Booking Review

Purpose: Give the passenger a final opportunity to check all booking
information.

Recommended layout:

Show bus/operator and route summary first.

Show date/time, boarding/drop-off, seats, and passenger information.

Show fare breakdown and total amount.

Show cancellation and handover policy summaries.

Place Terms checkbox and Proceed to Payment at the bottom.

UI components:

Bus/operator information

Route

Departure date and time

Boarding and drop-off

Selected seats

Passenger details

Ticket fare

Service charge only if configured in demo data

Discount/promo only if enabled

Total amount

Cancellation rule

Handover rule

Terms checkbox

Proceed to Payment button

User actions and expected behaviour:

The total must equal the sum of the displayed fare components minus any
enabled discount.

Do not invent a service charge or discount if it is not configured in
demo data.

Require Terms acceptance before payment.

For a connecting journey, show Leg 1, transfer point, waiting duration,
Leg 2, seat per leg, combined fare, and a clear combined-booking notice.

## 17. Demo Payment

Purpose: Simulate a payment choice without moving real money.

Recommended layout:

Show booking ID and total amount at the top.

Show a visible DEMO PAYMENT label.

Show payment method cards.

Place Confirm Demo Payment as the primary action and payment status
below.

UI components:

Booking ID

Total amount

Demo Payment label

Mobile banking option

Card option

Cash/other demo option

Confirm Demo Payment button

Payment status

User actions and expected behaviour:

Payment methods are selections for demonstration only; there is no
payment gateway.

On confirmation, run one local payment simulation and save its result.

Prevent duplicate booking creation if the user taps repeatedly or
revisits payment for the same booking.

Support Processing, Success, Failed, and Cancelled states.

If payment fails or is cancelled, retain the booking attempt safely and
provide a clear retry/back path without creating duplicate tickets.

## 18. Booking Confirmation

Purpose: Confirm that the local demo booking has been created.

Recommended layout:

Show a success icon and clear confirmation heading.

Show booking ID, payment status, bus, journey date, and seats.

Place View E-Ticket and My Tickets as primary actions, with Back to Home
as a secondary action.

UI components:

Success icon

Booking Confirmed title

Booking ID

Payment status

Bus name

Journey date

Seat number(s)

View E-Ticket button

My Tickets button

Back to Home button

User actions and expected behaviour:

Save the booking in the local database.

Create ticket record(s), generate a unique local QR token, and create a
local notification.

Only show a confirmed status after the local demo payment result is
successful.

## 19. My Tickets

Purpose: Let signed-in passengers access their upcoming, completed, and
cancelled tickets.

Recommended layout:

Show tabs at the top: Upcoming, Completed, Cancelled.

Show ticket cards in a vertical list.

Each card should show the route, journey date/time, seat, booking ID,
and status.

UI components:

Upcoming tab

Completed tab

Cancelled tab

Operator

Route

Journey date

Departure time

Seat number

Booking ID

Ticket status

View Details button

User actions and expected behaviour:

View Details opens E-Ticket or Ticket Details. Guests can reach only the
single ticket returned by Find My Ticket using its unique ticket number;
they cannot browse My Tickets or ticket history.

After a completed handover, the new owner's ticket appears in Upcoming
and the previous owner's ticket is removed from their active ticket
list.

Completed tickets cannot be handed over.

## 20. E-Ticket / QR Ticket

Purpose: Show the passenger's ticket details and a scannable demo token.

Recommended layout:

Show JatraNova branding and ticket status at the top.

Show passenger, bus, route, date/time, boarding/drop-off, and seat
details.

Place the QR code prominently, with Download and Share actions below.

UI components:

JatraNova logo

Booking ID

Passenger name

Bus name

Route

Date and departure time

Boarding point

Drop-off point

Seat number

QR code

Ticket status

Download/Share button

User actions and expected behaviour:

The QR code must contain only a unique local ticket token, not personal
information.

After a completed handover, invalidate the old QR token and create a new
token for the new owner's ticket.

The app must validate the token against local ticket data for demo
purposes.

## 21. Ticket History

Purpose: Provide a record of previous booking activity.

Recommended layout:

Show a title and filter chips at the top.

List historical booking records with date, operator, route, booking
status, and payment status.

UI components:

Booking history list

Journey date

Booking date

Bus operator

Route

Booking status

Payment status

View Ticket action

Filters: All, Completed, Cancelled, Handover

User actions and expected behaviour:

View Ticket opens the relevant ticket record if it is still available.

Handover history should remain traceable even when ticket ownership
changes.

## 22. Cancellation and Refund Status

Purpose: Explain whether a ticket can be cancelled and show the
simulated refund progress.

Recommended layout:

Show ticket summary first.

Show eligibility and the operator cancellation policy.

If eligible, show estimated demo refund and cancellation reason field.

Use a confirmation dialog before sending the cancellation request.

Show a status timeline after request submission.

UI components:

Ticket summary

Cancellation eligibility

Operator cancellation policy

Estimated refund

Cancellation reason

Request Cancellation button

Confirmation dialog

Cancellation status timeline

User actions and expected behaviour:

Calculate demo refund only from the configured cancellation policy.

States: Not Eligible, Eligible, Cancellation Requested, Cancelled,
Refund Pending (Demo), Refund Completed (Demo).

A handover-completed ticket cannot use the normal cancellation flow.

Clearly label all refund values and statuses as demo simulations.

# 6. Ticket Handover

## 23. Ticket Handover Home

Purpose: Explain ticket handover and show the user's eligible upcoming
tickets.

Recommended layout:

Show the Ticket Handover title and a short explanation.

Show Handover Rules and Revenue Sharing cards.

Show eligible ticket count and upcoming tickets.

Place Handover History shortcut below.

UI components:

Header

Short explanation

Handover rules card

Revenue sharing information

Eligible ticket count

Upcoming ticket list

Handover History shortcut

User actions and expected behaviour:

Guests may look up a ticket only through Find My Ticket using its unique
ticket number. All ticket list/history and Ticket Exchange actions
require login.

Show the revenue split: Operator 30%, Handoverer 50%, JatraNova 20%.

The split is calculated from the Original Ticket Price, not the handover
price or receiver's separately entered amount.

## 24. Available Tickets for Handover

Purpose: List the user's tickets and make eligibility clear.

Recommended layout:

Show eligible tickets first.

Each ticket card should show bus, route, date, original price, seat, and
an eligibility badge.

If ineligible tickets are shown, visually disable them and explain why.

UI components:

Eligible ticket list

Bus name

Route

Journey date

Original ticket price

Seat number

Eligibility badge

Select Ticket button

User actions and expected behaviour:

Ticket must be confirmed, unused, not cancelled, and the journey must
not have started.

Ticket must not have been handed over before.

Operator policy in the local dataset must allow handover.

For an ineligible ticket, show a clear reason such as Journey Started,
Already Handed Over, Cancelled, or Operator Policy Does Not Allow
Handover.

## 25. Handover Ticket Details

Purpose: Let the current owner review ticket details, eligibility, and
revenue sharing.

Recommended layout:

Show the selected ticket summary at the top.

Show the eligibility checklist and handover conditions.

Show the revenue split as a clear three-row breakdown.

Place Continue at the bottom.

UI components:

Selected ticket summary

Original ticket price

Bus operator

Route

Journey date

Seat number

Current ticket owner

Eligibility checklist

Handover conditions

Revenue split preview

Continue button

User actions and expected behaviour:

Example for an original ticket price of ৳1,000: Operator ৳300,
Handoverer ৳500, JatraNova ৳200.

Calculate all three shares from the original ticket price.

If a separate handover price/receiver amount is displayed, label it
separately and never use it as the split calculation base.

## 26. Receiver Information and Handover Request

Purpose: Collect the intended receiver's information and create a
pending request.

Recommended layout:

Show receiver fields first.

Show a compact ticket summary below or above the form.

Place Submit Request at the bottom.

UI components:

Receiver full name

Registered Bangladesh mobile number

Optional message

Ticket information

Submit Request button

User actions and expected behaviour:

Require full name and a valid Bangladesh mobile number.

The receiver must already exist in the local demo user database.

The current user cannot select themselves as the receiver.

Do not allow more than one active request for the same ticket.

On submission, save the receiver details and create a request with
Pending Approval status.

## 27. Handover Approval Status

Purpose: Show the current status of the handover request.

Recommended layout:

Show Request ID and ticket summary at the top.

Show sender and receiver information.

Show a vertical status timeline.

Show Cancel Request only while the request is Pending.

UI components:

Request ID

Ticket summary

Sender information

Receiver information

Request date

Approval status

Timeline

Cancel Request action when pending

User actions and expected behaviour:

Possible statuses: Pending, Approved, Rejected, Cancelled.

Use a local demo approval engine with predefined rules.

Save the approval result in the local database.

Label the result as Demo Operator Approval; never imply that a real bus
operator approved it.

## 28. Receiver Acceptance and Demo Settlement

Purpose: Allow the approved receiver to accept or decline the handover
and show the demo revenue split.

Recommended layout:

Show request and ticket details first.

Show original ticket price and revenue breakdown.

Show Demo Payment Summary.

Place Accept Handover and Decline as separate actions.

UI components:

Handover request details

Bus, route, date

Seat number

Original ticket price

Revenue split

Accept Handover button

Decline button

Demo payment summary

User actions and expected behaviour:

Only the registered receiver can accept or decline in the local demo
flow.

Accept starts the demo settlement sequence.

Decline changes the request to Cancelled/Declined and keeps the existing
ticket owner unchanged.

Show the split based on Original Ticket Price: Operator 30%, Handoverer
50%, JatraNova 20%.

No real payment or payout takes place.

## 29. Handover Success and History

Purpose: Confirm the completed ownership change and show the new ticket.

Recommended layout:

Show a success icon and Handover ID.

Show previous and new owner details with bus, route, seat, and journey
date.

Show revenue breakdown.

Show the new ticket QR and actions to view it or open history.

UI components:

Handover success icon

Handover ID

Previous owner

New owner

Bus details

Seat number

Journey date

Revenue breakdown

New ticket QR

View New Ticket button

View Handover History button

User actions and expected behaviour:

Before completion, the old ticket remains valid.

At completion, perform ownership change and QR replacement together in
one local database transaction.

Invalidate the old QR token and create a new ticket/token for the new
owner.

Remove the previous owner's active ticket access and show the new
owner's ticket in Upcoming.

Create notifications for both users and save handover history and
revenue split record.

If any database operation fails, roll back the transaction so ownership
and QR data remain consistent.

# 7. Connecting Journeys

## 30. Connecting Journey Search

Purpose: Search for both direct and same-operator connecting journeys.

Recommended layout:

Reuse the standard search form: origin, destination, date, and passenger
count.

Add a short information panel explaining that a connecting journey uses
two bus legs.

UI components:

Origin

Destination

Journey date

Passenger count

Search button

Connecting journey information

User actions and expected behaviour:

Search direct and connecting options using local demo data.

Show direct trips first in the Direct tab and connecting options in a
separate Connecting tab.

## 31. Connecting Journey Results

Purpose: Show each two-leg option clearly as a connecting journey.

Recommended layout:

Show search summary at the top.

Use Direct Results and Connecting Results tabs or clearly separated
sections.

Each connecting card must have a visible 2-Leg Journey badge.

Show both legs and the transfer information before the price.

UI components:

Search summary

Direct results section/tab

Connecting results section/tab

Operator name

Leg 1 departure and arrival

Transfer point

Waiting time

Leg 2 departure and arrival

Total journey duration

Combined fare

Available seats

View Connection button

User actions and expected behaviour:

Never display a connecting journey as a direct bus.

Both legs must use the same operator for this demo feature.

Show available seats only when both legs have enough seats for the
passenger count.

## 32. Connection Details

Purpose: Explain the full two-leg journey before the passenger commits.

Recommended layout:

Show an overall journey summary.

Use separate cards for Leg 1 and Leg 2.

Between the leg cards, show a visually prominent transfer point and
waiting duration.

Show total time and combined fare before Continue.

UI components:

Overall journey summary

Operator name

Leg 1 bus details

Leg 1 boarding/drop-off

Transfer point

Waiting time

Leg 2 boarding/drop-off

Leg 2 bus details

Total journey time

Total fare

Connection rules

Continue button

User actions and expected behaviour:

Validate same operator, matching transfer point, minimum transfer time,
maximum waiting time, and seat availability on both legs.

Do not allow continuation if any required validation fails.

Clearly show the passenger that they must change buses at the transfer
point.

## 33. Transfer Point Details

Purpose: Make the transfer process easy to understand and reduce the
risk of a missed connection.

Recommended layout:

Show the transfer hub name as the main heading.

Show Leg 1 arrival and Leg 2 departure times side by side or in a
timeline.

Show waiting duration and second bus boarding point.

Show change-bus instructions and a warning before Continue.

UI components:

Transfer hub name

First bus arrival time

Second bus departure time

Waiting duration

Second bus boarding point

Change bus instructions

Transfer warning

Continue button

User actions and expected behaviour:

Show the exact transfer location from demo data.

If the first bus drop-off and second bus boarding points differ, explain
the difference clearly.

Block booking when transfer time is below the configured minimum.

## 34. Seat Selection for Each Leg

Purpose: Collect a separate seat selection for each bus leg.

Recommended layout:

Use Leg 1 and Leg 2 tabs.

Show the bus details and seat layout for the selected leg.

Show selected seats and combined fare in a persistent summary.

UI components:

Leg 1 tab

Leg 2 tab

Bus details per leg

Separate seat layout

Seat legend

Selected seat summary

Combined fare

Continue button

User actions and expected behaviour:

Passenger count must match the seat count on each leg.

A passenger should have one selected seat on Leg 1 and one on Leg 2.

If either leg lacks enough available seats, block the combined booking.

Keep the seat selection for one leg when the user switches tabs, unless
it becomes invalid.

## 35. Connecting Journey Checkout

Purpose: Review both legs under one master booking and one demo payment.

Recommended layout:

Show a Master Booking Summary first.

Show Leg 1 and Leg 2 in separate sections.

Show transfer point and waiting time between them.

Show passenger details and fare breakdown.

Place one total payment and one Demo Payment action at the bottom.

UI components:

Master booking summary

Leg 1 details

Leg 2 details

Transfer point

Waiting time

Seat details per leg

Passenger information

Fare breakdown

One total payment

Demo Payment button

User actions and expected behaviour:

Create one Master Booking record and two separate Booking Leg records.

Each leg has its own Trip ID and seat record.

Use one demo payment for the combined journey.

Show one combined journey confirmation after successful demo payment.

## 36. Combined E-Ticket

Purpose: Show the complete connecting journey in one ticket view.

Recommended layout:

Show one Combined Ticket header and Master Booking ID.

Show passenger name and overall route.

Show Leg 1 and Leg 2 in separate, clearly labelled sections.

Show transfer point and seat number for each leg.

Show QR token and Download/Share actions.

UI components:

Master Booking ID

Passenger name

Combined journey route

Leg 1 ticket information

Leg 2 ticket information

Transfer point

Seat number per leg

QR code/ticket token

Download/Share

User actions and expected behaviour:

Use one combined ticket header, but keep the trip, seat, and departure
details separate for each leg.

Do not merge the two leg details into a misleading single bus record.

## 37. Connecting Journey Status

Purpose: Show the passenger's progress through both legs and the
transfer.

Recommended layout:

Show a journey progress timeline from departure to final arrival.

Show Leg 1, transfer, and Leg 2 as separate stages.

Show estimated arrival and any demo delay notice.

Show transfer instructions and View Ticket.

UI components:

Journey progress timeline

Leg 1 status

Transfer status

Leg 2 status

Estimated arrival

Delay notice

Transfer instructions

View Ticket button

User actions and expected behaviour:

Possible states: Upcoming, Leg 1 Boarding, In Transit, Arrived at
Transfer Point, Waiting for Leg 2, Leg 2 Boarding, Journey Completed,
Delayed, Disrupted.

Status changes come from local demo data only.

No live GPS or operator dispatch integration is included.

# 8. Journey Tracking and Supporting Screens

## 8.1 Live Journey Tracking Screen

Purpose: Give the passenger a visual representation of the bus journey.
This is a simulated demo screen, not a real-time tracking service.

Recommended layout:

Map area takes the main space.

Show origin, destination, route line, and a simulated bus marker.

Place journey status, estimated arrival, and delay information in a
bottom information panel.

Components:

Route map

Simulated bus location marker

Origin and destination

Route progress

Estimated arrival time

Journey status

Delay alert

Driver/support information only when demo data exists

Behaviour:

Move the marker only according to predefined local demo progress.

Show simulated ETA and delay notifications.

Do not label the location as live or real-time.

## 8.2 Additional screens and shared UI elements

| Screen / component \| Purpose and expected behaviour \|

| --- \| --- \|

| Edit Profile \| Update the user's name, email, mobile number, and
  profile image in local storage. Validate required fields and unique
  email/mobile values. \|

| App Settings \| Provide language, notification, and general preference
  controls. \|

| Language Settings \| Switch between Bangla and English and save the
  preference locally. \|

| Help & Support \| Show FAQ and demo contact information. Do not invent
  real support channels. \|

| About JatraNova \| Show app information, version, and a short product
  description. \|

| Handover History \| Show completed, pending, and rejected handover
  records. \|

| Saved Passengers \| Save, select, edit, or delete passenger details
  locally, with confirmation for deletion. \|

| Search Location Picker \| Search and select origin/destination from
  the supported local city list. \|

| Payment Result \| Reusable success, failure, and cancelled payment
  result view. Clearly label it as demo. \|

| Login Required Dialog \| Explain why login is required and offer Login
  and Create Account actions. \|

| Confirmation Dialog \| Reusable confirmation for cancellation, logout,
  and declining a handover. \|

| Empty State \| Show a helpful message and a next action when there are
  no tickets or search results. \|

| Error State \| Show a clear error and Retry action when a local
  operation fails. \|

| Offline State \| Show an internet information message only where
  relevant; core demo data is local. \|

# 9. Core Business Logic

## 9.1 Booking lifecycle

| Stage \| Rule \|

| --- \| --- \|

| Search \| Validate origin, destination, date, and passenger count. \|

| Select bus \| Passenger chooses a direct bus or a valid connecting
  option. \|

| Select seats \| Only available seats can be selected; selected count
  must match passenger count. \|

| Passenger information \| Required passenger details must be valid and
  mapped to seats. \|

| Review \| Show route, seats, passenger details, fare, and applicable
  policies. \|

| Demo payment \| Run one local payment simulation; do not create
  duplicate bookings. \|

| Confirmation \| On successful demo payment, save booking/ticket,
  generate a unique token, and create a notification. \|

| Ticket use \| Ticket status changes through local demo states.
  Completed tickets cannot be handed over. \|

## 9.2 Fare calculation

For a normal direct booking, calculate the total from the selected seat
fares and only the extra charges or discounts explicitly configured in
the demo dataset.

Example formula: Total Amount = Ticket Fare + Configured Service Charge
− Enabled Discount.

For a connecting journey, calculate the combined fare from the selected
fare for each leg. Show the leg-level breakdown and one combined total.

## 9.3 Ticket handover eligibility

The ticket must be confirmed and unused.

The journey must not have started.

The ticket must not be cancelled.

The ticket must not have been handed over previously.

The operator's local demo policy must allow handover.

Only one active handover request may exist for a ticket at a time.

The current owner cannot be the receiver.

## 9.4 Revenue sharing

The revenue split is always calculated from the Original Ticket Price. A
separate handover price or receiver amount must not change this
calculation.

| Recipient \| Share \| Example when original ticket price is ৳1,000 \|

| --- \| --- \| --- \|

| Bus Operator \| 30% \| ৳300 \|

| Ticket Handoverer \| 50% \| ৳500 \|

| JatraNova \| 20% \| ৳200 \|

| Total \| 100% \| ৳1,000 \|

This is a local demo record only. The application must not claim that
money has actually been collected, transferred, or paid out.

## 9.5 Handover status lifecycle

| Status \| Meaning \| Ticket ownership \|

| --- \| --- \| --- \|

| Pending \| Request submitted and waiting for demo approval. \| Current
  owner remains owner. \|

| Approved \| Local demo approval passed; receiver action is pending. \|
  Current owner remains owner. \|

| Rejected \| Local demo approval rejected the request. \| Current owner
  remains owner. \|

| Cancelled / Declined \| Sender cancelled or receiver declined before
  completion. \| Current owner remains owner. \|

| Completed \| Receiver accepted and demo settlement sequence completed.
  \| Ownership changes to receiver; new ticket and QR token are issued.
  \|

## 9.6 Safe ownership transfer

Check that the request is approved and the receiver accepted it.

Check that the ticket is still eligible and still belongs to the sender.

Create the new owner's ticket record.

Generate a new unique QR token.

Invalidate the old QR token.

Update ownership and active ticket access.

Save the revenue split and handover history.

Create notifications for the previous owner and new owner.

Commit all changes in one sqflite database transaction.

If any step fails, roll back the whole transaction. Never leave two
valid tickets for the same seat, and never remove the old ticket before
the new ownership transfer can be completed.

## 9.7 Connecting journey rules

A connecting journey consists of exactly two legs in this scope.

Both legs must use the same bus operator.

The first leg's drop-off/arrival point must match the transfer point
used by the second leg, or the app must clearly explain the physical
change between locations.

Waiting time must meet the configured minimum and maximum rules.

Both legs must have enough seats for all passengers.

Passenger information is collected once and associated with both legs.

One Master Booking contains two separate Booking Leg records.

One demo payment covers the combined fare.

Each leg retains its own trip, departure, seat, and ticket information.

# 10. Reusable UI Components

| Reusable component \| Where to use it \| Key requirements \|

| --- \| --- \| --- \|

| Primary Button \| Search, Continue, Submit, Confirm \| Consistent
  height and style; disabled/loading states. \|

| Secondary Button \| Back, Cancel, View details \| Lower visual
  emphasis than primary action. \|

| Text Input \| Login, registration, passenger details \| Label, hint,
  validation message, focus and error states. \|

| Location Selector \| Home and Search \| Selected city, clear action,
  searchable list. \|

| Date Selector \| Home and Search \| Past dates disabled; selected date
  clearly visible. \|

| Passenger Counter \| Search \| Minimum/maximum limits and total count.
  \|

| Bus Card \| Popular buses and search results \| Operator, bus type,
  time, route, available seats, fare. No rating. \|

| Connecting Journey Card \| Connecting results \| Prominent 2-Leg
  badge, both legs, transfer, waiting time, combined fare. \|

| Seat Tile \| Seat layouts \| Available, selected, booked, unavailable
  states. \|

| Status Badge \| Booking, payment, handover, ticket \| Use clear text
  labels, not colour alone. \|

| Fare Breakdown \| Booking review and handover \| Show amounts and
  calculation base. \|

| Timeline \| Handover and connecting status \| Ordered stages with
  current/completed/upcoming states. \|

| Empty State \| Tickets, notifications, search \| Short explanation and
  a useful next action. \|

| Error Message \| Forms and failed operations \| Explain what happened
  and how to recover. \|

| Confirmation Dialog \| Logout, cancel, decline \| State the
  consequence and provide confirm/cancel actions. \|

| Login Gate \| Protected guest features \| Explain why login is
  required and preserve the user's context. \|

## 10.1 Component state standards

Buttons: enabled, disabled, loading.

Inputs: empty, focused, filled, invalid, read-only.

Cards: default, selected, disabled, unavailable.

Lists: loading, populated, empty, error.

Requests: pending, approved, rejected, cancelled, completed.

Payments: processing, success, failed, cancelled (demo only).

# 11. Main User Flow Diagrams

## 11.1 First launch and account entry

``` text
START
  |
Splash Screen
  |
First launch?
  |-- YES --> Onboarding --> Language Selection
  |                            |
  |                       Welcome Choice
  |                     /       |        \
  |                  Login   Register   Guest
  |                    |        |         |
  |                    +-----> Home <-----+
  |
  |-- NO --> Valid local session?
               |-- YES --> Home (Signed in)
               |-- NO  --> Welcome Choice
```

## 11.2 Direct bus booking

``` text
Home / Search
     |
Select Origin + Destination + Date + Passengers
     |
Validate Search
     |
Bus Search Results
     |
Select Direct Bus
     |
Bus Details
     |
Seat Selection
     |
Passenger Information
     |
Booking Review
     |
Demo Payment
   /       \
Success   Failed/Cancelled
  |            |
Booking       Show Result
Confirmation  + Retry/Back
  |
E-Ticket / My Tickets
```

## 11.3 Ticket handover

``` text
Ticket Handover Home
        |
Eligible Tickets
        |
Select Ticket + Review Revenue Split
        |
Enter Receiver Information
        |
Submit Handover Request (Pending)
        |
Local Demo Approval
    /           \
Rejected       Approved
  |               |
Keep old ticket   Receiver reviews request
                  /             \
               Decline          Accept
                 |                |
           Keep old ticket   Demo settlement
                                  |
                         Atomic local transfer
                                  |
                      New owner + new QR ticket
                      Old QR invalidated
                      History + notifications
```

## 11.4 Connecting journey booking

``` text
Search
  |
Direct Results / Connecting Results
  |
Select 2-Leg Journey
  |
Connection Details
  |
Transfer Point Details
  |
Select Leg 1 Seat + Leg 2 Seat
  |
Passenger Information (once)
  |
Combined Booking Review
  |
One Demo Payment
  |
One Master Booking + Two Booking Legs
  |
Combined E-Ticket + Journey Status
```

# 12. Data and Implementation Notes

## 12.1 Suggested local data records

| Record \| Important fields (suggested) \|

| --- \| --- \|

| User \| id, fullName, mobile, email, passwordHash/demoCredential,
  language, createdAt \|

| BusOperator \| id, name, logoPath \|

| Trip \| id, operatorId, busName, busType, origin, destination,
  departureAt, arrivalAt, boardingPoint, dropOffPoint, facilities, fare
  \|

| Seat \| id, tripId, seatNumber, status \|

| Booking \| id, userId, masterBookingId (optional), bookingStatus,
  paymentStatus, totalAmount, createdAt \|

| BookingLeg \| id, bookingId, tripId, seatIds, legOrder \|

| Passenger \| id, bookingId, name, mobile, email (optional), seatNumber
  \|

| Ticket \| id, bookingId, ownerUserId, token, status,
  originalTicketPrice \|

| HandoverRequest \| id, ticketId, senderId, receiverId, status,
  createdAt \|

| HandoverRecord \| id, ticketId, previousOwnerId, newOwnerId,
  completedAt \|

| RevenueSplit \| id, handoverId, originalTicketPrice, operatorShare,
  handovererShare, platformShare \|

| PaymentDemo \| id, bookingId, method, status, amount, createdAt \|

| Notification \| id, userId, title, message, category, isRead,
  createdAt \|

These are suggested logical records to help keep the app's data
consistent. The final table structure and relationships should be
confirmed during implementation. Store passwords safely even in a demo;
do not save plain-text passwords.

## 12.2 Important implementation safeguards

Use database transactions for operations that must succeed together,
especially handover ownership and QR replacement.

Use unique IDs for bookings, tickets, handover requests, and QR tokens.

Prevent duplicate payment confirmation and duplicate active handover
requests.

Keep the source of truth in the local database; do not rely only on
temporary widget state.

Separate UI state from business rules through BLoC and feature-first
Clean Architecture.

Keep demo services/repositories clearly separated so a future backend
can replace local data sources.

Do not expose sensitive personal information inside QR codes.

Do not present simulated tracking, approvals, notifications, or payments
as real integrations.

# 13. Corrections and Decisions to Confirm

| Item \| Correction / recommendation \|

| --- \| --- \|

| Core screen count \| The source says 39 core screens, but its numbered
  list contains 37. This document uses 37 numbered core screens and
  lists supporting screens separately. \|

| Screen naming \| The source combines language selection, guest entry,
  and login as one group, but these are separate UI states/pages. This
  document describes them as distinct views within the entry flow. \|

| Home and Search \| Both can start a search. Keep one shared search
  model so values stay consistent when moving between them. \|

| Payment and refund wording \| Use "Demo Payment" and "Demo Refund"
  labels everywhere. Do not imply real money movement. \|

| Handover approval \| The local approval engine is a simulation, not
  actual bus operator approval. \|

| Revenue split \| Always calculate 30% / 50% / 20% from the Original
  Ticket Price. \|

| Handover price \| If shown, treat the receiver amount or handover
  price as a separate field. Do not use it as the revenue-share base. \|

| QR ownership \| Old QR must be invalidated and a new QR generated at
  the exact moment the ownership transfer commits. \|

| Connecting journey \| Keep one Master Booking and two separate Booking
  Leg records. Show each leg's seat and trip details separately. \|

| Live tracking \| The source describes simulated location and ETA. Name
  the feature "Journey Tracking (Demo)" or show a persistent Demo label.
  \|

| Bus ratings \| Remove ratings from bus cards and show available seat
  count instead. \|

| Facilities \| Only display facilities included in the local demo
  dataset. \|

| Passenger selector limits \| Define a single maximum passenger count
  and enforce it consistently in search, seat selection, and checkout.
  \|

| Cancellation policy \| Define demo policy values and calculation
  examples in the dataset before showing refund estimates. \|

| Booking failure \| Define whether a failed demo payment leaves a draft
  booking or a failed booking attempt. In either case, do not create a
  confirmed ticket. \|

| Ticket handover price/payment \| The original source mentions a
  separate receiver amount but does not define how it is calculated or
  collected. Keep it informational/demo-only until the product owner
  confirms the rule. \|

# Final Product Rule

The JatraNova demo must behave consistently from the passenger's point
of view. Every screen should show only information supported by local
demo data, every important action should have a clear result, and all
simulated features must be labelled honestly. The most sensitive
operations are booking confirmation, payment simulation, ticket
cancellation, and ticket ownership transfer; these must follow the rules
in this document without creating duplicate or inconsistent records.

# Version 1.1 --- Approved Passenger Access & Booking Rules

**Update date:** 24 November 2026

> **Authority:** This section records the latest approved changes to the
> passenger flow. Where an older paragraph or diagram in Version 1.0
> conflicts with this section, Version 1.1 takes precedence. The Agent
> Role / AGENTS file is not changed by this Project Flow update.

## 1. First Launch and Returning Launch Behaviour

### First app launch only

1.  Splash Screen.
2.  Onboarding screens (the introductory slides already defined in this
    Project Flow).
3.  Language Selection. English is selected by default; Bangla remains
    selectable.
4.  Welcome Choice: Login, Create Account, or Continue as Guest.
5.  Save the onboarding-completed flag and selected language locally.

### Second and every later app launch

-   Open the Home screen directly; do not show Onboarding, Language
    Selection, or Welcome Choice again automatically.
-   If a valid signed-in local session exists, show Home in signed-in
    mode.
-   If no signed-in session exists, show Home in Guest mode.
-   The saved language preference must be applied automatically.
-   Login and Create Account remain reachable from the Home/account
    entry points and Login Required prompts.
-   Changing language later is available from Settings and must not
    restart onboarding.

## 2. Guest Mode --- Booking Is Allowed, Account Features Are Restricted

Guest users are allowed to complete a full local demo ticket purchase.
Login must not be forced merely because a guest wants to buy a ticket.

### Guest users can

-   Open Home and search buses.
-   View bus results and bus details.
-   Select seats.
-   Enter passenger details manually.
-   Review the booking and complete the local Demo Payment flow.
-   See the purchase confirmation and the ticket generated for that
    purchase.
-   Later use **Find My Ticket** by entering the unique Ticket Number to
    open only the matching ticket.

### Guest users cannot

-   Open a full My Tickets list or browse ticket history.
-   Use Ticket Exchange or Ticket Exchange history.
-   Access account profile editing, Saved Passengers, account
    notifications, or other account-only features.
-   View any ticket merely by browsing or guessing another user's
    account history.

### Guest ticket lookup

-   Add a clearly visible **Find My Ticket** entry point on Home and/or
    the guest account area.
-   Ask for the unique Ticket Number.
-   Search the local ticket records for an exact match.
-   If found, show only that ticket's details and its E-Ticket view,
    including its QR code and Download Ticket action.
-   If no match exists, show a neutral "Ticket not found. Check the
    ticket number and try again." message.
-   Do not show a list of tickets, passenger history, or other bookings
    to a guest.
-   Ticket Numbers must be unique and difficult to guess; do not use
    simple sequential numbers.

## 3. Signed-in User Booking and Passenger Autofill

-   When a signed-in user starts booking, automatically prefill the
    first passenger form with the signed-in user's profile information
    (name, mobile number, and email where available).
-   The user may review or edit the booking passenger details without
    changing the stored profile unless they explicitly choose to update
    their profile.
-   By default, one signed-in user books one ticket for themselves.
-   If the user wants multiple tickets in the same booking, they must
    add/select the additional passengers as Friends or Family from
    **Saved Passengers**.
-   Each additional passenger must have their own saved passenger
    profile and their own details (at minimum name and valid mobile
    number; optional fields follow the existing passenger form rules).
-   Map each passenger to a separate selected seat. Do not copy the
    signed-in user's personal details into additional passenger records.
-   The account holder may manage saved Friends/Family profiles from the
    profile area: add, view, edit, and delete, with confirmation before
    deletion.
-   A saved passenger is a passenger profile, not a separate login
    account.
-   Apply the same passenger mapping rule to Direct and Connecting
    Journey bookings. For a connecting journey, collect passenger
    information once and associate it with both legs.

## 4. Updated Passenger Information Screen

### Signed-in flow

1.  Show the signed-in account holder as Passenger 1 and prefill their
    profile information.
2.  If more than one seat is selected, require the user to add/select a
    saved Friend or Family profile for each additional seat.
3.  Display a separate passenger card/form for every selected seat.
4.  Show the assigned seat beside each passenger.
5.  Validate each passenger's own required details.
6.  Continue to Booking Review only when every selected seat has exactly
    one valid passenger.

### Guest flow

1.  Show an empty passenger form for each selected seat.
2.  Require the guest to enter each passenger's details manually.
3.  Do not require login to continue to Booking Review or Demo Payment.
4.  After successful demo purchase, show the ticket and its unique
    Ticket Number, and provide Find My Ticket guidance for later
    retrieval.

## 5. Updated Profile and Saved Passengers

For signed-in users, the Profile area must include: - Account holder's
own profile details and Edit Profile. - **Saved Passengers** section for
Friends and Family. - Add Friend/Family passenger. - Edit saved
passenger details. - Delete saved passenger with confirmation. - My
Tickets and Ticket History (signed-in only). - Existing settings and
other approved account features.

For Guest users, show Login and Create Account entry points. Do not
expose Saved Passengers or the signed-in ticket list.

## 6. Updated Home and Navigation Behaviour

-   Home must be available in both Guest and signed-in modes.
-   Guest Home must include bus search and a **Find My Ticket** action.
-   Signed-in Home may show the user's account shortcuts and existing
    approved features.
-   Guest taps on account-only features should show a Login Required
    prompt with Login and Create Account actions.
-   Preserve the guest's current search and booking progress when the
    app prompts for login for an account-only feature.
-   Do not interrupt an allowed guest booking with a forced login
    prompt.

## 7. Updated Flow Diagrams

### 7.1 App launch and entry

``` text
START
  |
Splash Screen
  |
First launch?
  |-- YES --> Onboarding --> Language Selection --> Welcome Choice
  |                                               /      |       \
  |                                            Login  Register  Guest
  |                                              \       |       /
  |                                               ------ Home
  |
  |-- NO --> Home directly
               |
          Valid signed-in session?
             /             \
           YES              NO
            |                |
      Signed-in Home     Guest Home
```

### 7.2 Guest ticket purchase and lookup

``` text
Guest Home
   |
Search Buses
   |
Bus Results --> Bus Details --> Seat Selection
                                  |
                         Passenger Information
                         (manual entry for each seat)
                                  |
                           Booking Review
                                  |
                             Demo Payment
                              /       \
                          Success    Failed
                            |           |
                    Ticket Created   Retry / Back
                            |
                 Confirmation + Ticket Number
                            |
                   E-Ticket / Download Ticket
                            |
                   Later: Find My Ticket
                            |
                   Enter unique Ticket Number
                            |
                   Exact ticket match?
                       /          \
                     YES           NO
                      |             |
                Show that ticket  Not Found message
```

### 7.3 Signed-in booking with additional passengers

``` text
Signed-in Home
      |
  Search Buses
      |
  Select Bus + Seats
      |
Passenger Information
      |
Passenger 1 = Account Holder (profile auto-filled)
      |
More than one seat?
    /          \
   NO           YES
   |             |
Review       Add/Select saved Friend or Family
                 |
          One unique passenger per extra seat
                 |
          Validate all passenger details
                 |
             Booking Review
                 |
             Demo Payment
                 |
        Booking + Passenger Tickets
```

## 8. Acceptance Criteria for These Changes

-   First launch shows onboarding and language selection before Welcome
    Choice.
-   Second and later launches always open Home directly.
-   A returning user without a signed-in session enters Guest Home, not
    Welcome Choice.
-   Guest users can complete a ticket purchase without login.
-   Guest users can retrieve only one matching ticket by entering its
    unique Ticket Number.
-   Guest users cannot browse My Tickets or ticket history.
-   Signed-in booking automatically prefills the account holder's own
    passenger details.
-   One signed-in account holder is represented as one passenger by
    default.
-   Additional seats require separately saved Friend/Family passenger
    profiles.
-   Each seat maps to exactly one passenger with that passenger's own
    information.
-   Direct and Connecting Journey flows follow the same passenger rules.
-   Existing local-demo-only boundaries remain unchanged; no backend,
    API, or real payment integration is introduced.
