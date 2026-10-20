// An amount is a whole number of millionths, so a share rounds down to one
// and the remainder goes to nobody.
fn millionths(amount) {
    let parts = amount.split(".");
    let fraction = if parts.len() == 2 { parts[1] } else { "" };
    if parts.len() > 2 || parts[0] == "" || fraction.len() > 6 {
        throw "special_credit_limit holds " + amount + ", not a decimal of at most 6 places";
    }
    for digit in parts[0] + fraction {
        if digit < '0' || digit > '9' {
            throw "special_credit_limit holds " + amount + ", not a decimal of at most 6 places";
        }
    }
    parse_int(parts[0]) * 1000000 + parse_int((fraction + "000000").sub_string(0, 6))
}

fn share_of(total, agents) {
    let share = #{};
    for unit in total.keys() {
        let each = millionths(total[unit]) / agents;
        share[unit] = `${each / 1000000}.${(1000000 + each % 1000000).to_string().sub_string(1)}`;
    }
    share
}

// if there is a credit adjustment add it to the fixed credit limit
let amount = inputs.credit_limit.data;
let executor_pub_key = executor_pub_key;
for credit_adjustment_execution in inputs.credit_adjustment_execution.data {
    if type_of(credit_adjustment_execution) == "map" {
        amount = add_units(amount, credit_adjustment_execution.output.credit_limit);
    }
}

let special_agents = inputs.special_agents.data;
for special_agent in special_agents {
    if special_agent == executor_pub_key {
        amount = add_units(amount, share_of(inputs.special_credit_limit.data, special_agents.len()));
    }
}

return  #{
    "output": #{
        "credit_limit":  amount
    }
};  