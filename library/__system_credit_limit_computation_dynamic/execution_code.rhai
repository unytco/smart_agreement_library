/// Subject: Dynamic Credit Limit Computation Based on Agent Spend Count (optimized inputs)
/// 
/// Inputs:
/// agent_spend_records: array of spend count for the agent
/// 
/// Summary:
/// This RAVE computes a dynamic credit limit based on an agent's spending history.
/// The formula is: credit_limit = (spend_count + 1) × 10
/// 
/// For each agent, we:
/// 1. Count all their historical spends
/// 2. Apply the formula to calculate their credit limit
/// 3. Return the computed credit limit

// Count all spends from the claiming agent
let spend_count = inputs.agent_spend_records.data;

// Calculate dynamic credit limit using the formula: (spend_count + 1) × 10
let credit_limit = (spend_count + 1) * 10;
let service_credit_limit = 1000000000000;

// Return the computed credit limit for the agent
return #{
    "output": #{
        "credit_limit": #{
            "0": credit_limit.to_string(),
            "1": service_credit_limit.to_string(),
            "2": service_credit_limit.to_string(),
            "3": service_credit_limit.to_string(),
            "4": service_credit_limit.to_string(),
            "5": service_credit_limit.to_string(),
            "6": service_credit_limit.to_string(),
            "7": service_credit_limit.to_string(),
            "8": service_credit_limit.to_string(),
            "9": service_credit_limit.to_string(),
            "10": service_credit_limit.to_string(),
            "11": service_credit_limit.to_string(),
            "12": service_credit_limit.to_string(),
            "13": service_credit_limit.to_string(),
            "14": service_credit_limit.to_string(),
            "15": service_credit_limit.to_string(),
            "16": service_credit_limit.to_string(),
            "17": service_credit_limit.to_string(),
            "18": service_credit_limit.to_string(),
            "19": service_credit_limit.to_string(),
            "20": service_credit_limit.to_string()
        },
        "computed_values": #{
            "spend_count": spend_count,
            "formula": "( spend_count + 1 ) × 10"
        }
    }
};