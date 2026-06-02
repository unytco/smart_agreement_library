# smart_agreement_library — Agent Instructions

## Purpose

A content library of **RAVE** (Recorded Agreement Verifiably Executed) templates — the smart-agreement definitions the Unyt app executes for mutual-credit accounting and agreement enforcement. Each template is plain data: a Rhai execution script plus JSON Schemas for its inputs, outputs, and agreement-definition form. The library has no code of its own; it is loaded at runtime by the `rave_engine` crate inside the parent [`unyt-sandbox/unyt`](../) app. It is a nested git submodule of `unyt-sandbox/unyt` (base `main`, `pr-policy: reviewed`).

## Classification

`library` — pure template/data, consumed by `unyt-sandbox/unyt`. No build output of its own.

## Stack

- **Rhai** (v1.21.0) scripts (`execution_code.rhai`), executed by the parent's `rave_engine`.
- **JSON Schema** for input / output / definition signatures.
- No Rust/Cargo, no `flake.nix`, no JS/TS, no WASM/DNA build in this repo.

## Build

n/a — static data. Templates are read at runtime by `rave_engine` in the parent app; nothing compiles here.

## Format

No tooling enforced. Rhai files carry the documented header comments (`/// Subject:`, `/// Inputs:`, `/// Summary:`); JSON stays standard-formatted. Conventions are in [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Test

No suite here. Templates are exercised upstream by the parent app's sweettests (`nix develop -c make test` in `unyt-sandbox/unyt`), which run agreements through `rave_engine` in ephemeral conductors. Otherwise correctness is enforced by review of the Rhai logic + schemas per [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Deploy

n/a (library) — ships as part of the parent `unyt` app.

## Related repos in workshop

- Consumed by [`unyt-sandbox/unyt`](../) via the `rave_engine` crate (`crates/rave_engine`); the `transactor` coordinator zome calls into it.
- See workshop [`AGENTS.md`](../../../AGENTS.md) for the full map.

## Changelog

File: [`./CHANGELOG.md`](./CHANGELOG.md). Format: [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), `## [Unreleased]` at the top, standard subsections (Added/Changed/Deprecated/Removed/Fixed/Security). One bullet per agent change, ≤120 chars, present-tense imperative; branch-type → section mapping per [workshop `docs/WORKSHOP_WORKFLOW.md § Changelog conventions`](../../../docs/WORKSHOP_WORKFLOW.md). A new or changed RAVE template that affects execution output is user-visible → `### Added` / `### Changed`.

## Repo-specific rules

- **Rhai runs sandboxed.** Only the helper functions registered by `rave_engine` are callable — no arbitrary Rust. Don't author scripts assuming host access.
- **Outputs are a typed contract.** A RAVE returns `unyt_allocation`, `credit_limit`, and/or `computed_values`; match the `output_signature.json` exactly or `rave_engine` validation rejects it.
- **Each role declares a `parked_link_type`** used by the UI for link creation; keep it in sync with the agreement definition.
- **Changing a template's output shape is a breaking change for consumers** — coordinate with the parent app and run its sweettests before merging.

## Lessons learned

_Append entries here whenever an agent (or human) loses time to something a guardrail would have prevented. Keep each entry: date, short symptom, concrete fix._
