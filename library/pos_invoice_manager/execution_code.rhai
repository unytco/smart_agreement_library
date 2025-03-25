/// Subject: Example of a POS invoice manager
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// pos: the pos to be checked
/// 
/// Summary:
/// This is a simple return of the unyt_allocation

// todo: verify pos
let a = pos;

return #{
  "unyt_allocation": unyt_allocation,
  "computed_values": #{
    "pos": pos
  }
}