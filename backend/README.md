# 🚆 Train Ticket Booking System — Backend Development Guide

This document describes the **requirements analysis, system flow, and API development order** for the Train Ticket Booking backend system.
The goal is to follow a **structured development roadmap** so that APIs can be implemented in the correct dependency order.

---

## 📂 Folder Structure

<details>
<summary>Click to expand folder structure</summary>

```bash
src
│
├── config
│   ├── env.ts
│   ├── database.ts
│   ├── redis.ts
│   └── logger.ts
│
├── common
│   ├── constants
│   │   └── roles.ts
│   │
│   ├── middleware
│   │   ├── auth.middleware.ts
│   │   ├── role.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── rateLimit.middleware.ts
│   │
│   ├── utils
│   │   ├── generatePNR.ts
│   │   ├── generateTicketNumber.ts
│   │   ├── generateQRCode.ts
│   │   ├── calculateFare.ts
│   │   └── dateUtils.ts
│   │
│   └── types
│       └── express.d.ts
│
├── modules
│
│   ├── auth
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.route.ts
│   │   ├── auth.validation.ts
│   │   └── auth.repository.ts
│
│   ├── users
│   │   ├── user.controller.ts
│   │   ├── user.service.ts
│   │   ├── user.route.ts
│   │   ├── user.validation.ts
│   │   └── user.repository.ts
│
│   ├── stations
│   │   ├── station.controller.ts
│   │   ├── station.service.ts
│   │   ├── station.route.ts
│   │   ├── station.validation.ts
│   │   └── station.repository.ts
│
│   ├── routes
│   │   ├── route.controller.ts
│   │   ├── route.service.ts
│   │   ├── route.route.ts
│   │   ├── route.validation.ts
│   │   └── route.repository.ts
│
│   ├── routeStations
│   │   ├── routeStation.controller.ts
│   │   ├── routeStation.service.ts
│   │   ├── routeStation.route.ts
│   │   └── routeStation.repository.ts
│
│   ├── routeSegments
│   │   ├── segment.controller.ts
│   │   ├── segment.service.ts
│   │   ├── segment.route.ts
│   │   └── segment.repository.ts
│
│   ├── trains
│   │   ├── train.controller.ts
│   │   ├── train.service.ts
│   │   ├── train.route.ts
│   │   └── train.repository.ts
│
│   ├── coaches
│   │   ├── coach.controller.ts
│   │   ├── coach.service.ts
│   │   ├── coach.route.ts
│   │   └── coach.repository.ts
│
│   ├── seats
│   │   ├── seat.controller.ts
│   │   ├── seat.service.ts
│   │   ├── seat.route.ts
│   │   └── seat.repository.ts
│
│   ├── schedules
│   │   ├── schedule.controller.ts
│   │   ├── schedule.service.ts
│   │   ├── schedule.route.ts
│   │   └── schedule.repository.ts
│
│   ├── scheduleStops
│   │   ├── scheduleStop.controller.ts
│   │   ├── scheduleStop.service.ts
│   │   ├── scheduleStop.route.ts
│   │   └── scheduleStop.repository.ts
│
│   ├── seatManifest
│   │   ├── manifest.service.ts
│   │   ├── manifest.repository.ts
│   │   └── manifest.generator.ts
│
│   ├── search
│   │   ├── search.controller.ts
│   │   ├── search.service.ts
│   │   └── search.route.ts
│
│   ├── bookings
│   │   ├── booking.controller.ts
│   │   ├── booking.service.ts
│   │   ├── booking.route.ts
│   │   ├── booking.validation.ts
│   │   └── booking.repository.ts
│
│   ├── passengers
│   │   ├── passenger.service.ts
│   │   └── passenger.repository.ts
│
│   ├── payments
│   │   ├── payment.controller.ts
│   │   ├── payment.service.ts
│   │   ├── payment.route.ts
│   │   └── payment.repository.ts
│
│   ├── tickets
│   │   ├── ticket.service.ts
│   │   ├── ticket.controller.ts
│   │   └── ticket.repository.ts
│
│   ├── refunds
│   │   ├── refund.controller.ts
│   │   ├── refund.service.ts
│   │   ├── refund.route.ts
│   │   └── refund.repository.ts
│
│   ├── fareConfig
│   │   ├── fare.controller.ts
│   │   ├── fare.service.ts
│   │   ├── fare.route.ts
│   │   └── fare.repository.ts
│
│   ├── audit
│   │   ├── audit.service.ts
│   │   └── audit.repository.ts
│
│   └── admin
│       ├── admin.controller.ts
│       ├── admin.service.ts
│       └── admin.route.ts
│
├── jobs
│   ├── bookingExpiry.job.ts
│   ├── seatRelease.job.ts
│   └── queue.ts
│
├── prisma
│   └── prisma.client.ts
│
├── routes
│   └── index.ts
│
├── app.ts
│
└── server.ts
```

</details>

---

# 1. System Actors

The system has **three primary roles**.

## Passenger
Passengers are the main users of the platform. They can:

- Register an account
- Login to the system
- Search trains
- View seat availability
- Create bookings
- Add passengers to a booking
- Make payments
- Download tickets
- Cancel tickets
- Request refunds

## Admin
Admin users manage operational railway data.

Responsibilities include:

- Creating stations
- Creating routes
- Configuring route stations
- Configuring route segments
- Creating trains
- Configuring coaches
- Configuring seats
- Creating train schedules
- Managing bookings
- Processing refunds
- Blocking seats
- Managing fare configurations

## Super Admin
Super Admin controls the system administrators.

Capabilities include:

- Creating admin accounts
- Suspending users
- Monitoring system activities
- Viewing audit logs

---

# 2. High Level System Flow

The system follows this lifecycle:

1. Super Admin creates Admin accounts
2. Admin creates Stations
3. Admin creates Routes
4. Admin configures Route Stations
5. Admin configures Route Segments
6. Admin creates Trains
7. Admin configures Coaches
8. Admin configures Seats
9. Admin creates Train Schedules
10. System generates Seat Manifests automatically

After setup is complete:

11. Passenger searches trains
12. Passenger selects journey
13. Passenger selects seats
14. Booking is created with **PENDING** status
15. Passenger makes payment
16. Booking becomes **CONFIRMED**
17. Ticket is generated

```txt
SUPER ADMIN
    ↓
Creates ADMIN
    ↓
ADMIN creates STATIONS
    ↓
ADMIN creates ROUTES
    ↓
ADMIN creates ROUTE STATIONS
    ↓
ADMIN creates ROUTE SEGMENTS
    ↓
ADMIN creates TRAIN
    ↓
ADMIN creates COACHES
    ↓
ADMIN creates SEATS
    ↓
ADMIN creates TRAIN SCHEDULE
    ↓
SYSTEM generates SEAT MANIFESTS
    ↓
PASSENGER searches trains
    ↓
PASSENGER selects journey
    ↓
PASSENGER selects seats
    ↓
BOOKING created (PENDING)
    ↓
PAYMENT
    ↓
BOOKING CONFIRMED
    ↓
TICKET GENERATED
```
---

# 3. API Development Roadmap

Backend APIs should be implemented in the following phases.

---

## Phase 1 — Authentication System

Build authentication before anything else.

### APIs

- POST `/auth/register`
- POST `/auth/login`
- POST `/auth/refresh-token`
- POST `/auth/logout`
- GET `/auth/me`

### Database Tables

- User
- RefreshToken

---

## Phase 2 — Station Management

Admin creates railway stations used in routes.

### APIs

- POST `/stations`
- GET `/stations`
- GET `/stations/:id`
- PATCH `/stations/:id`
- DELETE `/stations/:id`

### Table

- Station

---

## Phase 3 — Route Management

A route represents a full railway path between cities.

Example:

Dhaka → Airport → Tangail → Rajshahi

### APIs

- POST `/routes`
- GET `/routes`
- PATCH `/routes/:id`
- DELETE `/routes/:id`

### Table

- Route

---

## Phase 4 — Route Stations

Define the station order within a route.

Example route:

1. Dhaka
2. Airport
3. Tangail
4. Rajshahi

### APIs

- POST `/routes/:routeId/stations`
- GET `/routes/:routeId/stations`

### Table

- RouteStation

---

## Phase 5 — Route Segments

A segment represents the connection between two stations.

Example:

- Dhaka → Airport
- Airport → Tangail
- Tangail → Rajshahi

### APIs

- POST `/routes/:routeId/segments`
- GET `/routes/:routeId/segments`

### Table

- RouteSegment

---

## Phase 6 — Train Management

Admin creates trains assigned to routes.

Example:

Train Name: Suborno Express
Train Number: 701

### APIs

- POST `/trains`
- GET `/trains`
- PATCH `/trains/:id`
- DELETE `/trains/:id`

### Table

- Train

---

## Phase 7 — Coach Management

Each train contains multiple coaches.

Coach types include:

- ECONOMY
- SLEEPER

### APIs

- POST `/trains/:trainId/coaches`
- GET `/trains/:trainId/coaches`

### Table

- Coach

---

## Phase 8 — Seat Management

Each coach contains multiple seats.

Seat types include:

- WINDOW
- MIDDLE
- AISLE

### APIs

- POST `/coaches/:coachId/seats`
- GET `/coaches/:coachId/seats`

### Table

- Seat

---

## Phase 9 — Train Schedule

A schedule defines when a train runs on a specific date.

Example:

Train: Suborno Express
Date: 10 May 2026
Departure: 07:00

### APIs

- POST `/schedules`
- GET `/schedules`
- GET `/schedules/:id`

### Table

- TrainSchedule

---

## Phase 10 — Schedule Stops

Stops for each train schedule.

Example:

- Dhaka — 07:00
- Airport — 07:30
- Tangail — 09:00
- Rajshahi — 12:00

### APIs

- POST `/schedules/:id/stops`
- GET `/schedules/:id/stops`

### Table

- ScheduleStop

---

## Phase 11 — Seat Manifest Generation

When a train schedule is created, the system generates seat manifests.

A SeatManifest tracks seat availability for each segment.

Example:

Seat A1
Segment: Dhaka → Airport
Status: AVAILABLE

### Table

- SeatManifest

---

## Phase 12 — Train Search

Passengers search trains by route and date.

### API

- GET `/search-trains`

### Query Parameters

- from_station
- to_station
- date

### Response

- Train details
- Departure time
- Arrival time
- Price
- Seat availability

---

## Phase 13 — Seat Availability

Passenger views available seats.

### API

- GET `/schedules/:id/seats`

### Table

- SeatManifest

---

## Phase 14 — Booking Creation

Passenger selects seats and creates a booking.

Booking status is initially **PENDING**.

Expiry time is usually **10 minutes**.

### API

- POST `/bookings`

### Tables

- Booking
- BookingPassenger
- SeatManifest

---

## Phase 15 — Payment Processing

Passenger pays for the booking.

### API

- POST `/payments`

If payment succeeds:

- Booking status becomes **CONFIRMED**
- SeatManifest status becomes **BOOKED**

### Table

- Payment

---

## Phase 16 — Ticket Generation

After payment, a ticket is generated.

Ticket includes:

- QR code
- Ticket number
- Seat details

### API

- GET `/bookings/:id/ticket`

### Table

- Ticket

---

## Phase 17 — Booking Expiry Worker

A background worker checks expired bookings.

Conditions:

- booking_status = PENDING
- expiry_time < current_time

Actions:

- booking_status → EXPIRED
- seat manifests released

Technologies:

- Redis
- BullMQ

---

## Phase 18 — Refund System

Passenger requests refund.

### API

- POST `/refund/request`

Admin processes refund.

### API

- PATCH `/refund/:id/process`

### Tables

- Refund
- SeatManifest

---

## Phase 19 — Admin Operations

Admin management APIs include:

- GET `/admin/bookings`
- GET `/admin/users`
- PATCH `/admin/block-seat`
- PATCH `/admin/suspend-user`

---

## Phase 20 — Audit Logging

Every admin action is recorded in audit logs.

Example actions:

- Admin created route
- Admin processed refund
- Admin cancelled booking

### Table

- AuditLog

---

# Final Development Order

1. Authentication
2. Users
3. Stations
4. Routes
5. RouteStations
6. RouteSegments
7. Trains
8. Coaches
9. Seats
10. TrainSchedules
11. ScheduleStops
12. SeatManifest Generator
13. Train Search
14. Seat Availability
15. Booking
16. Payment
17. Ticket
18. Refund
19. Admin APIs
20. Audit Logs
21. Background Workers

---

🚀 This roadmap ensures the backend is developed in the **correct dependency order**, preventing circular dependencies and simplifying feature implementation.
