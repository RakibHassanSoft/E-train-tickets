
#  Railway E-Ticket Platform — Backend Requirements Analysis

##  USERS
Stores all registered users (passengers/admin) with secure authentication.
Fields:
- user_id (PK, UUID): Unique user identifier
- name (varchar): Full name
- email (varchar, unique): Login email
- phone (varchar): Contact number
- password_hash (text): Securely hashed password
- role_id (FK, int): Reference to role
- created_at (datetime): Account creation timestamp
- status (boolean): Active / Blocked

## 2️ ROLES
Defines system authorization levels for RBAC.
Fields:
- role_id (PK, int): Role identifier
- role_name (varchar): Passenger / Admin / SuperAdmin

## STATIONS
Stores all railway stations with metadata for routing.
Fields:
- station_id (PK, int): Station ID
- station_name (varchar): Name
- city (varchar): City location
- code (varchar): Unique station code

##  TRAINS
Stores train information for schedule and route management.
Fields:
- train_id (PK, int): Train identifier
- train_name (varchar): Train name
- train_number (varchar): Unique train number
- total_coaches (int): Number of coaches

##  ROUTES
Defines train routes linking stations.
Fields:
- route_id (PK, int): Route ID
- train_id (FK, int): Assigned train
- source_station_id (FK, int): Start station
- destination_station_id (FK, int): End station
- distance (decimal): Route distance in KM

##  SCHEDULES
Represents train run times per date for seat allocation.
Fields:
- schedule_id (PK, int): Schedule ID
- train_id (FK, int): Train reference
- departure_time (datetime): Departure
- arrival_time (datetime): Arrival
- journey_date (date): Travel date

##  COACHES
Contains train coaches for seat management.
Fields:
- coach_id (PK, int): Coach identifier
- train_id (FK, int): Belongs to train
- coach_type (varchar): AC / Sleeper / Chair
- seat_count (int): Total seats

##  SEATS
Individual seats inside coaches with status tracking.
Fields:
- seat_id (PK, int): Seat identifier
- coach_id (FK, int): Coach reference
- seat_number (varchar): Seat label
- status (varchar): Available / Booked

##  BOOKINGS
Records all ticket bookings with transactional integrity.
Fields:
- booking_id (PK, UUID): Booking identifier
- user_id (FK, UUID): Passenger
- schedule_id (FK, int): Travel schedule
- booking_time (datetime): Timestamp
- total_amount (decimal): Fare
- status (varchar): Confirmed / Cancelled

##  BOOKING_PASSENGERS
Supports multiple passengers per booking.
Fields:
- bp_id (PK, int): Record ID
- booking_id (FK, UUID): Booking reference
- passenger_name (varchar): Traveler name
- age (int): Age
- seat_id (FK, int): Assigned seat

##  PAYMENTS
Stores all transaction/payment details securely.
Fields:
- payment_id (PK, UUID): Payment identifier
- booking_id (FK, UUID): Related booking
- amount (decimal): Paid amount
- payment_method (varchar): Card / Mobile Banking
- payment_status (varchar): Success / Failed
- transaction_ref (varchar): Gateway reference
- paid_at (datetime): Timestamp

##  TICKETS
Digital ticket generation after successful payment.
Fields:
- ticket_id (PK, UUID): Ticket identifier
- booking_id (FK, UUID): Booking reference
- pnr_code (varchar): Unique PNR
- qr_code (text): QR verification data
- issued_at (datetime): Issue time

##  REFUNDS
Handles cancellations and refunds in compliance with rules.
Fields:
- refund_id (PK, int): Refund identifier
- booking_id (FK, UUID): Cancelled booking
- refund_amount (decimal): Amount returned
- refund_status (varchar): Pending / Completed
- processed_at (datetime): Refund timestamp

##  Relationships (Cardinality)
- Users ↔ Roles: 1 Role → N Users
- Train ↔ Routes: 1 Train → N Routes
- Train ↔ Coaches: 1 Train → N Coaches
- Coach ↔ Seats: 1 Coach → N Seats
- Train ↔ Schedules: 1 Train → N Schedules
- User ↔ Bookings: 1 User → N Bookings
- Booking ↔ Passengers: 1 Booking → N Booking_Passengers
- Seat ↔ Booking Passenger: 1 Seat assigned to 1 passenger per schedule
- Booking ↔ Payment: 1 Booking → 1 Payment
- Booking ↔ Ticket: 1 Booking → 1 Ticket
- Booking ↔ Refund: 1 Booking → 0..1 Refund

##  Backend Considerations 
- Ensure transactional consistency (ACID) for booking and payment workflows.
- Implement JWT/OAuth2 for secure authentication.
- Enforce role-based access control (RBAC) at API and DB level.
- Input validation and sanitization to prevent SQL injection or XSS.
- Index critical tables (users, bookings, schedules) for high performance.
- Implement seat locking with expiration to prevent race conditions.
- Maintain audit logs for all admin actions.
- Use UUIDs for public-facing identifiers to avoid enumeration attacks.
- Consider microservice separation for payments, bookings, and notifications.
- Plan for horizontal scalability (load balancers, caching layers, message queues).






## Backend API Documentation 

This section documents all backend modules, endpoints, request/response structure, and role-based access.
APIs are grouped by functional modules, following production-level modular architecture.


## 1️⃣ Authentication Module (with Refresh Token)
Handles registration, login, OTP verification, password reset, and token refresh.

**POST /auth/register**
- Register a new Passenger.
- Body: `{ "name": string, "email": string, "phone": string, "password": string, "national_id": string (optional) }`
- Roles: Public
- Response: `201 Created` + user info (excluding password)

**POST /auth/login**
- Authenticate user and issue **JWT access token** and **refresh token**.
- Body: `{ "email_or_phone": string, "password": string }`
- Roles: Public
- Response: `200 OK`  
  ```json
  { "accessToken": "<JWT_ACCESS_TOKEN>", "refreshToken": "<JWT_REFRESH_TOKEN>" }
  ```

**POST /auth/refresh-token**
- Refresh expired access token using refresh token.
- Body: `{ "refreshToken": string }`
- Roles: Public (requires valid refresh token)
- Response: `200 OK`  
  ```json
  { "accessToken": "<NEW_JWT_ACCESS_TOKEN>", "refreshToken": "<NEW_REFRESH_TOKEN>" }
  ```

**POST /auth/logout**
- Invalidate refresh token (logout).
- Body: `{ "refreshToken": string }`
- Roles: Authenticated User
- Response: `200 OK` + confirmation

**POST /auth/otp-verify**
- Verify OTP for login or password reset.
- Body: `{ "user_id": UUID, "otp": string }`
- Roles: Public
- Response: `200 OK`

**POST /auth/password-reset**
- Reset password using OTP.
- Body: `{ "user_id": UUID, "new_password": string, "otp": string }`
- Roles: Public
- Response: `200 OK`


## 2️⃣ User Management Module
Manages users, profile updates, and admin-level user control.

**GET /users/:id**
- Fetch user profile.
- Roles: Admin, SuperAdmin
- Response: `200 OK` + user details

**PATCH /users/:id**
- Update user information or role/status.
- Roles: Admin, SuperAdmin
- Response: `200 OK` + updated user

**DELETE /users/:id**
- Deactivate or remove user.
- Roles: SuperAdmin
- Response: `204 No Content`

## 3️⃣ Train & Route Management Module
Handles all train, route, and schedule operations.

**GET /trains**
- List all trains with optional filters (source, destination, date)
- Roles: Passenger, Admin, SuperAdmin
- Response: `200 OK` + array of trains

**POST /trains**
- Add new train.
- Roles: Admin, SuperAdmin
- Response: `201 Created`

**PATCH /trains/:id**
- Update train info.
- Roles: Admin, SuperAdmin
- Response: `200 OK`

**DELETE /trains/:id**
- Remove train from system.
- Roles: SuperAdmin
- Response: `204 No Content`

**GET /routes**
- List all routes or filter by train.
- Roles: Passenger, Admin, SuperAdmin
- Response: `200 OK`

**POST /routes**
- Add new route.
- Roles: Admin, SuperAdmin
- Response: `201 Created`

**GET /schedules**
- Fetch schedules by train or date.
- Roles: Passenger, Admin, SuperAdmin
- Response: `200 OK`

**POST /schedules**
- Create new schedule entry.
- Roles: Admin, SuperAdmin
- Response: `201 Created`

## 4️⃣ Coach & Seat Management Module
Manages coaches, seat allocation, and availability.

**GET /coaches/:train_id**
- List all coaches for a train.
- Roles: Passenger, Admin, SuperAdmin
- Response: `200 OK`

**GET /seats/:coach_id**
- List all seats and status for a coach.
- Roles: Passenger, Admin, SuperAdmin
- Response: `200 OK` + seat status

## 5️⃣ Booking Module
Handles ticket creation, modification, and cancellation.

**POST /bookings**
- Create new booking.
- Body: `{ "user_id": UUID, "schedule_id": int, "passengers": [{ "name": string, "age": int, "seat_id": int }] }`
- Roles: Passenger
- Response: `201 Created` + booking info

**GET /bookings/:id**
- Get booking details by booking ID.
- Roles: Passenger (own), Admin, SuperAdmin
- Response: `200 OK`

**PATCH /bookings/:id/cancel**
- Cancel booking before departure.
- Roles: Passenger (own), Admin
- Response: `200 OK` + refund details

## 6️⃣ Payment Module
Handles all payment processing and transaction logging.

**POST /payments**
- Process payment for a booking.
- Body: `{ "booking_id": UUID, "amount": decimal, "payment_method": string }`
- Roles: Passenger
- Response: `200 OK` + payment status

**GET /payments/:id/status**
- Check payment status.
- Roles: Passenger, Admin, SuperAdmin
- Response: `200 OK`

## 7️⃣ Ticket Module
Generates and manages digital tickets.

**GET /tickets/:pnr**
- Retrieve ticket by PNR code.
- Roles: Passenger (own), Admin, SuperAdmin
- Response: `200 OK` + ticket info with QR code

**GET /tickets/:pnr/pdf**
- Download PDF version of ticket.
- Roles: Passenger (own), Admin, SuperAdmin
- Response: `200 OK` + PDF stream

## 8️⃣ Refund Module
Handles refunds and administrative overrides.

**GET /refunds/:booking_id**
- Check refund status.
- Roles: Passenger (own), Admin
- Response: `200 OK`

**POST /refunds/:booking_id/process**
- Admin processes or overrides refund.
- Roles: Admin, SuperAdmin
- Response: `200 OK` + refund processed

## Notes for Developers
- All endpoints validate input using DTOs or schemas.
- JWT authentication required for protected routes.
- Seat locking during payment prevents double booking.
- Audit logs maintained for all sensitive admin actions.
- High concurrency handled via transactions and Redis-based locks.


