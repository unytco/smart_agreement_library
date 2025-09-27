# Contributing to Smart Agreement Code Library

Thank you for your interest in contributing to the Smart Agreement Code Library! This document provides guidelines for submitting new SAVEDs.

## How to Contribute

1. Fork the repository
2. Create a new branch for your Smart Agreement
3. Follow the existing Smart Agreement structure (detailed below)
4. Submit a Pull Request

## Smart Agreement Structure

When adding a new Smart Agreement, please follow this directory structure:

```bash
smart_agreement_library/
└── library/
    └── your_saved_name/
        ├── README.md               # Documentation for your Smart Agreement
        ├── execution_code.rhai      # The Smart Agreement code in Rhai format
        ├── runtime_input_signature.json     # JSON schema for input validation
        ├── output_signature.json    # JSON schema for output validation
        └── agreements/              # Folder for agreement examples
            └── example_agreement_rules.json # File for agreement examples
            └── agreement_rules_1.json # Optional a default agreement rules file
            └── agreement_rules_n.json # Optional a default agreement rules file
```

### execution_code.rhai Requirements

Your Rhai code should:

- Begin with comprehensive comments explaining:

  ```rhai
  /// Subject: Brief description of what this Smart Agreement does
  ///
  /// Inputs:
  /// input_param1: Description of first parameter
  /// input_param2: Description of second parameter
  ///
  /// Summary:
  /// Detailed explanation of the Smart Agreement's functionality...
  ```

- Return an object with one or more of these properties: [SAVEDOutput](https://docs.rs/rave_engine/latest/rave_engine/types/saved_output/struct.SAVEDOutput.html)
- Use only the registered helper functions [Helper Functions](https://docs.rs/rave_engine/latest/rave_engine/rhai_engine/rhai_functions/prelude/index.html)
- Include error handling
- Follow Rhai language best practices

### runtime_input_signature.json Requirements

Provide a JSON Schema that defines the expected input structure to your code:

```json
{
  "type": "object",
  "required": ["param1", "param2"],
  "properties": {
    "param1": {
      "type": "string",
      "description": "Description of param1"
    },
    "param2": {
      "type": "array",
      "description": "Description of param2",
      "items": {
        "type": "object"
      }
    }
  }
}
```

### output_signature.json Requirements

Provide a JSON Schema that defines the expected output structure:

```json
{
  "type": "object",
  "properties": {
    "unyt_allocation": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "receiver": { "type": "string" },
          "amount": {
            "type": "array",
            "items": { "type": "string" }
          },
          "sources": { "type": "array" }
        }
      }
    },
    "computed_values": {
      "type": "object",
      "properties": {
        "total_amount": { "type": "number" }
      }
    }
  }
}
```

### Optional Agreement Examples

If your Smart Agreement is designed to work with specific types of agreements, provide example agreement configurations in the `agreement` folder to help users understand how to use your Smart Agreement.

### README.md Requirements

Your README should include:

- Clear description of what the Smart Agreement does
- Input parameters and their types
- Expected output format

## Code Review

Your PR will be reviewed for:

- Correct structure
- Code quality
- Documentation completeness
- Security considerations
- Adherence to the Rhai execution environment constraints

## Questions?

If you have questions about contributing, please open an issue in the repository.

Thank you for helping grow the Smart Agreement Code Library!
