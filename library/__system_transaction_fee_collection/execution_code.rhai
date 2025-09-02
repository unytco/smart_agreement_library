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
let total_amount = 0;
let merged_allocations = [];
        
for a in consumed_inputs.spender_allocations {
    merged_allocations.push(#{
        "receiver": inputs.receiver.data,
        "amounts": a.data.amount,
        "source": a.data.source
    });
    total_amount += parse_float(a.data.amount["0"]);
}

return #{
  "unyt_allocation": merged_allocations,
  "computed_values": #{
      "total_amount": total_amount,
  }
};