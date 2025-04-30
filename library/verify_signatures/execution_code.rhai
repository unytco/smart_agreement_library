let total_amount = 0;
let merged_allocations = [];
let error_message = "unset";
let is_valid;
for record in spend_data {
    try {
        is_valid = hdi_verify_record_signature(record);
        let allocation = parse_record_to_parked_amount_and_proof(record);
        
        merged_allocations.push(#{
            "receiver": receiver,
            "amount": allocation.amount,
            "proof": allocation.proof
        });
        total_amount += parse_float(allocation.amount[0]);
    
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