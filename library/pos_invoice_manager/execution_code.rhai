/// Subject: Example of a POS invoice manager
/// 
/// Inputs:
/// allocations: the allocations to be checked
/// pos: the pos to be checked
/// 
/// Summary:
/// This is a simple return of the unyt_allocation

// todo: verify pos
let a = pos;

return #{
  "unyt_allocations": allocations,
  "computed_values": #{
    "pos": pos
  }
}