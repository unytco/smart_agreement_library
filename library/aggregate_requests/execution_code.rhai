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

// Calculate total available spends
let total_available_spends = #{"0": "0"};
for spender_allocation in spender_unyt_allocation {
  total_available_spends = #{
    "0": add_fuel(total_available_spends["0"], spender_allocation.data.amount["0"])
  };
}

// Calculate total invoiced amount
let total_invoiced = #{"0": "0"};
for (value, count) in consumed_inputs.invoice_gateway_allocations_invoice {
  total_invoiced = #{
    "0": add_fuel(total_invoiced["0"], value.data.amount["0"])
  };
}

let invoice_gateway_unyt_allocation = [];
for (value, count) in consumed_inputs.invoice_gateway_allocations_invoice {
  let invoice_amount = value.data.amount;
  let remaining_invoice_amount = invoice_amount;
  let used_sources = [];
  
  // Try to cover the invoice amount using available spends
  for (spender_allocation, i) in spender_unyt_allocation {
    if parse_float(remaining_invoice_amount["0"]) <= 0 {
      break; // Invoice is fully covered
    }
    
    let available_amount = spender_allocation.data.amount;
    let available_float = parse_float(available_amount["0"]);
    let remaining_float = parse_float(remaining_invoice_amount["0"]);
    
    if available_float > 0 { // Only use spends that have remaining funds
      if available_float >= remaining_float {
        // This spend can cover the remaining invoice amount
        used_sources.push(spender_allocation.link_hash);
        
        // Calculate the remaining amount for this spend
        let remaining_amount = sub_units(available_amount, remaining_invoice_amount);
        spender_unyt_allocation[i].data.amount = remaining_amount;
        
        // Invoice is fully covered
        remaining_invoice_amount = #{"0": "0"};
        break;
      } else {
        // This spend can only partially cover the invoice
        used_sources.push(spender_allocation.link_hash);
        
        // Use the entire amount of this spend
        remaining_invoice_amount = sub_units(remaining_invoice_amount, available_amount);
        
        // This spend is now fully consumed
        spender_unyt_allocation[i].data.amount = #{"0": "0"};
      }
    }
  }
  
  // Check if the invoice was fully covered
  if parse_float(remaining_invoice_amount["0"]) > 0 {
    throw `Invoice not paid - insufficient funds. Total Invoiced: ${total_invoiced["0"]}, Total Available Spends: ${total_available_spends["0"]}`;
  }
  
  // Add the allocation with all used sources
  final_unyt_allocation.push(#{
    "receiver": consumed_inputs.receiver[count].data,
    "amounts": invoice_amount,
    "sources": used_sources
  });
}

// Check if there are excess spends (more available than invoiced)
let total_remaining_spends = #{"0": "0"};
for spender_allocation in spender_unyt_allocation {
  total_remaining_spends = #{
    "0": add_fuel(total_remaining_spends["0"], spender_allocation.data.amount["0"])
  };
}

if parse_float(total_remaining_spends["0"]) > 0 {
  throw `Excess spends detected. Total Invoiced: ${total_invoiced["0"]}, Total Available Spends: ${total_available_spends["0"]}, Remaining Unused Spends: ${total_remaining_spends["0"]}`;
}

return #{
  "output": #{
    "unyt_allocation": final_unyt_allocation
  }
};