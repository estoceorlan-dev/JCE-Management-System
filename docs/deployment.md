# Client deployment

Use Flutter 3.44.9 / Dart 3.12.2, matching CI and the locked dependencies. Windows and Android are native POS targets; web provides administration with checkout disabled. Hosted web production uses the online-only profile. A staging build does not approve a production release.

## Prerequisites

- Provision the [backend database and restricted roles](https://github.com/estoceorlan-dev/JCE-Backend/blob/main/docs/database_setup.md), apply the 24-migration catalog, and configure authenticated HTTPS.
- Retain the deployment UUID, organization code, and public P-256 verification keys from trusted operator setup. Private keys and database credentials stay server-side.
- For Windows builds, enable plugin symlink support and install Visual Studio's Desktop development with C++ workload. Android builds require the Flutter Android toolchain; release candidates require a provisioned signing keystore.

## Native installation

```powershell
flutter pub get --enforce-lockfile
Copy-Item config/node.local.example.json config/node.local.json
```

Fill the ignored profile with the trusted API origin, deployment UUID, organization code, and public verification-key map. The map is a JSON string keyed by `kid`. Start the staging client:

```powershell
flutter run -d windows --dart-define-from-file=config/node.local.json
```

Select a connected Android device instead of `windows` for Android validation. Same-machine development may explicitly allow HTTP `127.0.0.1` or `localhost` on both ends. LAN addresses and Android emulator aliases do not qualify as loopback.

Sign in with the provisioned account and claim a register. An installation is bound to one branch; provision branch access accordingly. Register reassignment uses the manager-authorized workflow. Enroll each cashier through **Offline cashier PIN** while online, then verify **Sign in with an offline PIN** without the API. Expired or locked enrollments require online recovery. Cashier switching and restart preserve signed pending work.

## Public configuration

| Setting | Purpose |
| --- | --- |
| `JCE_ENV` | `development`, `staging`, or `production` |
| `JCE_BACKEND` | `node`, the supported backend |
| `JCE_API_BASE_URL` | Trusted HTTPS origin |
| `JCE_DEPLOYMENT_ID` | Provisioned deployment UUID |
| `JCE_ORGANIZATION_CODE` | Provisioned organization selector |
| `JCE_OFFLINE_VERIFICATION_KEYS` | JSON string mapping key IDs to public P-256 JWKs |
| `JCE_TLS_CA_CERT_BASE64` | Optional public LAN CA certificate for native clients |
| `JCE_ONLINE_ONLY` | `true` for production web; `false` for native production |
| `JCE_ENABLE_DEMO_AUTH` / `JCE_DEMO_BRANCH_ID` | Explicit development demo and its branch selector |
| `JCE_ENABLE_DIAGNOSTICS` | Disabled in production |
| `JCE_ALLOW_HTTP_LOOPBACK` | Explicit local development only; disabled in production |
| `JCE_APPROVED_PRODUCTION_DEPLOYMENT_ID` | Independent protected build input matching the production profile |

Dart defines are public compiled data. Never include passwords, tokens, database URLs, private JWK fields, signing keys, or the web proxy routing secret. Follow [public release profiles](../config/README.md) for validation and protected approval inputs.

Local HTTPS uses the operator-verified public Caddy root certificate. Native clients extend normal trusted roots and retain hostname/expiry verification; browsers use their own certificate trust. Keep API and hosting origins consistent for cookies and CSRF. Separate local and hosted deployments have separate identities and queues.

## Hosted web administration

Follow the backend's [Vercel + Render + Neon runbook](https://github.com/estoceorlan-dev/JCE-Backend/blob/main/docs/vercel_neon.md) for the split hosted profile. Vercel builds and serves Flutter assets and proxies `/v1/*` and `/health/*` to Render. The routing secret stays in protected hosting configuration. The public API origin equals the browser origin.

For embedded web hosting, follow [Render deployment](https://github.com/estoceorlan-dev/JCE-Backend/blob/main/docs/render_deployment.md). Build with an actual provisioned public profile:

```powershell
flutter build web --release --no-web-resources-cdn --dart-define-from-file=config/node.render.local.json
```

Use `npm run build` in the configured Vercel build environment for the split profile. It validates public settings, enforces the dependency lock, bundles renderer assets, and prepares `.vercel/output`. Example JSON files contain placeholders and are unsuitable for a live installation.

## Release and recovery checks

Deploy a compatible server/schema before clients. Verify `/health/ready` and `/v1/meta` against the expected deployment UUID, API major 1, protocol 1, schema 24, public key, and recovery state. A recovery-locked server blocks online writes while preserving local queues. Preserve SQLite schema 20 and signed command evidence across upgrades.

Before promotion, verify browser login, refresh, logout, cookies, CSRF, permissions, deep-link reload, acknowledged writes, a second browser, and outage/reconnect behavior. Native acceptance additionally requires signed artifact installation, secure storage, PIN expiry/lockout, offline checkout and restart, lost-response replay across two tills, and physical scanner, printer, and cash-drawer checks.

For local installations, follow the backend's [service package](https://github.com/estoceorlan-dev/JCE-Backend/blob/main/docs/local_production_package.md) and test with the router WAN disconnected. Rehearse [backup/restore and reconciliation](https://github.com/estoceorlan-dev/JCE-Backend/blob/main/docs/backup_restore.md) before trading. Preserve the original deployment identity and signing key; never redirect a pending queue to an independent database.

Windows production validation and startup remain blocked under [ADR-0001](adr/0001_windows_production_transport.md). Hosted staging, recovery, and physical device acceptance must be completed for the intended environment before approving production.
