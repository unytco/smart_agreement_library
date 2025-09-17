/// Subject: Dynamic Credit Limit Computation Based on Agent Spend Count (unoptimized)
/// 
/// The issue with this implementation is that the input is a large size and grows with every
/// call which slows things down
/// 
///
/// Inputs:
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
for spend in inputs.agent_spend_records.data {
    if (verify_valid_spend_records(spend)) {
        spend_count = spend_count + 1;
    }
}

// Calculate dynamic credit limit using the formula: (spend_count + 1) × 10
let credit_limit = (spend_count + 1) * 10;

// Return the computed credit limit for the agent
return #{
    "output": #{
        "credit_limit": #{
            "0": credit_limit.to_string() 
        },
        "computed_values": #{
            "spend_count": spend_count,
            "formula": "( spend_count + 1 ) × 10"
        }
    }
};