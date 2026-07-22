# Contributing to Smart Agreement Code Library

Thank you for your interest in contributing to the Smart Agreement Code Library! This document covers the files a Smart Agreement is made of.

Read [Rules when writing a Smart Agreement](./docs/smart_agreement_rules.md) first — it defines the parts of a template and the output contract the engine enforces.

## How to Contribute

1. Fork the repository
2. Create a new branch for your Smart Agreement
3. Follow the existing Smart Agreement structure (detailed below)
4. Submit a Pull Request

## Smart Agreement Structure

When adding a new Smart Agreement, please follow this directory structure:

```text
smart_agreement_library/
└── library/
    └── your_agreement_name/
        ├── README.md                    # Documentation for your Smart Agreement
        ├── execution_code.rhai          # The Smart Agreement code in Rhai format
        ├── agreement_definition_input.json  # JSON schema the UI renders to create an agreement
        ├── runtime_input_signature.json # JSON schema for input validation
        ├── output_signature.json        # JSON schema for output validation
        ├── other_options.json           # one_time_run, aggregate_execution, tags, permissions
        └── agreements/                  # Folder for agreement examples
            ├── agreement_rules_1.json   # The agreement created with the template
            └── example_agreement_rules.json  # Optional further examples
```

The five files above `agreements/` are required — a missing one fails the whole template. The directory name becomes the template's on-chain title, so keep it plain and descriptive; the `__system_`, `_lane_`, and `_automation_` prefixes are reserved for templates the app loads by name during network setup.

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

- Return a map with an `output` key holding one or more [RAVEOutput](https://docs.rs/rave_engine/latest/rave_engine/types/entries/rave/rave_output/struct.RAVEOutput.html) fields — see [Rules for the Output](./docs/smart_agreement_rules.md#rules-for-the-output)
- Use only the registered [Helper Functions](https://docs.rs/rave_engine/latest/rave_engine/rhai_engine/rhai_functions/prelude/index.html)
- Keep money exact — amounts are strings in a unit map, added and subtracted with the fuel helpers, never a float
- Be deterministic — every validating peer re-runs it and compares
- Include error handling
- Follow Rhai language best practices

### runtime_input_signature.json Requirements

A JSON Schema for the inputs your code expects:

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

A JSON Schema for the output. Amounts are unit maps — an object keyed by unit index with string amounts — not arrays or numbers:

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
          "amounts": {
            "type": "object",
            "additionalProperties": { "type": "string" }
          },
          "sources": { "type": "array", "items": { "type": "string" } }
        },
        "required": ["receiver", "amounts", "sources"]
      }
    },
    "computed_values": {
      "type": "object",
      "properties": {
        "total_amount": { "type": "string" }
      }
    }
  },
  "required": ["unyt_allocation"]
}
```

### other_options.json Requirements

How the template runs. `tags` and `permissions` may be omitted, defaulting to empty and `{ "Default": null }`:

```json
{
  "one_time_run": false,
  "aggregate_execution": true,
  "tags": [],
  "permissions": { "Default": null }
}
```

### Agreement Examples

Ship at least one agreement showing how the template is meant to be configured — roles, executor rules, and where each input comes from.

The filename decides its fate. `agreement_rules_*.json` is picked up by the loaders and created as a live agreement during network setup (the lowest-sorting one). Use `example_agreement_rules*.json` for a template that is documentation only and should not be instantiated.

### README.md Requirements

Your README should include:

- Clear description of what the Smart Agreement does
- Input parameters and their types
- Expected output format
- The roles the agreement expects, and who is meant to fill each one

## Code Review

Your PR will be reviewed for:

- Correct structure
- Code quality
- Documentation completeness
- Security considerations
- Adherence to the Rhai execution environment constraints

Changing an existing template's output shape breaks anything already running it — say so in the PR, and expect it to be coordinated with a release.

## Questions?

If you have questions about contributing, please open an issue in the repository.

Thank you for helping grow the Smart Agreement Code Library!
