/// Subject: Example of a filter for base value check
/// 
/// Inputs:
/// allocation: the allocation to be checked
/// 
/// Summary:
/// we check the the base value of the allocation against the sum of the service units
/// if the base value is not equal to the sum of the service units, then we remove it from the allocation
/// 
/// We will return the allocation with the base value checked
const base_value_per_service_unit_1 = 1;
const base_value_per_service_unit_2 = 2;

let checked_allocation = [];

let service_unit_1_value = parse_float(allocation.amount[1]) * base_value_per_service_unit_1;
let service_unit_2_value = parse_float(allocation.amount[2]) * base_value_per_service_unit_2;

// spends have a negative value for the service units 
// so remember to handle that when verifying value
service_unit_1_value = service_unit_1_value * -1;
service_unit_2_value = service_unit_2_value * -1;

const expected_base_value = service_unit_1_value + service_unit_2_value;

if expected_base_value == parse_float(allocation.amount[0]) {
  // value verified so we forward the amount to the original receiver
  checked_allocation.push(#{
    "receiver": receiver,
    "amount": allocation.amount,
    "proof": allocation.proof
  });
} else {
  // forwarding the amount back to the return_address
  checked_allocation.push(#{
    "receiver": return_address,
    "amount": allocation.amount,
    "proof": allocation.proof
  });
}


return #{
  "unyt_allocation": checked_allocation
}