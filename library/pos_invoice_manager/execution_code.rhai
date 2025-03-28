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

// check type of unyt_allocation
let allocations = [];
if unyt_allocation.len > 0 {
  if type_of(unyt_allocation[0]) == "array" {
      // needs to be flatterened since this agreement is 
        for allocation in unyt_allocation {
            for a in allocation {
                allocations.push(a);
            }
        }
    } else {
        allocations = unyt_allocation;
    }
}

return #{
  "unyt_allocation": allocations,
  "computed_values": #{
    "pos": pos
  }
}