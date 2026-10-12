/// Subject: Global unit recovery
///
/// Executor: `unyt_cli progenitor global set-recovery` binds it to the
/// network's recovery agent as it publishes the agreement. The template ships
/// `Any`, and the global definition refuses any other executor.
///
/// Inputs:
/// inputs.call_method: the method to run, `stranded_commitment` or
/// `not_an_agent_key`.
/// inputs.evidence: the hashes the method reads, by name. Both read
/// `commitment`, the victim's Commitment. `stranded_commitment` also reads
/// `close`, its counterparty's CloseChain. `not_an_agent_key` also reads
/// `record`, if given, an action whose hash core, or whose public app entry's
/// hash core, is the counterparty's 32 bytes.
/// inputs.previous_execution: this agreement's latest run on the executor's
/// chain, or null before the first.
///
/// Summary:
/// The network's recovery agent raises its own credit limit by units a run
/// proves dead. `stranded_commitment` proves a commitment dead when its
/// counterparty closed their chain without accepting or rejecting it, the close
/// directly after their closing summary. `not_an_agent_key` proves it dead when
/// no private key matches its counterparty: by `record`, or because the
/// counterparty is no point of Ed25519's curve.
/// A run recovers what the commitment debited, not its fee, which the fee
/// collector already took. A commitment is recovered once, by either method.
/// The 1 unit minimum keeps dust out of the recovered set, and the 1024 cap
/// bounds what each run carries. `credit_limit` is the running total,
/// `carryover.recovered` the recovered hashes, and `computed_values` the victim
/// and what customer service pays them.

fn evidence_hash(evidence, key) {
    if type_of(evidence) != "map" {
        throw "The evidence is not a map of hashes";
    }
    let hash = evidence[key];
    if type_of(hash) != "string" {
        throw "The evidence names no " + key + " hash";
    }
    hash
}

fn stranded_commitment_evidence(evidence) {
    #{
        "commitment": evidence_hash(evidence, "commitment"),
        "close": evidence_hash(evidence, "close")
    }
}

fn not_an_agent_key_evidence(evidence) {
    let read = #{ "commitment": evidence_hash(evidence, "commitment") };
    if "record" in evidence {
        read.record = evidence_hash(evidence, "record");
    }
    read
}

fn stranded_commitment(commitment, read) {
    let answer = find_accept_or_reject_before_close(commitment.id, read.close);
    if answer != () {
        throw "The commitment " + commitment.id + " was answered: " + answer.kind + " " + answer.id;
    }
    #{ "close": read.close }
}

fn not_an_agent_key(commitment, read) {
    if "record" in read {
        let checked = check_key_is_hash_of_record(commitment.counterparty, read.record);
        return #{ "record": checked.id };
    }
    check_key_is_not_a_public_key(commitment.counterparty);
    #{}
}

let method = inputs.call_method.data;
let read = switch method {
    "stranded_commitment" => stranded_commitment_evidence(inputs.evidence.data),
    "not_an_agent_key" => not_an_agent_key_evidence(inputs.evidence.data),
    _ => {
        throw "Unknown method: " + method;
    }
};

let credit_limit = #{};
let recovered = #{};
let previous = inputs.previous_execution.data;
if type_of(previous) == "map" {
    credit_limit = previous.output.credit_limit;
    recovered = previous.output.carryover.recovered;
}

let commitment = get_commitment(read.commitment);
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

let references = switch method {
    "stranded_commitment" => stranded_commitment(commitment, read),
    "not_an_agent_key" => not_an_agent_key(commitment, read)
};

recovered[commitment.id] = method;
let computed_values = #{
    "method": method,
    "victim": commitment.author,
    "recovered": commitment.debited,
    "counterparty": commitment.counterparty,
    "commitment": commitment.id
};
computed_values += references;
return #{
    "output": #{
        "credit_limit": add_units(credit_limit, commitment.debited),
        "carryover": #{ "recovered": recovered },
        "computed_values": computed_values
    }
};
