/// Subject: This is for the Demo Aug 9
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// work_proof: the work_proof to be checked
/// 
/// Summary:
/// This is a simple return of the unyt_allocation

// what do you want to do with the work_proof?
// we could have a signature here and then verify its signature
// or we could calculate if the invoiced amount is correct based on the stats that are provided in the work_proof
let todo = inputs.work_proof;

// check type of unyt_allocation
let final_unyt_allocation = [];
let spender_unyt_allocation = consumed_inputs.spender_allocations;

let invoice_gateway_unyt_allocation = [];
for (value, count) in consumed_inputs.invoice_gateway_allocations_invoice {
  let invoice_amount = value.data.amount;
  
  // Find the index of the spend that will cover the invoice amount
  let spender_index = spender_unyt_allocation.index_of(|a| parse_float(a.data.amount["0"]) >= parse_float(invoice_amount["0"]));

  if spender_index >= 0 {
    let spender_amount = spender_unyt_allocation[spender_index];
    
    final_unyt_allocation.push(#{
      "receiver": consumed_inputs.receiver[count].data,
      "amounts": invoice_amount,
      "source": spender_amount.link_hash
    });
    
    // Calculate the remaining amount
    let remaining_amount = sub_units(spender_amount.data.amount, invoice_amount);
    
    // Update the element in place with the remaining amount
    spender_unyt_allocation[spender_index].data.amount = remaining_amount;
    
  } else {
    throw "Invoice not paid";
  }
}

return #{
  "output": #{
    "unyt_allocation": final_unyt_allocation
  }
};