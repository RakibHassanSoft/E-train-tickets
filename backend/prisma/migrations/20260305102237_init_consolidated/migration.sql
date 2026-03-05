-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('PASSENGER', 'ADMIN', 'SUPER_ADMIN');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'SUCCESS', 'FAILED');

-- CreateEnum
CREATE TYPE "RefundStatus" AS ENUM ('REQUESTED', 'PROCESSING', 'COMPLETED', 'FAILED', 'REJECTED');

-- CreateEnum
CREATE TYPE "SeatType" AS ENUM ('WINDOW', 'MIDDLE', 'AISLE');

-- CreateEnum
CREATE TYPE "CoachType" AS ENUM ('SLEEPER', 'ECONOMY');

-- CreateEnum
CREATE TYPE "SeatManifestStatus" AS ENUM ('AVAILABLE', 'HELD', 'BOOKED', 'BLOCKED');

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY');

-- CreateEnum
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'DELETE');

-- CreateEnum
CREATE TYPE "EntityType" AS ENUM ('USER', 'BOOKING', 'PAYMENT', 'REFUND', 'TRAIN', 'ROUTE', 'STATION', 'SEAT');

-- CreateTable
CREATE TABLE "User" (
    "user_id" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'PASSENGER',
    "full_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "RefreshToken" (
    "token_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "refresh_token" TEXT NOT NULL,
    "issued_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "is_revoked" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("token_id")
);

-- CreateTable
CREATE TABLE "Station" (
    "station_id" TEXT NOT NULL,
    "station_code" TEXT NOT NULL,
    "station_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "timezone" TEXT NOT NULL DEFAULT 'UTC',
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Station_pkey" PRIMARY KEY ("station_id")
);

-- CreateTable
CREATE TABLE "Route" (
    "route_id" TEXT NOT NULL,
    "route_name" TEXT NOT NULL,
    "distance_km" DOUBLE PRECISION NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Route_pkey" PRIMARY KEY ("route_id")
);

-- CreateTable
CREATE TABLE "RouteStation" (
    "route_id" TEXT NOT NULL,
    "station_id" TEXT NOT NULL,
    "stop_sequence" INTEGER NOT NULL,
    "distance_from_start" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "RouteStation_pkey" PRIMARY KEY ("route_id","station_id")
);

-- CreateTable
CREATE TABLE "RouteSegment" (
    "segment_id" TEXT NOT NULL,
    "route_id" TEXT NOT NULL,
    "start_station_id" TEXT NOT NULL,
    "end_station_id" TEXT NOT NULL,
    "price_modifier" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "segment_order" INTEGER NOT NULL,
    "travel_time_mins" INTEGER NOT NULL,
    "base_price" DECIMAL(12,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT "RouteSegment_pkey" PRIMARY KEY ("segment_id")
);

-- CreateTable
CREATE TABLE "Train" (
    "train_id" TEXT NOT NULL,
    "train_name" TEXT NOT NULL,
    "train_number" TEXT NOT NULL,
    "train_code" TEXT NOT NULL,
    "route_id" TEXT NOT NULL,
    "total_coaches" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "Train_pkey" PRIMARY KEY ("train_id")
);

-- CreateTable
CREATE TABLE "TrainSchedule" (
    "schedule_id" TEXT NOT NULL,
    "route_id" TEXT NOT NULL,
    "train_id" TEXT NOT NULL,
    "trip_date" TIMESTAMP(3) NOT NULL,
    "departure_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TrainSchedule_pkey" PRIMARY KEY ("schedule_id")
);

-- CreateTable
CREATE TABLE "ScheduleStop" (
    "stop_id" TEXT NOT NULL,
    "schedule_id" TEXT NOT NULL,
    "station_id" TEXT NOT NULL,
    "arrival_time" TIMESTAMP(3) NOT NULL,
    "departure_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ScheduleStop_pkey" PRIMARY KEY ("stop_id")
);

-- CreateTable
CREATE TABLE "Coach" (
    "coach_id" TEXT NOT NULL,
    "train_id" TEXT NOT NULL,
    "coach_type" "CoachType" NOT NULL,
    "coach_number" TEXT NOT NULL,

    CONSTRAINT "Coach_pkey" PRIMARY KEY ("coach_id")
);

-- CreateTable
CREATE TABLE "Seat" (
    "seat_id" TEXT NOT NULL,
    "coach_id" TEXT NOT NULL,
    "seat_number" TEXT NOT NULL,
    "seat_type" "SeatType" NOT NULL,

    CONSTRAINT "Seat_pkey" PRIMARY KEY ("seat_id")
);

-- CreateTable
CREATE TABLE "FareConfiguration" (
    "fare_id" TEXT NOT NULL,
    "coach_type" "CoachType" NOT NULL,
    "price_markup" DECIMAL(5,2) NOT NULL,
    "demand_factor" DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FareConfiguration_pkey" PRIMARY KEY ("fare_id")
);

-- CreateTable
CREATE TABLE "Booking" (
    "booking_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "schedule_id" TEXT NOT NULL,
    "start_station_id" TEXT NOT NULL,
    "end_station_id" TEXT NOT NULL,
    "pnr_code" TEXT NOT NULL,
    "booking_status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
    "booking_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiry_time" TIMESTAMP(3) NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 0,
    "unit_price" DECIMAL(12,2) NOT NULL,
    "total_amount" DECIMAL(12,2) NOT NULL,
    "currency_code" VARCHAR(3) NOT NULL DEFAULT 'USD',
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("booking_id")
);

-- CreateTable
CREATE TABLE "BookingPassenger" (
    "passenger_id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "passenger_name" TEXT NOT NULL,
    "age" INTEGER NOT NULL,
    "gender" "Gender" NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "BookingPassenger_pkey" PRIMARY KEY ("passenger_id")
);

-- CreateTable
CREATE TABLE "Ticket" (
    "ticket_id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "qr_code" TEXT NOT NULL,
    "seat_details" TEXT NOT NULL,
    "ticket_number" TEXT NOT NULL,
    "issued_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "passenger_id" TEXT NOT NULL,

    CONSTRAINT "Ticket_pkey" PRIMARY KEY ("ticket_id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "payment_id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "idempotency_key" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "payment_method" TEXT NOT NULL,
    "payment_status" "PaymentStatus" NOT NULL,
    "transaction_ref" TEXT NOT NULL,
    "paid_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'USD',
    "provider_id" TEXT,
    "raw_response" JSONB,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("payment_id")
);

-- CreateTable
CREATE TABLE "Refund" (
    "refund_id" TEXT NOT NULL,
    "booking_id" TEXT NOT NULL,
    "requested_by_user_id" TEXT NOT NULL,
    "admin_id" TEXT,
    "idempotency_key" TEXT NOT NULL,
    "amount_refunded" DECIMAL(12,2) NOT NULL,
    "cancellation_fee" DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    "reason" TEXT NOT NULL,
    "status" "RefundStatus" NOT NULL DEFAULT 'REQUESTED',
    "processed_at" TIMESTAMP(3),
    "transaction_ref" TEXT,

    CONSTRAINT "Refund_pkey" PRIMARY KEY ("refund_id")
);

-- CreateTable
CREATE TABLE "SeatManifest" (
    "manifest_id" TEXT NOT NULL,
    "seat_id" TEXT NOT NULL,
    "booking_id" TEXT,
    "schedule_id" TEXT NOT NULL,
    "segment_id" TEXT NOT NULL,
    "route_id" TEXT NOT NULL,
    "refund_id" TEXT,
    "passenger_id" TEXT,
    "status" "SeatManifestStatus" NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 0,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SeatManifest_pkey" PRIMARY KEY ("manifest_id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "audit_id" TEXT NOT NULL,
    "user_id" TEXT,
    "user_info" TEXT,
    "entity_type" "EntityType" NOT NULL,
    "entity_id" TEXT NOT NULL,
    "action" "AuditAction" NOT NULL,
    "old_value" JSONB,
    "new_value" JSONB,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ip_address" TEXT,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("audit_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "RefreshToken_refresh_token_key" ON "RefreshToken"("refresh_token");

-- CreateIndex
CREATE UNIQUE INDEX "Station_station_code_key" ON "Station"("station_code");

-- CreateIndex
CREATE UNIQUE INDEX "RouteStation_route_id_stop_sequence_key" ON "RouteStation"("route_id", "stop_sequence");

-- CreateIndex
CREATE UNIQUE INDEX "RouteSegment_segment_id_route_id_key" ON "RouteSegment"("segment_id", "route_id");

-- CreateIndex
CREATE UNIQUE INDEX "RouteSegment_route_id_segment_order_key" ON "RouteSegment"("route_id", "segment_order");

-- CreateIndex
CREATE UNIQUE INDEX "RouteSegment_route_id_start_station_id_end_station_id_key" ON "RouteSegment"("route_id", "start_station_id", "end_station_id");

-- CreateIndex
CREATE UNIQUE INDEX "Train_train_number_key" ON "Train"("train_number");

-- CreateIndex
CREATE UNIQUE INDEX "Train_train_code_key" ON "Train"("train_code");

-- CreateIndex
CREATE INDEX "TrainSchedule_trip_date_idx" ON "TrainSchedule"("trip_date");

-- CreateIndex
CREATE INDEX "TrainSchedule_train_id_trip_date_idx" ON "TrainSchedule"("train_id", "trip_date");

-- CreateIndex
CREATE UNIQUE INDEX "TrainSchedule_schedule_id_route_id_key" ON "TrainSchedule"("schedule_id", "route_id");

-- CreateIndex
CREATE UNIQUE INDEX "Booking_pnr_code_key" ON "Booking"("pnr_code");

-- CreateIndex
CREATE INDEX "Booking_pnr_code_idx" ON "Booking"("pnr_code");

-- CreateIndex
CREATE INDEX "Booking_user_id_idx" ON "Booking"("user_id");

-- CreateIndex
CREATE INDEX "Booking_booking_status_idx" ON "Booking"("booking_status");

-- CreateIndex
CREATE INDEX "Booking_booking_time_idx" ON "Booking"("booking_time" DESC);

-- CreateIndex
CREATE INDEX "Booking_booking_status_expiry_time_idx" ON "Booking"("booking_status", "expiry_time");

-- CreateIndex
CREATE UNIQUE INDEX "Ticket_ticket_number_key" ON "Ticket"("ticket_number");

-- CreateIndex
CREATE UNIQUE INDEX "Ticket_passenger_id_key" ON "Ticket"("passenger_id");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_idempotency_key_key" ON "Payment"("idempotency_key");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_transaction_ref_key" ON "Payment"("transaction_ref");

-- CreateIndex
CREATE INDEX "Payment_payment_status_idx" ON "Payment"("payment_status");

-- CreateIndex
CREATE UNIQUE INDEX "Refund_idempotency_key_key" ON "Refund"("idempotency_key");

-- CreateIndex
CREATE INDEX "SeatManifest_schedule_id_segment_id_idx" ON "SeatManifest"("schedule_id", "segment_id");

-- CreateIndex
CREATE INDEX "SeatManifest_status_idx" ON "SeatManifest"("status");

-- CreateIndex
CREATE INDEX "SeatManifest_passenger_id_idx" ON "SeatManifest"("passenger_id");

-- CreateIndex
CREATE INDEX "SeatManifest_route_id_idx" ON "SeatManifest"("route_id");

-- CreateIndex
CREATE INDEX "SeatManifest_schedule_id_segment_id_status_idx" ON "SeatManifest"("schedule_id", "segment_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "SeatManifest_seat_id_schedule_id_segment_id_key" ON "SeatManifest"("seat_id", "schedule_id", "segment_id");

-- CreateIndex
CREATE INDEX "AuditLog_entity_type_entity_id_idx" ON "AuditLog"("entity_type", "entity_id");

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteStation" ADD CONSTRAINT "RouteStation_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "Route"("route_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteStation" ADD CONSTRAINT "RouteStation_station_id_fkey" FOREIGN KEY ("station_id") REFERENCES "Station"("station_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteSegment" ADD CONSTRAINT "RouteSegment_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "Route"("route_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteSegment" ADD CONSTRAINT "RouteSegment_start_station_id_fkey" FOREIGN KEY ("start_station_id") REFERENCES "Station"("station_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteSegment" ADD CONSTRAINT "RouteSegment_end_station_id_fkey" FOREIGN KEY ("end_station_id") REFERENCES "Station"("station_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Train" ADD CONSTRAINT "Train_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "Route"("route_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TrainSchedule" ADD CONSTRAINT "TrainSchedule_train_id_fkey" FOREIGN KEY ("train_id") REFERENCES "Train"("train_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleStop" ADD CONSTRAINT "ScheduleStop_schedule_id_fkey" FOREIGN KEY ("schedule_id") REFERENCES "TrainSchedule"("schedule_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleStop" ADD CONSTRAINT "ScheduleStop_station_id_fkey" FOREIGN KEY ("station_id") REFERENCES "Station"("station_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Coach" ADD CONSTRAINT "Coach_train_id_fkey" FOREIGN KEY ("train_id") REFERENCES "Train"("train_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Seat" ADD CONSTRAINT "Seat_coach_id_fkey" FOREIGN KEY ("coach_id") REFERENCES "Coach"("coach_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_start_station_id_fkey" FOREIGN KEY ("start_station_id") REFERENCES "Station"("station_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_end_station_id_fkey" FOREIGN KEY ("end_station_id") REFERENCES "Station"("station_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_schedule_id_fkey" FOREIGN KEY ("schedule_id") REFERENCES "TrainSchedule"("schedule_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingPassenger" ADD CONSTRAINT "BookingPassenger_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("booking_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Ticket" ADD CONSTRAINT "Ticket_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("booking_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Ticket" ADD CONSTRAINT "Ticket_passenger_id_fkey" FOREIGN KEY ("passenger_id") REFERENCES "BookingPassenger"("passenger_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("booking_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Refund" ADD CONSTRAINT "Refund_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("booking_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Refund" ADD CONSTRAINT "Refund_requested_by_user_id_fkey" FOREIGN KEY ("requested_by_user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Refund" ADD CONSTRAINT "Refund_admin_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatManifest" ADD CONSTRAINT "SeatManifest_segment_id_route_id_fkey" FOREIGN KEY ("segment_id", "route_id") REFERENCES "RouteSegment"("segment_id", "route_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatManifest" ADD CONSTRAINT "SeatManifest_schedule_id_route_id_fkey" FOREIGN KEY ("schedule_id", "route_id") REFERENCES "TrainSchedule"("schedule_id", "route_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatManifest" ADD CONSTRAINT "SeatManifest_passenger_id_fkey" FOREIGN KEY ("passenger_id") REFERENCES "BookingPassenger"("passenger_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatManifest" ADD CONSTRAINT "SeatManifest_seat_id_fkey" FOREIGN KEY ("seat_id") REFERENCES "Seat"("seat_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatManifest" ADD CONSTRAINT "SeatManifest_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "Booking"("booking_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatManifest" ADD CONSTRAINT "SeatManifest_refund_id_fkey" FOREIGN KEY ("refund_id") REFERENCES "Refund"("refund_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;
