/// Subject: Execution for _lane_purchase_of_units
/// 
/// Inputs:
/// allocation: the allocation of units to redeem
/// redemption_price: the price of the units in the outside currency
/// sales_agent_pubkey: the pubkey of the sales agent
/// 
/// Summary:
/// The allocation is an array of objects that contains 
///  - amount: the amount of units to redeem
///  - source: the source of the units to redeem
///    
/// 
/// We will return the unyt_allocation


// sort the allocation based on the timestamp
let unyt_allocation = [];
let redemption_report = [];
let only_allocation = [];
for allo in consumed_inputs.allocation {
    only_allocation.push(allo.data);
}
let sorted_parked_links = acceding_sort_allocation(only_allocation);
let available_ledger_balance = inputs.sales_agent_balance.data;

// we can accept to pay only a specific amount based on the sales_agent_balance available
// move the oldest allocation to the unyt_allocation to be retrived
// make a log of the spender their fuel_allocation and their expected external currency amount

for (parked_link, i) in sorted_parked_links {
    let updated_balance  = sub_units(available_ledger_balance , parked_link.amount);
    if parse_float(updated_balance["0"]) > 0 {
        break;
    }
    available_ledger_balance = updated_balance;
    unyt_allocation.push(#{
        "receiver": inputs.sales_agent_pubkey.data,
        "amount": parked_link.amount,
        "source": parked_link.source
    });
    redemption_report.push(#{
        "spender": parked_link.spender,
        "fuel_allocation": parked_link.amount,
        "expected_external_currency_amount": `${parse_float(parked_link.amount["0"]) / inputs.redemption_price.data}`
    });
}


return  #{
    "unyt_allocation": unyt_allocation,
    "computed_values": #{
        "redemption_report": redemption_report,
        "redemption_price": `${inputs.redemption_price.data}`,
    }
}; 
