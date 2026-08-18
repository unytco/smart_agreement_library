# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `__system_transaction_fee_collection`: the collected total sums every unit of every allocation, with exact fuel arithmetic. Fees accrue per unit, and the total read the base unit alone through `parse_float`.
- `ioen_rec`: emit `amounts` as a unit map (`#{ "0": total }`), not an array — the array shape does not deserialize into `UnitMap` and contradicted the template's own `output_signature.json`. Its example agreement now uses the real `AuthorizedExecutor` variant and an array-valued `Authorized` qualification.
- Docs: the output contract had allocations as `amount` arrays and `credit_limit` as an `{ agent, amount }` object; both are unit maps. Executor rules are `AuthorizedExecutor` with one key, not `AuthorizedExecutors` with a list.
- Docs: dead links — `docs/rave_rules.md` and `unytco/unyt-releases` in `README.md`, the `RAVEOutput` docs.rs path in `CONTRIBUTING.md`.
- `__system_credit_limit_computation_holo_hosting`: declare `special_agent` and `special_credit_limit` in `runtime_input_signature.json` — the script reads both, but the signature was a copy of the generic template's, which has neither.

### Changed

- Docs: documented the previously undocumented — the `#{ "output": … }` return shape with `rejected_links` / `redacted_links`, the `locked` and `carryover` outputs, `other_options.json`, which template files are required, and the `spender` role-naming rule (folded in from `docs/rough_rules.md`, now removed).

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
- `__system_credit_limit_computation_holo_hosting`: narrow the special agent's elevated `special_credit_limit` to the HoloFuel unit only (index `0`), dropping the stale, over-broad second index, and set it to `177619433541.14`.
