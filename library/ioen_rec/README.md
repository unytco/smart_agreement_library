# Renewable Energy Certificate (REC) by IOEN

This RAVE implements the generation and management of Renewable Energy Certificates (RECs) for the IOEN network, specifically designed for solar installations in developing markets like Myanmar.

## Roles

### LogHarvester (Spender)

- Responsible for collecting and submitting inverter data from solar installations
- Typically automated system connected to inverters
- Must provide valid site agent key and properly formatted inverter data
- Submits data in a standardized format from CSV exports
- Responsible for initial data validation and formatting

### Executor

- todo: confirm who this agent is going to be?
- Recommendation is going to be an agent controlled by IOEN

### Receiver

- The agent who receives the REC allocation
- Typically the solar installation owner or designated beneficiary
- Identified by their agent key in the logs
- Has rights to transfer or trade the certificates
- Must be properly registered in the system

## Inputs

The RAVE accepts two main input types:

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

Array of objects containing:

- Amount: Array of string values representing energy generation
- Proof: Verification string for the allocation

## Code Execution Flow

1. **Data Collection**

   - System receives logs from solar installations
   - Validates input format and required fields

2. **Processing**

   - Iterates through each log entry
   - Calculates total generation for each time period
   - Validates against allocation proofs

3. **Allocation**

   - Creates unyt_allocation entries for each owner
   - Computes total REC amount
   - Associates proofs with allocations

4. **Output Generation**
   - Returns structured allocation data
   - Includes computed totals
   - Maintains audit trail through proofs

## Output Structure

The RAVE produces:

### unyt_allocation

Array of objects containing:

- receiver: Agent key of the certificate recipient
- amount: Array of string values representing allocated RECs
- proof: Verification string for the allocation

### computed_values

Object containing:

- total_rec_amount: String representing the total RECs generated

## Security Considerations

- Owner addresses must be properly validated
- Data integrity is maintained through proof verification
- System prevents double-counting of generation
- Audit trail is maintained for all allocations
