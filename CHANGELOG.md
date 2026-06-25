# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `holo_hosting_proof_of_service`: one agreement now pays the EdgeNode Hosts for **both** Holo services — EdgeNode and WindTunnel — through a single instance (only the invoice payload differs). It prices five independently-optional dimensions — storage, gossip, the new **gets**, and two reserved WindTunnel placeholders — reading every price-sheet rate and log count defensively (absent ⇒ 0), so partial invoices never break. Fixes the gossip/storage service-unit-index swap (each dimension now credits its own index), and renames the paying role Happ Provider → **EdgeNode Customer**.
- `__system_credit_limit_computation_holo_hosting`: narrow the special agent's elevated `special_credit_limit` to the HoloFuel unit only (`{0: 9999999}`), dropping the stale, over-broad second index.
