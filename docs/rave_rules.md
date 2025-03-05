# Rules when writing a RAVE Code Template in Rhai

[![hackmd-github-sync-badge](https://hackmd.io/SkZ7oej0SqqP3NSl4fzQQg/badge)](https://hackmd.io/SkZ7oej0SqqP3NSl4fzQQg)


## Overview

- the current executable code is written in Rhai, so you need to follow the [Rhai language](https://rhai.rs/) rules
- The key to writing a RAVe is understanding the [RaveOutput](todo) struct. this is the structure of output the RAVE-rhai engine is looking for expecting for the code to return. Read the Rules for the output section to understand how to return the correct output.

## RAVE Code Template

A RAVE code template is a combination of 3 parts:

1. The input signature
2. The output signature
3. The code template

### Input Signature

- The input signature is a JSON Schema that defines the expected inputs into your code.
- For this you also should think through how you expect to pass the input when the RAVE is run.
- Here are the ways you can pass the input to the RAVE [Instructions](todo)
  - note: this instructions is what you will have to set in the agreements that are created for each code template

### Output Signature

- The output signature is a JSON Schema that defines the expected output structure from your code.
- Look at the [RaveOutput](todo) struct to understand the expected output.

### Execution Code

The code template is the Rhai code that implements the logic of your RAVE.

#### RaveOutput struct

Look at the Rave output ([link](todo))

```rust
pub struct RaveOutput {
    // This is an optional field that is used to specify the UNYT that would authorized to transfer to the receiver
    pub unyt_allocation: Option<UnytAllocation>,
    // This is an optional field that is used to specify the credit limit that is authorized for the receiver
    pub credit_limit: Option<CreditLimit>,
    // This is an optional field that is used to specify the computed values that need to be returned by the code template
    pub computed_values: Option<Value>,
}

pub type UnytAllocation = Vec<UnytType>;

pub struct UnytType {
    pub agent: AgentPubKeyB64,
    pub amount: Pieces,
    pub proof: ActionHashB64,
}

pub type Pieces = Vec<ZFuel>;

```

## Executable Agreement

An executable agreement is a combination of input rules and execution rules.

### Input Rules

- The input rules are a JSON Schema that defines the how will the executor fetch the inputs when running the RAVE
- Here are the ways you can pass the input to the RAVE [Instructions](todo)

### Execution Rules

- For evecution rules we have to options
  - `Any` - this will allow anyone to execute the agreement
    - you would pass `{ "Any": null }`
  - `AuthorizedExecutors` - this will require a list of authorized executors to execute the agreement
    - you would pass `{ "AuthorizedExecutors": ["executor_pubkey_1", "executor_pubkey_2"] }`

## Rules for the output

### when using RAVEs to transfer funds

- The code template much have a output signature that contains `unyt_allocation` field, This unyt_allocation will be a json object

  ```json
  {
    "unyt_allocation": [
      {
        "amount": ["100", "0"],
        "agent": "receiver_agent_pubkey",
        "proof": "proof_hash"
      }
    ]
  }
  ```

  - This can be used to transfer funds to multiple agents

### when using RAVEs to set a credit limit

- The code template much have a output signature that contains `credit_limit` field, This credit_limit will be a json object

  ```json
  {
    "credit_limit": {
      "amount": ["100", "0"],
      "agent": "uhCAk0iWcAxNXcgZ7-URnYkTYOBUrgmwmXdQ7rkAzWsVLJz4bd-pa"
    }
  }
  ```

### when using RAVEs to compute values

- for anything else that the rave needs to return, the code template much have a output signature that contains `computed_values` field, This computed_values will be a json object

```json
{
  "computed_values": {
    "value_1": "value_1...",
    "value_2": "value_2..."
  }
}
```
