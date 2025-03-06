# Contributing to RAVE Library

Thank you for your interest in contributing to the RAVE Library! This document provides guidelines for submitting new RAVEs.

## How to Contribute

1. Fork the repository
2. Create a new branch for your RAVE
3. Follow the existing RAVE structure (detailed below)
4. Submit a Pull Request

## RAVE Structure

When adding a new RAVE, please follow this directory structure:

```bash
rave_library/
└── library/
    └── your_rave_name/
        ├── README.md               # Documentation for your RAVE
        ├── execution_code.rhai      # The RAVE code in Rhai format
        ├── input_signature.json     # JSON schema for input validation
        ├── output_signature.json    # JSON schema for output validation
        └── agreement/              # Optional folder for agreement examples
            └── [agreement_examples]
```

### execution_code.rhai Requirements

Your Rhai code should:

- Begin with comprehensive comments explaining:

  ```rhai
  /// Subject: Brief description of what this RAVE does
  ///
  /// Inputs:
  /// input_param1: Description of first parameter
  /// input_param2: Description of second parameter
  ///
  /// Summary:
  /// Detailed explanation of the RAVE's functionality...
  ```

- Return an object with one or more of these properties: [RaveOutput](https://docs.rs/rave_engine/latest/rave_engine/types/rave_output/struct.RaveOutput.html)
- Use only the registered helper functions [Helper Functions](https://docs.rs/rave_engine/latest/rave_engine/rhai_engine/rhai_functions/prelude/index.html)
- Include error handling
- Follow Rhai language best practices

### input_signature.json Requirements

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
          "agent": { "type": "string" },
          "amount": {
            "type": "array",
            "items": { "type": "string" }
          },
          "proof": { "type": "string" }
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

If your RAVE is designed to work with specific types of agreements, provide example agreement configurations in the `agreement` folder to help users understand how to use your RAVE.

### README.md Requirements

Your README should include:

- Clear description of what the RAVE does
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

Thank you for helping grow the RAVE Library!
