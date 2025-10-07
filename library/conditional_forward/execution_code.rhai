/// Subject: Example of a conditional forward
/// 
/// Inputs:
/// allocation: the allocation to be checked
/// return_address: the agent that is spending the unyt_allocation and to whom the unyt_allocation will be returned if it is not in the whitelisted_receiver
/// 
/// Summary:
///

let receiver = consumed_inputs.return_address.data;
if inputs.condition_met.data {
  receiver = consumed_inputs.receiver.data;
}

return #{
  "output": #{
    "unyt_allocation": [
      #{
        "receiver": receiver,
        "amounts": consumed_inputs.spender_allocations.data.amount,
        "sources": [consumed_inputs.spender_allocations.data.source]
      }
    ]
  }
};
