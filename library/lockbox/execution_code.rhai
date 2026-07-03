/// Subject: lockbox — a minimal agreement that HOLDS conserved base-unit funds,
/// the proving ground for the locked-funds primitive. It parks funds and locks
/// the unspent remainder, carries the lock to the next execution, spends it
/// down, and unlocks it back to the creator. Base unit "0" only.
///
/// Users:
/// - Locker (spender + executor): parks base-unit credit and runs the agreement.
/// - Payout receiver: paid the requested amount out of the available balance.
///
/// Inputs:
/// - locker_spender_allocations: base-unit credit parked this run (pre-processor).
/// - previous_execution (Custom GetPreviousExecution): { id, output } of the last
///   run — its `output.locked` is the carried balance, its `id` the source a
///   lock-funded allocation names.
/// - unlock (ExecutorProvided bool): return the whole balance to the creator.
/// - payout_amount / payout_receiver (ExecutorProvided): pay this much to this
///   receiver, lock the rest.
///
/// Note: locking newly-parked funds requires a nonzero payout so the parked
/// source is named (the conservation rule counts a parked source only when an
/// allocation references it); a carried lock needs no naming — it is the running
/// balance, inherited from the predecessor unconditionally.

let BASE = "0";

// Carried lock + the previous execution's hash (the lock source next run names).
let carried = 0.0;
let prev_source = ();
if type_of(inputs.previous_execution.data) == "map" {
    prev_source = inputs.previous_execution.data.id;
    let locked = inputs.previous_execution.data.output.locked ?? #{};
    carried = parse_float(locked[BASE] ?? "0");
}

// Newly parked funds this run, with their sources.
let parked = 0.0;
let sources = [];
for alloc in consumed_inputs.locker_spender_allocations {
    parked = parked + parse_float(alloc.data.amount[BASE] ?? "0");
    sources.push(alloc.data.source);
}
if carried > 0.0 {
    sources.push(prev_source);
}

let available = carried + parked;

// Unlock: return the whole balance to the creator (the executor); no new lock.
if type_of(inputs.unlock) == "map" && inputs.unlock.data == true {
    let out = [];
    if available > 0.0 {
        let amt = #{};
        amt[BASE] = available.to_string();
        out.push(#{ "receiver": executor_pub_key, "amounts": amt, "sources": sources });
    }
    return #{ "output": #{ "unyt_allocation": out } };
}

// Otherwise pay the requested amount and lock the rest. Both payout inputs are
// optional (runtime_input_signature.json): an omitted/absent `payout_amount`
// means a pure hold (pay 0). A negative payout is rejected — it would make
// `remaining` exceed what was parked/carried and mint locked funds past the
// first-law check.
let payout = 0.0;
if type_of(inputs.payout_amount) == "map" {
    payout = parse_float(inputs.payout_amount.data ?? "0");
}
if payout < 0.0 {
    throw "lockbox: payout_amount must not be negative";
}
if payout > available {
    throw "lockbox: payout " + payout.to_string() + " exceeds available " + available.to_string();
}

let allocation = [];
if payout > 0.0 {
    if type_of(inputs.payout_receiver) != "map" {
        throw "lockbox: payout_receiver is required for a nonzero payout";
    }
    let amt = #{};
    amt[BASE] = payout.to_string();
    allocation.push(#{
        "receiver": inputs.payout_receiver.data,
        "amounts": amt,
        "sources": sources
    });
} else if parked > 0.0 {
    // Pure hold of freshly-parked funds: name the parked sources with a
    // zero-amount allocation so they count as conserved input — a parked source
    // is an input only when a `unyt_allocation` names it (a carried lock is the
    // running balance inherited from the predecessor and needs no naming).
    let amt = #{};
    amt[BASE] = "0";
    allocation.push(#{
        "receiver": executor_pub_key,
        "amounts": amt,
        "sources": sources
    });
}

let output = #{ "unyt_allocation": allocation };
let remaining = available - payout;
if remaining > 0.0 {
    // A `locked` output requires this instance to use `AuthorizedExecutor`:
    // the DNA rejects `locked` under `ExecutorRules::Any` (lock lineage /
    // anti-replay needs a fixed executor). The shipped default rules declare
    // `Any`, so a locking instance must set the executor at instantiation.
    let locked = #{};
    locked[BASE] = remaining.to_string();
    output.locked = locked;
}
return #{ "output": output };
