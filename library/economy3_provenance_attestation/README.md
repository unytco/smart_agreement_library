# Economy3 Provenance Attestation Credit

## What This Is

A Unyt Smart Agreement that issues 1 E3 attestation credit to a producer each time they sign a verified provenance record in the Economy3 Heritage app.

**The economic loop:**
1. A brand/buyer parks N E3 base units against this agreement — one per expected attestation in their supply chain.
2. The Economy3 Gateway (automated executor) harvests SignedFact logs from PostgreSQL (primary) or the Holochain DHT when a conductor is available.
3. For each valid log, the producer identified by `creator_did` receives 1 E3.
4. Authority-only records (privacy tier 3) are excluded — their parked spend is returned to the brand.

## Roles

| Role | Who | What they do |
|------|-----|--------------|
| `spender` | Brand / buyer | Parks Base Unit spend against this agreement |
| `executor` | Economy3 Gateway | Harvests logs, runs RAVE execution |
| Receiver (implicit) | Producer / artisan | Accepts credit once allocated |

## SignedFact Log Blob Format

Each log data blob is a JSON object with these fields:

```json
{
  "record_id":     "E3-20260403-001",
  "resource_hash": "abc123...",
  "material":      "Upland Cotton",
  "step":          "harvest",
  "creator_did":   "uhCAk...",
  "qty":           500,
  "unit":          "KG",
  "privacy_tier":  0
}
```

`step` values: `plant` | `grow` | `harvest` | `process` | `pack` | `handoff`

## Credit Logic (v1)

- **1 E3 per attestation**, regardless of material, quantity, or step.
- Future versions can weight by step or material using a `price_sheet` data blob (see `holo_hosting_proof_of_service` for that pattern).

## Status

Ready for import into a Unyt Alliance once the Holochain Q2 web service ships and the Economy3 `qr_infra` DNA is running on-chain. Currently modeled in Postgres (`credit_ledger` table in economy3-web).
