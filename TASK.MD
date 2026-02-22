Tarana — Ride-Hailing App Build
Phase 0: Architecture & Planning
 Step 2 — Domain & Feature Breakdown
 Step 3 — Assign Responsibility
 Step 4 — Communication Style
Step 5 — Final Architecture (data models, folder structure, architecture summary)
 User approval of implementation plan
Phase 1: Project Initialization
 Create Flutter project with correct package/bundle IDs
 Install all dependencies (pubspec.yaml)
 Configure Firebase (Auth, Firestore, RTDB, Storage, FCM)
 Set up layered folder structure
 Set up theme (light palette, glassmorphism, modern gradient)
 Configure GoRouter navigation
 Set up Provider state management scaffold
Phase 2: Core Identity Module
 Email/Password registration with role selection (rider default)
 Login screen
 Forgot password flow
 Soft-delete account flow
 Auth state management with Provider
 RBAC role model (rider, driver, dispatcher, admin, super_admin)
Phase 3: User & Driver Profiles
 User profile screen (view/edit)
 Profile photo upload (Firebase Storage)
 Driver application flow (submit docs + vehicle info)
 Driver extended profile model
 Driver online status (multi-state presence via RTDB)
Phase 4: Maps & Location
 Google Maps rendering
 Current location detection
 Saved places CRUD
 Markers / pins
 Distance & ETA calculation
 Nearby driver search (RTDB geo-queries)
Phase 5: Booking Module
 Booking request flow (rider creates via Cloud Functions - UI done)
 Dispatch logic (sequential nearest driver)
 Driver accept/reject UI (backend & frontend implemented)
 Booking states (pending → searching → assigned → arriving → in_progress → completed) - UI done
 Scheduled rides
 Cash payment recording
 Fare estimation (UI calculation)
Phase 6: Live Tracking
 Driver location broadcasting (RTDB writes every 2–3s)
 Rider live tracking view (map updates)
 Nearby available drivers on map (pre-booking)
Phase 7: Contacts & Address Book
 Emergency contacts CRUD
 Saved passengers (book for someone else)
Phase 8: Promos, Referrals & Discounts
 Promo code redemption (via Cloud Functions)
 Referral code generation & sharing
 Referral reward logic (after first completed trip)
 Discount rules engine (flat, percentage, caps, region, expiry)
Phase 9: Settings & Preferences
 Preferences screen (notifications, language)
 App settings with GetStorage persistence
Phase 10: Admin & Dispatcher Features
 Driver approval screen
 Active trips overview
 Manual ride assignment (dispatcher)
 Staff assignment
Phase 11: Landing Pages & Polish
 Landing/onboarding pages
 Glassmorphism UI components
 Modern gradient design system
 Final UI polish & responsiveness

Comment
⌥⌘M
