# Rules when writing a RAVE Code Template in Rhai

## Overview

- The current executable code is written in Rhai, so you need to follow the [Rhai language](https://rhai.rs/) rules
- The key to writing a RAVe is understanding the [RaveOutput](https://docs.rs/rave_engine/latest/rave_engine/types/rave_output/struct.RaveOutput.html) struct. this is the structure of output the RAVE-rhai engine is looking for expecting for the code to return. Read the Rules for the output section to understand how to return the correct output.

## RAVE Code Template

A RAVE code template is a combination of 3 parts:

1. The input signature
2. The output signature
3. The code template

### Input Signature

- The input signature is a JSON Schema that defines the expected inputs into your code.
- For this you also should think through how you expect to pass the input when the RAVE is run.
- Here are the ways you can pass the input to the RAVE [Instructions](https://docs.rs/rave_engine/latest/rave_engine/types/executable_agreement/enum.Instruction.html)
  - note: this instructions is what you will have to set in the agreements that are created for each code template

### Output Signature

- The output signature is a JSON Schema that defines the expected output structure from your code.
- Look at the [RaveOutput](https://docs.rs/rave_engine/latest/rave_engine/types/rave_output/struct.RaveOutput.html) struct to understand the expected output.

### Execution Code

The code template is the Rhai code that implements the logic of your RAVE.

## Executable Agreement

An executable agreement is a combination of input rules and execution rules.

### Input Rules

- The input rules are a JSON Schema that defines the how will the executor fetch the inputs when running the RAVE
- Here are the ways you can pass the input to the RAVE [Instructions](https://docs.rs/rave_engine/latest/rave_engine/types/executable_agreement/enum.Instruction.html)

### Execution Rules

- For execution rules we have two options
  - `Any` - this will allow anyone to execute the agreement
    - you would pass `{ "Any": null }`
  - `AuthorizedExecutor` - this will require a list of authorized executors to execute the agreement
    - you would pass `{ "AuthorizedExecutor": "executor_pubkey" }`

## Rules for the output

### when using RAVEs to transfer funds

- The code template must have a output signature that contains `unyt_allocation` field, This unyt_allocation will be a json object

  ```json
  {
    "unyt_allocation": [
      {
        "amount": ["100", "0"],
        "agent": "receiver_agent_pubkey",
        "source": "source_hash"
      }
    ]
  }
  ```

  - This can be used to transfer funds to multiple agents

### when using RAVEs to set a credit limit

- The code template must have a output signature that contains `credit_limit` field, This credit_limit will be a json object

  ```json
  {
    "credit_limit": {
      "amount": ["100", "0"],
      "agent": "uhCAk0iWcAxNXcgZ7-URnYkTYOBUrgmwmXdQ7rkAzWsVLJz4bd-pa"
    }
  }
  ```

### when using RAVEs to compute values

- for anything else that the rave needs to return, the code template must have a output signature that contains `computed_values` field, This computed_values will be a json object

```json
{
  "computed_values": {
    "value_1": "value_1...",
    "value_2": "value_2..."
  }
}
```
