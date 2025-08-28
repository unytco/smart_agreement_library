if consumed_inputs.method == "deposit" {

    // check if parse the proof of deposit
    // - chain_id: string // Eth, polygon
    // - tx_hash: 
    // - timestmap/block_id: ?
    // - assest_id: HOT, HOT's contract ID
    // - amount of units:
    // - target_agent_key: string
// Optional: smart contract identifier


// AML check
// tuple signed by the aml provider
// status code

// logic:
// validated asset
// amount in spend link matches the execution request
// not double spend (done but the DNA since we use a consumable link)

// send to target agent
// AML outcome:
// Who is the units getting allocated to?
// if its approved, send to target agent
// else aml_resolution agent

// output:
// allocaiton
// caryover: 
// {
    // external units pre smart contract
//     "blockchain_contract": "balance change"
// }
// consumed_spend_link
// - get the prev_rave_hash from the ea_id carry over data
// - adjust it with the new allocation
// - add that to the output

} else if consumed_inputs.method == "withdraw" {
// tansfer out

// Check cooldown period
// - check the holdings 6 hours ago
// - subtract it with any spends in the last 6 hours
// it should not be greater than the amount that is been trying to be withdraw


// smart contract needs:
// - 2 of 3 sig
// - bridge agent
// - clearing house auditor
// - any from a list of predefine notarys


} else {
    error("Invalid method");
}