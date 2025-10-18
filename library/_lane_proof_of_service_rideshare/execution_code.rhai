/// Subject: Example of a conditional forward
/// 
/// Inputs:
/// allocation: the allocation to be checked
/// return_address: the agent that is spending the unyt_allocation and to whom the unyt_allocation will be returned if it is not in the whitelisted_receiver
/// 
/// Summary:
///


// itterate over the spender_allocations and create a new unyt_allocation for each spender_allocation
let unyt_allocations = [];
for (spender_link, index) in consumed_inputs.spender_allocations {
  if inputs.condition_met.data {
    unyt_allocations.push(#{
      "receiver": consumed_inputs.receiver[index].data,
      "amounts": spender_link.data.amount,
      "sources": [spender_link.data.source]
    });
  } else {
    unyt_allocations.push(#{
      "receiver": consumed_inputs.return_address[index].data,
      "amounts": spender_link.data.amount,
      "sources": [spender_link.data.source]
    });
  }
}

return #{
  "output": #{
    "unyt_allocation": unyt_allocations
  }
};
