# smart_agreement_library — Agent Instructions

> **This repo follows the workshop root's patterns — it does not define its own.** Development workflow, process, changelog conventions, and spec/feature-doc discipline live in the workshop: [`CLAUDE.md`](../../../CLAUDE.md), [`AGENTS.md`](../../../AGENTS.md), [`documentation/DEVELOPMENT_WORKFLOW.md`](../../../documentation/DEVELOPMENT_WORKFLOW.md). Below is only what's specific to THIS repo.

## Purpose

`library` — a content library of **RAVE** (Recorded Agreement Verifiably Executed) templates (pure template/data, no code of its own): each is a Rhai execution script plus JSON Schemas for inputs, outputs, and agreement-definition form, loaded at runtime by the `rave_engine` crate in the parent [`unyt-sandbox/unyt`](../) app. Nested git submodule of `unyt-sandbox/unyt`.

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

## Repo-specific rules

- **Rhai runs sandboxed.** Only the helper functions registered by `rave_engine` are callable — no arbitrary Rust. Don't author scripts assuming host access.
- **Outputs are a typed contract.** A RAVE returns `unyt_allocation`, `credit_limit`, and/or `computed_values`; match the `output_signature.json` exactly or `rave_engine` validation rejects it.
- **Each role declares a `parked_link_type`** used by the UI for link creation; keep it in sync with the agreement definition.
- **Changing a template's output shape is a breaking change for consumers** — coordinate with the parent app and run its sweettests before merging.
