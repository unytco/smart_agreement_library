/// Subject: Dynamic Credit Limit Computation Based on Agent Spend Count
/// 
/// Inputs:
/// claiming_agent_pubkey: the pubkey of the agent that is claiming the credit limit
/// agent_spend_records: array of spend records for the agent
/// 
/// Summary:
/// This SAVED computes a dynamic credit limit based on an agent's spending history.
/// The formula is: credit_limit = (spend_count + 1) × 10
/// 
/// For each agent, we:
/// 1. Count all their historical spends
/// 2. Apply the formula to calculate their credit limit
/// 3. Return the computed credit limit

// Count all spends from the claiming agent
let spend_count = 0;

// Iterate through all agent spends to count spends for this specific agent
for spend in agent_spend_records {
    if (verify_valid_spend_records(spend)) {
        spend_count = spend_count + 1;
    }
}

for spend in agent_spend_links {
    if (verify_valid_spend_records(spend)) {
        spend_count = spend_count + 1;
    }
}

// Calculate dynamic credit limit using the formula: (spend_count + 1) × 10
let credit_limit = (spend_count + 1) * 10;

// Return the computed credit limit for the agent
return #{
    "credit_limit": #{
        "agent": claiming_agent_pubkey,
        "amount": credit_limit.to_string(),
    },
    "computed_values": #{
        "spend_count": spend_count,
        "formula": "( spend_count + 1 ) × 10"
    }
};