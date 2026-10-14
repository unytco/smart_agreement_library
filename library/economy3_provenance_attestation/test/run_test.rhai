// Local test harness for economy3_provenance_attestation RAVE logic.
// Simulates get_data_blob() and add_fuel() since we're outside the Unyt runtime.

// ── Mock get_data_blob ────────────────────────────────────────────────────────
fn get_data_blob(hash) {
    let blobs = #{
        "blob_1": #{ record_id: "E3-20260412-001", material: "Upland Cotton",        step: "harvest", creator_did: "uhCAkProducerAlice", qty: 500, unit: "KG", privacy_tier: 0 },
        "blob_2": #{ record_id: "E3-20260412-002", material: "Merino Wool",           step: "shear",   creator_did: "uhCAkProducerBob",   qty: 120, unit: "KG", privacy_tier: 1 },
        "blob_3": #{ record_id: "E3-20260412-003", material: "Upland Cotton",         step: "gin",     creator_did: "uhCAkCoopNairobi",   qty: 480, unit: "KG", privacy_tier: 2 },
        "blob_4": #{ record_id: "E3-20260412-004", material: "Wool and Luxury Fibres",step: "handoff", creator_did: "uhCAkProducerDave",  qty: 200, unit: "KG", privacy_tier: 3 },
    };
    blobs[hash]
}

// ── Mock add_fuel (string integer addition) ───────────────────────────────────
fn add_fuel(a, b) {
    let result = parse_int(a) + parse_int(b.amount);
    result.to_string()
}

// ── Mock inputs (mirrors runtime_input_signature.json) ───────────────────────
let consumed_inputs = #{
    logs: [
        #{ data: "blob_1" },
        #{ data: "blob_2" },
        #{ data: "blob_3" },
        #{ data: "blob_4" },
    ],
    spender_allocations: [
        #{ data: #{ amount: "1", source: "spend_src_1" } },
        #{ data: #{ amount: "1", source: "spend_src_2" } },
        #{ data: #{ amount: "1", source: "spend_src_3" } },
        #{ data: #{ amount: "1", source: "spend_src_4" } },
    ],
};

// ── RAVE execution code (copied verbatim from execution_code.rhai) ────────────
let unyt_allocation = [];
let total_attested = 0;
let skipped_authority_only = 0;
let returned_to_spender = "0";

for (log, i) in consumed_inputs.logs {
    let allocation = consumed_inputs.spender_allocations[i].data;
    let fact = get_data_blob(log.data);

    if fact.privacy_tier == 3 {
        skipped_authority_only += 1;
        returned_to_spender = add_fuel(returned_to_spender, allocation);
        continue;
    }

    let credit_amount = "1";

    unyt_allocation.push(#{
        "receiver": fact.creator_did,
        "amounts": [credit_amount, "0", "0"],
        "sources": [allocation.source]
    });

    total_attested += 1;
}

// ── Print results ─────────────────────────────────────────────────────────────
print("=== RAVE OUTPUT ===");
print(`total_attested:         ${total_attested}`);
print(`skipped_authority_only: ${skipped_authority_only}`);
print(`returned_to_spender:    ${returned_to_spender}`);
print("");
print("unyt_allocation:");
for entry in unyt_allocation {
    print(`  receiver: ${entry.receiver}  amount: ${entry.amounts[0]}`);
}
print("");
print("PASS: tier-3 record excluded =  " + (skipped_authority_only == 1));
print("PASS: credits issued         =  " + (total_attested == 3));
print("PASS: spend returned         =  " + (returned_to_spender == "1"));
