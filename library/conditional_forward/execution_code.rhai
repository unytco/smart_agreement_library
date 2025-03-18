/// Subject: Example of a conditional forward
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// spender: the agent that is spending the unyt_allocation and to whom the unyt_allocation will be returned if it is not in the whitelisted_receiver
/// 
/// Summary:
///

for i in 0..unyt_allocation.len {
  if !condition {
    unyt_allocation[i].agent = spender;
  }
}

return #{
  "unyt_allocation": unyt_allocation
}