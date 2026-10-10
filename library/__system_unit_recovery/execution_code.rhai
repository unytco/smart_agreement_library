/// Subject: Global unit recovery
///
/// Inputs:
/// inputs.call_method: the method to run, only `stranded_commitment`.
/// inputs.evidence: the action hashes the method reads, by name.
/// `stranded_commitment` reads `commitment`, the victim's Commitment, and
/// `close`, its counterparty's CloseChain.
/// inputs.previous_execution: this agreement's latest run on the executor's
/// chain, or null before the first.
///
/// Summary:
/// The network's recovery agent raises its own credit limit by units a run
/// proves dead. `stranded_commitment` proves a commitment dead when its
/// counterparty closed their chain without accepting or rejecting it, the close
/// directly after their closing summary. It recovers what the commitment
/// debited, not its fee, which the fee collector already took. A commitment is
/// recovered once. The 1 unit minimum keeps dust out of the recovered set, and
/// the 1024 cap bounds what each run carries. `credit_limit` is the running
/// total, `carryover.recovered` the recovered hashes, and `computed_values` the
/// victim and what customer service pays them.

fn evidence_hash(evidence, key) {
    let hash = evidence[key];
    if type_of(hash) != "string" {
        throw "The evidence names no " + key + " hash";
    }
    hash
}

let method = inputs.call_method.data;
if method != "stranded_commitment" {
    throw "Unknown method: " + method;
}
let evidence = inputs.evidence.data;
if type_of(evidence) != "map" {
    throw "The evidence is not a map of hashes";
}
let commitment_hash = evidence_hash(evidence, "commitment");
let close = evidence_hash(evidence, "close");

let credit_limit = #{};
let recovered = #{};
let previous = inputs.previous_execution.data;
if type_of(previous) == "map" {
    credit_limit = previous.output.credit_limit;
    recovered = previous.output.carryover.recovered;
}

let commitment = get_commitment(commitment_hash);
if commitment.id in recovered {
    throw "The commitment " + commitment.id + " is already recovered";
}
if recovered.len() >= 1024 {
    throw "The recovered set is full: it holds 1024 commitments";
}
if commitment.debited.len() == 0 {
    throw "The commitment " + commitment.id + " debited nothing";
}
let whole = false;
for unit in commitment.debited.keys() {
    if is_greater_than_eq(commitment.debited[unit], "1") {
        whole = true;
    }
}
if !whole {
    throw "The commitment " + commitment.id + " debited less than 1 whole unit of every unit";
}
let answer = find_answer_before_close(commitment.id, close);
if answer != () {
    throw "The commitment " + commitment.id + " was answered: " + answer.kind + " " + answer.id;
}

recovered[commitment.id] = method;
return #{
    "output": #{
        "credit_limit": add_units(credit_limit, commitment.debited),
        "carryover": #{ "recovered": recovered },
        "computed_values": #{
            "method": method,
            "victim": commitment.author,
            "recovered": commitment.debited,
            "counterparty": commitment.counterparty,
            "commitment": commitment.id,
            "close": close
        }
    }
};
