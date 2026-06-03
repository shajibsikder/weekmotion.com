## 🎬Weekmotion: System Architecture & Design Overview

This repository serves as the architectural documentation and system design blueprint for **Weekmotion**, a scalable video-sharing, content monetization, and creator ecosystem built using a decoupled monolithic architecture.

The system is optimized for maintainability and efficient handling of media-heavy workloads, leveraging asynchronous processing and strong database-level consistency.

---

## 🧠 Core System Architecture

The platform is organized into modular backend components, each responsible for a specific domain of the system.

### 1. Media & Content System
- **Chunked Video Ingestion:** Processes high-volume media file uploads in sequential chunks to prevent web server process blocking.
- **Polymorphic Community Feed:** Powers articles, user updates, and feed interactions using unified relational tables with polymorphic mapping for comments and reactions.
- **Role-Gated Content Middleware:** Enforces real-time access control on the activity feed, dynamically segregating content visibility between Free and Pro membership tiers.

### 2. Advertisement & Access Control System
- **Native Ad Campaign Engine:** Routes and serves configured Direct Link and Vignette ad zone streams based on client demand.
- **Asynchronous Analytics Tier:** Deflects high-frequency ad impression logs away from core tables to prevent write-locks under peak traffic.
- **Conditional Ad Filtering:** Stateful middleware checks user subscription status to completely bypass ad-injection loops for premium accounts.

### 3. Monetization & Incentive System
- **Creator Eligibility Router:** Validates eligibility metrics (strictly enforcing the 5 long videos and 50 subscribers criteria) via indexed relational queries before account onboarding.
- **Watch & Reward Pipeline:** Event-driven listeners capture user consumption milestones and dispatch credits to background queues away from the main HTTP thread.

### 4. Digital Commerce & Ledger System
- **Double-Entry Financial Ledger:** Manages user deposits, withdrawals, and internal balances inside atomic database transactions (`DB::transaction`) to guarantee consistency and eliminate race conditions.
- **Content Paywalls & Marketplace:** Processes single-unit purchase validation tokens to securely unlock premium posts and digital assets.

---

## 🏗️ System Data Flow

This diagram represents the high-level request lifecycle, asynchronous processing flow, and storage segmentation layers.

```mermaid
graph TD
    User[Client Application] --> Nginx[Nginx Reverse Proxy]
    Nginx --> AuthMW[Authentication Middleware]
    AuthMW --> CoreApp[Laravel Core Application]

    %% Async Processing Layer
    CoreApp --> RedisQueue[Redis Queue]
    RedisQueue --> Workers[Background Workers]

    %% Database Layer
    CoreApp --> DBTransaction[Database Transaction Layer]
    DBTransaction --> MySQL[(MySQL Database)]
    Workers --> MySQL

    %% Caching Layer
    CoreApp --> RedisCache[(Redis Cache)]
    MySQL --> RedisCache
