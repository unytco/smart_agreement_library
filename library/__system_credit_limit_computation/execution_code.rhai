// if there is a credit adjustment add it to the fixed credit limit
let amount = inputs.credit_limit.data;
for credit_adjustment_execution in inputs.credit_adjustment_execution.data {
    if type_of(credit_adjustment_execution) == "map" {
        amount = add_units(amount, credit_adjustment_execution.output.credit_limit);
    }
}

return  #{
    "output": #{
        "credit_limit":  amount
    }
};  