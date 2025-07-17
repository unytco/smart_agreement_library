# Rules when writing Agreement Code Templates and Smart Agreements in Rhai

## Overview

Currently, Smart Agreement Execution Code is written in Rhai, so you need to follow the [Rhai language](https://rhai.rs/) rules

The key to writing Agreement Code Templates and Smart Agreements is understanding the [SAVEDOutput](https://docs.rs/saved_engine/latest/saved_engine/types/entries/saved/saved_output/struct.SAVEDOutput.html) struct. This is the structure of output the SAVED-rhai engine is expecting for the code to return.

Read the Rules for the output section to understand how to return the correct output.

## Agreement Code Template

An Agreement Code template is a combination of 4 parts:

1. The Input Schema
2. The Execution Code
3. The Output Schema
4. The Expected Roles

### Input Schema

The input schema is a JSON Schema that defines the expected inputs into your code.

For this, you also should think through how you expect to pass the input when the Smart Agreement is Executed.

Here are the ways you can pass the input to the Smart Agreement [Instructions](https://docs.rs/saved_engine/latest/saved_engine/types/entries/smart_agreement/rules/enum.Instruction.html)

Note: You won't set the particular input sources in the template. Instead, you will have to set these Input Source instructions when creating a Smart Agreement (which will adhere to this Agreement Code Template).

### Execution Code

The code template is the Rhai code that implements the logic of your SAVED. It is the code that, when executed takes the set of inputs, transforms them, and produces a set of outputs.

### Output Schema

- The output schema is a JSON Schema that defines the expected structure of outputs resulting from execution of the Execution Code.
- Look at the [SAVEDOutput](https://docs.rs/saved_engine/latest/saved_engine/types/entries/saved/saved_output/struct.SAVEDOutput.html) struct to understand the expected output.

### Expected Roles

- The expected roles is a JSON file that defines the roles that are expected to be present in the Smart Agreement.
- It is an array of objects, where each object has an `id` and a `consumed_link` field.
- The `id` is a string that will be referenced in the Smart Agreement's `roles` array under the `ct_role_id` field.
- The `consumed_link` is a boolean that indicates whether the link associated with this role should be consumed (deleted) after the SAVED is committed to the chain.

  ```json
  [
    {
      "id": "spender",
      "consumed_link": true
    }
  ]
  ```

## Smart Agreement

A Smart Agreement borrows from a specific Agreement Code Template, and adds additional definitions of Execution Rules, Roles and Input rules.

### Execution Rules

- For execution rules we have two options
  - `Any` - this will allow anyone to execute the agreement
    - you would pass `{ "Any": null }`
  - `AuthorizedExecutors` - this will require a list of authorized executors to execute the agreement
    - you would pass `{ "AuthorizedExecutors": ["executor_pubkey_1", "executor_pubkey_2"] }`

### Input Rules

- The Input Rules are a JSON Schema that defines how the Executor will fetch the inputs when executing the Smart Agreement to produce a SAVED (Smart Agreement Verifiable Execution Doc).

## Rules for the Output

### when using Smart Agreements to transfer funds

- The code template must have an Output Schema that contains a `unyt_allocation` field, This unyt_allocation will be a json object

  ```json
  {
    "unyt_allocation": [
      {
        "receiver": "receiver_agent_pubkey",
        "amount": ["100", "0"],
        "source": "source_hash"
      }
    ]
  }
  ```

  - This can be used to transfer funds to multiple agents

### When using Smart Agreements to set a credit limit

- The code template must have a Output Schema that contains a `credit_limit` field, This credit_limit will be a json object

  ```json
  {
    "credit_limit": {
      "agent": "uhCAk0iWcAxNXcgZ7-URnYkTYOBUrgmwmXdQ7rkAzWsVLJz4bd-pa",
      "amount": "100"
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
