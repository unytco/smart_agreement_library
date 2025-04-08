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

let unyt_allocation = [];

for (pod, i) in proof_of_deposit_hash {
    let proof_of_deposit = get_data_blob(pod);
    
    // optional: verify
    let check_1 = hdi_verify_signature(proof_of_deposit.signature, proof_of_deposit.payload, proof_of_deposit.payload.signing_key);

    // optional: we can validate the price 
    // code to retrieve current price/conversion rate between 
    // the outside capitalization currency and fuel base unit

    if check_1 {
        unyt_allocation.push(#{
            "receiver": proof_of_deposit.payload.receiver,
            "amount": allocation[i].amount,
            "proof": allocation[i].proof
        });            
    }
}


return  #{
    "unyt_allocation": unyt_allocation
}; 
