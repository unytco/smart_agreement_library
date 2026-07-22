/// Subject: Example of a POS invoice manager
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// 
/// Summary:
/// This is a simple return of the unyt_allocation

// check type of unyt_allocation
let unyt_allocation = [];
for a in consumed_inputs.spender_allocations {
  unyt_allocation.push(#{
    "receiver": inputs.receiver.data,
    "amounts": a.data.amount,
    "sources": [a.data.source]
  });
}

return #{
  "output": #{
    "unyt_allocation": unyt_allocation
  }
}