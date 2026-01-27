// list of contract addresses for bridging into yolofuel
let state = #{
    "0xholofuel_testnet": "0",
    "0xtf_testnet": "0",
};
// Function definitions first
fn deposit_logic(consumed_inputs, state) {
    let deposit_unyt_index = "1";
    let unyt_allocation = [];
    // use the output of this agreement to update it based on the input
    for pod_link in consumed_inputs.proof_of_deposit {
        for pod in pod_link.data {
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
            amounts[deposit_unyt_index] = pod.amount; 
            unyt_allocation.push(#{
                "receiver": pod.depositor_wallet_address,
                "amounts": amounts,
                "sources": [pod_link.link_hash]
            });
        }
    }
    return #{
        "unyt_allocation": unyt_allocation, 
        "state": state
    };
}

fn withdraw_logic(consumed_inputs, state, ea_id, executed_timestamp, cool_down_period, executor_pub_key) {
    let withdraw_unyt_index = "0";
    // Path to transfer out
    // Check Cool-Down period
    // - check the holdings 6 hours ago
    // - subtract it with any spends in the last 6 hours
    // it should not be greater than the amount that is been trying to be withdraw

    // Get the spend links for the last 6 hours
    let unyt_allocation = [];
    let rejected_links = [];
    for allocation in consumed_inputs.withdrawer_allocations {
        // if  custom_logic_for_withdraw(
        //     allocation.link_hash,
        //     ea_id,
        //     executed_timestamp,
        //     cool_down_period, // in seconds
        //     withdraw_unyt_index,
        // ) {
            let found_contract_address = false;
            let contract_address;
            for addresses in consumed_inputs.withdraw_contract_address {
                // this is to match the request with the appropriate contract address
                if addresses.link_hash == allocation.link_hash {
                    found_contract_address = true;
                    contract_address = addresses.data;
                    break;
                }
            }
            let amount = state[contract_address];
            if type_of(amount) == "string" {
                let spent_amount = allocation.data.amount;
                amount = sub_fuel(amount, spent_amount[withdraw_unyt_index]);
                // if is_greater_than_eq(amount, "0") {

                // unique to the requestor side to let you withdraw credit
                // This means that there can be withdrawals can get the amount go to negative 
                // since its the credit of the yolofuel network that is being used to withdraw   
                state[contract_address] = amount;
                    unyt_allocation.push(#{
                        "receiver": executor_pub_key,
                        "amounts": spent_amount,
                        "sources": [allocation.link_hash]
                    });
                break;
                // } else {
                //     rejected_links.push(#{
                //         "hash": allocation.link_hash,
                //         "reason": "Failed to withdraw: the contract needs to hold a balance for the expected amount"
                //     });
                // }
            } else {
                rejected_links.push(#{
                    "hash": allocation.link_hash,
                    "reason": "Failed to withdraw: contract_address (" + contract_address + ") is invalid or does not have any balance"
                });
               
            }
        // } else {
        //     rejected_links.push(#{
        //         "hash": allocation.link_hash,
        //         "reason": "Failed to withdraw: the users needs to hold a balance for the unyt for the cool down period"
        //     });           
        // }
    }
    return #{
        "unyt_allocation": unyt_allocation, 
        "state": state,
        "rejected_links": rejected_links
    };
    // Additional Notes:
    // After the output is created, the withdrawer will need to request signatures 
    // from the 3 agents to sign the output which can be used to claim the funds from the outside chain
    // Requires 2 of 3 signatures
    // Signers:
    // - bridge agent
    // - clearing house auditor
    // - any from a list of predefine notaries

}

// Main execution code
// This agreement is going to have two types of spend links
// The bridging agent will be attaching spend links with POD to send to the depositor
// The withdrawer will be attaching spend links with ?? to send to the depositor
if type_of(inputs.previous_execution.data) == "map" {
    state = inputs.previous_execution.data.output.carryover;
}

if inputs.call_method.data == "deposit" {
    let updated_state = deposit_logic(consumed_inputs, state);
    return #{
        "output": #{
            "unyt_allocation": updated_state.unyt_allocation,
            "carryover": updated_state.state,
        }
    };
} else if inputs.call_method.data == "withdraw" {
    let updated_state = withdraw_logic(consumed_inputs, state, ea_id, executed_timestamp, inputs.cool_down_period.data, executor_pub_key);
    if updated_state.unyt_allocation.is_empty {
        throw "Failed to withdraw: No valid unyt allocation to process in yolofuel network "+ updated_state;
    }
    return #{
        "output": #{
            "unyt_allocation": updated_state.unyt_allocation,
            "carryover": updated_state.state,
        },
        "rejected_links": updated_state.rejected_links
    };
} else {
    throw "Invalid call method: "+ inputs.call_method.data;
}