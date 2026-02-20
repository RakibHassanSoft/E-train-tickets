
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

