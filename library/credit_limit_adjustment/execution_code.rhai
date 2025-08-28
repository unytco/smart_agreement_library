
let default_contract_list = {
    "0xeth_mainnet": "0",
    "0xpolygon_mainnet": "0"
}

// get the previous execution of this agreement
// todo in the rhai engine
let previous_execution_output = get_previous_execution_output();


// use the output of this agreement to update it based on the input
for pod in consumed_inputs.proof_of_deposit {
    
    if pod.data.method == "deposit" {

        // Contract address used
        let contract_address = pod.data.contract_address;

        let new_amount = pod.data.amount;
        let previous_amount = default_contract_list[contract_address];
        // insert the new amount to the default_contract_list
        default_contract_list[contract_address] = add_fuel(previous_amount, new_amount);

    } else if pod.data.method == "withdraw" {

        // Contract address used
        let contract_address = pod.data.contract_address;

        let new_amount = pod.data.amount;
        let previous_amount = default_contract_list[contract_address];
        // insert the new amount to the default_contract_list
        default_contract_list[contract_address] = sub_fuel(previous_amount, new_amount);

    } else {
        error("Invalid method");
    }
}

return #{
    "carryover_data": default_contract_list
}