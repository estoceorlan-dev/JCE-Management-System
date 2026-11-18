# Frontend architecture

JCE is a feature-based Flutter application for native Windows/Android POS and web administration. The standalone [Node.js/PostgreSQL backend](https://github.com/estoceorlan-dev/JCE-Backend/blob/main/docs/architecture.md) owns authoritative transactions and identity. Native clients retain SQLite-first operation; the hosted web profile is online-only.

## Layers and ownership

| Layer | Responsibility |
| --- | --- |
| Presentation | Pages, shared widgets, Riverpod controllers/providers, navigation, and user feedback |
| Domain | Entities, repository interfaces, use cases, business rules, and typed results |
| Data | Local repositories, Drift queries, HTTP adapters, DTOs, and platform storage adapters |
| Core | Configuration, startup, routing, database infrastructure, logging, theme, and synchronization |

Features live under `lib/features/<feature>`. Domain code stays independent of Flutter, SQLite, and HTTP libraries. Widgets depend on providers and contracts rather than constructing services or executing SQL. Shared UI lives under `lib/core/widgets`; shared domain types live under `lib/shared`.

The feature set includes authentication, dashboard, branches, products, imports, inventory, transfers, purchasing, customers, POS, shifts, reports, staff, settings, logs, and hardware.

## Local write model

Native mutations atomically persist business state and a signed outbox envelope in Drift/SQLite. The dedicated `lib/core/sync` module owns upload, retry/backoff, dependencies, conflicts, snapshots, and incremental changes. Features do not run their own synchronization loops.

The saved command retains its operation ID, actor, creation time, payload, and authorization across logout, cashier switching, application restart, and a lost response. Transport retries use fresh request proof without rewriting the command. Server acknowledgement updates local state; permanent rejection retains evidence for reconciliation.

SQLite schema 20 is deployment-specific. Profiles for another deployment use separate database and credential namespaces. Changing an API address requires verifying the same deployment identity and public key; no automatic local/cloud database failover exists. Released Drift snapshots remain immutable.

## Startup, routing, and availability

Startup validates the environment and deployment profile, initializes platform services, and restores identity before permission-aware routing. Deep links wait for session restoration, then enforce the target route's permission. Invalid configuration and unsupported production platforms stop on a controlled failure screen.

Native offline behavior uses previously enrolled device credentials and local data. The hosted web gate requires a database-connected API readiness response before allowing access. Dashboard errors distinguish unavailable metrics from real zero counts.

## Authentication and platform boundaries

Native clients protect per-installation P-256 credentials using platform secure storage. Cashiers enroll a 6–12 digit PIN while the API is reachable. Offline authorization is device-bound, expiring, and limited to cashier operations. PIN lockout, clock checks, and online recovery apply; offline PINs do not authorize supervisor actions.

Browser administration uses same-origin HTTPS, Secure HttpOnly cookies, and CSRF protection. Browser storage contains public metadata rather than native private keys, bearer credentials, PINs, or offline enrollments. Browser checkout is disabled.

Public client profiles include the API origin, deployment UUID, organization code, and public verification keys. Database credentials and signing private keys remain on the server. Local native TLS may add an operator-verified public CA while retaining hostname, expiry, and certificate-chain validation.

## Images and hardware

Product images use a separate optional queue and replaceable storage adapters. Missing images or an upload failure never block product creation, checkout, or core synchronization. Hardware adapters and receipt queues isolate platform-dependent scanner, printer, and cash-drawer behavior.

Windows production remains gated by [ADR-0001](adr/0001_windows_production_transport.md). Linux, macOS, and iOS are evaluation scaffolds. See [deployment](deployment.md) for setup and physical acceptance requirements and the backend's [signed protocol](https://github.com/estoceorlan-dev/JCE-Backend/blob/main/docs/signed_sync_protocol.md) for wire contracts.
