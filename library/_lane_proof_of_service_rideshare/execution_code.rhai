/// Subject: Rideshare agreement
/// 
/// Inputs:
/// spender_allocations: the spender_allocations to be checked
/// condition_met: the condition_met to be checked
///
/// Summary:
///  
/// 1. Itterate over the spender_allocations and create a new unyt_allocation for each spender_allocation
/// 2. Validate the price of the spender_allocation
/// 3. Create a new unyt_allocation for the spender_allocation
/// 4. Return the unyt_allocation


const INDEX_MIN = inputs.index_of_min.data;
const INDEX_KM = inputs.index_of_km.data;
const INDEX_TOLL = inputs.index_of_tolls.data;
const INDEX_SURGE = inputs.index_of_surge.data;

const PRICE_PER_KM = 1;
const PRICE_PER_MIN = 2;
const SERVICE_FEES = 1;

// itterate over the spender_allocations and create a new unyt_allocation for each spender_allocation
let unyt_allocations = [];
for (spender_link, index) in consumed_inputs.spender_allocations {

  // validate price of the spender_allocation
  let price_km = (round(parse_float(spender_link.data.amount[INDEX_KM]) * PRICE_PER_KM * 100) / 100);
  let price_min = (round(parse_float(spender_link.data.amount[INDEX_MIN]) * PRICE_PER_MIN * 100) / 100);
  let price_tolls = parse_float(spender_link.data.amount[INDEX_TOLL]);
  let surge_multiplier = parse_float(spender_link.data.amount[INDEX_SURGE]);
  
  let price = ((-price_km) + (-price_min) + (-price_tolls))  * (-surge_multiplier);

  let final_price = (round(price * 100) / 100) + SERVICE_FEES; // round to 2 decimal places

  let validate_price = parse_float(spender_link.data.amount["0"]) == final_price;

  if inputs.condition_met.data && validate_price {
    let amount = sub_units(spender_link.data.amount, #{
      "0": SERVICE_FEES.to_string()
    });
    unyt_allocations.push(#{
      "receiver": consumed_inputs.receiver[index].data,
      "amounts": amount,
      "sources": [spender_link.data.source]
    });
    unyt_allocations.push(#{
      "receiver": inputs.service_agent_address.data,
      "amounts": #{
        "0": SERVICE_FEES.to_string()
      },
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
