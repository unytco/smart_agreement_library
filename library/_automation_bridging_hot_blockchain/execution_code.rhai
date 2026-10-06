let unyt_index = "1";
let lock_vault = inputs.lock_vault_address.data;
let state = #{};
state[lock_vault] = "0";
fn deposit_logic(consumed_inputs, state, unyt_index) {
    let unyt_allocation = [];
    for pod_link in consumed_inputs.proof_of_deposit {
        for pod in pod_link.data {
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
                "sources": [pod_link.link_hash]
            });
        }
    }
    return #{
        "unyt_allocation": unyt_allocation, 
        "state": state
    };
}

fn withdraw_logic(consumed_inputs, state, ea_id, unyt_index, executed_timestamp, cool_down_period, executor_pub_key, coupons) {
    let unyt_allocation = [];
    let rejected_links = [];
    let processed_coupons = #{};
    for allocation in consumed_inputs.withdrawer_allocations {
        if !(allocation.link_hash in coupons) {
            rejected_links.push(#{
                "hash": allocation.link_hash,
                "reason": "No coupon provided for this withdrawal"
            });
            continue;
        }
        let found_contract_address = false;
        let contract_address;
        for addresses in consumed_inputs.withdraw_contract_address {
            if addresses.link_hash == allocation.link_hash {
                found_contract_address = true;
                contract_address = addresses.data;
                break;
            }
        }
        let amount = state[contract_address];
        if type_of(amount) == "string" {
            let spent_amount = allocation.data.amount;
            amount = sub_fuel(amount, spent_amount[unyt_index]);
            state[contract_address] = amount;
            unyt_allocation.push(#{
                "receiver": executor_pub_key,
                "amounts": spent_amount,
                "sources": [allocation.link_hash]
            });
            processed_coupons[allocation.link_hash] = coupons[allocation.link_hash];
        } else {
            rejected_links.push(#{
                "hash": allocation.link_hash,
                "reason": "Failed to withdraw: contract_address does not have any balance"
            });
        }
    }
    return #{
        "unyt_allocation": unyt_allocation, 
        "state": state,
        "rejected_links": rejected_links,
        "processed_coupons": processed_coupons
    };
}

if type_of(inputs.previous_execution.data) == "map" {
    state = inputs.previous_execution.data.output.carryover;
    if !(lock_vault in state) {
        throw "The carried state holds no balance for the configured lock vault " + lock_vault;
    }
}

let deposit_result = deposit_logic(consumed_inputs, state, unyt_index);
state = deposit_result.state;
let unyt_allocation = deposit_result.unyt_allocation;

let withdraw_result = withdraw_logic(
    consumed_inputs, state, ea_id, unyt_index,
    executed_timestamp, inputs.cool_down_period.data,
    executor_pub_key, inputs.coupons.data
);
state = withdraw_result.state;
for alloc in withdraw_result.unyt_allocation {
    unyt_allocation.push(alloc);
}

return #{
    "output": #{
        "unyt_allocation": unyt_allocation,
        "carryover": state,
        "computed_values": #{
            "coupons": withdraw_result.processed_coupons
        }
    },
    "rejected_links": withdraw_result.rejected_links
};