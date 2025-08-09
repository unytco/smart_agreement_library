/// Subject: Execution for _lane_purchase_of_units
/// 
/// Inputs:
/// proof_of_deposit_hash: the hash of the proof of deposit
/// service_fee_wallet_address: the wallet address of the service fee agent
/// 
/// Summary:
/// The poof_of_deposit is a data blob that contains 
///  - payload:
///    - receiver_wallet_address pubkey
///    - external_currency_amount of units to purchase
///    - conversion_sheet: the conversion rate between the outside capitalization currency and fuel base unit
///    - spender_wallet_address: the key that signed the payload
///  - signature: signature of the payload
/// 
/// Use the conversion_rate from the data blob to convert the external_currency_amount to fuel base unit
/// 
/// We will return the unyt_allocation

let unyt_allocation = [];
let computed_values = [];
for (pod, i) in consumed_inputs.proof_of_deposit_hash {
    let proof_of_deposit = get_data_blob(pod.data);
    
    // optional: verify
    let payload = proof_of_deposit.payload;
    let signature = proof_of_deposit.signature;
    let signing_key = payload.spender_wallet_address;
    let check_1 = hdi_verify_signature(signing_key, signature, payload);

    // optional: we can validate the price 
    // code to retrieve current price/conversion rate between 
    // the outside capitalization currency and fuel base unit
    let conversion_sheet = get_data_blob(payload.conversion_sheet);
    let expected_fuel_base_units = conversion_sheet.hf_per_usd * payload.external_currency_amount;
  
    let check_2 = consumed_inputs.spender_allocations[i].data.amount["0"] == expected_fuel_base_units.to_string();
  
    // optional: build in a service fee;
    let service_fee_percentage = 0.01; // 1%
    let service_fee = expected_fuel_base_units * service_fee_percentage;
    let expected_fuel_base_units_after_fee = expected_fuel_base_units - service_fee;

     if check_1 && check_2 {
        unyt_allocation.push(#{
            "receiver": payload.receiver_wallet_address,
            "amount": #{
                "0": expected_fuel_base_units_after_fee.to_string()
            },
            "source": consumed_inputs.spender_allocations[i].data.source
        });
        unyt_allocation.push(#{
            "receiver": inputs.service_fee_wallet_address.data,
            "amount": #{
                "0": service_fee.to_string()
            },
            "source": consumed_inputs.spender_allocations[i].data.source
        });            
    }
    // for debugging
    computed_values.push(#{
        "check_1": check_1,
        "check_2": check_2,
        "conversion_sheet": conversion_sheet,
        "allocation[i].amount[0]": consumed_inputs.spender_allocations[i].data.amount["0"],
        "external_currency_amount": payload.external_currency_amount,
        "expected_fuel_base_units": expected_fuel_base_units,
        "service_fee": service_fee
    });
}


return  #{
    "unyt_allocation": unyt_allocation,
    "computed_values": computed_values
}; 
