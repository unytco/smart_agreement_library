/// Subject: Example of a POS invoice manager
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// pos: the pos to be checked
/// 
/// Summary:
/// This is a simple return of the unyt_allocation

// check type of unyt_allocation
let unyt_allocation = [];
for a in consumed_inputs.allocation.data {
  unyt_allocation.push(#{
    "receiver": inputs.receiver.data,
    "amount": a.amount,
    "source": a.source
  });
}

return #{
  "unyt_allocation": unyt_allocation,
  "computed_values": #{
    "pos": inputs.pos.data,
  }
}