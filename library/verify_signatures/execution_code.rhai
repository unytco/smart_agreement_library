let total_amount = 0;
let merged_allocations = [];
let error_message = "unset";
let test_allocations = "unset";
let check = 0;
let is_valid;
for record in spend_data {
    try {
        is_valid = hdi_verify_record_signature(record);
        let allocations = parse_record_to_parked_spend_allocations(record);
        
        for allocation in allocations {
            merged_allocations.push(allocation);
            total_amount += parse_int(allocation.amount[0]);
        }
        check += 1;
        test_allocations = allocations;
    } catch(error) {
        // print("Error parsing record: " + error);
        error_message = error;
        continue;
    }
}

return #{
  "unyt_allocation": merged_allocations,
  "computed_values": #{
      "total_amount": total_amount,
      "signature_valid": is_valid,
      "error": if !is_valid { "Invalid signature" } else { "" },
      "spend_data": spend_data,
  }
};