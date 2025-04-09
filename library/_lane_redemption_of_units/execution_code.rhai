/// Subject: Execution for _lane_purchase_of_units
/// 
/// Inputs:
/// proof_of_deposit_hash: the hash of the proof of deposit
/// 
/// Summary:
/// The poof_of_deposit is a data blob that contains 
///  - payload:
///    - receiver_wallet_address pubkey
///    - amount of units to purchase
///    - spender_wallet_address: the key that signed the payload
///  - signature: signature of the payload
///    
/// 
/// We will return the unyt_allocation
/// 

// Calculate the total amount that the redeemers would redeem
let total_amount = 0;
for (allocation, i) in allocation {
    total_amount += allocation.amount;
}




let unyt_allocation = [];

for (pod, i) in proof_of_deposit_hash {
    let proof_of_deposit = get_data_blob(pod);
    
    // optional: verify
    let payload = proof_of_deposit.payload;
    let signature = proof_of_deposit.signature;
    let signing_key = payload.spender_wallet_address;
    let check_1 = hdi_verify_signature(signing_key, signature, payload);

    // optional: we can validate the price 
    // code to retrieve current price/conversion rate between 
    // the outside capitalization currency and fuel base unit

    let check_2 = allocation[i].amount == payload.amount;
    if check_1 && check_2 {
        unyt_allocation.push(#{
            "receiver": payload.receiver_wallet_address,
            "amount": allocation[i].amount,
            "proof": allocation[i].proof
        });            
    }
}


return  #{
    "unyt_allocation": unyt_allocation
}; 
