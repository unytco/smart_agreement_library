let unyt_index = "0";

let amount = "0";
if type_of(inputs.previous_execution.data) == "map" {
    amount = inputs.previous_execution.data.output.credit_limit[unyt_index];
}

// use the output of this agreement to update it based on the input
for pod in consumed_inputs.proof_of_deposit {
    
    if pod.data.method == "deposit" {
        let new_amount = pod.data.amount;
        amount = add_fuel(amount, new_amount);
    } 
    else if pod.data.method == "withdraw" {
        let new_amount = pod.data.amount;
        amount = sub_fuel(amount, new_amount);
    } 
    else {
        error("Invalid method");
    }
}

// INDEX of the external unyt that the credit limit is adjusted for
let credit_limit = #{};
credit_limit[unyt_index] = amount;

return #{
    "output": #{
        "credit_limit": credit_limit
    }
};
