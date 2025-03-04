# Rules when writing a RAVE

Look at the Rave output

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

## when using RAVEs to transfer funds

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

## when using RAVEs to set a credit limit

- The code template much have a output signature that contains `credit_limit` field, This credit_limit will be a json object

  ```json
  {
    "credit_limit": {
      "amount": ["100", "0"],
      "agent": "uhCAk0iWcAxNXcgZ7-URnYkTYOBUrgmwmXdQ7rkAzWsVLJz4bd-pa"
    }
  }
  ```

## when using RAVEs to compute values

- for anything else that the rave needs to return, the code template much have a output signature that contains `computed_values` field, This computed_values will be a json object

```json
{
  "computed_values": {
    "processed_data": "processed_data..."
  }
}
```
