# Rules when writing an Agreement Code Template and a Smart Agreement based on that Template in Rhai

## Overview

Currently, Smart Agreement Execution Code is written in Rhai, so you need to follow the [Rhai language](https://rhai.rs/) rules

The key to writing Agreement Code Templates and Smart Agreements is understanding the [RaveOutput](https://docs.rs/rave_engine/latest/rave_engine/types/entries/rave/rave_output/struct.RaveOutput.html) struct. This is the structure of output the RAVE-rhai engine is expecting for the code to return.

Read the Rules for the output section to understand how to return the correct output.

## Agreement Code Template

An Agreement Code template is a combination of 3 parts:

1. The Input Schema
2. The Execution Code
3. The Output Schema

### Input Schema

The input schema is a JSON Schema that defines the expected inputs into your code.

For this, you also should think through how you expect to pass the input when the Smart Agreement is Executed.

Here are the ways you can pass the input to the Smart Agreement [Instructions](https://docs.rs/rave_engine/latest/rave_engine/types/executable_agreement/enum.Instruction.html) {TODO: Update Link}

Note: You won't set the particular input sources in the template. Instead, you will have to set these Input Source instructions when creating a Smart Agreement (which will adhere to this Agreement Code Template).

### Execution Code

The code template is the Rhai code that implements the logic of your RAVE. It is the code that, when executed takes the set of inputs, transforms them, and produces a set of outputs.

### Output Schema

- The output schema is a JSON Schema that defines the expected structure of outputs resulting from execution of the Execution Code.
- Look at the [RaveOutput](https://docs.rs/rave_engine/latest/rave_engine/types/rave_output/struct.RaveOutput.html) {TODO: Update Link} struct to understand the expected output.

## Smart Agreement

A Smart Agreement borrows from a specific Agreement Code Template, and adds additional definitions of Execution Rules, Roles and Input rules.

### Execution Rules

- For execution rules we have two options
  - `Any` - this will allow anyone to execute the agreement
    - you would pass `{ "Any": null }`
  - `AuthorizedExecutors` - this will require a list of authorized executors to execute the agreement
    - you would pass `{ "AuthorizedExecutors": ["executor_pubkey_1", "executor_pubkey_2"] }`

### Input Rules

- The Input Rules are a JSON Schema that defines how the Executor will fetch the inputs when executing the Smart Agreement to produce a SAVED.

## Rules for the Output

### when using Smart Agreements to transfer funds

- The code template must have an Output Schema that contains a `unyt_allocation` field, This unyt_allocation will be a json object

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

### Qhen using Smart Agreements to set a credit limit

- The code template must have a Output Schema that contains a `credit_limit` field, This credit_limit will be a json object

  ```json
  {
    "credit_limit": {
      "amount": ["100", "0"],
      "agent": "uhCAk0iWcAxNXcgZ7-URnYkTYOBUrgmwmXdQ7rkAzWsVLJz4bd-pa"
    }
  }
  ```

### When using Smart Agreements to compute values

- for anything else that the Smart Agreement needs to return, the code template must have an output signature that contains a `computed_values` field, This computed_values will be a json object

```json
{
  "computed_values": {
    "value_1": "value_1...",
    "value_2": "value_2..."
  }
}
```
