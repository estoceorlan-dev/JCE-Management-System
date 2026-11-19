# ADR-0001: Windows production transport

Original decision: 15 September 2026.
Status: accepted interim restriction; Windows production remains disabled.

## Context

This restriction originated when the desktop application used Firebase adapters.
The active application now uses the standalone Node.js/PostgreSQL API with HTTPS,
per-installation P-256 keys, server authorization, and signed offline commands.
Replacing the transport did not complete native device and operational acceptance
or authorize removal of the production gate.

## Decision

Configuration validation and startup reject `JCE_ENV=production` on Windows.
Development and staging remain available for integration, installation, and
hardware testing. The Windows gate applies independently of online browser checkout. Android production
candidates require their own signing, device, security, and recovery acceptance.

Enable Windows production only through a superseding architecture decision backed
by the evidence below. This documentation cleanup does not supersede the decision
or change runtime policy.

## Required supersession evidence

- Platform and dependency support review for the intended release.
- Threat model for key storage, enrollment, replay, theft, cloning, revocation,
  rotation, clock skew, offline authority, and recovery.
- Protected unique per-installation asymmetric credentials; evaluate TPM/CNG
  protection on supported Windows hardware. No shared application secret,
  database credential, or server signing private key in the binary.
- Contract-tested HTTPS transport with authoritative organization, branch, and
  permission checks on the server.
- Device proofs bound to method, path, body digest, nonce, and timestamp, with
  replay expiry and emergency revocation.
- Signed installer, clean installation, OS reboot, upgrade, and rollback checks.
- Physical scanner, printer, receipt, and cash-drawer acceptance on the target till.
- Offline checkout and restart, two-device WAN-disconnected operation, lost-response
  replay, revocation, load/abuse checks, and backup/restore reconciliation.
- Security, operations, and release-owner approval recorded with the new decision.

## Consequences

The production release validator rejects Windows and startup displays a controlled
failure screen. Staging remains available, including the automated process-restart
pilot. Passing automated tests or building a staging executable does not remove
the production restriction.

See [client architecture](../architecture.md) and [deployment](../deployment.md)
for current transport behavior and acceptance procedures.
