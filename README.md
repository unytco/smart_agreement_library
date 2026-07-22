# Smart Agreement Code Library

## Welcome to the Smart Agreement Code Library

A **Smart Agreement** is a recorded agreement, verifiably executed. It is similar to a Blockchain Smart Contract, but designed to take advantage of the Agent-Centric Holochain Application Architecture: an executor runs the agreement's code against the inputs each party has parked, and every peer re-runs it to validate the result. The record of one execution is a **RAVE** — a Record of Agreement Verifiably Executed.

## Smart Agreements

See the [library directory](./library) for the Smart Agreements.

Each has its own directory holding the Rhai execution code and the JSON Schemas for its runtime inputs, its output, and the creation form a UI renders — layout in [CONTRIBUTING.md](./CONTRIBUTING.md). Each should carry contextual information and a summary in comments at the top of its `execution_code.rhai`.

Names starting with `__system_`, `_lane_`, or `_automation_` are loaded by directory name during network setup, so renaming or removing one is a breaking change. The rest are examples and community templates. `library/.deprecated/` is reference only and never loaded.

## Documentation

- [Rules when writing a Smart Agreement](./docs/smart_agreement_rules.md) — the parts of a template and the output contract the engine enforces
- [How to contribute to the Smart Agreement Code Library](./CONTRIBUTING.md)
- [`rave_engine` API docs](https://docs.rs/rave_engine) — the engine that loads, executes, and validates these templates
- [Changelog](./CHANGELOG.md)

## More Info and Where to Run Smart Agreements

Smart Agreements run in a Peer-to-Peer Unyt Accounting application. Documentation is at [unyt.co/docs](https://unyt.co/docs/); downloads are on the [Unyt Sandbox releases page](https://github.com/unytco/unyt-sandbox/releases).
