/// Subject: Example of an aggregate receive
/// 
/// Inputs:
/// allocation: a list of allocations
/// 
/// Summary:
/// Here the input expected is a list of allocations attaches the receiver for the fees
///
///
/// A total amount is passed back as the computed_values
let total_amount = "0";
let merged_allocations = [];
        
for a in consumed_inputs.spender_allocations {
    merged_allocations.push(#{
        "receiver": inputs.receiver.data,
        "amounts": a.data.amount,
        "sources": [a.data.source]
    });
    // Fees accrue per unit, so every unit in the allocation counts toward the
    // total. Summed with exact fuel arithmetic (add_fuel) — an f64 accumulation
    // drifts on the fractional amounts a percentage produces.
    for unit_amount in a.data.amount.values() {
        total_amount = add_fuel(total_amount, unit_amount);
    }
}

return #{
  "output": #{
        "unyt_allocation": merged_allocations,
        "computed_values": #{
            "total_amount": total_amount,
        }
    }
};
