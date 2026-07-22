# Rules when writing Agreement Code Templates and Smart Agreements in Rhai

## Overview

Smart Agreement Execution Code is written in Rhai, so it follows the [Rhai language](https://rhai.rs/) rules.

The key to writing one is the [RAVEOutput](https://docs.rs/rave_engine/latest/rave_engine/types/entries/rave/rave_output/struct.RAVEOutput.html) struct — the structure the engine expects your code to return. See [Rules for the Output](#rules-for-the-output).

Three terms, often confused:

- **Agreement Code Template** — the reusable logic: execution code plus its input and output schemas. One directory under [`library/`](../library) is one template.
- **Smart Agreement** — a template plus who may execute it, who fills each role, and where each input comes from. One template backs many Smart Agreements.
- **RAVE** (Record of Agreement Verifiably Executed) — the record of one execution, which every peer re-runs to validate.

## Agreement Code Template

A template has 4 parts, plus [Other Options](#other-options) for the remaining [CodeTemplate](https://docs.rs/rave_engine/latest/rave_engine/types/entries/code_template/struct.CodeTemplate.html) fields:

1. The Agreement Definition Input
2. The Runtime Input Schema
3. The Execution Code
4. The Output Schema

[CONTRIBUTING.md](../CONTRIBUTING.md) maps each part to its file.

### Agreement Definition Input

`agreement_definition_input` is a JSON schema defining the inputs needed to create a Smart Agreement. UIs render it as a form, so it must be a JSON object with a `properties` field. The standard defines an initial set of properties; the UI may extend it.

### `expected_roles`

Mandatory. An array of objects, one per role the agreement requires. Each needs:

- `id` — a string identifier for the role.
- `parked_link_type` — the link parked on execution for this role, one of [`PossibleParkedLinks`](https://docs.rs/rave_engine/latest/rave_engine/types/entries/code_template/enum.PossibleParkedLinks.html): `"ParkedSpendBalance"`, `"ParkedSpendCredit"`, or `{ "ParkedData": <bool> }` where the boolean says whether the data is consumed.

```json
"expected_roles": {
  "type": "array",
  "items": [
    { "const": { "id": "admin", "parked_link_type": "ParkedSpendCredit" } },
    { "const": { "id": "user", "parked_link_type": { "ParkedData": true } } }
  ]
}
```

#### Naming a role that spends

The UI reads role behaviour from a **substring** of the `id`. An id containing `spender` parks a spend instead of data — so a log harvester that creates a spend link is `log_harvester_spender`, not `log_harvester`. The same matching sorts roles into send actions (`sender`, `spender`, `sender_agent`, `withdrawer`, `oracle`) and collect actions (`receiver`, `payee`, `depositor`, `receiver_agent`). Keep the `id` in step with the `ct_role_id` the Smart Agreement uses.

### `api_calls` (Optional)

Defines external API calls the agreement requires — oracles, timestamping servers. Each key is an API; its value is a JSON schema for that API's input. The UI uses this to prompt for URLs or other parameters, and may add properties of its own.

```json
 "api_calls": {
   "type": "object",
   "properties": {
     "timestamp_server": {
       "type": "string",
       "format": "uri",
       "description": "URL of the trusted timestamping service."
     },
     "oracle_service": {
       "type": "string",
       "format": "uri",
       "description": "URL of the data oracle."
     }
   },
   "required": ["timestamp_server"]
 }
```

### Runtime Input Schema

A JSON Schema defining the inputs your code expects. Think through how each will be supplied at execution time — the [Instruction](https://docs.rs/rave_engine/latest/rave_engine/types/entries/smart_agreement/rules/enum.Instruction.html) enum lists the ways.

Note: input sources are not set in the template. They are set as Input Rules when creating a Smart Agreement against it.

### Execution Code

The Rhai code that takes the inputs, transforms them, and produces the outputs.

It runs sandboxed: only the [helper functions](https://docs.rs/rave_engine/latest/rave_engine/rhai_engine/rhai_functions/prelude/index.html) the engine registers are callable, and it must be deterministic — every validating peer re-runs it and compares.

### Output Schema

A JSON Schema for the execution's output. It describes the contents of the `output` map your code returns, not the whole return value. See [RAVEOutput](https://docs.rs/rave_engine/latest/rave_engine/types/entries/rave/rave_output/struct.RAVEOutput.html).

### Other Options

`other_options.json` carries the [CodeTemplate](https://docs.rs/rave_engine/latest/rave_engine/types/entries/code_template/struct.CodeTemplate.html) fields the four schemas don't:

- `one_time_run` — when `true`, an agreement using this template executes once only.
- `aggregate_execution` — when `true`, an input rule returns values from **all** matching parked links; when `false`, only the latest.
- `tags` (optional, defaults to empty) — the tag filters the template is discoverable under.
- `permissions` (optional, defaults to `{ "Default": null }`) — the template's permission space.

```json
{
  "one_time_run": false,
  "aggregate_execution": true,
  "tags": [{ "Public": "lockbox" }],
  "permissions": { "Default": null }
}
```

## Smart Agreement

A Smart Agreement borrows a template and adds Execution Rules, Roles, and Input Rules.

### Execution Rules

Two options ([`ExecutorRules`](https://docs.rs/rave_engine/latest/rave_engine/types/entries/smart_agreement/rules/enum.ExecutorRules.html)):

- `{ "Any": null }` — anyone may execute.
- `{ "AuthorizedExecutor": "executor_pubkey" }` — one named agent may execute.

An agreement that **locks funds** must use `AuthorizedExecutor`. The DNA rejects a lock under `Any`, since the lock has to name the agent who can release it.

### Roles

Each role names a `ct_role_id` matching an `id` in the template's `expected_roles`, plus a [`RoleQualification`](https://docs.rs/rave_engine/latest/rave_engine/types/entries/smart_agreement/enum.RoleQualification.html):

- `{ "Any": null }` — anyone.
- `{ "Authorized": ["agent_pubkey_1", "agent_pubkey_2"] }` — always an array, even for one agent.

### Input Rules

How the Executor fetches each input. Each entry names an input from the runtime input schema and gives the [Instruction](https://docs.rs/rave_engine/latest/rave_engine/types/entries/smart_agreement/rules/enum.Instruction.html) for where its value comes from:

```json
{ "name": "spender_allocations", "instruction": { "ProvidedBy": "spender" } }
```

## Rules for the Output

### The shape your code returns

A map with the result under `output`, plus two optional link lists:

```rhai
return #{
    "output": #{ /* the RAVEOutput fields below */ },
    "rejected_links": [],  // optional
    "redacted_links": []   // optional
};
```

- `rejected_links` — parked links dropped from this execution's inputs; they stay on the chain.
- `redacted_links` — parked links dropped **and** deleted.
- Each entry is `#{ "hash": <parked link ActionHash>, "reason": <string> }`. Both fields required.

Every field inside `output` is optional — return only what your agreement produces:

| Field | Type | Purpose |
| --- | --- | --- |
| `unyt_allocation` | array of allocations | transfer funds |
| `credit_limit` | unit map | credit limit authorized for the receiver |
| `locked` | unit map | funds held back, carried into the next execution |
| `carryover` | any JSON | data carried into the next execution |
| `computed_values` | any JSON | anything else the agreement returns |

**Amounts are unit maps, and they are exact.** A unit map is a JSON object keyed by unit index *as a string*, amount *as a string*: `{ "0": "100.5" }`. Never route an amount through a float — use the fuel helpers (`add_fuel`, `sub_fuel`, `add_units`), and `to_num` only for comparisons. A float round-trip loses precision and the RAVE then fails peer validation.

### Transferring funds

`unyt_allocation` is an array of allocation objects. All three fields are required:

```json
{
  "unyt_allocation": [
    {
      "receiver": "receiver_agent_pubkey",
      "amounts": { "0": "100" },
      "sources": ["source_action_hash"]
    }
  ]
}
```

- `receiver` — the agent being paid. One object per receiver.
- `amounts` — a unit map.
- `sources` — the parked links this allocation draws from. A parked source counts as a conserved input only once an allocation names it.

To name a source without paying for it (a pure hold), give it empty `amounts` (`{}`), not a zero amount. A zero amount is uncollectable at the ledger and strands a deposit the receiver can never settle.

### Setting a credit limit

`credit_limit` is a unit map — not an object naming an agent. The limit applies to the agreement's receiver:

```json
{
  "credit_limit": { "0": "100" }
}
```

### Locking funds

`locked` is a unit map of the funds the agreement holds back:

```json
{
  "locked": { "0": "42.5" }
}
```

Locked funds carry into the next execution of the same agreement, which spends them down or releases them. The agreement must use `AuthorizedExecutor` — see [Execution Rules](#execution-rules).

### Computing values

`computed_values` is a JSON object for anything else the agreement returns:

```json
{
  "computed_values": {
    "value_1": "value_1...",
    "value_2": "value_2..."
  }
}
```
