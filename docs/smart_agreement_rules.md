# Rules when writing Agreement Code Templates and Smart Agreements in Rhai

## Overview

Currently, Smart Agreement Execution Code is written in Rhai, so you need to follow the [Rhai language](https://rhai.rs/) rules

The key to writing Agreement Code Templates and Smart Agreements is understanding the [RAVEOutput](https://docs.rs/rave_engine/latest/rave_engine/types/entries/rave/rave_output/struct.RAVEOutput.html) struct. This is the structure of output the RAVE-rhai engine is expecting for the code to return.

Read the Rules for the output section to understand how to return the correct output.

## Agreement Code Template

An Agreement Code template is a combination of 4 parts:

1. The Agreement Definition Input
2. The Runtime Input Schema
3. The Execution Code
4. The Output Schema

### Agreement Definition Input

The `agreement_definition_input` is a JSON schema that defines the inputs required for creating a smart agreement. UIs can use this to dynamically render forms for creating and configuring agreements. The schema should be a JSON object with a `properties` field.

This struct wraps a JSON schema (`serde_json::Value`) that defines the inputs required for a smart agreement.
It is intended to be used by UIs to dynamically render forms for creating and configuring agreements.
The schema should be a JSON object with a `properties` field.

The standard defines an initial set of properties, but it can be extended by the UI.

### `expected_roles`

An array of objects, where each object defines a role required by the agreement. This is a mandatory property.
Each role object must have:

- `id`: A string identifier for the role.
- `parked_link_type`: A string indicating the type of link parked upon execution for this role.

#### Example:

```json
"expected_roles": {
  "type": "array",
  "items": [
    { "const": { "id": "admin", "parked_link_type": "ParkedSpendCredit" } },
    { "const": { "id": "user", "parked_link_type": { "ParkedData": true } } }
  ]
}
```

### `api_calls` (Optional)

An object that defines external API calls required by the agreement.
This can be used for services like oracles or timestamping servers.
Each key represents an API, and its value is a JSON schema for its input (e.g., a URL).
The UI can use this to prompt the user for URLs or other parameters.

#### Example:

```json
 "api_calls": {
   "type": "object",
   "properties": {
     "timestamp_server": {
       "type": "string",
       "format": "uri",
       "description": "URL of the trusted timestamping service."
     },
     "oracle_service": {
       "type": "string",
       "format": "uri",
       "description": "URL of the data oracle."
     }
   },
   "required": ["timestamp_server"]
 }
```

The UI can be designed to allow users to add more properties to this schema,
so the the UI of creating an agreement can use it to help out users autofilling the inputs or certain fields.

### Runtime Input Schema

The runtime input schema is a JSON Schema that defines the expected inputs into your code.

For this, you also should think through how you expect to pass the input when the Smart Agreement is Executed.

Here are the ways you can pass the input to the Smart Agreement [Instructions](https://docs.rs/rave_engine/latest/rave_engine/types/entries/smart_agreement/rules/enum.Instruction.html)

Note: You won't set the particular input sources in the template. Instead, you will have to set these Input Source instructions when creating a Smart Agreement (which will adhere to this Agreement Code Template).

### Execution Code

The code template is the Rhai code that implements the logic of your RAVE. It is the code that, when executed takes the set of inputs, transforms them, and produces a set of outputs.

### Output Schema

- The output schema is a JSON Schema that defines the expected structure of outputs resulting from execution of the Execution Code.
- Look at the [RAVEOutput](https://docs.rs/rave_engine/latest/rave_engine/types/entries/rave/rave_output/struct.RAVEOutput.html) struct to understand the expected output.

## Smart Agreement

A Smart Agreement borrows from a specific Agreement Code Template, and adds additional definitions of Execution Rules, Roles and Input rules.

### Execution Rules

- For execution rules we have two options
  - `Any` - this will allow anyone to execute the agreement
    - you would pass `{ "Any": null }`
  - `AuthorizedExecutors` - this will require a list of authorized executors to execute the agreement
    - you would pass `{ "AuthorizedExecutors": ["executor_pubkey_1", "executor_pubkey_2"] }`

### Input Rules

- The Input Rules are a JSON Schema that defines how the Executor will fetch the inputs when executing the Smart Agreement to produce a RAVE (Smart Agreement Verifiable Execution Doc).

## Rules for the Output

### when using Smart Agreements to transfer funds

- The code template must have an Output Schema that contains a `unyt_allocation` field, This unyt_allocation will be a json object

  ```json
  {
    "unyt_allocation": [
      {
        "receiver": "receiver_agent_pubkey",
        "amount": ["100", "0"],
        "sources": ["source_hash"]
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
