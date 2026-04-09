-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('SUPER_ADMIN', 'ADMIN', 'DRIVER', 'AGENT');

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'UNKNOWN');

-- CreateEnum
CREATE TYPE "DriverWorkStatus" AS ENUM ('AVAILABLE', 'BUSY', 'OFFLINE');

-- CreateEnum
CREATE TYPE "NavigationStatus" AS ENUM ('STARTED', 'ON_THE_WAY', 'ARRIVED', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "TripActionStatus" AS ENUM ('YOLDAMAN', 'YETIB_KELDIM', 'YAKUNLADIM', 'CANCELLED');

-- CreateEnum
CREATE TYPE "NavigatorType" AS ENUM ('YANDEX', 'GOOGLE', 'INTERNAL', 'UNKNOWN');

-- CreateEnum
CREATE TYPE "ChangeAction" AS ENUM ('CREATE', 'UPDATE', 'VERIFY', 'DEACTIVATE');

-- CreateEnum
CREATE TYPE "AuditEntityType" AS ENUM ('USER', 'HOUSEHOLD', 'RESIDENT', 'SEARCH', 'NAVIGATION', 'SYSTEM');

-- CreateTable
CREATE TABLE "regions" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "regions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "districts" (
    "id" SERIAL NOT NULL,
    "region_id" INTEGER NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "districts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branches" (
    "id" SERIAL NOT NULL,
    "district_id" INTEGER NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(50),
    "address" VARCHAR(300),
    "phone" VARCHAR(30),
    "latitude" DECIMAL(10,7),
    "longitude" DECIMAL(10,7),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "branch_id" INTEGER,
    "district_id" INTEGER,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "middle_name" VARCHAR(100),
    "phone" VARCHAR(30),
    "username" VARCHAR(80) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "role" "UserRole" NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "households" (
    "id" BIGSERIAL NOT NULL,
    "region_id" INTEGER NOT NULL,
    "district_id" INTEGER NOT NULL,
    "branch_id" INTEGER,
    "created_by_agent_id" INTEGER NOT NULL,
    "cadastral_number" VARCHAR(100),
    "official_address" VARCHAR(500) NOT NULL,
    "house_number" VARCHAR(50),
    "apartment" VARCHAR(50),
    "landmark" VARCHAR(255),
    "latitude" DECIMAL(10,7) NOT NULL,
    "longitude" DECIMAL(10,7) NOT NULL,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "households_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "residents" (
    "id" BIGSERIAL NOT NULL,
    "household_id" BIGINT NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "middle_name" VARCHAR(100),
    "full_name" VARCHAR(255),
    "phone_primary" VARCHAR(30),
    "phone_secondary" VARCHAR(30),
    "birth_date" DATE,
    "gender" "Gender" NOT NULL DEFAULT 'UNKNOWN',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "residents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "search_logs" (
    "id" BIGSERIAL NOT NULL,
    "driver_id" INTEGER NOT NULL,
    "branch_id" INTEGER,
    "query_text" VARCHAR(255) NOT NULL,
    "resident_id" BIGINT,
    "household_id" BIGINT,
    "searched_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "search_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "driver_search_logs" (
    "id" BIGSERIAL NOT NULL,
    "driver_id" INTEGER NOT NULL,
    "branch_id" INTEGER,
    "search_type" VARCHAR(50),
    "first_name" VARCHAR(100),
    "last_name" VARCHAR(100),
    "middle_name" VARCHAR(100),
    "phone" VARCHAR(30),
    "query_text" VARCHAR(255),
    "result_count" INTEGER NOT NULL DEFAULT 0,
    "selected_resident_id" BIGINT,
    "selected_household_id" BIGINT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "driver_search_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "navigation_sessions" (
    "id" BIGSERIAL NOT NULL,
    "driver_id" INTEGER NOT NULL,
    "branch_id" INTEGER,
    "resident_id" BIGINT,
    "household_id" BIGINT NOT NULL,
    "started_at" TIMESTAMP(3),
    "arrived_at" TIMESTAMP(3),
    "finished_at" TIMESTAMP(3),
    "status" "NavigationStatus" NOT NULL DEFAULT 'STARTED',
    "navigator_type" "NavigatorType" NOT NULL DEFAULT 'UNKNOWN',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "navigation_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "driver_daily_statuses" (
    "id" BIGSERIAL NOT NULL,
    "driver_id" INTEGER NOT NULL,
    "work_date" DATE NOT NULL,
    "status" "DriverWorkStatus" NOT NULL,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "driver_daily_statuses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_status_logs" (
    "id" BIGSERIAL NOT NULL,
    "navigation_session_id" BIGINT NOT NULL,
    "driver_id" INTEGER NOT NULL,
    "status" "TripActionStatus" NOT NULL,
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "trip_status_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "household_change_logs" (
    "id" BIGSERIAL NOT NULL,
    "household_id" BIGINT NOT NULL,
    "changed_by_user_id" INTEGER NOT NULL,
    "action" "ChangeAction" NOT NULL,
    "old_data" JSONB,
    "new_data" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "household_change_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "resident_change_logs" (
    "id" BIGSERIAL NOT NULL,
    "resident_id" BIGINT NOT NULL,
    "changed_by_user_id" INTEGER NOT NULL,
    "action" "ChangeAction" NOT NULL,
    "old_data" JSONB,
    "new_data" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "resident_change_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" BIGSERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "action" VARCHAR(120) NOT NULL,
    "entity_type" "AuditEntityType" NOT NULL,
    "entity_id" BIGINT,
    "ip_address" VARCHAR(64),
    "user_agent" VARCHAR(500),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "regions_name_key" ON "regions"("name");

-- CreateIndex
CREATE INDEX "districts_region_id_idx" ON "districts"("region_id");

-- CreateIndex
CREATE UNIQUE INDEX "districts_region_id_name_key" ON "districts"("region_id", "name");

-- CreateIndex
CREATE UNIQUE INDEX "branches_code_key" ON "branches"("code");

-- CreateIndex
CREATE INDEX "branches_district_id_idx" ON "branches"("district_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE INDEX "users_branch_id_idx" ON "users"("branch_id");

-- CreateIndex
CREATE INDEX "users_district_id_idx" ON "users"("district_id");

-- CreateIndex
CREATE INDEX "users_role_idx" ON "users"("role");

-- CreateIndex
CREATE INDEX "households_region_id_idx" ON "households"("region_id");

-- CreateIndex
CREATE INDEX "households_district_id_idx" ON "households"("district_id");

-- CreateIndex
CREATE INDEX "households_branch_id_idx" ON "households"("branch_id");

-- CreateIndex
CREATE INDEX "households_created_by_agent_id_idx" ON "households"("created_by_agent_id");

-- CreateIndex
CREATE INDEX "households_latitude_longitude_idx" ON "households"("latitude", "longitude");

-- CreateIndex
CREATE INDEX "households_official_address_idx" ON "households"("official_address");

-- CreateIndex
CREATE INDEX "residents_household_id_idx" ON "residents"("household_id");

-- CreateIndex
CREATE INDEX "residents_first_name_idx" ON "residents"("first_name");

-- CreateIndex
CREATE INDEX "residents_last_name_idx" ON "residents"("last_name");

-- CreateIndex
CREATE INDEX "residents_full_name_idx" ON "residents"("full_name");

-- CreateIndex
CREATE INDEX "residents_phone_primary_idx" ON "residents"("phone_primary");

-- CreateIndex
CREATE INDEX "residents_phone_secondary_idx" ON "residents"("phone_secondary");

-- CreateIndex
CREATE INDEX "search_logs_driver_id_idx" ON "search_logs"("driver_id");

-- CreateIndex
CREATE INDEX "search_logs_branch_id_idx" ON "search_logs"("branch_id");

-- CreateIndex
CREATE INDEX "search_logs_resident_id_idx" ON "search_logs"("resident_id");

-- CreateIndex
CREATE INDEX "search_logs_household_id_idx" ON "search_logs"("household_id");

-- CreateIndex
CREATE INDEX "search_logs_searched_at_idx" ON "search_logs"("searched_at");

-- CreateIndex
CREATE INDEX "driver_search_logs_driver_id_idx" ON "driver_search_logs"("driver_id");

-- CreateIndex
CREATE INDEX "driver_search_logs_branch_id_idx" ON "driver_search_logs"("branch_id");

-- CreateIndex
CREATE INDEX "driver_search_logs_phone_idx" ON "driver_search_logs"("phone");

-- CreateIndex
CREATE INDEX "driver_search_logs_first_name_last_name_idx" ON "driver_search_logs"("first_name", "last_name");

-- CreateIndex
CREATE INDEX "driver_search_logs_created_at_idx" ON "driver_search_logs"("created_at");

-- CreateIndex
CREATE INDEX "navigation_sessions_driver_id_idx" ON "navigation_sessions"("driver_id");

-- CreateIndex
CREATE INDEX "navigation_sessions_branch_id_idx" ON "navigation_sessions"("branch_id");

-- CreateIndex
CREATE INDEX "navigation_sessions_resident_id_idx" ON "navigation_sessions"("resident_id");

-- CreateIndex
CREATE INDEX "navigation_sessions_household_id_idx" ON "navigation_sessions"("household_id");

-- CreateIndex
CREATE INDEX "navigation_sessions_status_idx" ON "navigation_sessions"("status");

-- CreateIndex
CREATE INDEX "navigation_sessions_created_at_idx" ON "navigation_sessions"("created_at");

-- CreateIndex
CREATE INDEX "driver_daily_statuses_status_idx" ON "driver_daily_statuses"("status");

-- CreateIndex
CREATE UNIQUE INDEX "driver_daily_statuses_driver_id_work_date_key" ON "driver_daily_statuses"("driver_id", "work_date");

-- CreateIndex
CREATE INDEX "trip_status_logs_navigation_session_id_idx" ON "trip_status_logs"("navigation_session_id");

-- CreateIndex
CREATE INDEX "trip_status_logs_driver_id_idx" ON "trip_status_logs"("driver_id");

-- CreateIndex
CREATE INDEX "trip_status_logs_created_at_idx" ON "trip_status_logs"("created_at");

-- CreateIndex
CREATE INDEX "household_change_logs_household_id_idx" ON "household_change_logs"("household_id");

-- CreateIndex
CREATE INDEX "household_change_logs_changed_by_user_id_idx" ON "household_change_logs"("changed_by_user_id");

-- CreateIndex
CREATE INDEX "household_change_logs_created_at_idx" ON "household_change_logs"("created_at");

-- CreateIndex
CREATE INDEX "resident_change_logs_resident_id_idx" ON "resident_change_logs"("resident_id");

-- CreateIndex
CREATE INDEX "resident_change_logs_changed_by_user_id_idx" ON "resident_change_logs"("changed_by_user_id");

-- CreateIndex
CREATE INDEX "resident_change_logs_created_at_idx" ON "resident_change_logs"("created_at");

-- CreateIndex
CREATE INDEX "audit_logs_user_id_idx" ON "audit_logs"("user_id");

-- CreateIndex
CREATE INDEX "audit_logs_entity_type_entity_id_idx" ON "audit_logs"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "audit_logs_created_at_idx" ON "audit_logs"("created_at");

-- AddForeignKey
ALTER TABLE "districts" ADD CONSTRAINT "districts_region_id_fkey" FOREIGN KEY ("region_id") REFERENCES "regions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "districts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "districts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "households" ADD CONSTRAINT "households_region_id_fkey" FOREIGN KEY ("region_id") REFERENCES "regions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "households" ADD CONSTRAINT "households_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "districts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "households" ADD CONSTRAINT "households_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "households" ADD CONSTRAINT "households_created_by_agent_id_fkey" FOREIGN KEY ("created_by_agent_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "residents" ADD CONSTRAINT "residents_household_id_fkey" FOREIGN KEY ("household_id") REFERENCES "households"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "search_logs" ADD CONSTRAINT "search_logs_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "search_logs" ADD CONSTRAINT "search_logs_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "search_logs" ADD CONSTRAINT "search_logs_resident_id_fkey" FOREIGN KEY ("resident_id") REFERENCES "residents"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "search_logs" ADD CONSTRAINT "search_logs_household_id_fkey" FOREIGN KEY ("household_id") REFERENCES "households"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "driver_search_logs" ADD CONSTRAINT "driver_search_logs_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "driver_search_logs" ADD CONSTRAINT "driver_search_logs_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "driver_search_logs" ADD CONSTRAINT "driver_search_logs_selected_resident_id_fkey" FOREIGN KEY ("selected_resident_id") REFERENCES "residents"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "driver_search_logs" ADD CONSTRAINT "driver_search_logs_selected_household_id_fkey" FOREIGN KEY ("selected_household_id") REFERENCES "households"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "navigation_sessions" ADD CONSTRAINT "navigation_sessions_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "navigation_sessions" ADD CONSTRAINT "navigation_sessions_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "navigation_sessions" ADD CONSTRAINT "navigation_sessions_resident_id_fkey" FOREIGN KEY ("resident_id") REFERENCES "residents"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "navigation_sessions" ADD CONSTRAINT "navigation_sessions_household_id_fkey" FOREIGN KEY ("household_id") REFERENCES "households"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "driver_daily_statuses" ADD CONSTRAINT "driver_daily_statuses_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_status_logs" ADD CONSTRAINT "trip_status_logs_navigation_session_id_fkey" FOREIGN KEY ("navigation_session_id") REFERENCES "navigation_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_status_logs" ADD CONSTRAINT "trip_status_logs_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "household_change_logs" ADD CONSTRAINT "household_change_logs_household_id_fkey" FOREIGN KEY ("household_id") REFERENCES "households"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "household_change_logs" ADD CONSTRAINT "household_change_logs_changed_by_user_id_fkey" FOREIGN KEY ("changed_by_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "resident_change_logs" ADD CONSTRAINT "resident_change_logs_resident_id_fkey" FOREIGN KEY ("resident_id") REFERENCES "residents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "resident_change_logs" ADD CONSTRAINT "resident_change_logs_changed_by_user_id_fkey" FOREIGN KEY ("changed_by_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
