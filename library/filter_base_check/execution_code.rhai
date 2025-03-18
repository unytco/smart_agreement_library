/// Subject: Example of a filter for base value check
/// 
/// Inputs:
/// unyt_allocation: the unyt_allocation to be checked
/// 
/// Summary:
/// we check the the base value of the unyt_allocation against the sum of the service units
/// if the base value is not equal to the sum of the service units, then we remove it from the unyt_allocation
/// 
/// We will return the unyt_allocation with the base value checked
const base_value_per_service_unit_1 = 1;
const base_value_per_service_unit_2 = 2;

let checked_unyt_allocation = [];

for piece in unyt_allocation {
  let service_unit_1_value = parse_int(piece.amount[1]) * base_value_per_service_unit_1;
  let service_unit_2_value = parse_int(piece.amount[2]) * base_value_per_service_unit_2;

  // promises have a negative value for the service units 
  // so remember to handle that when verifying value
  service_unit_1_value = service_unit_1_value * -1;
  service_unit_2_value = service_unit_2_value * -1;

  const expected_base_value = service_unit_1_value + service_unit_2_value;

  if expected_base_value == parse_int(piece.amount[0]) {
    // value verified so we forward the amount to the original receiver
    checked_unyt_allocation.push(piece);
  } else {
    // forwarding the amount back to the spender
    let updated_piece = piece;
    updated_piece.agent = spender;
    checked_unyt_allocation.push(updated_piece);
  }
}

return #{
  "unyt_allocation": checked_unyt_allocation
}