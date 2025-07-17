/// Subject: Example of a POS invoice manager
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// pos: the pos to be checked
/// 
/// Summary:
/// This is a simple return of the unyt_allocation

// todo: verify pos
let a = inputs.pos;

// check type of unyt_allocation
let unyt_allocation = [];
for a in consumed_inputs.allocation {
  unyt_allocation.push(#{
    "receiver": inputs.receiver[0].data,
    "amount": a.data.amount,
    "source": a.data.source
  });
}

return #{
  "unyt_allocation": unyt_allocation,
  "computed_values": #{
    "pos": inputs.pos[0].data,
  }
}