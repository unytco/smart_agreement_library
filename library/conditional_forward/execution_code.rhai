/// Subject: Example of a conditional forward
/// 
/// Inputs:
/// allocation: the allocation to be checked
/// return_address: the agent that is spending the unyt_allocation and to whom the unyt_allocation will be returned if it is not in the whitelisted_receiver
/// 
/// Summary:
///

if !inputs.condition.data {
  receiver = consumed_inputs.return_address.data;
}

return #{
  "unyt_allocation": [
    #{
      "receiver": consumed_inputs.receiver.data,
      "amount": consumed_inputs.spender_allocations.data.amount,
      "source": consumed_inputs.spender_allocations.data.source
    }
  ]
}