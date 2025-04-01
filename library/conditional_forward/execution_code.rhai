/// Subject: Example of a conditional forward
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// return_address: the agent that is spending the unyt_allocation and to whom the unyt_allocation will be returned if it is not in the whitelisted_receiver
/// 
/// Summary:
///

if !condition {
  receiver = return_address;
}

return #{
  "unyt_allocation": [
    #{
      "receiver": receiver,
      "amount": allocation.amount,
      "proof": allocation.proof
    }
  ]
}