# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `holo_hosting_proof_of_service`: pay EdgeNode Hosts for both Holo services through one agreement instance.
- `holo_hosting_proof_of_service`: price five optional dimensions (storage, gossip, gets, 2 WindTunnel); absent ⇒ 0.
- `holo_hosting_proof_of_service`: fix the gossip/storage unit-index swap so each dimension credits its own index.
- `holo_hosting_proof_of_service`: rename the paying role Happ Provider → EdgeNode Customer.
- `__system_credit_limit_computation_holo_hosting`: narrow the special agent's elevated `special_credit_limit` to the HoloFuel unit only (`{0: 9999999}`), dropping the stale, over-broad second index.
