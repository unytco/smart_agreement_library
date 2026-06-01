/// Subject: Economy3 Provenance Attestation Credit
///
/// Users:
/// - Brand / Buyer (Spender):
///     Parks spend in Base Units against this agreement to fund producer credits
///     for each verified provenance attestation in their supply chain.
/// - Economy3 Gateway (Executor):
///     Automated agent that harvests SignedFact logs from the DHT (or Postgres
///     bridge) and executes this agreement on behalf of the spender.
/// - Producer / Artisan (Receiver):
///     The smallholder, gin, loom, or factory agent whose signed attestation
///     triggered the credit. Identified by creator_did in the SignedFact payload.
///
/// Inputs:
/// - logs: data blobs, each containing one Economy3 SignedFact:
///     {
///       "record_id":     string,  // Economy3 record ID (e.g. E3-20260403-001)
///       "resource_hash": string,  // Postgres / DHT content hash
///       "material":      string,  // e.g. "Upland Cotton"
///       "step":          string,  // Heritage step: plant | grow | harvest |
///                                 //   process | pack | handoff
///       "creator_did":   string,  // Producer's DID / Holochain agent key
///       "qty":           number,  // quantity attested
///       "unit":          string,  // KG | MT | bale | yard
///       "privacy_tier":  number   // 0=public 1=alias 2=community 3=authorities
///     }
/// - spender_allocations: parked Base Unit spend from the brand, one entry
///   per attestation log, cross-checked against expected credit.
///
/// Credit logic:
/// - 1 E3 attestation credit per SignedFact log.
///   (Future: weight by step, quantity, or material via a price_sheet data blob.)
/// - Privacy tier 3 records are excluded — authority-only records do not earn
///   public credits. Their spend allocation is returned to the spender.
///
/// Summary:
/// 1. Brand parks N E3 base units against this agreement (one per expected attestation).
/// 2. Economy3 Gateway harvests SignedFact logs from the DHT or Postgres bridge.
/// 3. For each valid log, allocate 1 E3 to the producer at creator_did.
/// 4. Return allocations and computed totals (attested, skipped, returned to spender).

let unyt_allocation = [];
let total_attested = 0;
let skipped_authority_only = 0;
let returned_to_spender = "0";

for (log, i) in consumed_inputs.logs {
    let allocation = consumed_inputs.spender_allocations[i].data;
    let fact = get_data_blob(log.data);

    // Exclude authority-only records (privacy_tier == 3).
    // The credit cannot be issued publicly when the record content is sealed.
    // Return the parked spend to the spender for these cases.
    if fact.privacy_tier == 3 {
        skipped_authority_only += 1;
        returned_to_spender = add_fuel(returned_to_spender, allocation.amount);
        continue;
    }

    // 1 E3 attestation credit per verified SignedFact.
    // amounts: [base_units, service_units_1, service_units_2]
    let credit_amount = "1";

    unyt_allocation.push(#{
        "receiver": fact.creator_did,
        "amounts": [credit_amount, "0", "0"],
        "sources": [allocation.source]
    });

    total_attested += 1;
}

return #{
    "output": #{
        "unyt_allocation": unyt_allocation,
        "computed_values": #{
            "total_attested": total_attested,
            "skipped_authority_only": skipped_authority_only,
            "returned_to_spender": returned_to_spender
        }
    }
}
