# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `lockbox`: a minimal AuthorizedExecutor agreement that holds conserved base-unit funds — parks and locks the remainder, carries the lock forward, spends it down, and unlocks it back to the creator. The proving ground for the locked-funds primitive.

### Changed

- `lockbox` + `holo_hosting_proof_of_service`: a hold names its funding with a name-only (empty `amounts`) allocation, so it settles and collects instead of stranding an uncollectable deposit; the holo-hosting no-metered-work lock now settles too.
- `holo_hosting_proof_of_service`: a host invoice draws from as many customer allocations as needed (split funding settles); a zero-priced invoice emits no payment.
- `holo_hosting_proof_of_service` + `lockbox`: numeric reads go through the engine's `to_num` — accepts a number or numeric string, refuses garbage loudly instead of silently pricing at 0.
- These three changes need an engine carrying `to_num` + `consume_allocations` (rave_engine > 0.6.0).
- `holo_hosting_proof_of_service`: lock the unspent base-unit funding instead of returning it to the executor, auto-apply the carried lock on the next run (spend-down), and add an `unlock` executor input to reclaim it; `input_rules` gain `previous_execution` and `unlock` (both declared in the runtime input signature).
- `holo_hosting_proof_of_service`: the EdgeNode Customer (executor) role's `comment` now notes it must be the sole `AuthorizedExecutor`, not `Any` — the agreement locks funds, which the DNA rejects under `ExecutorRules::Any` (the `lockbox` Locker role already documents this in its description).
- `holo_hosting_proof_of_service`: pay EdgeNode Hosts for both Holo services through one agreement instance.
- `holo_hosting_proof_of_service`: price five optional dimensions (storage, gossip, gets, 2 WindTunnel); absent ⇒ 0.
- `holo_hosting_proof_of_service`: fix the gossip/storage unit-index swap so each dimension credits its own index.
- `holo_hosting_proof_of_service`: rename the paying role Happ Provider → EdgeNode Customer.
- `__system_credit_limit_computation_holo_hosting`: narrow the special agent's elevated `special_credit_limit` to the HoloFuel unit only (`{0: 9999999}`), dropping the stale, over-broad second index.
