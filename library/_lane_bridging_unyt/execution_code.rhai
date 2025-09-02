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
fn withdraw_logic(consumed_inputs, ea_id, unyt_index) {
    // Path to transfer out
    
    // Check Cool-Down period
    // - check the holdings 6 hours ago
    // - subtract it with any spends in the last 6 hours
    // it should not be greater than the amount that is been trying to be withdraw

    // Get the spend links for the last 6 hours
    if  custom_logic_for_withdraw(
        allocation.link_hash,
        ea_id,
        360, // mins -> 6 hours
        unyt_index,
    ) {
        let amount = state[consumed_inputs.withdraw_contract_address];
        if type_of(amount) == "string" {
            let spent_amount = consumed_inputs.withdrawer_agent_allocations.data.amount;
            amount = sub_fuel(amount, spent_amount);
            state[consumed_inputs.withdraw_contract_address] = amount;
            unyt_allocation.push(#{
                "receiver": executor_pub_key,
                "amounts": spent_amount,
                "source": consumed_inputs.withdrawer_agent_allocations.data.source
            });

            return #{
                "unyt_allocation": unyt_allocation, 
                "state": state
            };
        
        } else {
            error("Failed to withdraw: contract_address does not have any balance");
        }
    }else {
        error("Failed to withdraw: the users needs to hold a balance for the unyt for atleast 6 hours");
    }

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

let updated_state = #{};
if is_def_var(consumed_inputs.bridging_agent_allocations) {
    updated_state = deposit_logic(consumed_inputs, unyt_allocation, state, unyt_index);
} else if is_def_var(consumed_inputs.withdrawer_agent_allocations) {
    updated_state = withdraw_logic(consumed_inputs, ea_id, unyt_index);
} else {
    error("Invalid input");
}

let unyt_allocation = updated_state.unyt_allocation;
let state = updated_state.state;

return #{
    "unyt_allocation": unyt_allocation,
    "carryover": state
};
