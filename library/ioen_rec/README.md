# Renewable Energy Certificate (REC) by IOEN

Generation and management of Renewable Energy Certificates (RECs) for the IOEN network, designed for solar installations in developing markets like Myanmar.

This is an **example template** — its agreement lives in `agreements/example_agreement_rules_1.json` and is not instantiated by the app. Copy it and fill in real agent keys to run it.

## Participants

### LogHarvester — the `spender` role

The only declared role, parking a `ParkedSpendCredit` link:

- Responsible for collecting and submitting inverter data from solar installations
- Typically an automated system connected to inverters
- Must provide valid site agent key and properly formatted inverter data
- Submits data in a standardized format from CSV exports
- Responsible for initial data validation and formatting

### Executor

Not a role — set by the agreement's `executor_rules`, `AuthorizedExecutor` in the example. Intended to be an agent controlled by IOEN, keeping REC issuance with the network operator rather than the data submitter.

### Receivers

Not a role either — each is read from the `owner_address` in the log data:

- The agent who receives the REC allocation
- Typically the solar installation owner or designated beneficiary
- Identified by their agent key in the logs
- Has rights to transfer or trade the certificates
- Must be properly registered in the system

## Inputs

Two inputs, both `ProvidedBy` the `spender`:

### Logs

This is going to be a hash of the data blob

#### DataBlob format

```json
[
  {
    "source": "GRG - Bottling Plant - 1 Jan 2023 - 30 Nov 2024 - Raw Data",
    "project": "TBV-R1",
    "site": "GRG1-1",
    "owner_address": "uhCA...", // receivers key
    "data": [
      { "date": "2024-12", "value": "0.00" },
      { "date": "2024-11", "value": "91.62" }
    ]
  }
]
```

### Allocation

The spender's parked spend allocations, one per log. Each contributes the `source` the resulting REC allocation draws from.

## Code Execution Flow

1. **Data Collection**
   - System receives logs from solar installations
   - Validates input format and required fields

2. **Processing**
   - Iterates through each log entry
   - Calculates total generation for each time period
   - Validates against allocation sources

3. **Allocation**
   - Creates unyt_allocation entries for each owner
   - Computes total REC amount
   - Associates sources with allocations

4. **Output Generation**
   - Returns structured allocation data
   - Includes computed totals
   - Maintains audit trail through sources

## Output Structure

Execution produces:

### unyt_allocation

Array of objects containing:

- `receiver`: Agent key of the certificate recipient
- `amounts`: Unit map of allocated RECs, keyed by unit index with string amounts, e.g. `{ "0": "91.62" }`
- `sources`: Array of the parked-link hashes the allocation draws from

### computed_values

Object containing:

- `total_rec_amount`: String representing the total RECs generated

## Security Considerations

- Owner addresses must be properly validated
- Data integrity is maintained through source verification
- System prevents double-counting of generation
- Audit trail is maintained for all allocations
