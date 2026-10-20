// if there is a credit adjustment add it to the fixed credit limit
let amount = inputs.credit_limit.data;
let special_agents = inputs.special_agents.data;
let executor_pub_key = executor_pub_key;
for credit_adjustment_execution in inputs.credit_adjustment_execution.data {
    if type_of(credit_adjustment_execution) == "map" {
        amount = add_units(amount, credit_adjustment_execution.output.credit_limit);
    }
}

if executor_pub_key in special_agents {
    amount = add_units(amount, special_agents[executor_pub_key]);
}

return  #{
    "output": #{
        "credit_limit":  amount
    }
};  