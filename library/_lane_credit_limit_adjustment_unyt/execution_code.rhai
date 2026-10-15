/// Subject: Credit limit adjustment
///
/// Executor: the template ships `Any`. The DNA takes a run's credit limit only
/// from the lane's bridging agent or reserver.
///
/// Inputs:
/// inputs.call_method: `bridge` or `reserve`.
/// consumed_inputs.proof_of_deposit: the oracle's proofs, for `bridge`.
/// inputs.commitment: a commitment's action hash, for `reserve`.
/// inputs.previous_execution: this agreement's latest run on the executor's
/// chain, or null before the first. A state carried across a migration has no
/// `id`.
/// inputs.unyt_index: the unit `bridge` adjusts.
/// inputs.reserve_units: `debit_unit_index` and `credit_unit_index`, from the
/// committing agent's side.
/// inputs.reserve_window_seconds: how long after its `committed_at` a
/// commitment can be reserved, for `reserve`.
///
/// Summary:
/// `credit_limit` is a running total: a run keeps every unit of the previous
/// run's and changes one. `bridge` adds each `deposit` proof's amount to
/// `unyt_index` and subtracts each `withdraw` proof's. `reserve` takes one
/// commitment to the executor, dated before the run and inside the window
/// before it, that pays `x` of the debit unit, a conserved one, for `x` of the
/// credit unit, and adds `x` to the credit unit. It reserves a commitment once,
/// by walking back from the previous run to the commitment's time, so it
/// refuses one with more than about 990 runs, of any agreement, after it on
/// the executor's chain.

fn equal(a, b) {
    is_greater_than_eq(a, b) && is_greater_than_eq(b, a)
}

fn proofs(consumed) {
    let proofs = [];
    for pod in consumed.proof_of_deposit {
        for proof in pod.data {
            proofs.push(proof);
        }
    }
    proofs
}

fn bridge(credit_limit, unit, consumed, inputs) {
    if "commitment" in inputs {
        throw "bridge takes no commitment";
    }
    let amount = "0";
    if unit in credit_limit {
        amount = credit_limit[unit];
    }
    for proof in proofs(consumed) {
        if proof.method == "deposit" {
            amount = add_fuel(amount, proof.amount);
        } else if proof.method == "withdraw" {
            amount = sub_fuel(amount, proof.amount);
        } else {
            throw "Invalid method: " + proof.method;
        }
    }
    credit_limit[unit] = amount;
    credit_limit
}

fn reserve(credit_limit, units, consumed, inputs, previous, agreement, executor, executed_at) {
    if proofs(consumed).len() > 0 {
        throw "reserve consumes no proof";
    }
    if !("commitment" in inputs) {
        throw "reserve names no commitment";
    }
    let commitment = get_commitment(inputs.commitment.data);
    let id = commitment.id;
    if commitment.counterparty != executor {
        throw "The commitment " + id + " is not to the executor";
    }
    if !is_before(commitment.committed_at, executed_at) {
        throw "The commitment " + id + " is not dated before the run";
    }
    if !("reserve_window_seconds" in inputs) {
        throw "The agreement names no reserve_window_seconds";
    }
    let window_start = seconds_before(executed_at, inputs.reserve_window_seconds.data);
    if !is_before(window_start, commitment.committed_at) {
        throw "The commitment " + id + " is not dated inside the reserve window, after " + window_start;
    }
    let debit = units.debit_unit_index;
    let credit = units.credit_unit_index;
    let amount = commitment.amount;
    if amount.len() != 2 || !(debit in amount) || !(credit in amount) {
        throw "The commitment " + id + " does not name exactly units " + debit + " and " + credit;
    }
    let x = amount[credit];
    if is_greater_than_eq("0", x) || !equal(amount[debit], sub_fuel("0", x)) {
        throw "The commitment " + id + " does not pay an amount of unit " + debit + " for the same amount of unit " + credit;
    }
    if !(debit in commitment.debited) || !equal(commitment.debited[debit], x) {
        throw "The commitment " + id + " does not debit " + x + " of unit " + debit;
    }
    if type_of(previous) == "map" && "id" in previous {
        let cited = find_run_citing(agreement, previous.id, id);
        if cited != () {
            throw "The commitment " + id + " is reserved by run " + cited.id;
        }
    }
    let reserved = "0";
    if credit in credit_limit {
        reserved = credit_limit[credit];
    }
    credit_limit[credit] = add_fuel(reserved, x);
    credit_limit
}

let credit_limit = #{};
let previous = inputs.previous_execution.data;
if type_of(previous) == "map" && type_of(previous.output.credit_limit) == "map" {
    credit_limit = previous.output.credit_limit;
}

let method = inputs.call_method.data;
credit_limit = switch method {
    "bridge" => bridge(credit_limit, inputs.unyt_index.data, consumed_inputs, inputs),
    "reserve" => reserve(
        credit_limit,
        inputs.reserve_units.data,
        consumed_inputs,
        inputs,
        previous,
        ea_id,
        executor_pub_key,
        executed_timestamp
    ),
    _ => {
        throw "Unknown method: " + method;
    }
};

return #{
    "output": #{
        "credit_limit": credit_limit
    }
};
