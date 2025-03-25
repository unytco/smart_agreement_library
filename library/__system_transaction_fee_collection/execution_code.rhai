/// Subject: Example of an aggregate receive
/// 
/// Inputs:
/// spend_data: a list of parked_spend links
/// 
/// Summary:
/// Here the input expected is a list of parked_spend links
/// we use the parse_record_to_parked_spend_allocations function to parse the parked_spend links
/// Note: the parse_record_to_parked_spend_allocations functions is a function that is defined in the rave_library/library/parked_spend_manager/execution_code.rhai file
/// it is a helper function that is provided by the RHAI Engine that we are using within the dan
///
/// Then we loop through the links and collect the amount allocated in the links
///
/// This allocated amount is passed back as the unyt_allocation
///
/// We also compute the total amount of the parked_spend links
///
/// This total amount is passed back as the computed_values
let total_amount = 0;
let merged_allocations = [];
let error_message = "none";
for record in spend_data {
    try {
        let allocations = parse_record_to_parked_spend_allocations(record);
        
        for allocation in allocations {
            if !allocation.contains("receiver") {
                merged_allocations.push(#{
                    "receiver": receiver,
                    "amount": allocation.amount,
                    "proof": allocation.proof
                });
            } else {
                merged_allocations.push(allocation);
            }
            total_amount += parse_int(allocation.amount[0]);
        }
    } catch(error) {
        error_message = error;
        continue;
    }
}

return #{
  "unyt_allocation": merged_allocations,
  "computed_values": #{
      "total_amount": total_amount,
      "error": error_message
  }
};