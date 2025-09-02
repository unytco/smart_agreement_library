let unyt_index = "1";
let state = #{
    "0xeth_mainnet": "0",
    "0xeth_rinkeby": "0",
    "0xpolygon_mainnet": "0"
};
let unyt_allocation = [];
// Function definitions first
fn deposit_logic(consumed_inputs, unyt_allocation, state, unyt_index) {
    // use the output of this agreement to update it based on the input
    for pod in consumed_inputs.proof_of_deposit.data {
        // find the contract this is going to touch
        let contract_address = pod.contract_address;
        let amount = state[contract_address];
        if pod.method == "deposit" {
            let new_amount = pod.amount;
            amount = add_fuel(amount, new_amount);
        } else if pod.method == "withdraw" {
            let new_amount = pod.amount;
            amount = sub_fuel(amount, new_amount);
        } 
        state[contract_address] = amount;
        let amounts = #{};
        amounts[unyt_index] = pod.amount; 
        unyt_allocation.push(#{
            "receiver": pod.depositor_wallet_address,
            "amounts": amounts,
            "source": consumed_inputs.proof_of_deposit.link_hash
        });
    }
    return #{
        "unyt_allocation": unyt_allocation, 
        "state": state
    };
}

// todo
fn withdraw_logic() {}

// Main execution code
// This agreement is going to have two types of spend links
// The bridging agent will be attaching spend links with POD to send to the depositor
// The withdrawer will be attaching spend links with ?? to send to the depositor
if type_of(inputs.previous_execution.data) == "map" {
    state = inputs.previous_execution.data.output.carryover;
}


let updated_state = deposit_logic(consumed_inputs, unyt_allocation, state, unyt_index);

let unyt_allocation = updated_state.unyt_allocation;
let state = updated_state.state;

return #{
    "unyt_allocation": unyt_allocation,
    "carryover": state
};

// if consumed_inputs.method == "deposit" {

//     // The proof of deposit contains
//     // - chain_id: string // Eth, polygon
//     // - tx_hash: 
//     // - timestmap/block_id: ?
//     // - assest_id: HOT, HOT's contract ID
//     // - amount of units:
//     // - target_agent_key: string
//     // Optional: smart contract identifier

// // logic:
// // validated asset
// // amount in spend link matches the execution request
// // not double spend (done but the DNA since we use a consumable link)

// // send/assign units to target agent

// // output:
// // allocaiton
// // caryover: 
// // {
// //      external units pre smart contract
// //     "blockchain_contract": "balance change"
// // }
// // consumed_spend_link
// // - get the prev_rave_hash from the ea_id carry over data
// // - adjust it with the new allocation
// // - add that to the output

// } else if consumed_inputs.method == "withdraw" {
// // tansfer out

// // Check cooldown period
// // - check the holdings 6 hours ago
// // - subtract it with any spends in the last 6 hours
// // it should not be greater than the amount that is been trying to be withdraw


// // smart contract needs:
// // - 2 of 3 sig
// // - bridge agent
// // - clearing house auditor
// // - any from a list of predefine notarys


// } else {
//     error("Invalid method");
// }