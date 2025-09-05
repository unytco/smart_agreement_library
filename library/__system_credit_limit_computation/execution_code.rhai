// if there is a credit adjustment add it to the fixed credit limit
if type_of(inputs.credit_adjustment_execution.data.output.credit_limit) == "map" {
    let amount = add_units(inputs.credit_limit.data, inputs.credit_adjustment_execution.data.output.credit_limit);
    return #{
        "output": #{
            "credit_limit": amount
        }
    };
}

return  #{
    "output": #{
        "credit_limit":  inputs.credit_limit.data
    }
};  