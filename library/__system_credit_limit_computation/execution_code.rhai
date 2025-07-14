/// Subject: Execution for __system_credit_limit_computation
/// 
/// Inputs:
/// claiming_agent_pubkey: the pubkey of the agent that is claiming the credit limit
/// 
/// Summary:
/// This is a simple example of a credit limit computation
/// 
/// We will return the credit limit for the agent
/// 
/// The credit limit is 10000
return  #{
    "credit_limit":  #{
        "agent": inputs.claiming_agent_pubkey.data,
        "amount": inputs.credit_limit.data
    }
};  