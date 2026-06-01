# Economy3 Provenance Attestation — Local Test Procedure

Tests the RAVE against 4 mock SignedFact blobs:
- 3 public/alias/community records → each earns 1 E3 credit
- 1 authority-only (tier 3) record → skipped, spend returned to brand

**Expected result:** `total_attested: 3`, `skipped_authority_only: 1`, `returned_to_spender: "1"`

---

## Step 1 — Install and open unyt-sandbox

The v0.54.0 DMGs are on your Desktop. Install the **Holo Hosting** full-arc Silicon DMG.

On first launch: System Settings → Privacy & Security → allow unyt to run.

---

## Step 2 — Upload the 4 mock data blobs

In the app: **DEV MODE → Data Records → Add New Data Record (Custom)**

Upload each blob file in this order and note the hash the app assigns each one:

| # | File | Expected behaviour |
|---|------|--------------------|
| 1 | `blob_1_cotton_harvest_public.json` | tier 0 → earns credit |
| 2 | `blob_2_wool_shear_alias.json` | tier 1 → earns credit |
| 3 | `blob_3_cotton_gin_community.json` | tier 2 → earns credit |
| 4 | `blob_4_wool_handoff_authority_only.json` | tier 3 → skipped |

Write down the 4 blob hashes the app assigns. You'll need them in Step 5.

---

## Step 3 — Upload the Agreement Code Template

**DEV MODE → Library → Add Agreement Code Template**

Fill in the fields by copying from the template files:

| Field | Source file |
|-------|-------------|
| Title | `Economy3 Provenance Attestation Credit` |
| Input Schema | paste content of `../runtime_input_signature.json` |
| Execution Code | paste content of `../execution_code.rhai` |
| Output Schema | paste content of `../output_signature.json` |

Save the template.

---

## Step 4 — Create a Smart Agreement from the template

**DEV MODE → Library → Create Smart Agreement from Template**

Settings:
- **Title:** `Economy3 Provenance Attestation — Test Run`
- **One Time Run:** ON (this is a single test execution)
- **Aggregate Execution:** OFF
- **Who can Execute:** Anyone (for local testing)

Roles (2 required):

| Role ID | Description | Qualification |
|---------|-------------|---------------|
| `spender` | Brand / buyer parking base units | Any |
| `executor` | Economy3 Gateway (you, for testing) | Any |

Input Rules — map the two inputs from `runtime_input_signature.json`:
- `consumed_inputs.logs` → **Executor Provided** (you will supply the blob hashes at execution time)
- `consumed_inputs.spender_allocations` → **Provided by Role: spender** (the parked spend)

Save the agreement.

---

## Step 5 — Park a spend as the spender

In the app as the spender agent:

**Home → Interact with Smart Agreement → [find your agreement] → Park Spend**

Park **4 Base Units** — one per expected attestation log.

---

## Step 6 — Execute the agreement

As the executor:

**Home → Interact with Smart Agreement → [find your agreement] → Execute**

When prompted for `consumed_inputs.logs`, provide the 4 blob hashes from Step 2:

```json
[
  "<hash of blob_1>",
  "<hash of blob_2>",
  "<hash of blob_3>",
  "<hash of blob_4>"
]
```

The `spender_allocations` will be drawn from the parked spend automatically.

Execute.

---

## Step 7 — Verify the RAVE output

The RAVE should show:

```json
{
  "unyt_allocation": [
    { "receiver": "uhCAkProducerAlice1111111111111111111111111111111111111111", "amounts": ["1", "0", "0"] },
    { "receiver": "uhCAkProducerBob22222222222222222222222222222222222222222222", "amounts": ["1", "0", "0"] },
    { "receiver": "uhCAkCoopNairobi333333333333333333333333333333333333333333", "amounts": ["1", "0", "0"] }
  ],
  "computed_values": {
    "total_attested": 3,
    "skipped_authority_only": 1,
    "returned_to_spender": "1"
  }
}
```

Note: `uhCAkProducerDave444...` (blob 4, tier 3) should NOT appear in `unyt_allocation`.

---

## What you're confirming

1. The RAVE engine runs the Rhai code correctly
2. Tier 3 records are excluded from public credit allocation
3. The parked spend for the skipped record is returned to the spender
4. Each producer's `creator_did` is used directly as the receiver address
5. The `computed_values` totals are correct

---

## If something goes wrong

| Symptom | Likely cause |
|---------|-------------|
| Template won't save | Input/output schema JSON syntax error — validate the JSON first |
| Execution fails with missing input | `consumed_inputs.logs` input rule not set to Executor Provided |
| All 4 records earn credit | Tier 3 check in execution code not running — verify `privacy_tier` field is present in blob |
| `returned_to_spender` is wrong | `add_fuel` Rhai function call — check Rhai version compatibility |
what is this?
