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
        
for a in allocation {
    merged_allocations.push(#{
        "receiver": receiver,
        "amount": a.amount,
        "proof": a.proof
    });
    total_amount += parse_int(a.amount[0]);
}

return #{
  "unyt_allocation": merged_allocations,
  "computed_values": #{
      "total_amount": total_amount,
  }
};