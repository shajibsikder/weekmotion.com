## 🎬 Weekmotion: Core Platform Architecture & System Design

This repository serves as the public architectural blueprint and documentation showcase for **Weekmotion**, a high-performance video-sharing, content monetization, and creator ecosystem built using a decoupled monolithic structure. 

The primary focus of this design is to demonstrate clean code organization, maintainable database schemas, and efficient async task processing under real-world loads.

---

### 🧠 Core System Capabilities & Architectural Mapping

Here is how the platform capabilities are translated into modular backend engineering components:

#### 1. Media & Content Pipelines
* **Video Ingestion & Chunked Input:** Handled via custom file pipelines and background meta-parsing to ensure smooth request cycles without blocking application threads.
* **Unified CMS Framework (Articles & Community Posts):** Designed with indexed relational database structures supporting polymorphically linked user interactions, comments, and media attachments.
* **User Profile Matrix:** A highly scalable schema managing unique creator identities, customized branding parameters, and operational metadata.
* **Polymorphic Creator Activity Feed (New):** An asymmetric activity timeline tracking multi-media nodes, textual updates, and real-time engagement patterns. Integrated with access-control layers to dynamically filter content visibility between segmented audiences.

#### 2. Native Ad Distribution & Analytics
* **Programmatic Ad Campaign Engine:** Engine configured to dynamically route and serve optimized Direct Link and Vignette ad zone delivery pipelines, maximizing CPM throughput while preserving UI layout stability.
* **Premium Access Controls (Ad-Free Pro Tiers):** Managed through stateless authorization middleware that tracks membership states to conditionally filter runtime ad-injection layers.

#### 3. Monetization & Incentive Engines
* **Creator Monetization Router:** Evaluates baseline eligibility metrics (strictly enforcing the 5 long videos and 50 subscribers validation threshold) via localized database verification before routing accounts to active revenue programs.
* **Engagement Incentives (Watch & Reward Module):** Utilizes event-driven listeners to track user viewing thresholds, sending completed metrics to an isolated background queue to award account units smoothly.

#### 4. Digital Commerce & Ledger Matrix
* **Digital Asset Marketplace:** Secure provisioning pipeline handling download authorization tokens, license key generation, and single-purchase logs for buying digital products.
* **Double-Entry Financial Ledger (Deposit, Withdraw, Balance Transfer):** Built with strict database transaction atomicity (`DB::transaction`). Every financial movement—whether loading capital, requesting pay-outs, or initiating peer transfers—guarantees mathematical balance symmetry with automated rolling audit logs to eliminate race conditions.
* **Dynamic Content Paywall Gate (New):** Enforces transaction thresholds to securely unlock premium premium posts. Utilizes server-side token verification blocks before streaming the gated payload to the client application.

---

### 🏗️ Complete System Data Flow

> This blueprint maps how the platform handles standard API actions, asynchronous reward processing, and secure ledger modifications safely away from the main server routing layer.

```mermaid
graph TD
    User[Client Application] -->|HTTP Requests / Media Ingestion| Nginx[Nginx Reverse Proxy]
    Nginx -->|Route Traffic| AuthMW[Stateless Auth Middleware]
    AuthMW -->|Valid Sessions| CoreApp[Laravel Core Engine]
    
    %% Async Job Decoupling
    CoreApp -->|Dispatch Telemetry & Rewards| RedisQueue[Redis Async Queue]
    RedisQueue -->|Pop Tasks| Workers[Background Process Workers]
    
    %% Transaction Layer
    CoreApp -->|Atomic Financial Ledger| DBTransaction[DB Transaction Block]
    DBTransaction -->|Strict Commit/Rollback| MySQL[(MySQL Relational DB)]
    Workers -->|Process Meta / Compute Points| MySQL
    
    %% Caching Layer
    CoreApp -->|Read-Heavy Query Caching| RedisCache[(Redis Cache Memory)]
    MySQL -->|Cache Hydration| RedisCache
    
    style User fill:#F85D7F,stroke:#fff,stroke-width:2px,color:#fff
    style CoreApp fill:#1F222E,stroke:#F8D866,stroke-width:1px,color:#fff
    style RedisQueue fill:#1F222E,stroke:#F8D866,stroke-width:1px,color:#fff
    style DBTransaction fill:#050A14,stroke:#fff,stroke-width:1px,color:#fff
    style MySQL fill:#050A14,stroke:#fff,stroke-width:1px,color:#fff
    style RedisCache fill:#050A14,stroke:#fff,stroke-width:1px,color:#fff
