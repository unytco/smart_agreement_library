/// Subject: Example of an aggregate receive
/// 
/// Inputs:
/// promised_data: a list of parked_promise links
/// 
/// Summary:
/// Here the input expected is a list of parked_promise links
/// we use the parse_record_to_parked_promise_allocations function to parse the parked_promise links
/// Note: the parse_record_to_parked_promise_allocations functions is a function that is defined in the rave_library/library/parked_promise_manager/execution_code.rhai file
/// it is a helper function that is provided by the RHAI Engine that we are using within the dan
///
/// Then we loop through the links and collect the amount allocated in the links
///
/// This allocated amount is passed back as the unyt_allocation
///
/// We also compute the total amount of the parked_promise links
///
/// This total amount is passed back as the computed_values
let total_amount = 0;
let merged_allocations = [];
let error_message = "unset";
for record in promised_data {
    try {
        let allocations = parse_record_to_parked_promise_allocations(record);
        
        for allocation in allocations {
            merged_allocations.push(allocation);
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
      "total_amount": total_amount
  }
};