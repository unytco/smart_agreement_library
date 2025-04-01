/// Subject: Example of a filter for whitelisting
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// whitelisted_receiver: an array of whitelisted agents that are allowed to receive the unyt_allocation
/// return_address: the agent that is spending the unyt_allocation and to whom the unyt_allocation will be returned if it is not in the whitelisted_receiver
/// 
/// Summary:
/// we check the the receiver of the unyt_allocation against the whitelisted_receiver
/// if the receiver is in the whitelisted_receiver, then we forward the transaction
/// else if the receiver is not in the whitelisted_receiver, then we reject the transaction
const zero = 0;

let final_receiver = return_address;

for agent in whitelisted_receiver {
  if receiver == agent {
    final_receiver = receive;
  }
}


return #{
  "unyt_allocation": [
    #{
      "receiver": final_receiver,
      "amount": allocation.amount,
      "proof": allocation.proof
    }
  ]
}