/// Subject: Transaction fee collection
///
/// Inputs:
/// consumed_inputs.spender_allocations: the parked fee spends being swept
/// inputs.receiver: the fee collector, who receives all of them
///
/// Summary:
/// One allocation to the collector: the amounts of every parked spend summed per
/// unit, and every one of their sources.
let amounts = #{};
let sources = [];

for a in consumed_inputs.spender_allocations {
    amounts = add_units(amounts, a.data.amount);
    sources.push(a.data.source);
}

// Nothing parked is nothing to collect, and an allocation of nothing would still
// be written.
let unyt_allocation = [];
if !sources.is_empty() {
    unyt_allocation.push(#{
        "receiver": inputs.receiver.data,
        "amounts": amounts,
        "sources": sources
    });
}

return #{
    "output": #{
        "unyt_allocation": unyt_allocation
    }
};
